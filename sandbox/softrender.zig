//! vulkan and opengl are that bad
//! uses a bunch of threads + insalubrious levels of simd to not be horribly slow
//! also raymarched instead of rasterized
const std = @import("std");
const builtin = @import("builtin");
const zglm = @import("zglm");
const sunshine = @import("sunshine");

/// placeholder world data, should be eventually replaced with the real starry.world api
const World = struct {
    pub noinline fn invertedViewProjectionMatrix() zglm.Mat4x4f {
        // 32 bit is faster but inverse() shits all over the precision
        // TODO consider unfucking inverse()
        const mat64 = zglm.inverse(zglm.perspectived(.{
            .aspect_ratio = @as(f64, image_width) / @as(f64, image_height),
            .fovy_rad = zglm.radians(45),
            .z_near = 0.0001,
            .z_far = 5000,
        }));
        const mat32 = zglm.Mat4x4f.init(
            @floatCast(mat64.raw[0]),
            @floatCast(mat64.raw[1]),
            @floatCast(mat64.raw[2]),
            @floatCast(mat64.raw[3]),
        );
        return mat32;
    }

    pub noinline fn cameraPosition() zglm.Vec3f {
        return .{ 0, 0, 1 };
    }

    pub noinline fn viewport() zglm.Vec4f {
        return .{ 0, 0, image_width, image_height };
    }
};

/// not uniforms and not for real shaders. this is just where i keep the stuff that only has to be
/// calculated once per frame instead of once per pixel
const ShaderUniforms = struct {
    inv_vp_mat: zglm.Mat4x4f,
    viewport: zglm.Vec4f,
    cam_pos: zglm.Vec3f,
};

/// one thread per pixel is stupid, one thread per a few pixels is less
const tile_size = 16;

const image_width = 1366;
const image_height = 768;
const image_size = @Vector(2, u32){ image_width, image_height };

/// the image size won't always be divisible by the tile size,
/// however having a consistent tile size is important for simd stuff,
/// and branching in the middle of rendering to check for bounds is slow
/// so just make the buffer a little bigger and ignore that extra part later :)
fn realImageSize() @Vector(2, u32) {
    if (zglm.any(image_size % @as(@Vector(2, u32), @splat(tile_size)) !=
        @as(@Vector(2, u32), @splat(0))))
    {
        return image_size + @as(@Vector(2, u32), @splat(tile_size * 2));
    }
    return image_size;
}

var backbuffer: [realImageSize()[0]][realImageSize()[1]]@Vector(4, u8) =
    std.mem.zeroes([realImageSize()[0]][realImageSize()[1]]@Vector(4, u8));

const Ray = struct {
    origin: zglm.Vec3f,
    dir: zglm.Vec3f,
};

// TODO this is slow
// so like, don't
// unless the compiler can optimize it away
// idk if it does
// probably not
fn rgbafToRgba8(src: @Vector(4, f32)) @Vector(4, u8) {
    return @intFromFloat(src * @as(@Vector(4, f32), @splat(255)));
}

// TODO it's Late as of writing so there may be overdraw

fn colorTile(pos: @Vector(2, u32), params: ShaderUniforms) void {
    @setFloatMode(.optimized);

    // has to be inline to be vectorized
    // also eliminates branches probably
    // could probably put more vector stuff but i can't be bothered rn
    inline for (0..tile_size) |y| inline for (0..tile_size) |x| {
        const pixel = pos + @Vector(2, u32){ x, y };

        const window_near = zglm.Vec3f{ @floatFromInt(pixel[0]), @floatFromInt(pixel[1]), 0 };
        const window_far = zglm.Vec3f{ @floatFromInt(pixel[0]), @floatFromInt(pixel[1]), 1 };

        const world_near = zglm.unprojectf(.{
            .pos = window_near,
            .inv_mat = params.inv_vp_mat,
            .viewport_pos = .{ params.viewport[0], params.viewport[1] },
            .viewport_size = .{ params.viewport[2], params.viewport[3] },
        });
        const world_far = zglm.unprojectf(.{
            .pos = window_far,
            .inv_mat = params.inv_vp_mat,
            .viewport_pos = .{ params.viewport[0], params.viewport[1] },
            .viewport_size = .{ params.viewport[2], params.viewport[3] },
        });

        const ray = Ray{
            .origin = params.cam_pos,
            .dir = world_far - world_near,
        };

        const mhmjjdhnijsoh = zglm.Vec4f{ ray.dir[0], ray.dir[1], ray.dir[2], 1 };
        backbuffer[pixel[0]][pixel[1]] = rgbafToRgba8(
            zglm.clamp(mhmjjdhnijsoh, @as(zglm.Vec4f, @splat(0)), @as(zglm.Vec4f, @splat(0))),
        );
    };
}

pub fn render() !void {
    var scratch = sunshine.ScratchAllocator.init();
    defer scratch.deinit();
    const alloc = scratch.allocator();

    const shader_params = ShaderUniforms{
        .inv_vp_mat = World.invertedViewProjectionMatrix(),
        .viewport = World.viewport(),
        .cam_pos = World.cameraPosition(),
    };

    // fancy threading shitfuckery
    // TODO this is completely different in v0.16 because of course it is
    var thread_pool: std.Thread.Pool = undefined;
    try thread_pool.init(.{
        .allocator = alloc,
        // rendering is expensive!
        // max number of os threads != number of cpu cores so this is probably fine
        // note this has to be balanced with the tile size to work properly
        .n_jobs = (std.Thread.getCpuCount() catch 1) * 2,
    });
    defer thread_pool.deinit();
    std.log.debug("using {d}* threads", .{thread_pool.getIdCount()});

    const render_start = std.time.microTimestamp();
    var wg: std.Thread.WaitGroup = .{};

    var x: u32 = 0;
    var y: u32 = 0;
    while (y < image_height) : (y += tile_size) {
        x = 0;
        while (x < image_width) : (x += tile_size) {
            thread_pool.spawnWg(&wg, colorTile, .{ @Vector(2, u32){ x, y }, shader_params });
        }
    }

    wg.wait();
    const render_end = std.time.microTimestamp();
    std.log.debug("rendering took {d} µs ({d} FPS)", .{
        render_end - render_start,
        1 / (@as(f32, @floatFromInt(render_end - render_start)) / 1000 / 1000),
    });

    const save_image_start = std.time.microTimestamp();
    try backbufferToPpm();
    const save_image_end = std.time.microTimestamp();
    std.log.debug("saving image took {d} µs", .{save_image_end - save_image_start});
}

pub fn backbufferToPpm() !void {
    const file = try std.fs.cwd().createFile("out.ppm", .{ .read = true });
    defer file.close();

    var buffer: [32 * 1024]u8 = undefined;
    var file_writer = file.writer(&buffer);
    const writer = &file_writer.interface;

    // ppm header
    try writer.writeAll("P6\n");
    try writer.print("{d} {d}\n", .{ image_width, image_height });
    try writer.writeAll("255\n");

    var pixels: [image_width * image_height * 3]u8 = undefined;
    for (0..image_height) |y| {
        for (0..image_width) |x| {
            const c = backbuffer[x][y];
            const idx = (y * image_width + x) * 3;
            pixels[idx] = c[0];
            pixels[idx + 1] = c[1];
            pixels[idx + 2] = c[2];
        }
    }
    try writer.writeAll(&pixels);
    try writer.flush();
}
