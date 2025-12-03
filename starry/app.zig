//! Manages the engine/app's lifetime and puts the whole engine together
const std = @import("std");
const window = @import("window.zig");
const log = @import("log.zig");

/// Used for creating a Starry application
pub const Settings = struct {
    /// Used for the window title and stuff
    name: []const u8,

    /// Called after the engine is initialized but just before the main loop
    new: ?fn () anyerror!void,
    /// Called before the engine is freed,
    free: ?fn () void, // making this potentially fail is against the zig zen!!!1!11!1
    /// Called every frame. `delta` is the time it took to run the last frame, in seconds.
    update: ?fn (delta: f32) anyerror!void,
    // TODO optional callbacks for input and stuff

    /// You usually want this to be configurable by the end user
    window: window.Settings = .{},

    /// List of files which log.
    logfiles: ?[]const []const u8 = null,
};

/// Runs the engine, and eventually, your app :)
pub fn run(comptime settings: Settings) !void {
    // values that last for as long as the program does
    var core_alloc = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = core_alloc.deinit();

    try log.__initLogging(core_alloc.allocator(), settings);
    defer log.__freeLogging();

    var win = try window.Window.open(settings.name, settings.window);
    defer win.close();

    if (settings.new) |real_new_fn| {
        try real_new_fn();
    }
    defer {
        if (settings.free) |real_free_fn| {
            real_free_fn();
        }
    }

    while (!win.isClosing()) {
        win.pollEvents();

        if (settings.update) |real_update_fn| {
            try real_update_fn(0); // TODO the real fucking delta time
        }

        win.swapBuffers();
    }
}
