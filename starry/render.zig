//! This renderer is called Emerson Victor. Be nice to Emerson Victor.
//!
//! burger
//! 🟧🟩🟥🟫🟧
//! fries
//! 🟨🟨🟨🟨🟥

const std = @import("std");
const log = std.log.scoped(.starry);
const zglm = @import("zglm");
const gpu = @import("gpu.zig");
const app = @import("app.zig");
const world = @import("world.zig");
const rtshader = @import("shader/rt.zig");

var global: struct {
    pipeline: gpu.Pipeline = undefined,
} = .{};

pub fn init() !void {
    const vert_shader = try gpu.Shader.init(.{
        .src_glsl = @embedFile("shader/tri.vert"),
        .stage = .vertex,
        .label = "triangle.vert",
    });
    defer vert_shader.deinit();

    const frag_shader = try gpu.Shader.init(.{
        .src_glsl = @embedFile("shader/tri.frag"),
        .stage = .fragment,
        .label = "triangle.frag",
    });
    defer frag_shader.deinit();

    global.pipeline = try gpu.Pipeline.init(.{
        .raster = .{
            .vertex_shader = vert_shader,
            .fragment_shader = frag_shader,
        },
        .label = "triangle pipeline",
    });

    log.info("initialized renderer", .{});
}

pub fn deinit() void {
    global.pipeline.deinit();

    log.info("deinitialized renderer", .{});
}

pub fn draw() void {
    gpu.setViewport(.{ .size = app.framebufferSize() });

    gpu.startRenderPass(.{
        .frame = .{
            .load_action = .clear,
            .store_action = .ignore,
            .clear_color = .{ 1, 0, 0, 1 },
        },
    });
    gpu.applyPipeline(global.pipeline);

    gpu.endRenderPass();
    gpu.submit();
}

// const RenderState = struct {
//     /// beware of the render pipeline
//     pipeline: sg.Pipeline,
// };
// var global: RenderState = undefined;

// /// Initializes the renderer. You probably shouldn't call this yourself.
// pub fn __init() !void {
//     global.pipeline = sg.makePipeline(.{
//         .shader = sg.makeShader(rtshader.rtShaderDesc(sg.queryBackend())),
//     });

//     log.info("initialized renderer", .{});
// }

// /// Deinitializes the renderer. You probably shouldn't call this yourself.
// pub fn __deinit() void {
//     log.info("deinitialized renderer", .{});
// }

// pub fn __draw() void {
//     sg.applyPipeline(global.pipeline);

//     const fb_sizef = app.framebufferSizef();

//     // we use 64 bit matrices since this is enough transformations to lose precision and fuck everything
//     // however 64 bit floats are horrible on consumer gpus, they're horrible for performance and you
//     // can't send them on a uniform because fuck you, so we have to do this bullshit
//     const mat64 = world.current_camera.projectionMatrix()
//         .mul(world.current_camera.viewMatrix())
//         .inverse();
//     const mat32 = zglm.Mat4x4f.init(
//         @floatCast(mat64.raw[0]),
//         @floatCast(mat64.raw[1]),
//         @floatCast(mat64.raw[2]),
//         @floatCast(mat64.raw[3]),
//     );
//     const mat_final = mat32.toArray1D();
//     // first one mysteriously segfaults
//     // awesome!
//     // const pos: zglm.Vec3f = @floatCast(world.current_camera.position);
//     const pos = zglm.Vec3f{
//         @floatCast(world.current_camera.position[0]),
//         @floatCast(world.current_camera.position[1]),
//         @floatCast(world.current_camera.position[2]),
//     };

//     const uniforms = rtshader.FsUniform{
//         .u_inv_view_proj_mat = mat_final,
//         .u_camera_pos = pos,
//         .u_viewport = .{ 0, 0, fb_sizef[0], fb_sizef[1] },
//     };
//     sg.applyUniforms(rtshader.UB_fs_uniform, sg.asRange(&uniforms));

//     sg.draw(0, 6, 1);
// }
