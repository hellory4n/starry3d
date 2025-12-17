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
pub fn __init() void {
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

    const win_size = app.framebufferSizef();
    var uniforms = rtshader.FsUniform{
        .u_image_width = win_size.x(),
        .u_image_height = win_size.y(),
        .u_aspect_ratio = app.aspectRatio(),
        .u_fovy = world.current_camera.fov,
        .u_camera_position = world.current_camera.position.toArray(),
        .u_camera_rotation = world.current_camera.rotation.toArray(),
    };
    sg.applyUniforms(rtshader.UB_fs_uniform, sg.asRange(&uniforms));

    sg.draw(0, 6, 1);
}
