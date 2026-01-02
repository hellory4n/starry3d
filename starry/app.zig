//! Manages the engine/app's lifetime and puts the whole engine together
const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const zglm = @import("zglm");
const log = @import("log.zig");
const root = @import("root.zig");
const gpu = @import("gpu.zig");
// const render = @import("render.zig");
const world = @import("world.zig");
const ScratchAllocator = @import("ScratchAllocator.zig");

/// Used for creating a Starry application
pub const Settings = struct {
    /// Used for the window title and stuff
    name: [:0]const u8,
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
    size: zglm.Vec2i = .{ 1280, 720 },
    /// MSAA sample count
    sample_count: ?i32 = null,
    /// Disables VSync so that the renderer can push as many frames as possible, which is useful for
    /// benchmarking and stuff. Only works on desktop.
    debug_frame_rate: bool = builtin.mode == .Debug,
    /// Whether the rendering canvas is full resolution on high-DPI displays
    high_dpi: bool = true,
    /// Whether the window should be resizable (only works on desktop)
    resizable: bool = true,
};

/// internal state stuff and stuff
const GlobalState = struct {
    settings: Settings = undefined,

    /// for allocating values that last as long as the engine/program does
    core_alloc: std.heap.GeneralPurposeAllocator(.{}) = undefined,

    window: *glfw.Window = undefined,
    key_state: [@intFromEnum(Key.last) + 1]InputState =
        .{InputState.not_pressed} ** (@intFromEnum(Key.last) + 1),
    mouse_state: [@intFromEnum(MouseButton.last) + 1]InputState =
        .{InputState.not_pressed} ** (@intFromEnum(MouseButton.last) + 1),
    prev_mouse_pos: zglm.Vec2f = @splat(0),

    prev_time: f64 = 0,
    smooth_dt: f64 = 0,
};
var global: GlobalState = .{};

/// Runs the engine, and eventually, your app :)
pub fn run(comptime settings: Settings) void {
    global.settings = settings;
    global.core_alloc = std.heap.GeneralPurposeAllocator(.{}).init;
    defer _ = global.core_alloc.deinit();

    log.__init(global.core_alloc.allocator(), global.settings);
    defer log.__free();

    // the rest of the engine has to be wrapped so that errors are logged properly
    starryMain() catch |err| {
        log.stlog.err("fatal error: {s}", .{@errorName(err)});
        return;
    };
}

fn starryMain() !void {
    // TODO clean this up
    log.stlog.info("starry v{d}.{d}.{d}{s}{s}", .{
        root.version.major,
        root.version.minor,
        root.version.patch,
        if (root.version.pre) |pre| "-" ++ pre else "",
        if (root.version.build) |build| "+" ++ build else "",
    });
    defer log.stlog.info("deinitialized starry", .{});

    // glfw is more mature than sokol_app
    // and stuff
    // TODO use sokol_app on platforms other than desktop
    try glfw.init();
    log.stlog.info("initialized GLFW", .{});
    defer {
        glfw.terminate();
        log.stlog.info("deinitialized GLFW", .{});
    }

    glfw.windowHint(.client_api, .opengl_api);
    glfw.windowHint(.opengl_forward_compat, true);
    glfw.windowHint(.opengl_profile, .opengl_core_profile);
    glfw.windowHint(.context_version_major, 4);
    glfw.windowHint(.context_version_minor, 3);

    glfw.windowHint(.doublebuffer, true);
    glfw.windowHint(.resizable, global.settings.window.resizable);
    glfw.windowHint(.samples, if (global.settings.window.sample_count) |samples| samples else 0);
    // TODO idk if high dpi works lmao
    glfw.windowHint(.scale_to_monitor, !global.settings.window.high_dpi);
    glfw.windowHint(.scale_framebuffer, !global.settings.window.high_dpi);

    glfw.windowHintString(.x11_class_name, global.settings.name);
    glfw.windowHintString(.wayland_app_id, global.settings.name);

    global.window = try glfw.Window.create(
        @intCast(global.settings.window.size[0]),
        @intCast(global.settings.window.size[1]),
        global.settings.name,
        null,
    );
    log.stlog.info("created window for {s} on {s}", .{
        @tagName(glfw.getPlatform()),
        @tagName(builtin.os.tag),
    });
    defer {
        global.window.destroy();
        log.stlog.info("destroyed window", .{});
    }

    glfw.makeContextCurrent(global.window);
    glfw.swapInterval(if (global.settings.window.debug_frame_rate) 0 else 1);

    try gpu.init();
    log.stlog.info("initialized gpu backend for {s}", .{@tagName(gpu.getBackend())});
    defer {
        gpu.deinit();
        log.stlog.info("deinitialized gpu backend", .{});
    }

    // try render.__init();
    // defer render.__deinit();

    global.prev_time = glfw.getTime();
    global.smooth_dt = 1 / 60; // initial guess

    if (global.settings.init) |realInitFn| {
        try realInitFn();
    }
    defer {
        if (global.settings.deinit) |realDeinitFn| {
            realDeinitFn();
        }
    }

    // main loop
    while (!global.window.shouldClose()) {
        if (global.settings.update) |realUpdateFn| {
            // f64 -> f32 because most game code uses f32
            realUpdateFn(@floatCast(deltaTime()));
        }

        // rendering
        gpu.testRender();
        // render.__draw();

        // housekeeping type shit
        const alpha = 0.1; // controls how smooth the smoothing is
        global.smooth_dt = global.smooth_dt * (1.0 - alpha) + deltaTime() * alpha;
        global.prev_time = secondsSinceStart();
        global.prev_mouse_pos = mousePosition();

        glfw.pollEvents();
        pollInputStates();
        global.window.swapBuffers();
    }
}

/// Keyboard keys. Splendid. Note these values are the same as Sokol which are the same as GLFW.
/// Additional constants using `@""` syntax for fun
pub const Key = enum(u32) {
    invalid = 0,
    space = 32,
    apostrophe = 39, // '
    comma = 44, // ,
    minus = 45, // -
    period = 46, // .
    slash = 47, // /
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
    semicolon = 59, // ;
    equal = 61, // =
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
    backslash = 92, // \
    right_bracket = 93, // ]
    grave_accent = 96, // `
    international_1 = 161, // non-US #1
    international_2 = 162, // non-US #2
    escape = 256,
    enter = 257,
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
    right_shift = 344,
    right_ctrl = 345,
    right_alt = 346,
    right_super = 347,
    menu = 348,

    const @" ": Key = .space;
    const @"'": Key = .apostrophe;
    const @",": Key = .comma;
    const @"-": Key = .minus;
    const @".": Key = .period;
    const @"/": Key = .slash;
    const @"0": Key = .num_0;
    const @"1": Key = .num_1;
    const @"2": Key = .num_2;
    const @"3": Key = .num_3;
    const @"4": Key = .num_4;
    const @"5": Key = .num_5;
    const @"6": Key = .num_6;
    const @"7": Key = .num_7;
    const @"8": Key = .num_8;
    const @"9": Key = .num_9;
    const @";": Key = .semicolon;
    const @"=": Key = .equal;
    const @"[": Key = .left_bracket;
    const @"\\": Key = .backslash;
    const @"]": Key = .right_bracket;
    const @"`": Key = .grave_accent;
    const @"return": Key = .enter;
    const left_meta: Key = .left_super;
    const right_meta: Key = .right_super;
    const last: Key = .menu;
};

/// The buttons located on your pointing device technological artifice. Values are the same as GLFW
pub const MouseButton = enum(u32) {
    btn_1 = 0,
    btn_2 = 1,
    btn_3 = 2,
    btn_4 = 3,
    btn_5 = 4,
    btn_6 = 5,
    btn_7 = 6,
    btn_8 = 7,

    const @"1": MouseButton = .btn_1;
    const @"2": MouseButton = .btn_2;
    const @"3": MouseButton = .btn_3;
    const @"4": MouseButton = .btn_4;
    const @"5": MouseButton = .btn_5;
    const @"6": MouseButton = .btn_6;
    const @"7": MouseButton = .btn_7;
    const @"8": MouseButton = .btn_8;

    const left: MouseButton = .btn_1;
    const right: MouseButton = .btn_2;
    const middle: MouseButton = .btn_3;
    const last: MouseButton = .btn_8;
};

const InputState = enum(u8) {
    not_pressed,
    just_pressed,
    held,
    just_released,

    pub fn isPressed(state: InputState) bool {
        return switch (state) {
            .just_pressed, .held => true,
            else => false,
        };
    }
};

fn pollInputStates() void {
    for (@intFromEnum(Key.space)..@intFromEnum(Key.last) + 1) |key| {
        // glfw keys have these gaps for some reason, and if you try to normally go over them and
        // then convert it to an enum, zig crashes and dies
        // so skip the gaps to prevent fucking
        const enum_fields = @typeInfo(Key).@"enum".fields;
        var field_exists = false;
        inline for (enum_fields) |field| {
            if (field.value == key) {
                field_exists = true;
                break;
            }
        }
        if (!field_exists) {
            continue;
        }

        const is_down = global.window.getKey(@enumFromInt(key)) == .press;
        const was_down = global.key_state[key].isPressed();

        if (!was_down and is_down) {
            global.key_state[key] = .just_pressed;
        } else if (was_down and is_down) {
            global.key_state[key] = .held;
        } else if (was_down and !is_down) {
            global.key_state[key] = .just_released;
        } else {
            global.key_state[key] = .not_pressed;
        }
    }

    for (@intFromEnum(MouseButton.btn_1)..@intFromEnum(MouseButton.last) + 1) |btn| {
        // glfw and starry keys have the same values
        const is_down = global.window.getMouseButton(@enumFromInt(btn)) == .press;
        const was_down = global.mouse_state[btn].isPressed();

        if (!was_down and is_down) {
            global.mouse_state[btn] = .just_pressed;
        } else if (was_down and is_down) {
            global.mouse_state[btn] = .held;
        } else if (was_down and !is_down) {
            global.mouse_state[btn] = .just_released;
        } else {
            global.mouse_state[btn] = .not_pressed;
        }
    }
}

pub fn isKeyJustPressed(key: Key) bool {
    return global.key_state[@intFromEnum(key)] == .just_pressed;
}

pub fn isKeyJustReleased(key: Key) bool {
    return global.key_state[@intFromEnum(key)] == .just_released;
}

pub fn isKeyHeld(key: Key) bool {
    return global.key_state[@intFromEnum(key)].isPressed();
}

pub fn isKeyNotPressed(key: Key) bool {
    return !global.key_state[@intFromEnum(key)].isPressed();
}

pub fn isMouseButtonJustPressed(btn: MouseButton) bool {
    return global.mouse_state[@intFromEnum(btn)] == .just_pressed;
}

pub fn isMouseButtonJustReleased(btn: MouseButton) bool {
    return global.mouse_state[@intFromEnum(btn)] == .just_released;
}

pub fn isMouseButtonHeld(btn: MouseButton) bool {
    return global.mouse_state[@intFromEnum(btn)].isPressed();
}

pub fn isMouseButtonNotPressed(btn: MouseButton) bool {
    return !global.mouse_state[@intFromEnum(btn)].isPressed();
}

pub fn mousePosition() zglm.Vec2f {
    const pos = global.window.getCursorPos();
    return .{ @floatCast(pos[0]), @floatCast(pos[1]) };
}

/// Returns the difference between the last frame's mouse position and the current frame's mouse
/// position.
pub fn deltaMousePosition() zglm.Vec2f {
    return mousePosition() - global.prev_mouse_pos;
}

/// Returns the size of the framebuffer.
pub fn framebufferSize() zglm.Vec2i {
    const size: [2]c_int = global.window.getFramebufferSize();
    return .{ @intCast(size[0]), @intCast(size[1]) };
}

/// Returns the size of the framebuffer but in floats.
pub fn framebufferSizef() zglm.Vec2f {
    const size: [2]c_int = global.window.getFramebufferSize();
    return .{ @floatFromInt(size[0]), @floatFromInt(size[1]) };
}

/// Returns the aspect ratio of the framebuffer.
pub fn aspectRatio() f32 {
    const win_size = framebufferSizef();
    return win_size[0] / win_size[1];
}

/// Returns true if high DPI is enabled and the app is actually running in a high DPI setting
pub fn isHighDpi() bool {
    return global.settings.window.high_dpi and
        std.mem.eql(f32, global.window.getContentScale(), [2]f32{ 1, 1 });
}

/// Returns the DPI scaling factor (window pixels to framebuffer pixels)
pub fn dpiScale() f32 {
    // TODO pretty sure all platforms use the same scale horizontally and vertically but i'm not sure
    return global.window.getContentScale()[0];
}

/// If true, locks the mouse inside the window and enables raw mouse input, otherwise unlocks it.
pub fn lockMouse(lock: bool) void {
    // setInputMode returning an error is really unlikely
    _ = global.window.setInputMode(.cursor, if (lock) .disabled else .normal) catch |err| {
        std.log.err("{s}", .{@errorName(err)});
        @panic(@errorName(err));
    };
}

/// Returns true if the mouse is locked inside the window (this may toggle a few frames later)
pub fn isMouseLocked() bool {
    // getInputMode returning an error is really unlikely
    const input_mode = global.window.getInputMode(.cursor) catch |err| {
        std.log.err("{s}", .{@errorName(err)});
        @panic(@errorName(err));
    };
    return switch (input_mode) {
        .disabled => true,
        else => false,
    };
}

/// Asks nicely for the app to close (the app can handle it and not actually quit)
pub fn requestQuit() void {
    global.window.setShouldClose(true);
}

/// Cancels a pending quit from `requestQuit`
pub fn cancelQuit() void {
    global.window.setShouldClose(false);
}

/// Truly quits the application (the app doesn't handle the quit event)
pub fn forceQuit() void {
    global.window.setShouldClose(true); // TODO make this different
}

/// Returns the time in seconds since the app started
pub fn secondsSinceStart() f64 {
    return glfw.getTime();
}

/// Returns the time it took to run the last frame
pub fn deltaTime() f64 {
    return secondsSinceStart() - global.prev_time;
}

/// Returns the average/smoothed FPS the app is running at
pub fn averageFps() f64 {
    return 1 / global.smooth_dt;
}

/// Sets the window title to something else duh
pub fn setWindowTitle(title: []const u8) void {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const title_cstr =
        std.mem.concatWithSentinel(scratch.allocator(), u8, &[_]u8{title}, 0) catch unreachable;
    global.window.setTitle(title_cstr);
}
