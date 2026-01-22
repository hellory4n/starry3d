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
