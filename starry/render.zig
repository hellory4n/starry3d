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
            zglm.vec3f(0, 0, 0),
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

    pub fn color(ray: Ray) zglm.Vec3f {
        // balls<3
        if (ray.hitSphere(zglm.vec3f(0, 0, 1), 0.5)) {
            return zglm.vec3f(1, 0, 0);
        }

        // sky thingy
        const unit_dir = ray.dir.normalize();
        const a = 0.5 * (unit_dir.y() + 1);
        return zglm.Vec3f.one().muls(1 - a).add(zglm.vec3f(0.5, 0.7, 1.0).muls(a));
    }

    pub fn hitSphere(ray: Ray, center: zglm.Vec3f, radius: f32) bool {
        const oc = center.sub(ray.origin);
        const a = ray.dir.dot(ray.dir);
        const b = -2.0 * ray.dir.dot(oc);
        const c = oc.dot(oc) - radius * radius;
        const discriminant = b * b - 4 * a * c;
        return discriminant >= 0;
    }
};

/// simulates what the final shader would look like
fn pixel(
    texcoord: zglm.Vec2f,
    resolution: zglm.Vec2f,
    camera_pos: zglm.Vec3f,
) zglm.Vec4f {
    // fuckery
    // TODO most of this could be calculated once on the cpu, instead of once per pixel
    // might be better for performance?
    const aspect_ratio = resolution.width() / resolution.height();

    const image_width: i32 = @intFromFloat(resolution.width());
    const image_height: i32 = @max(@as(i32, @intFromFloat(resolution.width() / aspect_ratio)), 1);

    // camera
    const focal_length: f32 = 1;
    const viewport_height: f32 = 2.0;
    const viewport_width = viewport_height *
        (@as(f32, @floatFromInt(image_width)) / @as(f32, @floatFromInt(image_height)));

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    // vectors across the horizontal and down the vertical viewport edges
    const viewport_u = zglm.vec3f(viewport_width, 0, 0);
    // TODO unnegate this in glsl
    const viewport_v = zglm.vec3f(0, -viewport_height, 0);

    // horizontal and vertical delta vectors from pixel to pixel
    const pixel_delta_u = viewport_u.divs(@floatFromInt(image_width));
    const pixel_delta_v = viewport_v.divs(@floatFromInt(image_height));
    std.debug.assert(pixel_delta_u.approxEq(zglm.vec3f(0.0055555555555555558, 0, 0)));
    std.debug.assert(pixel_delta_v.approxEq(zglm.vec3f(0, --0.0055555555555555558, 0)));

    // location of the upper left pixel
    const viewport_upper_left = camera_pos
        .sub(zglm.vec3f(0, 0, focal_length))
        .sub(viewport_u.divs(2)).sub(viewport_v.divs(2));
    const pixel00_loc = viewport_upper_left.add(
        pixel_delta_u.add(pixel_delta_v).muls(0.5),
    );

    // this actually has to be calculated once per pixel
    const frag_coord = texcoord.mul(resolution);
    const pixel_center = pixel00_loc
        .add(pixel_delta_u.muls(frag_coord.x())).add(pixel_delta_v.muls(frag_coord.y()));
    // not normalizing the direction is faster
    const ray_direction = pixel_center.sub(camera_pos);

    // actually raytrace stuff
    const ray = Ray{
        .origin = camera_pos,
        .dir = ray_direction,
    };

    return zglm.swizzle(ray.color(), .rgb1);
}
