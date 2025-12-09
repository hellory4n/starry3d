//! Manages the engine/app's lifetime and puts the whole engine together
const std = @import("std");
const log = @import("log.zig");
const version = @import("root.zig").version;

/// Used for creating a Starry application
pub const Settings = struct {
    /// Used for the window title and stuff
    name: []const u8,
    /// The app version. Amazing.
    version: std.SemanticVersion = .{ .major = 0, .minor = 0, .patch = 1 },

    /// Called after the engine is initialized but just before the main loop
    new: ?fn () anyerror!void,
    /// Called before the engine is freed,
    free: ?fn () void, // making this potentially fail is against the zig zen!!!1!11!1
    /// Called every frame. `delta` is the time it took to run the last frame, in seconds.
    update: ?fn (delta: f32) anyerror!void,
    // TODO optional callbacks for input and stuff

    /// You usually want this to be configurable by the end user
    // window: window.Settings = .{},

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
    log.stlog.info("starry v{d}.{d}.{d}{s}{s}", .{
        version.major,
        version.minor,
        version.patch,
        if (version.pre) |pre| "-" ++ pre else "",
        if (version.build) |build| "+" ++ build else "",
    });
    defer log.stlog.info("deinitialized starry", .{});

    if (settings.new) |real_new_fn| {
        try real_new_fn();
    }
    defer {
        if (settings.free) |real_free_fn| {
            real_free_fn();
        }
    }

    {
        if (settings.update) |real_update_fn| {
            try real_update_fn(0); // TODO the real fucking delta time
        }
    }
}
