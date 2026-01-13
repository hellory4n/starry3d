//! Direct3D 11 implemenation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo Daquavious
//! II Sr. Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE aka
//! Joel Pablo aka QuejaPalronicador aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka QuejaGontificador

const std = @import("std");
const app = @import("app.zig");
const gpu = @import("gpu.zig");
const gpubk = @import("gpu_backend.zig");

var ctx: struct {} = .{};

pub fn init(comptime settings: app.Settings) gpu.Error!void {
    _ = settings;
    @panic("TODO");
}

pub fn deinit() void {
    @panic("TODO");
}
