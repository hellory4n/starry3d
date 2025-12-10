//! Manages the engine/app's lifetime and puts the whole engine together
const std = @import("std");
const builtin = @import("builtin");
const sapp = @import("sokol").app;
const sglue = @import("sokol").glue;
const sg = @import("sokol").gfx;
const slog = @import("sokol").log;
const stime = @import("sokol").time;
const log = @import("log.zig");
const util = @import("util.zig");
const render = @import("render.zig");
const ScratchAllocator = @import("scratch.zig").ScratchAllocator;
const version = @import("root.zig").version;

/// Used for creating a Starry application
pub const Settings = struct {
    /// Used for the window title and stuff
    name: []const u8,
    /// The app version. Amazing.
    version: std.SemanticVersion = .{ .major = 0, .minor = 0, .patch = 1 },

    /// Called after the engine is initialized but just before the main loop
    init: ?*const fn () anyerror!void,
    /// Called before the engine is deinitialized
    deinit: ?*const fn () void,
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
    global.core_alloc = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = global.core_alloc.deinit();

    // sokol itself may use the logging system so it's here
    try log.__init(global.core_alloc.allocator(), global.settings);
    defer log.__free();

    log.stlog.info("starry v{d}.{d}.{d}{s}{s}", .{
        version.major,
        version.minor,
        version.patch,
        if (version.pre) |pre| "-" ++ pre else "",
        if (version.build) |build| "+" ++ build else "",
    });
    defer log.stlog.info("deinitialized starry", .{});

    sapp.run(.{
        .init_cb = sokolErrorWrapper(sokolInit),
        .cleanup_cb = sokolErrorWrapper(sokolCleanup),
        .frame_cb = sokolErrorWrapper(sokolFrame),

        .width = settings.window.size[0],
        .height = settings.window.size[1],
        .sample_count = settings.window.sample_count,
        .high_dpi = settings.window.high_dpi,
        .fullscreen = settings.window.fullscreen,
        .icon = .{ .sokol_default = true }, // TODO set icon and stuff

        .logger = .{
            .func = sokolLog,
        },
        .win32 = .{
            .console_utf8 = true,
        },
    });
}

/// internal state stuff and stuff
const GlobalState = struct {
    settings: Settings,
    /// Used for allocating values that last as long as the engine/program does
    core_alloc: std.heap.GeneralPurposeAllocator(.{}),

    prev_time: f64,
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
    log.stlog.info("created window for {s}", .{@tagName(builtin.os.tag)});

    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = sokolLog },
    });
    log.stlog.info("using {s} graphics backend", .{@tagName(sg.queryBackend())});
    stime.setup();

    if (global.settings.init) |realInitFn| {
        try realInitFn();
    }
}

fn sokolCleanup() !void {
    if (global.settings.deinit) |realDeinitFn| {
        realDeinitFn();
    }

    sg.shutdown();
    log.stlog.info("shutdown graphics backend", .{});
}

fn sokolFrame() !void {
    if (global.settings.update) |realUpdateFn| {
        // f64 -> f32 because most game code uses f32
        realUpdateFn(@floatCast(deltaTime()));
    }

    global.prev_time = secondsSinceStart();
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

/// Keyboard keys. Splendid. Note these values are the same as Sokol which are the same as GLFW.
/// Additional constants using `@""` syntax for fun
pub const Key = enum(u32) {
    invalid = 0,
    space = 32,
    @" " = .space,
    apostrophe = 39, // '
    @"'" = .apostrophe,
    comma = 44, // ,
    @"," = .comma,
    minus = 45, // -
    @"-" = .minus,
    period = 46, // .
    full_stop = .period,
    @"." = .period,
    slash = 47, // /
    @"/" = .slash,
    num_0 = 48,
    num_1 = 49,
    num_2 = 50,
    num_3 = 51,
    num_4 = 52,
    num_5 = 53,
    num_6 = 54,
    num_7 = 55,
    num_8 = 56,
    num_9 = 57,
    @"0" = .num_0,
    @"1" = .num_1,
    @"2" = .num_2,
    @"3" = .num_3,
    @"4" = .num_4,
    @"5" = .num_5,
    @"6" = .num_6,
    @"7" = .num_7,
    @"8" = .num_8,
    @"9" = .num_9,
    semicolon = 59, // ;
    @";" = .semicolon,
    equal = 61, // =
    @"=" = .equal,
    a = 65,
    b = 66,
    c = 67,
    d = 68,
    e = 69,
    f = 70,
    g = 71,
    h = 72,
    i = 73,
    j = 74,
    k = 75,
    l = 76,
    m = 77,
    n = 78,
    o = 79,
    p = 80,
    q = 81,
    r = 82,
    s = 83,
    t = 84,
    u = 85,
    v = 86,
    w = 87,
    x = 88,
    y = 89,
    z = 90,
    left_bracket = 91, // [
    @"[" = .left_bracket,
    backslash = 92, // \
    @"\\" = .backslash,
    right_bracket = 93, // ]
    @"]" = .right_bracket,
    grave_accent = 96, // `
    @"`" = .grave_accent,
    international_1 = 161, // non-US #1
    international_2 = 162, // non-US #2
    escape = 256,
    enter = 257,
    @"return" = .enter,
    tab = 258,
    backspace = 259,
    insert = 260,
    delete = 261,
    right = 262,
    left = 263,
    down = 264,
    up = 265,
    page_up = 266,
    page_down = 267,
    home = 268,
    end = 269,
    caps_lock = 280,
    scroll_lock = 281,
    num_lock = 282,
    print_screen = 283,
    pause = 284,
    f1 = 290,
    f2 = 291,
    f3 = 292,
    f4 = 293,
    f5 = 294,
    f6 = 295,
    f7 = 296,
    f8 = 297,
    f9 = 298,
    f10 = 299,
    f11 = 300,
    f12 = 301,
    f13 = 302,
    f14 = 303,
    f15 = 304,
    f16 = 305,
    f17 = 306,
    f18 = 307,
    f19 = 308,
    f20 = 309,
    f21 = 310,
    f22 = 311,
    f23 = 312,
    f24 = 313,
    f25 = 314,
    kp_0 = 320,
    kp_1 = 321,
    kp_2 = 322,
    kp_3 = 323,
    kp_4 = 324,
    kp_5 = 325,
    kp_6 = 326,
    kp_7 = 327,
    kp_8 = 328,
    kp_9 = 329,
    kp_decimal = 330,
    kp_divide = 331,
    kp_multiply = 332,
    kp_subtract = 333,
    kp_add = 334,
    kp_enter = 335,
    kp_equal = 336,
    left_shift = 340,
    left_ctrl = 341,
    left_alt = 342,
    left_super = 343,
    left_meta = .left_super,
    right_shift = 344,
    right_ctrl = 345,
    right_alt = 346,
    right_super = 347,
    right_meta = .right_super,
    menu = 348,
};

/// The buttons located on your pointing device technological artifice. Values are the same as Sokol
pub const MouseButton = enum(u32) {
    left = 0x1,
    right = 0x1,
    middle = 0x2,
    invalid = 0x100,
};

/// Returns the size of the framebuffer.
fn framebufferSize() @Vector(2, i32) {
    return .{ sapp.width(), sapp.height() };
}

/// Returns the size of the framebuffer but in floats.
fn framebufferSizef() @Vector(2, f32) {
    return .{ sapp.widthf(), sapp.heightf() };
}

/// Returns true if high DPI is enabled and the app is actually running in a high DPI setting
fn isHighDpi() bool {
    return sapp.highDpi();
}

/// Returns the DPI scaling factor (window pixels to framebuffer pixels)
fn dpiScale() f32 {
    return sapp.dpiScale();
}

/// Returns true if the app is running in fullscreen
fn isFullscreen() bool {
    return sapp.isFullscreen();
}

/// Toggles fullscreen mode
fn toggleFullscreen() void {
    return sapp.toggleFullscreen();
}

/// If true, shows the mouse, otherwise, hides the mouse. See also `lockMouse`
fn showOrHideMouse(show: bool) void {
    sapp.showMouse(show);
}

/// If true, locks the mouse inside the window, otherwise unlocks it.
fn lockMouse(lock: bool) void {
    sapp.lockMouse(lock);
}

/// Returns true if the mouse is locked inside the window (this may toggle a few frames later)
fn isMouseLocked() bool {
    return sapp.mouseLocked();
}

/// Asks nicely for the app to close (the app can handle it and not actually quit)
fn requestQuit() void {
    sapp.requestQuit();
}

/// Cancels a pending quit from `requestQuit`
fn cancelQuit() void {
    sapp.cancelQuit();
}

/// Truly quits the application (the app doesn't handle the quit event)
fn forceQuit() void {
    sapp.quit();
}

/// Returns the frame count since the app started
fn frameCount() i32 {
    return sapp.frameCount();
}

/// Returns the time in seconds since the app started
fn secondsSinceStart() f64 {
    return stime.sec(stime.now());
}

/// Returns the time it took to run the last frame
fn deltaTime() f64 {
    return secondsSinceStart() - global.prev_time;
}

/// Returns the average/smoothed FPS the app is running at
fn averageFps() f64 {
    return 1 / sapp.frameDuration();
}

/// Sets the window title to something else duh
fn setWindowTitle(title: []const u8) void {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const title_cstr = util.zigstrToCstr(scratch.allocator(), title) catch unreachable;
    sapp.setWindowTitle(title_cstr[0..title.len]);
}
