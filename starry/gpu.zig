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
const handle = @import("sunshine").handle;
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
pub fn submit() void {
    gpubk.cmdSubmit();
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

/// How many pipelines can live at the same time
pub const max_pipelines = 128;

/// BEWARE OF THE GRAPHICS PIPELINE
pub const Pipeline = struct {
    id: handle.Opaque,

    pub fn init(settings: PipelineSettings) Error!Pipeline {
        const cmd_idx = gpubk.cmdQueue(.{
            .compile_pipeline = .{
                .settings = settings,
            },
        });
        gpubk.cmdSubmit();
        return gpubk.getCmdReturn(cmd_idx).compile_pipeline;
    }

    pub fn deinit(pipeline: Pipeline) void {
        _ = gpubk.cmdQueue(.{
            .deinit_pipeline = .{
                .pipeline = pipeline,
            },
        });
        gpubk.cmdSubmit();
    }
};

pub fn applyPipeline(pipeline: Pipeline) void {
    _ = gpubk.cmdQueue(.{
        .apply_pipeline = .{
            .pipeline = pipeline,
        },
    });
}

pub const PipelineSettings = struct {
    raster: ?struct {
        vertex_shader: Shader,
        fragment_shader: Shader,
        topology: Topology = .triangle_list,
        front_face: WindingOrder = .counter_clockwise,
        cull: CullMode = .none,
    } = null,
    compute: ?struct {
        shader: Shader,
    } = null,
    label: []const u8 = "unknown",
};

pub const Topology = enum {
    /// Vertices 0, 1, and 2 form a triangle. Vertices 3, 4, and 5 form a triangle. And so on.
    triangle_list,
    /// Every group of 3 adjacent vertices forms a triangle. The face direction of the strip is
    /// determined by the winding of the first triangle. Each successive triangle will have its
    /// effective face order reversed, so the system compensates for that by testing it in the
    /// opposite way. A vertex stream of n length will generate n-2 triangles.
    triangle_strip,
    /// The first vertex is always held fixed. From there on, every group of 2 adjacent vertices
    /// form a triangle with the first. So with a vertex stream, you get a list of triangles
    /// like so: (0, 1, 2) (0, 2, 3), (0, 3, 4), etc. A vertex stream of n length will
    /// generate n-2 triangles.
    triangle_fan,
};

pub const WindingOrder = enum {
    clockwise,
    counter_clockwise,
};

pub const CullMode = enum {
    front_face,
    back_face,
    front_and_back_faces,
    none,
};

pub const Viewport = struct {
    pos: zglm.Vec2i = .{ 0, 0 },
    size: zglm.Vec2i,
};

pub fn setViewport(v: Viewport) void {
    _ = gpubk.cmdQueue(.{
        .set_viewport = .{
            .viewport = v,
        },
    });
}

pub const Scissor = struct {
    pos: zglm.Vec2i = .{ 0, 0 },
    size: zglm.Vec2i,
};

pub fn setScissor(v: Scissor) void {
    _ = gpubk.cmdQueue(.{
        .set_scissor = .{
            .scissor = v,
        },
    });
}

/// Describes what happens to a framebuffer, depth buffer, or stencil buffers, before a render pass.
pub const LoadAction = enum {
    /// Keep existing contents
    load,
    /// All contents reset and set to a constant
    clear,
    /// Existing contents are undefined and ignored
    ignore,
};

/// Describes what happens to a framebuffer, depth buffer, or stencil buffers, after a render pass.
pub const StoreAction = enum {
    /// Rendered contents will be stored in memory and can be read later
    store,
    /// Existing contents are undefined and ignored
    ignore,
};

/// As the name implies, it is a pass of rendering
pub const RenderPass = union(enum) {
    frame: struct {
        clear_color: ?zglm.Rgbaf = .{ 0, 0, 0, 1 },
        load_action: LoadAction = .clear,
        store_action: StoreAction = .ignore,
    },
};

pub fn startRenderPass(pass: RenderPass) void {
    _ = gpubk.cmdQueue(.{
        .start_render_pass = .{
            .pass = pass,
        },
    });
}

pub fn endRenderPass() void {
    _ = gpubk.cmdQueue(.{
        .end_render_pass = {},
    });
}

pub fn startComputePass() void {
    _ = gpubk.cmdQueue(.{
        .start_compute_pass = {},
    });
}

pub fn endComputePass() void {
    _ = gpubk.cmdQueue(.{
        .end_compute_pass = {},
    });
}

/// no indices
pub fn draw(base_elem: u32, len: u32, instances: u32) void {
    _ = gpubk.cmdQueue(.{
        .draw = .{
            .base_idx = base_elem,
            .len = len,
            .instances = instances,
        },
    });
}
