//! OpenGL 4 implementation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr.
//! Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE aka QuejaPalronicador
//! aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka QuejaGontificador
const std = @import("std");
const glfw = @import("zglfw");
const c = @cImport({
    @cInclude("glad.h");
});
const gpu = @import("gpu.zig");

var global: struct {} = .{};

pub fn init() gpu.BackendError!void {
    const version = c.gladLoadGL(@ptrCast(&glfw.getProcAddress));
    if (version == 0) {
        return gpu.BackendError.DeviceUnsupported;
    }
}

pub fn deinit() void {
    // nothing yet
}

pub fn startPass(pass: gpu.RenderPass) void {
    if (pass.color.load_op == .clear) {
        if (pass.color.clear_color) |clear_color| {
            c.glClear(c.GL_COLOR_BUFFER_BIT);
            c.glClearColor(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);
        }
    }
}

pub fn endPass() void {
    // TODO i don't think you can emulate the store op in opengl
    // so this is a noop here
}
