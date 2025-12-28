//! This renderer is called Emerson Victor. Be nice to Emerson Victor.
const std = @import("std");
const zglm = @import("zglm");
const sg = @import("sokol").gfx;
const app = @import("app.zig");
const log = @import("log.zig").stlog;
const world = @import("world.zig");
const rtshader = @import("rt.glsl");

const RenderState = struct {
    /// beware of the render pipeline
    pipeline: sg.Pipeline,
};
var global: RenderState = undefined;

/// Initializes the renderer. You probably shouldn't call this yourself.
pub fn __init() !void {
    global.pipeline = sg.makePipeline(.{
        .shader = sg.makeShader(rtshader.rtShaderDesc(sg.queryBackend())),
    });

    log.info("initialized renderer", .{});

    // this vexes me
    softwareRenderer() catch |err| @panic(@errorName(err));
    return error{FuckOff}.FuckOff;
}

/// Deinitializes the renderer. You probably shouldn't call this yourself.
pub fn __deinit() void {
    log.info("deinitialized renderer", .{});
}

pub fn __draw() void {
    sg.applyPipeline(global.pipeline);
    sg.draw(0, 6, 1);
}

fn softwareRenderer() !void {
    const framebuffer = try std.fs.cwd().createFile("out.ppm", .{ .read = true });
    defer framebuffer.close();
    var w = framebuffer.writer(&.{});
    const writer = &w.interface;

    const fb_width = 640;
    const fb_height = 360;

    // ppm header
    _ = try writer.write("P6\n");
    try writer.print("{d} {d}\n", .{ fb_width, fb_height });
    _ = try writer.write("255\n");
    _ = try writer.flush();

    // i am writing it
    // this is horribly slow :)

    const start = std.time.milliTimestamp();

    inline for (0..fb_height) |y| for (0..fb_width) |x| {
        const u = @as(f32, @floatFromInt(x)) / (fb_width - 1);
        const v = @as(f32, @floatFromInt(y)) / (fb_height - 1);

        const color = pixel(
            zglm.vec2f(u, v),
            zglm.vec2f(@floatFromInt(fb_width), @floatFromInt(fb_height)),
            zglm.Vec3f.zero(),
        );

        // convert to 8 bit color
        // alpha is ignored fuck you
        const r: u8 = @intFromFloat(color.r() * 255);
        const g: u8 = @intFromFloat(color.g() * 255);
        const b: u8 = @intFromFloat(color.b() * 255);

        _ = try writer.write(&[_]u8{ r, g, b });
    };

    const end = std.time.milliTimestamp();
    std.log.debug("render took {d} ms", .{end - start});
}

// actual rendering stuff

const Ray = struct {
    origin: zglm.Vec3f,
    dir: zglm.Vec3f,

    pub fn at(ray: Ray, t: f32) zglm.Vec3f {
        return ray.origin.add(ray.dir.muls(t));
    }

    pub fn color(_: Ray) zglm.Vec4f {
        return zglm.Vec4f.zero();
    }
};

/// simulates what the final shader would look like
fn pixel(
    texcoord: zglm.Vec2f,
    _: zglm.Vec2f,
    _: zglm.Vec3f,
) zglm.Vec4f {
    // fuckery
    // const aspect_ratio = resolution.width() / resolution.height();

    // const image_width: i32 = @intFromFloat(resolution.width());
    // const image_height: i32 = @max(@as(i32, @intFromFloat(resolution.width() / aspect_ratio)), 1);

    // // camera
    // const focal_length: f32 = 1;
    // const viewport_height: f32 = 2.0;
    // const viewport_width = viewport_height * (@as(f32, @floatFromInt(image_width)) / image_height);

    return zglm.swizzle(texcoord, .xy01);
}
