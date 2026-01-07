//! Desktop OpenGL 4.5 implemenation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo
//! Daquavious II Sr. Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr.
//! OBE aka Joel Pablo aka QuejaPalronicador aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka
//! QuejaGontificador

const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const c = @cImport({
    @cInclude("glad.h");
});
const gpu = @import("gpu.zig");

const valog = std.log.scoped(.gl_debug);

var global: struct {
    // validation layer stuff
    backend_initialized: bool = false,

    device: ?gpu.Device = null,
} = .{};

pub fn init() gpu.BackendError!void {
    const version = c.gladLoadGL(@ptrCast(&glfw.getProcAddress));
    if (version == 0) {
        return gpu.BackendError.DeviceUnsupported;
    }

    // ReleaseSafe relies only on our own custom validation layers
    // Debug can crash and die all it wants
    if (builtin.mode == .Debug) {
        c.glEnable(c.GL_DEBUG_OUTPUT);
        c.glEnable(c.GL_DEBUG_OUTPUT_SYNCHRONOUS);
        c.glDebugMessageCallback(debugCallback, null);
    }

    global.backend_initialized = true;

    // cache the device already so it doesn't have to do more api calls
    _ = queryDevice();
}

fn debugCallback(
    source: c.GLenum,
    @"type": c.GLenum,
    id: c.GLuint,
    severity: c.GLenum,
    length: c.GLsizei,
    msg: [*c]const c.GLchar,
    data: ?*const anyopaque,
) callconv(.c) void {
    _ = data;
    _ = length;
    _ = source;
    _ = @"type";

    switch (severity) {
        c.GL_DEBUG_SEVERITY_HIGH => {
            valog.err("from OpenGL id({d}): {s}", .{ id, msg });
            @trap();
        },
        c.GL_DEBUG_SEVERITY_MEDIUM, c.GL_DEBUG_SEVERITY_LOW => {
            valog.warn("from OpenGL id({d}): {s}", .{ id, msg });
        },
        else => {
            valog.info("from OpenGL id({d}): {s}", .{ id, msg });
        },
    }
}

fn assertBackendInitialized() void {
    if (gpu.validationEnabled() and !global.backend_initialized) {
        valog.err("gpu backend hasn't initialized yet", .{});
        @trap();
    }
}

pub fn deinit() void {
    assertBackendInitialized();
    global.backend_initialized = false;
}

pub fn queryDevice() gpu.Device {
    assertBackendInitialized();
    if (global.device) |device| {
        return device;
    }

    global.device = .{};

    const vendor_cstr = c.glGetString(c.GL_VENDOR);
    const vendor_len = std.mem.indexOfSentinel(u8, 0, vendor_cstr);
    global.device.?.vendor_name = vendor_cstr[0..vendor_len];

    // it's not really that but close enough
    const device_name_cstr = c.glGetString(c.GL_RENDERER);
    const device_name_len = std.mem.indexOfSentinel(u8, 0, device_name_cstr);
    global.device.?.device_name = device_name_cstr[0..device_name_len];

    var texture_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_RECTANGLE_TEXTURE_SIZE, &texture_size);
    global.device.?.max_image_2d_size = @splat(@as(i32, @intCast(texture_size)));

    var workgroup_size: @Vector(3, c.GLint) = undefined;
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 0, &workgroup_size[0]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 1, &workgroup_size[1]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 2, &workgroup_size[2]);
    global.device.?.max_compute_workgroup_dispatch = @intCast(workgroup_size);

    // conveniently you can't use more than 2 gb because they decided to use an int for this
    var storage_buffer_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BLOCK_SIZE, &storage_buffer_size);
    global.device.?.max_storage_buffer_size = @intCast(storage_buffer_size);

    var storage_buffer_bindings: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS, &storage_buffer_bindings);
    global.device.?.max_storage_buffer_bindings = @intCast(storage_buffer_bindings);

    return global.device orelse unreachable;
}
