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
}

/// Deinitializes the renderer. You probably shouldn't call this yourself.
pub fn __deinit() void {
    log.info("deinitialized renderer", .{});
}

pub fn __draw() void {
    sg.applyPipeline(global.pipeline);

    // const uniforms = rtshader.FsUniform{
    //     .u_inv_view = world.current_camera.viewMatrix().invert().toArray1D(),
    //     .u_inv_centered_view = world.current_camera.centeredViewMatrix().invert().toArray1D(),
    //     .u_inv_projection = world.current_camera.projectionMatrix().invert().toArray1D(),
    //     .u_image_size = app.framebufferSizef().toArray(),
    // };
    // sg.applyUniforms(rtshader.UB_fs_uniform, sg.asRange(&uniforms));

    sg.draw(0, 6, 1);
}
