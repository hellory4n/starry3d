//! OpenGL 4 implementation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr.
//! Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE aka QuejaPalronicador
//! aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka QuejaGontificador
const std = @import("std");
const glfw = @import("zglfw");
const gl = @import("zgl");
const gpu = @import("gpu.zig");

var global: struct {} = .{};

pub fn init() gpu.BackendError!void {
    const proc: glfw.GlProc = undefined;
    gl.loadExtensions(proc, glGetProcAddress) catch {
        return gpu.BackendError.DeviceUnsupported;
    };
}

pub fn deinit() void {
    // nothing yet
}

fn glGetProcAddress(p: glfw.GlProc, proc: [:0]const u8) ?gl.binding.FunctionPointer {
    _ = p;
    return glfw.getProcAddress(proc);
}

pub fn startPass(pass: gpu.RenderPass) void {
    if (pass.color.load_op == .clear) {
        if (pass.color.clear_color) |clear_color| {
            gl.clearColor(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);
        }
    }
}

pub fn endPass() void {
    // TODO i don't think you can emulate the store op in opengl
    // so this is a noop here
}
