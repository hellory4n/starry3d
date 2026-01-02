//! OpenGL 4 implementation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr.
//! Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE aka QuejaPalronicador
//! aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka QuejaGontificador
const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const c = @cImport({
    @cInclude("glad.h");
});
const gpu = @import("gpu.zig");
const log = @import("log.zig").stlog;

var global: struct {
    in_render_pass: bool = false,
} = .{};

pub fn init() gpu.BackendError!void {
    const version = c.gladLoadGL(@ptrCast(&glfw.getProcAddress));
    if (version == 0) {
        return gpu.BackendError.DeviceUnsupported;
    }

    // ReleaseSafe relies only our own custom validation layers
    // Debug can crash and die all it wants
    if (builtin.mode == .Debug) {
        c.glEnable(c.GL_DEBUG_OUTPUT);
        c.glEnable(c.GL_DEBUG_OUTPUT_SYNCHRONOUS);
        c.glDebugMessageCallback(debugCallback, null);
    }
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
            log.err("from OpenGL id({d}): {s}", .{ id, msg });
            @breakpoint();
        },
        c.GL_DEBUG_SEVERITY_MEDIUM, c.GL_DEBUG_SEVERITY_LOW => {
            log.warn("from OpenGL id({d}): {s}", .{ id, msg });
        },
        else => {
            log.info("from OpenGL id({d}): {s}", .{ id, msg });
        },
    }
}

pub fn deinit() void {
    // nothing yet
}

pub fn queryDevice() gpu.Device {
    // TODO this can be cached
    var device: gpu.Device = undefined;

    var texture_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_RECTANGLE_TEXTURE_SIZE, &texture_size);
    device.max_image_2d_size = @splat(@as(i32, @intCast(texture_size)));

    var workgroup_size: @Vector(3, c.GLint) = undefined;
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 0, &workgroup_size[0]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 1, &workgroup_size[1]);
    c.glGetIntegeri_v(c.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 2, &workgroup_size[2]);
    device.max_compute_workgroup_dispatch = @intCast(workgroup_size);

    // conveniently you can't use more than 2 gb because they decided to use an int for this
    var storage_buffer_size: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BLOCK_SIZE, &storage_buffer_size);
    device.max_storage_buffer_size = @intCast(storage_buffer_size);

    var storage_buffer_bindings: c.GLint = undefined;
    c.glGetIntegerv(c.GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS, &storage_buffer_bindings);
    device.max_storage_buffer_bindings = @intCast(storage_buffer_bindings);

    return device;
}

pub fn startPass(pass: gpu.RenderPass) void {
    global.in_render_pass = true;
    if (pass.action.load_op == .clear) {
        const clear_color = pass.action.clear_color orelse .{ 0, 0, 0, 1 };
        c.glClearColor(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
    }
}

pub fn endPass() void {
    // TODO i don't think you can emulate the store op in opengl
    // so this is a noop here
    global.in_render_pass = false;
}
