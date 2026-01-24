//! I love the Graphics Processing Unit

const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;
const c = @cImport({
    @cInclude("starrygpu.h");
});

pub const Error = error{
    Unknown,
    OutOfCpuMemory,
    OutOfGpuMemory,
    IncompatibleGpu,
};

fn check(err_code: c.sgpu_error_t) Error!void {
    return switch (err_code) {
        c.SGPU_ERROR_UNKNOWN => Error.Unknown,
        c.SGPU_ERROR_OUT_OF_CPU_MEMORY => Error.OutOfCpuMemory,
        c.SGPU_ERROR_OUT_OF_GPU_MEMORY => Error.OutOfGpuMemory,
        c.SGPU_ERROR_INCOMPATIBLE_GPU => Error.IncompatibleGpu,
        else => {},
    };
}

pub const Version = extern struct {
    major: u32,
    minor: u32,
    patch: u32,
};

pub const Settings = extern struct {
    app_name: ?[*:0]const u8 = null,
    engine_name: ?[*:0]const u8 = null,
    app_version: Version,
    engine_version: Version,
    validation_enabled: bool = switch (builtin.mode) {
        .Debug, .ReleaseSafe => true,
        else => false,
    },
    backend_validation_enabld: bool = builtin.mode == .Debug,

    /// OpenGL-specific settings
    gl: extern struct {
        /// e.g. glfwGetProcAddress
        load_fn: ?*const fn (proc: [*:0]const u8) callconv(.c) ?*const fn () callconv(.c) void,
    },

    /// optional
    logger: extern struct {
        debug: ?*const fn (msg: [*:0]const u8) callconv(.c) void = defaultLoggerDebug,
        info: ?*const fn (msg: [*:0]const u8) callconv(.c) void = defaultLoggerInfo,
        warn: ?*const fn (msg: [*:0]const u8) callconv(.c) void = defaultLoggerWarn,
        err: ?*const fn (msg: [*:0]const u8) callconv(.c) void = defaultLoggerError,
        trap: ?*const fn () callconv(.c) void = defaultLoggerTrap,
    } = .{},
};

fn defaultLoggerDebug(msg: [*:0]const u8) callconv(.c) void {
    std.log.scoped(.starrygpu).debug("{s}", .{msg});
}

fn defaultLoggerInfo(msg: [*:0]const u8) callconv(.c) void {
    std.log.scoped(.starrygpu).info("{s}", .{msg});
}

fn defaultLoggerWarn(msg: [*:0]const u8) callconv(.c) void {
    std.log.scoped(.starrygpu).warn("{s}", .{msg});
}

fn defaultLoggerError(msg: [*:0]const u8) callconv(.c) void {
    std.log.scoped(.starrygpu).err("{s}", .{msg});
}

fn defaultLoggerTrap() callconv(.c) void {
    @trap();
}

/// Initializes the graphics context
pub fn init(settings: Settings) Error!void {
    try check(c.sgpu_init(@bitCast(settings)));
}

/// Deinitializes the graphics context
pub fn deinit() void {
    c.sgpu_deinit();
}

/// Returns info about the GPU being used
pub fn queryDevice() Device {
    return @bitCast(c.sgpu_query_device());
}

pub fn queryBackend() Backend {
    return @enumFromInt(c.sgpu_query_backend());
}

/// Poor man's command buffer
pub fn submit() void {
    return c.sgpu_submit();
}

/// render my pass<3
pub fn startRenderPass(pass: RenderPass) void {
    c.sgpu_start_render_pass(@bitCast(pass));
}

pub fn endRenderPass() void {
    c.sgpu_end_render_pass();
}

pub fn setViewport(viewport: Viewport) void {
    c.sgpu_set_viewport(@bitCast(viewport));
}

pub fn setScissor(scissor: Scissor) void {
    c.sgpu_set_scissor(@bitCast(scissor));
}

pub fn compileShader(settings: ShaderSettings) Error!Shader {
    var handle: c.sgpu_shader_t = undefined;
    try check(c.sgpu_compile_shader(@bitCast(settings), &handle));
    return @bitCast(handle);
}

pub fn deinitShader(shader: Shader) void {
    c.sgpu_deinit_shader(@bitCast(shader));
}

pub fn compilePipeline(settings: PipelineSettings) Error!Pipeline {
    var handle: c.sgpu_pipeline_t = undefined;
    try check(c.sgpu_compile_pipeline(@bitCast(settings), &handle));
    return @bitCast(handle);
}

pub fn deinitPipeline(pip: Pipeline) void {
    c.sgpu_deinit_pipeline(@bitCast(pip));
}

pub fn applyPipeline(pip: Pipeline) void {
    c.sgpu_apply_pipeline(@bitCast(pip));
}

pub fn setBlend(blend: BlendTest) void {
    c.sgpu_set_blend(@bitCast(blend));
}

/// Base draw command with no indices
pub fn draw(base_elem: u32, count: u32, instances: u32) void {
    c.sgpu_draw(base_elem, count, instances);
}

pub const Device = extern struct {
    vendor_name_cstr: [*:0]const u8,
    device_name_cstr: [*:0]const u8,

    max_image_2d_size: [2]u32,
    /// Applies to a single storage buffer block; in bytes
    max_storage_buffer_size: u64,
    /// How many storage buffers can be bound at the same time, per shader stage
    max_storage_buffer_bindings: u32,
    /// The GPU doesn't have infinite cores unfortunately
    max_compute_workgroup_size: [3]u32,
    /// The GPU doesn't have infinite cores unfortunately
    max_compute_workgroup_threads: u32,

    pub fn vendorName(dev: Device) [:0]const u8 {
        const len = std.mem.indexOfSentinel(u8, 0, dev.vendor_name_cstr);
        return dev.vendor_name_cstr[0..len];
    }

    pub fn name(dev: Device) [:0]const u8 {
        const len = std.mem.indexOfSentinel(u8, 0, dev.device_name_cstr);
        return dev.device_name_cstr[0..len];
    }
};

pub const Backend = enum(c_uint) {
    unsupported = c.SGPU_BACKEND_UNSUPPORTED,
    glcore = c.SGPU_BACKEND_GLCORE,
};

pub const LoadAction = enum(c_uint) {
    /// Keep existing contents
    load = c.SGPU_LOAD_ACTION_LOAD,
    /// All contents reset and set to a constant
    clear = c.SGPU_LOAD_ACTION_CLEAR,
    /// Existing contents are undefined and ignored
    ignore = c.SGPU_LOAD_ACTION_IGNORE,
};

pub const StoreAction = enum(c_uint) {
    /// Rendered contents will be stored in memory and can be read later
    store = c.SGPU_STORE_ACTION_STORE,
    /// Existing contents are undefined and ignored
    ignore = c.SGPU_STORE_ACTION_IGNORE,
};

pub const RenderPass = extern struct {
    frame: extern struct {
        load_action: LoadAction,
        store_action: StoreAction,
        clear_color: extern struct {
            r: f32,
            g: f32,
            b: f32,
            a: f32,
        },
    },
    swapchain: extern struct {
        width: u32,
        height: u32,
        gl: extern struct {
            /// it's probably 0
            framebuffer: u32 = 0,
        } = .{},
    },
};

pub const Viewport = extern struct {
    top_left_x: i32,
    top_left_y: i32,
    width: i32,
    height: i32,
    min_depth: f32,
    max_depth: f32,
};

pub const Scissor = extern struct {
    top_left_x: i32,
    top_left_y: i32,
    width: i32,
    height: i32,
    enabled: bool,
};

pub const ShaderStage = enum(c_uint) {
    vertex = c.SGPU_SHADER_STAGE_VERTEX,
    fragment = c.SGPU_SHADER_STAGE_FRAGMENT,
    compute = c.SGPU_SHADER_STAGE_COMPUTE,
};

pub const ShaderSettings = extern struct {
    label: ?[*:0]const u8 = "a Starry shader",
    src: [*:0]const u8,
    /// doesn't include the null terminator
    src_len: usize,
    entry_point: ?[*:0]const u8 = "main",
    stage: ShaderStage,
};

pub const Shader = extern struct {
    id: u32,
};

pub const PipelineType = enum(c_uint) {
    raster = c.SGPU_PIPELINE_TYPE_RASTER,
    compute = c.SGPU_PIPELINE_TYPE_COMPUTE,
};

pub const Topology = enum(c_uint) {
    /// Vertices 0, 1, and 2 form a triangle. Vertices 3, 4, and 5 form a triangle. And so on.
    triangle_list = c.SGPU_TOPOLOGY_TRIANGLE_LIST,
    /// Every group of 3 adjacent vertices forms a triangle. The face direction of the strip is
    /// determined by the winding of the first triangle. Each successive triangle will have its
    /// effective face order reversed, so the system compensates for that by testing it in the
    /// opposite way. A vertex stream of n length will generate n-2 triangles.
    triangle_strip = c.SGPU_TOPOLOGY_TRIANGLE_STRIP,
    /// The first vertex is always held fixed. From there on, every group of 2 adjacent vertices
    /// form a triangle with the first. So with a vertex stream, you get a list of triangles
    /// like so: (0, 1, 2) (0, 2, 3), (0, 3, 4), etc. A vertex stream of n length will
    /// generate n-2 triangles.
    triangle_fan = c.SGPU_TOPOLOGY_TRIANGLE_FAN,
};

pub const WindingOrder = enum(c_uint) {
    clockwise = c.SGPU_WINDING_ORDER_CLOCKWISE,
    counter_clockwise = c.SGPU_WINDING_ORDER_COUNTER_CLOCKWISE,
};

pub const CullMode = enum(c_uint) {
    none = c.SGPU_CULL_MODE_NONE,
    front_face = c.SGPU_CULL_MODE_FRONT_FACE,
    back_face = c.SGPU_CULL_MODE_BACK_FACE,
    front_and_back_faces = c.SGPU_CULL_MODE_FRONT_AND_BACK_FACES,
};

pub const PipelineSettings = extern struct {
    label: ?[*:0]const u8 = "a Starry pipeline",
    type: PipelineType,
    raster: extern struct {
        vertex_shader: Shader,
        fragment_shader: Shader,
        topology: Topology = .triangle_list,
        front_face: WindingOrder = .counter_clockwise,
        cull: CullMode = .none,
    } = undefined,
    compute: extern struct {
        shader: Shader,
    } = undefined,
};

pub const Pipeline = extern struct {
    id: u32,
};

pub const BlendScaleFactor = enum(c_uint) {
    zero = c.SGPU_BLEND_SCALE_FACTOR_ZERO,
    one = c.SGPU_BLEND_SCALE_FACTOR_ONE,
    src_color = c.SGPU_BLEND_SCALE_FACTOR_SRC_COLOR,
    one_minus_src_color = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_COLOR,
    dst_color = c.SGPU_BLEND_SCALE_FACTOR_DST_COLOR,
    one_minus_dst_color = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_COLOR,
    src_alpha = c.SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA,
    one_minus_src_alpha = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC_ALPHA,
    dst_alpha = c.SGPU_BLEND_SCALE_FACTOR_DST_ALPHA,
    one_minus_dst_alpha = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_DST_ALPHA,
    constant_color = c.SGPU_BLEND_SCALE_FACTOR_CONSTANT_COLOR,
    one_minus_constant_color = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_COLOR,
    constant_alpha = c.SGPU_BLEND_SCALE_FACTOR_CONSTANT_ALPHA,
    one_minus_constant_alpha = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_CONSTANT_ALPHA,
    src_alpha_saturate = c.SGPU_BLEND_SCALE_FACTOR_SRC_ALPHA_SATURATE,
    src1_color = c.SGPU_BLEND_SCALE_FACTOR_SRC1_COLOR,
    one_minus_src1_color = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_COLOR,
    src1_alpha = c.SGPU_BLEND_SCALE_FACTOR_SRC1_ALPHA,
    one_minus_src1_alpha = c.SGPU_BLEND_SCALE_FACTOR_ONE_MINUS_SRC1_ALPHA,
};

pub const BlendTest = extern struct {
    src_factor: BlendScaleFactor,
    dst_factor: BlendScaleFactor,
    constant_color: extern struct {
        r: f32 = 0,
        g: f32 = 0,
        b: f32 = 0,
        a: f32 = 0,
    } = .{},
};
