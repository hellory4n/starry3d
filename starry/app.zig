//! Manages the engine/app's lifetime and puts the whole engine together
const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const zglm = @import("zglm");
const render = @import("starry3d_render");
const root = @import("root.zig");
const world = @import("world.zig");
const ScratchAllocator = @import("sunshine").ScratchAllocator;

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
};

/// You usually want this to be configurable by the end user
pub const WindowSettings = struct {
    /// The preferred size of the window
    size: zglm.Vec2i = .{ 1280, 720 },
    /// Whether the rendering canvas is full resolution on high-DPI displays
    high_dpi: bool = true,
    /// Whether the window should be resizable (only works on desktop)
    resizable: bool = true,
};

/// internal state stuff and stuff
const GlobalState = struct {
    settings: Settings = undefined,

    /// for allocating values that last as long as the engine/program does
    core_alloc: std.mem.Allocator = undefined,

    window: *glfw.Window = undefined,
    key_state: [@intFromEnum(Key.last) + 1]InputState =
        .{InputState.not_pressed} ** (@intFromEnum(Key.last) + 1),
    mouse_state: [@intFromEnum(MouseButton.last) + 1]InputState =
        .{InputState.not_pressed} ** (@intFromEnum(MouseButton.last) + 1),
    prev_mouse_pos: zglm.Vec2f = @splat(0),
    minimized: bool = false,

    prev_time: f64 = 0,
    smooth_dt: f64 = 1 / 60, // initial guess
};
var ctx: GlobalState = .{};

/// Runs the engine, and eventually, your app :)
pub fn run(alloc: std.mem.Allocator, comptime settings: Settings) void {
    ctx.settings = settings;
    ctx.core_alloc = alloc;
    const stlog = std.log.scoped(.starry);

    // the rest of the engine has to be wrapped so that errors are logged properly
    starryMain() catch |err| {
        stlog.err("fatal error: {s}", .{@errorName(err)});
        @panic(@errorName(err)); // for the stack trace
    };
}

fn starryMain() !void {
    // TODO clean this up
    const stlog = std.log.scoped(.starry);
    stlog.info("starry v{d}.{d}.{d}{s}{s}", .{
        root.version.major,
        root.version.minor,
        root.version.patch,
        if (root.version.pre) |pre| "-" ++ pre else "",
        if (root.version.build) |build| "+" ++ build else "",
    });
    defer stlog.info("deinitialized starry", .{});

    // renderdoc consider unshitting yourself
    if (builtin.mode == .Debug and builtin.os.tag == .linux) {
        try glfw.initHint(.platform, glfw.Platform.x11);
    }

    // window fuckery
    try glfw.init();
    stlog.info("initialized GLFW", .{});
    defer {
        glfw.terminate();
        stlog.info("deinitialized GLFW", .{});
    }

    glfw.windowHint(.client_api, .opengl_api);
    glfw.windowHint(.opengl_profile, .opengl_core_profile);
    glfw.windowHint(.context_version_major, 3);
    glfw.windowHint(.context_version_minor, 3);

    glfw.windowHint(.resizable, ctx.settings.window.resizable);
    // TODO idk if high dpi works lmao
    glfw.windowHint(.scale_to_monitor, !ctx.settings.window.high_dpi);
    glfw.windowHint(.scale_framebuffer, !ctx.settings.window.high_dpi);

    glfw.windowHintString(.x11_class_name, ctx.settings.name);
    glfw.windowHintString(.wayland_app_id, ctx.settings.name);

    ctx.window = try glfw.Window.create(
        @intCast(ctx.settings.window.size[0]),
        @intCast(ctx.settings.window.size[1]),
        ctx.settings.name,
        null,
    );
    stlog.info("created window for {s} on {s}", .{
        @tagName(glfw.getPlatform()),
        @tagName(builtin.os.tag),
    });
    defer {
        ctx.window.destroy();
        stlog.info("destroyed window", .{});
    }

    glfw.makeContextCurrent(ctx.window);
    // disable vsync on debug so that you can see the true fps
    // which is useful for making renderers and shit
    glfw.swapInterval(if (builtin.mode == .Debug) 1 else 0);

    // idk man
    ctx.prev_time = glfw.getTime();

    // 2050 different callbacks
    _ = glfw.setWindowIconifyCallback(ctx.window, struct {
        pub fn callback(window: *glfw.Window, minimized: glfw.Bool) callconv(.c) void {
            _ = window;
            ctx.minimized = @intFromEnum(minimized) == 1;
        }
    }.callback);

    try render.init();
    defer render.deinit();

    // Job Done!
    if (ctx.settings.init) |realInitFn| {
        try realInitFn();
    }
    defer {
        if (ctx.settings.deinit) |realDeinitFn| {
            realDeinitFn();
        }
    }

    // main loop
    while (!ctx.window.shouldClose()) {
        if (!isMinimized()) {
            try render.render();
        }

        if (ctx.settings.update) |realUpdateFn| {
            // f64 -> f32 because most game code uses f32
            realUpdateFn(@floatCast(deltaTime()));
        }

        // housekeeping type shit
        const alpha = 0.1; // controls how smooth the smoothing is i have a way with words
        ctx.smooth_dt = ctx.smooth_dt * (1.0 - alpha) + deltaTime() * alpha;
        ctx.prev_time = secondsSinceStart();
        ctx.prev_mouse_pos = mousePosition();

        glfw.pollEvents();
        pollInputStates();
        glfw.swapBuffers(ctx.window);
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

        const is_down = ctx.window.getKey(@enumFromInt(key)) == .press;
        const was_down = ctx.key_state[key].isPressed();

        if (!was_down and is_down) {
            ctx.key_state[key] = .just_pressed;
        } else if (was_down and is_down) {
            ctx.key_state[key] = .held;
        } else if (was_down and !is_down) {
            ctx.key_state[key] = .just_released;
        } else {
            ctx.key_state[key] = .not_pressed;
        }
    }

    for (@intFromEnum(MouseButton.btn_1)..@intFromEnum(MouseButton.last) + 1) |btn| {
        // glfw and starry keys have the same values
        const is_down = ctx.window.getMouseButton(@enumFromInt(btn)) == .press;
        const was_down = ctx.mouse_state[btn].isPressed();

        if (!was_down and is_down) {
            ctx.mouse_state[btn] = .just_pressed;
        } else if (was_down and is_down) {
            ctx.mouse_state[btn] = .held;
        } else if (was_down and !is_down) {
            ctx.mouse_state[btn] = .just_released;
        } else {
            ctx.mouse_state[btn] = .not_pressed;
        }
    }
}

pub fn isKeyJustPressed(key: Key) bool {
    return ctx.key_state[@intFromEnum(key)] == .just_pressed;
}

pub fn isKeyJustReleased(key: Key) bool {
    return ctx.key_state[@intFromEnum(key)] == .just_released;
}

pub fn isKeyHeld(key: Key) bool {
    return ctx.key_state[@intFromEnum(key)].isPressed();
}

pub fn isKeyNotPressed(key: Key) bool {
    return !ctx.key_state[@intFromEnum(key)].isPressed();
}

pub fn isMouseButtonJustPressed(btn: MouseButton) bool {
    return ctx.mouse_state[@intFromEnum(btn)] == .just_pressed;
}

pub fn isMouseButtonJustReleased(btn: MouseButton) bool {
    return ctx.mouse_state[@intFromEnum(btn)] == .just_released;
}

pub fn isMouseButtonHeld(btn: MouseButton) bool {
    return ctx.mouse_state[@intFromEnum(btn)].isPressed();
}

pub fn isMouseButtonNotPressed(btn: MouseButton) bool {
    return !ctx.mouse_state[@intFromEnum(btn)].isPressed();
}

pub fn mousePosition() zglm.Vec2f {
    const pos = ctx.window.getCursorPos();
    return .{ @floatCast(pos[0]), @floatCast(pos[1]) };
}

/// Returns the difference between the last frame's mouse position and the current frame's mouse
/// position.
pub fn deltaMousePosition() zglm.Vec2f {
    return mousePosition() - ctx.prev_mouse_pos;
}

/// Returns the size of the framebuffer.
pub fn framebufferSize() zglm.Vec2i {
    const size: [2]c_int = ctx.window.getFramebufferSize();
    return .{ @intCast(size[0]), @intCast(size[1]) };
}

/// Returns the size of the framebuffer but in floats.
pub fn framebufferSizef() zglm.Vec2f {
    const size: [2]c_int = ctx.window.getFramebufferSize();
    return .{ @floatFromInt(size[0]), @floatFromInt(size[1]) };
}

/// Returns the aspect ratio of the framebuffer.
pub fn aspectRatio() f32 {
    const win_size = framebufferSizef();
    return win_size[0] / win_size[1];
}

/// Returns true if high DPI is enabled and the app is actually running in a high DPI setting
pub fn isHighDpi() bool {
    return ctx.settings.window.high_dpi and
        std.mem.eql(f32, ctx.window.getContentScale(), [2]f32{ 1, 1 });
}

/// Returns the DPI scaling factor (window pixels to framebuffer pixels)
pub fn dpiScale() f32 {
    // TODO pretty sure all platforms use the same scale horizontally and vertically but i'm not sure
    return ctx.window.getContentScale()[0];
}

/// If true, locks the mouse inside the window and enables raw mouse input, otherwise unlocks it.
pub fn lockMouse(lock: bool) void {
    // setInputMode returning an error is really unlikely
    _ = ctx.window.setInputMode(.cursor, if (lock) .disabled else .normal) catch |err| {
        std.log.err("lockMouse: {s}", .{@errorName(err)});
    };
}

/// Returns true if the mouse is locked inside the window (this may toggle a few frames later)
pub fn isMouseLocked() bool {
    // getInputMode returning an error is really unlikely
    const input_mode = ctx.window.getInputMode(.cursor) catch |err| {
        std.log.err("isMouseLocked: {s}", .{@errorName(err)});
        return false;
    };
    return switch (input_mode) {
        .disabled => true,
        else => false,
    };
}

/// Asks nicely for the app to close (the app can handle it and not actually quit)
pub fn requestQuit() void {
    ctx.window.setShouldClose(true);
}

/// Cancels a pending quit from `requestQuit`
pub fn cancelQuit() void {
    ctx.window.setShouldClose(false);
}

/// Truly quits the application (the app doesn't handle the quit event)
pub fn forceQuit() void {
    ctx.window.setShouldClose(true); // TODO make this different
}

/// Returns the time in seconds since the app started
pub fn secondsSinceStart() f64 {
    return glfw.getTime();
}

/// Returns the time it took to run the last frame
pub fn deltaTime() f64 {
    return secondsSinceStart() - ctx.prev_time;
}

/// Returns the average/smoothed FPS the app is running at
pub fn averageFps() f64 {
    return 1 / ctx.smooth_dt;
}

/// Sets the window title to something else duh
pub fn setWindowTitle(title: []const u8) void {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const title_cstr =
        std.mem.concatWithSentinel(scratch.allocator(), u8, &[_]u8{title}, 0) catch unreachable;
    ctx.window.setTitle(title_cstr);
}

/// Returns the "native" handle for the window. Except it actually isn't native, it's using whatever
/// windowing API the engine is using. You can then get the real native handle from that.
pub fn nativeHandle() *anyopaque {
    return ctx.window;
}

/// If true, the window is minimized. Else, it's restored/visible.
pub fn isMinimized() bool {
    return ctx.minimized;
}
