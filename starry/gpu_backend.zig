//! Common crap used by GPU backends that isn't meant to be public
const std = @import("std");
const handle = @import("sunshine").handle;
const zglm = @import("zglm");
const gpu = @import("gpu.zig");

pub const BackendShader = struct {
    settings: gpu.ShaderSettings,
    gl: struct {
        id: c_uint,
    },
};

pub const BackendPipeline = struct {
    settings: gpu.PipelineSettings,
    gl: struct {
        program: c_uint,
    },
};

pub var resources: struct {
    shaders: handle.Table(BackendShader, gpu.max_shaders) = .{},
    pipelines: handle.Table(BackendPipeline, gpu.max_pipelines) = .{},
} = .{};
