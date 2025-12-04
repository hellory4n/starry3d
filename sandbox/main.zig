const std = @import("std");
const starry = @import("starry3d");

pub const std_options = starry.util.std_options;

pub fn sandboxNew() !void {
    std.log.info("sandbox", .{});
    std.log.err("error", .{});
    std.log.warn("warning", .{});
    std.log.debug("debug", .{});
}

pub fn sandboxFree() void {
    std.log.info("amxobdnas", .{});
}

pub fn sandboxUpdate(_: f32) !void {}

pub fn main() !void {
    try starry.app.run(.{
        .name = "sandbox",
        .new = sandboxNew,
        .free = sandboxFree,
        .update = sandboxUpdate,
        .logfiles = &[_][]const u8{"log.txt"},
    });
}
