//! crap
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
};
