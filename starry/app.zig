const window = @import("window.zig");
const internal = @import("internal.zig");

/// Used for creating a Starry application
pub const Settings = struct {
    /// Called after the engine is initialized but just before the main loop
    new: ?fn () anyerror!void,
    /// Called before the engine is freed,
    free: ?fn () void, // making this potentially fail is against the zig zen!!!1!11!1
    /// Called every frame. `delta` is the time it took to run the last frame, in seconds.
    update: ?fn (delta: f32) anyerror!void,
    // TODO optional callbacks for input and stuff

    /// You usually want this to be configurable by the end user
    window: window.Settings = .{},
};

pub fn run(comptime name: []const u8, settings: Settings) !void {
    internal.engine.window = try window.Window.open(name, settings.window);
    defer internal.engine.window.close();

    if (settings.new) |real_new_fn| {
        try real_new_fn();
    }
    if (settings.free) |real_free_fn| {
        defer real_free_fn();
    }

    while (!internal.engine.window.isClosing()) {
        internal.engine.window.pollEvents();

        if (settings.update) |real_update_fn| {
            try real_update_fn(0); // TODO the real fucking delta time
        }

        internal.engine.window.swapBuffers();
    }
}
