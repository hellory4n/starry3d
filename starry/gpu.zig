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
const bke_gl4 = @import("gpu_gl4.zig");

/// Unfortunately GPU drivers don't natively support the hit graphics API starry dot gee pee you dot zig.
pub const Backend = enum {
    /// Panics or returns an error if you try to do anything
    invalid,
    /// Desktop OpenGL 4.5
    gl4,
};

/// Returns the backend being currently used
pub fn getBackend() Backend {
    // TODO compile option for headless builds

    // TODO metal or webgpu support?
    if (builtin.os.tag.isDarwin()) {
        return .invalid;
    }
    // TODO vulkan support?
    if (builtin.abi.isAndroid()) {
        return .invalid;
    }

    return switch (builtin.os.tag) {
        .windows, .linux => .gl4,
        .freebsd, .openbsd, .netbsd => .gl4,
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

pub const BackendError = error{
    DeviceUnsupported,
};

/// Initializes the GPU backend. Amazing.
pub fn init() BackendError!void {
    return switch (comptime getBackend()) {
        .gl4 => bke_gl4.init(),
        else => @compileError("unsupported backend"),
    };
}

/// Deinitializes the GPU backend. .gnizamA
pub fn deinit() void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.deinit(),
        else => @compileError("unsupported backend"),
    }
}

/// Describes the limits of a GPU. There can only be one.
pub const Device = struct {
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
        .gl4 => bke_gl4.queryDevice(),
        else => @compileError("unsupported backend"),
    };
}

/// Returns `BackendError.DeviceUnsupported` if the current device doesn't match the minimum
/// requirements in `dev`
pub fn expectDevice(dev: Device) BackendError!void {
    const cur = queryDevice();
    if (zglm.any(dev.max_image_2d_size > cur.max_image_2d_size)) {
        return BackendError.DeviceUnsupported;
    }
    if (dev.max_storage_buffer_size > cur.max_storage_buffer_size) {
        return BackendError.DeviceUnsupported;
    }
    if (dev.max_storage_buffer_bindings > cur.max_storage_buffer_bindings) {
        return BackendError.DeviceUnsupported;
    }
    if (zglm.any(dev.max_compute_workgroup_dispatch > cur.max_compute_workgroup_dispatch)) {
        return BackendError.DeviceUnsupported;
    }
}

/// How many shaders can live at the same time
pub const max_shaders = 32;
/// How many pipelines can live at the same time
pub const max_pipelines = 128;

pub const BackendShader = union {
    gl: struct {
        id: c_uint,
        settings: ShaderSettings,
    },
};

pub const BackendPipeline = union {
    gl: struct {
        shader_program: c_uint,
        settings: PipelineSettings,
    },
};

pub var resources: struct {
    shaders: handle.Table(BackendShader, max_shaders) = .{},
    pipelines: handle.Table(BackendPipeline, max_pipelines) = .{},
} = .{};

pub const ShaderStage = enum { vertex, fragment, compute };

pub const ShaderSettings = struct {
    glsl_src: []const u8,
    stage: ShaderStage,
    label: []const u8 = "shader",
};

pub const ShaderError = handle.Error || error{
    CompilationFailed,
    /// linking park
    LinkingFailed,
};

/// A program that runs on the GPU. Linked at pipeline creation.
pub const Shader = struct {
    id: handle.Opaque,

    /// Compiles a shader. Amazing.
    pub fn init(settings: ShaderSettings) ShaderError!Shader {
        return switch (comptime getBackend()) {
            .gl4 => .{ .id = try bke_gl4.compileShader(settings) },
            else => @compileError("unsupported backend"),
        };
    }

    /// Frees a shader. You can safely call this once it has been linked.
    pub fn deinit(shader: Shader) void {
        return switch (comptime getBackend()) {
            .gl4 => bke_gl4.deinitShader(shader.id),
            else => @compileError("unsupported backend"),
        };
    }
};

/// Describes what happens to a framebuffer, depth buffer, or stencil buffers, before a render pass.
pub const LoadOp = enum {
    /// Keep existing contents
    load,
    /// All contents reset and set to a constant
    clear,
    /// Existing contents are undefined and ignored
    ignore,
};

/// Describes what happens to a framebuffer, depth buffer, or stencil buffers, after a render pass.
pub const StoreOp = enum {
    /// Rendered contents will be stored in memory and can be read later
    store,
    /// Existing contents are undefined and ignored
    ignore,
};

/// As the name implies, it is a pass of rendering (or compute who knows)
pub const RenderPass = struct {
    action: struct {
        clear_color: ?zglm.Rgbaf = .{ 0, 0, 0, 1 },
        load_op: LoadOp = .clear,
        store_op: StoreOp = .ignore,
    } = .{},
};

/// Starts a render pass
pub fn startPass(pass: RenderPass) void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.startPass(pass),
        else => @compileError("unsupported backend"),
    }
}

/// Ends a render pass
pub fn endPass() void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.endPass(),
        else => @compileError("unsupported backend"),
    }
}

/// Projects normalized device coordinates to window coordinates. Not part of the pipeline since you
/// may want to set this every frame.
pub const Viewport = struct {
    pos: zglm.Vec2i = .{ 0, 0 },
    size: zglm.Vec2i,
};

/// Sets the current viewport. Can be called at any time.
pub fn setViewport(viewport: Viewport) void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.setViewport(viewport),
        else => @compileError("unsupported backend"),
    }
}

/// Crops the viewport to some part of the window. Not part of the pipeline since you may want to
/// set this every frame.
pub const Scissor = union(enum) {
    portion: struct {
        pos: zglm.Vec2i,
        size: zglm.Vec2i,
    },
    /// Disables cropping
    window,
};

/// Sets the current scissor. Can be called at any time.
pub fn setScissor(scissor: Scissor) void {
    switch (comptime getBackend()) {
        .gl4 => bke_gl4.setScissor(scissor),
        else => @compileError("unsupported backend"),
    }
}

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

pub const PipelineSettings = union(enum) {
    raster: struct {
        vertex_shader: Shader,
        fragment_shader: Shader,
        front_face: WindingOrder = .counter_clockwise,
        cull: CullMode = .none,
    },
};

/// BEWARE OF THE GRAPHICS PIPELINE
pub const Pipeline = struct {
    id: handle.Opaque,

    pub fn init(settings: PipelineSettings) ShaderError!Pipeline {
        return switch (comptime getBackend()) {
            .gl4 => .{ .id = try bke_gl4.initPipeline(settings) },
            else => @compileError("unsupported backend"),
        };
    }

    pub fn deinit(pipeline: Pipeline) void {
        switch (comptime getBackend()) {
            .gl4 => bke_gl4.deinitPipeline(pipeline.id),
            else => @compileError("unsupported backend"),
        }
    }

    pub fn apply(pipeline: Pipeline) void {
        switch (comptime getBackend()) {
            .gl4 => bke_gl4.applyPipeline(pipeline),
            .invalid => @compileError("unsupported backend"),
        }
    }
};

// pub const AllocationError = error{
//     OutOfMemory,
//     BindSlotOutOfRange,
// };

// pub const BufferType = enum {
//     storage,
// };

// pub const BufferSettings = struct {
//     type: BufferType,
//     bind_slot: u32,
//     size: usize,
// };

// /// A handle to GPU memory
// pub const Buffer = struct {
//     handle: u32,

//     /// Allocates GPU memory at the specified bind slot.
//     pub fn init(settings: BufferSettings) AllocationError!Buffer {
//         _ = settings;
//         return switch (getBackend()) {
//             else => @compileError("unsupported backend"),
//         };
//     }

//     /// Frees the storage buffer.
//     pub fn deinit(buffer: Buffer) void {
//         _ = buffer;
//         switch (getBackend()) {
//             else => @compileError("unsupported backend"),
//         }
//     }
// };
