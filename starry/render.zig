//! This renderer is called Emerson Victor. Be nice to Emerson Victor.
const std = @import("std");
const sg = @import("sokol").gfx;
const log = @import("log.zig").stlog;
const basicShader = @import("basic.glsl").basicShaderDesc;

const RenderState = struct {
    /// beware of the render pipeline
    pipeline: sg.Pipeline,
};
var global: RenderState = undefined;

/// Initializes the renderer. You probably shouldn't call this yourself.
pub fn __init() void {
    global.pipeline = sg.makePipeline(.{
        .shader = sg.makeShader(basicShader(sg.queryBackend())),
    });

    log.info("initialized renderer", .{});
}

/// Deinitializes the renderer. You probably shouldn't call this yourself.
pub fn __deinit() void {
    log.info("deinitialized renderer", .{});
}
