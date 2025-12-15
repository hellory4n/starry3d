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

    var uniforms = rtshader.FsUniform{
        .plane_height = world.current_camera.near * std.math.tan(world.current_camera.fov * 0.5) * 2,
        .near_clip_plane = world.current_camera.near,
        .camera_position = world.current_camera.position.toArray(),

        // shut up compiler
        .plane_width = 0,
        .view_matrix = [1]f32{0} ** 16,
    };
    uniforms.plane_width = uniforms.plane_height * app.aspectRatio();

    const view_matrix = world.current_camera.viewMatrix();
    // TODO consider not
    const view_matrix_ptr: [*]const f32 = @ptrCast((&view_matrix.repr).ptr);
    @memcpy(&uniforms.view_matrix, view_matrix_ptr[0 .. 4 * 4]);
    sg.applyUniforms(rtshader.UB_fs_uniform, sg.asRange(&uniforms));

    sg.draw(0, 6, 1);
}
