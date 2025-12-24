//! This renderer is called Emerson Victor. Be nice to Emerson Victor.
const std = @import("std");
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

fn softwareRenderer() !void {
    const framebuffer = try std.fs.cwd().createFile("out.ppm", .{ .read = true });
    defer framebuffer.close();

    const fb_width = 640;
    const fb_height = 360;

    // ppm header
    var shia_labuffer: [64]u8 = undefined;
    try framebuffer.writeAll("P6\n");
    const crap = try std.fmt.bufPrint(&shia_labuffer, "{d} {d}\n", .{ fb_width, fb_height });
    try framebuffer.writeAll(crap);
    try framebuffer.writeAll("255\n");
    try framebuffer.sync();

    // i am writing it
    // this is horribly slow :)
    inline for (0..fb_width) |_| for (0..fb_height) |_| {
        try framebuffer.writeAll(&[_]u8{255});
        try framebuffer.writeAll(&[_]u8{0});
        try framebuffer.writeAll(&[_]u8{0});
    };
}

pub fn __draw() void {
    sg.applyPipeline(global.pipeline);
    sg.draw(0, 6, 1);
}
