//! Non-vexing postmodern graphics API.
//! Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE (Joel Pablo for short) is key.
//! Joel Pablo name is also QuejaPalronicador
//! QuejaPalronicadorf                 name is also Qurjs fhycmjjjjjjjjjjjjjjjjjç
//! Qurjs fhycmjjjjjjjjjjjjjjjjjç foyr6th name is QuejaGontificador
//!
//! Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr. Jr. OBE is key ( 🇪🇸 Émerez Víctor
//! Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OIB) or QuejaPalronicador or Qurjs
//! fhycmjjjjjjjjjjjjjjjjjç can produce mind boggling effects.
//!
//! There's a logo for some fucking reason. (docs/gpu_api_logo.png, i didn't make it)
//!
//! This crap is NOT feature complete. A lot of important features are missing (most of the
//! rasterizer pipeline for example) just because I don't use them.
const std = @import("std");
const builtin = @import("builtin");
const zglm = @import("zglm");
const handle = @import("handle.zig");
const gpubk = @import("gpu_backend.zig");
const bk_glcore = @import("gpu_glcore.zig");

/// Unfortunately GPU drivers don't natively support the hit graphics API starry dot gee pee you dot zig.
pub const Backend = enum {
    /// Panics or returns an error if you try to do anything
    invalid,
    /// Desktop OpenGL 4.5
    glcore4,
};

/// Returns the backend being currently used
pub fn getBackend() Backend {
    // TODO compile option for headless builds

    // TODO metal or webgpu support?
    if (builtin.os.tag.isDarwin()) {
        return .invalid;
    }
    // TODO vulkan support?
    // opengl es support is possible if you make it ass
    if (builtin.abi.isAndroid()) {
        return .invalid;
    }

    return switch (builtin.os.tag) {
        .windows, .linux => .glcore4,
        .freebsd, .openbsd, .netbsd => .glcore4,
        else => .invalid,
    };
}

/// Returns true if validation layers are enabled. Note that the backend API's own validation layers
/// are enabled on debug mode.
pub fn validationEnabled() bool {
    return switch (builtin.mode) {
        .Debug, .ReleaseSafe => true,
        .ReleaseFast, .ReleaseSmall => false,
    };
}

pub const Error = handle.Error || error{
    DeviceUnsupported,
    OutOfMemory,
    ShaderCompilationFailed,
    PipelineCompilationFailed,
};

/// Initializes the GPU backend. Amazing.
pub fn init() Error!void {
    return switch (comptime getBackend()) {
        .glcore4 => bk_glcore.init(),
        else => @compileError("unsupported backend"),
    };
}

/// Deinitializes the GPU backend. .gnizamA
pub fn deinit() void {
    switch (comptime getBackend()) {
        .glcore4 => bk_glcore.deinit(),
        else => @compileError("unsupported backend"),
    }
}

/// Describes the limits of a GPU. There can only be one.
pub const Device = struct {
    vendor_name: []const u8 = "Big Graphics",
    device_name: []const u8 = "Device McDeviceson",

    // default values are the ones required by all backend APIs
    max_image_2d_size: zglm.Vec2i = .{ 1024, 1024 },
    /// Applies to a single storage buffer block; in bytes
    max_storage_buffer_size: u64 = 16 * 1024 * 1024,
    /// How many storage buffers can be bound at the same time, per shader stage
    max_storage_buffer_bindings: u32 = 8,
    /// The GPU doesn't have infinite cores unfortunately
    max_compute_workgroup_dispatch: zglm.Vec3i = .{ 0, 0, 0 },
};

/// Returns the current GPU being used.
pub fn queryDevice() Device {
    return switch (comptime getBackend()) {
        .glcore4 => bk_glcore.queryDevice(),
        else => @compileError("unsupported backend"),
    };
}

/// Returns `BackendError.DeviceUnsupported` if the current device doesn't match the minimum
/// requirements in `dev`
pub fn expectDevice(dev: Device) Error!void {
    const cur = queryDevice();
    if (zglm.any(dev.max_image_2d_size > cur.max_image_2d_size)) {
        return Error.DeviceUnsupported;
    }
    if (dev.max_storage_buffer_size > cur.max_storage_buffer_size) {
        return Error.DeviceUnsupported;
    }
    if (dev.max_storage_buffer_bindings > cur.max_storage_buffer_bindings) {
        return Error.DeviceUnsupported;
    }
    if (zglm.any(dev.max_compute_workgroup_dispatch > cur.max_compute_workgroup_dispatch)) {
        return Error.DeviceUnsupported;
    }
}

/// Poor man's command buffer
pub fn submit() Error!void {
    return gpubk.cmdSubmit();
}

/// How many shaders can live at the same time
pub const max_shaders = 32;

/// A program on the GPU. Touching.
pub const Shader = struct {
    id: handle.Opaque,

    pub fn init(settings: ShaderSettings) Error!Shader {
        const cmd_idx = gpubk.cmdQueue(.{
            .compile_shader = .{
                .settings = settings,
            },
        });
        gpubk.cmdSubmit();
        return gpubk.getCmdReturn(cmd_idx).compile_shader;
    }

    pub fn deinit(shader: Shader) void {
        _ = gpubk.cmdQueue(.{
            .deinit_shader = .{
                .shader = shader,
            },
        });
        gpubk.cmdSubmit();
    }
};

pub const ShaderSettings = struct {
    src_glsl: []const u8,
    stage: ShaderStage,
    label: []const u8 = "unknown",
};

pub const ShaderStage = enum { vertex, fragment, compute };
