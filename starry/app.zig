//! Manages the engine/app's lifetime and puts the whole engine together
const std = @import("std");
const sapp = @import("sokol").app;
const slog = @import("sokol").log;
const log = @import("log.zig");
const util = @import("util.zig");
const version = @import("root.zig").version;

/// Used for creating a Starry application
pub const Settings = struct {
    /// Used for the window title and stuff
    name: []const u8,
    /// The app version. Amazing.
    version: std.SemanticVersion = .{ .major = 0, .minor = 0, .patch = 1 },

    /// Called after the engine is initialized but just before the main loop
    new: ?*const fn () anyerror!void,
    /// Called before the engine is freed,
    free: ?*const fn () void,
    /// Called every frame. `delta` is the time it took to run the last frame, in seconds.
    update: ?*const fn (delta: f32) void,
    // TODO optional callbacks for input and stuff

    /// You usually want this to be configurable by the end user
    window: WindowSettings = .{},

    /// List of files which log.
    logfiles: ?[]const []const u8 = null,
};

/// You usually want this to be configurable by the end user
pub const WindowSettings = struct {
    /// The preferred size of the window
    size: @Vector(2, i32) = .{ 1280, 720 },
    /// MSAA sample count
    sample_count: i32 = 0,
    /// The preferred swap interval (ignored on some platforms)
    swap_interval: i32 = 0,
    /// Whether the rendering canvas is full resolution on high-DPI displays
    high_dpi: bool = true,
    /// Whether the window should be created in fullscreen mode
    fullscreen: bool = false,
};

/// Runs the engine, and eventually, your app :)
pub fn run(comptime settings: Settings) !void {
    global.settings = settings;
    sapp.run(.{
        .init_cb = sokolErrorWrapper(sokolInit),
        .cleanup_cb = sokolErrorWrapper(sokolCleanup),
        .frame_cb = sokolErrorWrapper(sokolFrame),
        .width = settings.window.size[0],
        .height = settings.window.size[1],
        .sample_count = settings.window.sample_count,
        .high_dpi = settings.window.high_dpi,
        .fullscreen = settings.window.fullscreen,
        .icon = .{ .sokol_default = true },
        .logger = .{
            .func = sokolLog,
        },
    });
}

/// internal state stuff and stuff
const GlobalState = struct {
    settings: Settings,
    /// Used for allocating values that last as long as the engine/program does
    core_alloc: std.heap.GeneralPurposeAllocator(.{}),
};
var global: GlobalState = undefined;

/// sokol doesn't expect the callbacks to return Zig errors, so we handle it here
fn sokolErrorWrapper(comptime func: fn () anyerror!void) fn () callconv(.c) void {
    // struct fuckery to get a lambda
    return struct {
        pub fn wrapper() callconv(.c) void {
            func() catch |err| {
                @panic(@errorName(err));
            };
        }
    }.wrapper;
}

fn sokolInit() !void {
    global.core_alloc = std.heap.GeneralPurposeAllocator(.{}).init;

    try log.__initLogging(global.core_alloc.allocator(), global.settings);
    log.stlog.info("starry v{d}.{d}.{d}{s}{s}", .{
        version.major,
        version.minor,
        version.patch,
        if (version.pre) |pre| "-" ++ pre else "",
        if (version.build) |build| "+" ++ build else "",
    });

    if (global.settings.new) |real_new_fn| {
        try real_new_fn();
    }
}

fn sokolCleanup() !void {
    if (global.settings.free) |real_free_fn| {
        real_free_fn();
    }

    log.stlog.info("deinitialized starry", .{});
    log.__freeLogging();
    _ = global.core_alloc.deinit();
}

fn sokolFrame() !void {
    if (global.settings.update) |real_update_fn| {
        real_update_fn(0); // TODO the real fucking delta time
    }
}

fn sokolLog(
    tag: [*c]const u8,
    log_level: u32,
    log_item_id: u32,
    msg_or_null: [*c]const u8,
    _: u32,
    _: [*c]const u8,
    _: ?*anyopaque,
) callconv(.c) void {
    // slightly evil shit so that you can do at runtime what should be done at compile time
    const sapp_log = struct {
        pub fn log(level: u32, log_id: u32, msg: [*c]const u8) void {
            const scoped = std.log.scoped(.sapp);
            switch (level) {
                0, 1 => {
                    if (msg == null) {
                        scoped.err("id:{d}", .{log_id});
                    } else {
                        scoped.err("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                2 => {
                    if (msg == null) {
                        scoped.warn("id:{d}", .{log_id});
                    } else {
                        scoped.warn("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                else => {
                    if (msg == null) {
                        scoped.info("id:{d}", .{log_id});
                    } else {
                        scoped.info("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
            }
        }
    }.log;

    const saudio_log = struct {
        pub fn log(level: u32, log_id: u32, msg: [*c]const u8) void {
            const scoped = std.log.scoped(.saudio);
            switch (level) {
                0, 1 => {
                    if (msg == null) {
                        scoped.err("id:{d}", .{log_id});
                    } else {
                        scoped.err("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                2 => {
                    if (msg == null) {
                        scoped.warn("id:{d}", .{log_id});
                    } else {
                        scoped.warn("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                else => {
                    if (msg == null) {
                        scoped.info("id:{d}", .{log_id});
                    } else {
                        scoped.info("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
            }
        }
    }.log;

    const sg_log = struct {
        pub fn log(level: u32, log_id: u32, msg: [*c]const u8) void {
            const scoped = std.log.scoped(.sg);
            switch (level) {
                0, 1 => {
                    if (msg == null) {
                        scoped.err("id:{d}", .{log_id});
                    } else {
                        scoped.err("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                2 => {
                    if (msg == null) {
                        scoped.warn("id:{d}", .{log_id});
                    } else {
                        scoped.warn("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                else => {
                    if (msg == null) {
                        scoped.info("id:{d}", .{log_id});
                    } else {
                        scoped.info("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
            }
        }
    }.log;

    const sglue_log = struct {
        pub fn log(level: u32, log_id: u32, msg: [*c]const u8) void {
            const scoped = std.log.scoped(.sglue);
            switch (level) {
                0, 1 => {
                    if (msg == null) {
                        scoped.err("id:{d}", .{log_id});
                    } else {
                        scoped.err("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                2 => {
                    if (msg == null) {
                        scoped.warn("id:{d}", .{log_id});
                    } else {
                        scoped.warn("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                else => {
                    if (msg == null) {
                        scoped.info("id:{d}", .{log_id});
                    } else {
                        scoped.info("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
            }
        }
    }.log;

    const sokol_log = struct {
        pub fn log(level: u32, log_id: u32, msg: [*c]const u8) void {
            const scoped = std.log.scoped(.sokol);
            switch (level) {
                0, 1 => {
                    if (msg == null) {
                        scoped.err("id:{d}", .{log_id});
                    } else {
                        scoped.err("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                2 => {
                    if (msg == null) {
                        scoped.warn("id:{d}", .{log_id});
                    } else {
                        scoped.warn("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
                else => {
                    if (msg == null) {
                        scoped.info("id:{d}", .{log_id});
                    } else {
                        scoped.info("(id:{d}) {s}", .{ log_id, msg });
                    }
                },
            }
        }
    }.log;

    const tagstr = tag[0..util.strnlen(tag, 64)];
    const logfn: *const fn (u32, u32, [*c]const u8) void =
        if (std.mem.eql(u8, tagstr, "sapp"))
            sapp_log
        else if (std.mem.eql(u8, tagstr, "saudio"))
            saudio_log
        else if (std.mem.eql(u8, tagstr, "sg"))
            sg_log
        else if (std.mem.eql(u8, tagstr, "sglue"))
            sglue_log
        else
            sokol_log;

    logfn(log_level, log_item_id, msg_or_null);
}
