//! Extends std.log for handsome functionality
const std = @import("std");
const builtin = @import("builtin");
const ScratchAllocator = @import("ScratchAllocator.zig");

// color constants things
// may or may not work on windows, who knows
const color_reset = "\x1b[0m";
const color_gray = "\x1b[0;90m";
const color_yellow = "\x1b[0;93m";
const color_red = "\x1b[0;91m";

/// Adds a new place where the engine and app can dump their crap into. `path` is relative, unless you
/// make it not relative. You probably should use `app.Settings.logfiles` instead so that it can get
/// all the logs from when the engine starts.
pub fn addLogPath(path: []const u8) !void {
    try global.logfiles.append(global.alloc, try std.fs.cwd().createFile(path, .{ .read = true }));
}

/// See `starry.util.std_options` to see how you're supposed to use this
pub fn logfn(
    comptime message_level: std.log.Level,
    comptime scope: @TypeOf(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    // get formatted string
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const str = std.fmt.allocPrint(scratch.allocator(), format, args) catch |err| {
        std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
        return;
    };

    // "default" is the default for when there's no scope, as the name implies
    const lib = comptime if (!std.mem.eql(u8, @tagName(scope), "default"))
        "(" ++ @tagName(scope) ++ ")"
    else
        "";
    const prefix = switch (message_level) {
        .debug => if (lib.len > 0) lib else "",
        .info => if (lib.len > 0) lib ++ " " else "",
        .warn => "warning" ++ lib ++ ": ",
        .err => "error" ++ lib ++ ": ",
    };

    // TODO i'd like to add the time here but the stdlib can't format time yet so that's unfortunate
    // TODO print stack trace to files on panic

    for (global.logfiles.items) |*file| {
        // one failed log shouldn't bring down the entire engine
        _ = file.write(prefix) catch |err| {
            std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
        };
        _ = file.write(str) catch |err| {
            std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
        };
        _ = file.write("\n") catch |err| {
            std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
        };
        file.sync() catch |err| {
            std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
        };
    }

    // stdout is printed separately for colors
    const stdout = std.fs.File.stdout();
    const color = switch (message_level) {
        .debug => "",
        .info => color_gray,
        .warn => color_yellow,
        .err => color_red,
    };

    _ = stdout.write(color) catch |err| {
        std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
    };
    _ = stdout.write(prefix) catch |err| {
        std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
    };
    _ = stdout.write(str) catch |err| {
        std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
    };
    _ = stdout.write(color_reset) catch |err| {
        std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
    };
    _ = stdout.write("\n") catch |err| {
        std.debug.print("couldn't log with format '{s}': {s}", .{ format, @errorName(err) });
    };
}

var global: struct {
    alloc: std.mem.Allocator = undefined,
    logfiles: std.ArrayList(std.fs.File) = .{},
} = .{};

/// Initializes the logging stuff
pub fn init(
    alloc: std.mem.Allocator,
) void {
    global.alloc = alloc;

    if (builtin.os.tag == .windows) {
        _ = std.fs.File.stdout().getOrEnableAnsiEscapeSupport();
        _ = std.fs.File.stderr().getOrEnableAnsiEscapeSupport();
    }
}

/// Deinitializes the logging stuff
pub fn deinit() void {
    for (global.logfiles.items) |*file| {
        file.close();
    }
    global.logfiles.deinit(global.alloc);
}
