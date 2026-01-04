//! crap
const zglm = @import("zglm");
const gpu = @import("../gpu.zig");

pub const vert = gpu.ShaderSettings{
    .glsl_src = @embedFile("rt.vert"),
    .stage = .vertex,
    .label = "raytracer.vert",
};

pub const frag = gpu.ShaderSettings{
    .glsl_src = @embedFile("rt.frag"),
    .stage = .fragment,
    .label = "raytracer.frag",
    .uniforms = &.{
        .{ .bind_slot = ub_fs_uniforms },
    },
};

pub const ub_fs_uniforms = 0;

pub const FsUniforms = struct {
    inv_view_proj_mat: zglm.Mat4x4f,
    viewport: zglm.Vec4f,
    camera_pos: zglm.Vec4f,
};
