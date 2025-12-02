const std = @import("std");
const starry = @import("starry3d");

pub fn sandboxNew() !void {
    std.debug.print("sandboxma\n", .{});
}

pub fn sandboxFree() void {
    std.debug.print("amxobdnas\n", .{});
}

pub fn sandboxUpdate(_: f32) !void {
    std.debug.print("oughhh\n", .{});
}

pub fn main() !void {
    try starry.app.run(.{
        .name = "sandbox",
        .new = sandboxNew,
        .free = sandboxFree,
        .update = sandboxUpdate,
    });
}
