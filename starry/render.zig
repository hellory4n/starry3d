//! This file includes:
//! - the actual renderer
//! - the software renderer foundation
//! - opengl interop so that you can see something
//! - some other crap
//! These have to be tightly integrated for the best performance
//!
//! Software rendering can be a pickle, so this is always compiled in ReleaseSafe/ReleaseFast
//! as a separate module. You should import "starry3d_render", instead of the file itself.
//!
//! Why software rendering? I really don't like Vulkan.
const std = @import("std");
const builtin = @import("builtin");
const zglm = @import("zglm");
const glfw = @import("zglfw");
const sunshine = @import("sunshine");
const starry = @import("starry3d");
const c = @cImport({
    @cInclude("glad.h");
});

comptime {
    if (builtin.mode == .Debug) {
        @compileError("'starry3d_render' should be imported instead of 'render.zig'");
    }
}

/// one thread per pixel is stupid, one thread per a few pixels is less
const tile_size = 16;

fn imageSize() @Vector(2, u32) {
    return @intCast(starry.app.framebufferSize());
}

/// the image size won't always be divisible by the tile size,
/// however having a consistent tile size is important for simd stuff,
/// and branching in the middle of rendering to check for bounds is slow
/// so just make the buffer a little bigger and ignore that extra part later :)
fn storedImageSize() @Vector(2, u32) {
    if (zglm.any(imageSize() % @as(@Vector(2, u32), @splat(tile_size)) !=
        @as(@Vector(2, u32), @splat(0))))
    {
        return imageSize() + @as(@Vector(2, u32), @splat(tile_size * 2));
    }
    return imageSize();
}

var ctx: struct {
    scratch: sunshine.ScratchAllocator = undefined,
    qgpu: *QuasiGpu = undefined,
    prev_image_size: @Vector(2, u32) = @splat(0),

    backbuffer: [][4]f16 = undefined,
    frontbuffer: [][4]f16 = undefined,
} = .{};

// std.atomic.Value(T) is annoying
const Tile = packed struct {
    x: i32,
    y: i32,
};

/// custom thread pool/event loop implementation
const QuasiGpu = struct {
    const null_tile = Tile{ .x = -1, .y = -1 };
    threads: []std.Thread,
    /// in pixels, (-1,-1) == no value because this is an extern struct apparently
    pending_tile: std.atomic.Value(Tile),
    rendering: std.atomic.Value(bool),
    tiles_rendered: std.atomic.Value(i32),
    alloc: std.mem.Allocator,

    pub fn init(alloc: std.mem.Allocator) !*QuasiGpu {
        // more than x2 doesn't seem to change much
        const thread_count = (std.Thread.getCpuCount() catch 1) * 2;

        const qgpu = try alloc.create(QuasiGpu);
        qgpu.* = .{
            .threads = try alloc.alloc(std.Thread, thread_count),
            .pending_tile = .init(null_tile),
            .rendering = .init(true),
            .tiles_rendered = .init(0),
            .alloc = alloc,
        };

        // spawning it <3
        for (qgpu.threads) |*thread| {
            thread.* = try .spawn(.{}, waitLoop, .{qgpu});
            thread.detach();
        }

        return qgpu;
    }

    pub fn deinit(qgpu: *QuasiGpu) void {
        qgpu.rendering.store(false, .release); // ends all sub threads
        // horrible way of waiting for threads to die so it doesn't segfault
        // TODO consider not
        std.Thread.sleep(8 * 1000 * 1000);

        qgpu.alloc.free(qgpu.threads);
    }

    fn waitLoop(qgpu: *QuasiGpu) void {
        while (qgpu.rendering.load(.acquire)) {
            const pending_tile = qgpu.pending_tile.load(.acquire);
            if (pending_tile.x != null_tile.x or pending_tile.y != pending_tile.y) {
                shader(.{ @intCast(pending_tile.x), @intCast(pending_tile.y) });
                _ = qgpu.tiles_rendered.fetchAdd(1, .release);
            }
        }
    }

    fn submit(qgpu: *QuasiGpu, pos: @Vector(2, u32)) void {
        while (qgpu.pending_tile.load(.acquire).x == null_tile.x and
            qgpu.pending_tile.load(.acquire).y == null_tile.y and
            qgpu.rendering.load(.acquire))
        {}
        qgpu.pending_tile.store(.{ .x = @intCast(pos[0]), .y = @intCast(pos[1]) }, .release);
    }

    pub fn render(qgpu: *QuasiGpu) void {
        var x: u32 = 0;
        var y: u32 = 0;
        var expected_tile_count: u32 = 0;
        while (y < imageSize()[1]) : (y += tile_size) {
            x = 0;
            expected_tile_count += 1;
            while (x < imageSize()[0]) : (x += tile_size) {
                expected_tile_count += 1;
                qgpu.submit(.{ x, y });
            }
        }

        while (qgpu.tiles_rendered.load(.acquire) != expected_tile_count) {}
        std.mem.swap([][4]f16, &ctx.frontbuffer, &ctx.backbuffer);
    }
};

/// works on tiles instead of pixels, returns a 16x16 tile of rgba colors from 0 to 1.
/// start is at the top left corner.
fn shader(start: @Vector(2, u32)) void {
    @setFloatMode(.optimized);

    // has to be inline to be vectorized
    // also eliminates branches probably
    // could probably put more vector stuff but i can't be bothered rn
    inline for (0..tile_size) |y| inline for (0..tile_size) |x| {
        const pixel = start + @Vector(2, u32){ x, y };
        setPixel(pixel, .{ 1, 0, 0, 1 });
    };
}

fn setPixel(pos: @Vector(2, u32), color: @Vector(4, f16)) void {
    const idx = pos[0] * imageSize()[1] + pos[1];
    ctx.backbuffer[idx] = color;
}

pub const GlError = error{
    LoadFailed,
    ShaderCompilationFailed,
    ShaderLinkingFailed,
};

pub fn init() !void {
    ctx.scratch = sunshine.ScratchAllocator.init();
    const alloc = ctx.scratch.allocator();
    ctx.backbuffer = try alloc.alloc([4]f16, storedImageSize()[0] * storedImageSize()[1]);
    ctx.frontbuffer = try alloc.alloc([4]f16, storedImageSize()[0] * storedImageSize()[1]);
    ctx.qgpu = try .init(alloc);
    ctx.prev_image_size = imageSize();

    const version = c.gladLoadGL(@ptrCast(&glfw.getProcAddress));
    if (version == 0) {
        std.log.scoped(.starry).err("couldn't initialize opengl", .{});
        return GlError.LoadFailed;
    }

    // dummy vao so it stops bitching
    var vao: c.GLuint = undefined;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);

    const vert_shader: c.GLuint = c.glCreateShader(c.GL_VERTEX_SHADER);
    const vert_shader_src: [*:0]const u8 = @embedFile("shader/blit.vert");
    c.glShaderSource(vert_shader, 1, &vert_shader_src, null);
    c.glCompileShader(vert_shader);
    defer c.glDeleteShader(vert_shader);

    var success: c.GLint = undefined;
    c.glGetShaderiv(vert_shader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        var info_log_cstr: [1024:0]u8 = undefined;
        c.glGetShaderInfoLog(vert_shader, info_log_cstr.len, null, &info_log_cstr);
        const info_log = info_log_cstr[0..std.mem.indexOfSentinel(u8, 0, @ptrCast(&info_log_cstr))];

        std.log.err("compiling vertex shader failed: {s}", .{info_log});
        return GlError.ShaderCompilationFailed;
    }

    const frag_shader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    const frag_shader_src: [*:0]const u8 = @embedFile("shader/blit.frag");
    c.glShaderSource(frag_shader, 1, &frag_shader_src, null);
    c.glCompileShader(frag_shader);
    defer c.glDeleteShader(frag_shader);

    c.glGetShaderiv(frag_shader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        var info_log_cstr: [1024:0]u8 = undefined;
        c.glGetShaderInfoLog(frag_shader, info_log_cstr.len, null, &info_log_cstr);
        const info_log = info_log_cstr[0..std.mem.indexOfSentinel(u8, 0, @ptrCast(&info_log_cstr))];

        std.log.err("compiling fragment shader failed: {s}", .{info_log});
        return GlError.ShaderCompilationFailed;
    }

    const shader_program = c.glCreateProgram();
    c.glAttachShader(shader_program, vert_shader);
    c.glAttachShader(shader_program, frag_shader);
    c.glLinkProgram(shader_program);

    c.glGetProgramiv(shader_program, c.GL_LINK_STATUS, &success);
    if (success == 0) {
        var info_log_cstr: [1024:0]u8 = undefined;
        c.glGetProgramInfoLog(shader_program, info_log_cstr.len, null, &info_log_cstr);
        const info_log = info_log_cstr[0..std.mem.indexOfSentinel(u8, 0, @ptrCast(&info_log_cstr))];

        std.log.err("linking shader failed: {s}", .{info_log});
        return GlError.ShaderLinkingFailed;
    }

    c.glUseProgram(shader_program);

    const border_color = [4]f32{ 0, 0, 0, 1 };
    c.glTexParameterfv(c.GL_TEXTURE_2D, c.GL_TEXTURE_BORDER_COLOR, &border_color);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_CLAMP_TO_BORDER);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_CLAMP_TO_BORDER);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);

    var texture: c.GLuint = undefined;
    c.glGenTextures(1, &texture);
    c.glActiveTexture(c.GL_TEXTURE0);
    c.glBindTexture(c.GL_TEXTURE_2D, texture);
}

pub fn deinit() void {
    ctx.scratch.deinit();
}

pub fn render() !void {
    if (zglm.any(ctx.prev_image_size != imageSize())) {
        try remakeSwapchain();
    }
    ctx.prev_image_size = imageSize();

    ctx.qgpu.render();

    c.glClearColor(0, 0, 0, 1);
    c.glClear(c.GL_COLOR_BUFFER_BIT);
    c.glTexImage2D(
        c.GL_TEXTURE_2D,
        0,
        c.GL_RGBA16F,
        @intCast(imageSize()[0]),
        @intCast(imageSize()[1]),
        0,
        c.GL_RGBA,
        c.GL_FLOAT,
        ctx.frontbuffer.ptr,
    );
    c.glDrawArrays(c.GL_TRIANGLES, 0, 6);
}

pub fn remakeSwapchain() !void {
    deinit();
    try init();
}
