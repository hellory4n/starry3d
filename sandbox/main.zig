const std = @import("std");
const starry = @import("starry3d");

pub const std_options = starry.util.std_options;

fn initApp() !void {
    std.log.info("hi", .{});
}

fn deinitApp() void {
    std.log.info("bye", .{});
}

pub fn updateApp(_: f32) void {}

pub fn main() !void {
    try starry.app.run(.{
        .name = "sandbox",
        .init = initApp,
        .deinit = deinitApp,
        .update = updateApp,
        .logfiles = &[_][]const u8{"log.txt"},
    });
}
