//! Windowing and input and stuff. Amazing.
const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");

/// Window settings duh
pub const Settings = struct {
    size: @Vector(2, i32) = .{ 1280, 720 },
    resizable: bool = true,
    vsync: bool = false,
    // TODO should have more options but i can't be bothered rn
};

const WindowError = error{VulkanUnsupported};

pub const Window = struct {
    __handle: ?*glfw.Window = undefined,

    pub fn open(comptime title: []const u8, settings: Settings) !Window {
        // just in case you want multiple windows
        // really doubt anyone will ever close all windows just to make new ones but ok
        if (__glfw_deinitialized) {
            __glfw_deinitialized = false;
            __glfw_initialized = false;
        }
        if (!__glfw_initialized) {
            try glfw.init();
            std.log.info("initialized GLFW", .{});
            __glfw_initialized = true;
        }

        // vulkan is required, obviously
        if (!glfw.isVulkanSupported()) {
            std.log.err("vulkan isn't supported!", .{});
            return error.VulkanUnsupported;
        }

        glfw.windowHint(.client_api, .no_api);
        // resizing requires some special fuckery in vulkan
        // TODO do the fuckery dumbass
        //glfw.windowHint(.resizable, settings.resizable);
        glfw.windowHint(.resizable, false);
        glfw.swapInterval(if (settings.vsync) 1 else 0);
        _ = glfw.setErrorCallback(windowErrorCallback);

        var window = Window{};
        window.__handle = try glfw.createWindow(settings.size[0], settings.size[1], title ++ "\x00", null);

        __windows_opened += 1;
        std.log.info(
            "created window for {s} on {s}",
            .{ @tagName(windowSystem()), @tagName(builtin.os.tag) },
        );
        return window;
    }

    pub fn close(window: *Window) void {
        if (window.__handle != null) {
            glfw.destroyWindow(window.__handle.?);
            std.log.info("closed window", .{});
        }
        window.__handle = null;

        __windows_opened -= 1;
        if (__windows_opened == 0) {
            glfw.terminate();
            std.log.info("deinitialized GLFW", .{});
            __glfw_deinitialized = true;
        }
    }

    /// Used for setting up the main loop
    pub fn isClosing(window: Window) bool {
        return glfw.windowShouldClose(window.__handle.?);
    }

    /// Recommended to be called at the start of your main loop
    pub fn pollEvents(_: Window) void {
        glfw.pollEvents();
    }

    /// Recommended to be called at the end of your main loop
    pub fn swapBuffers(_: Window) void {
        //glfw.swapBuffers(window.__handle.?);
    }
};

pub const WindowSystem = enum {
    // No window system
    headless,
    /// Windows
    win32,
    /// macOS
    cocoa,
    /// *nix
    x11,
    /// *nix though most likely Linux, maybe BSD?
    wayland,
};

/// Conveniently the window system and OS are different things because of *nix platformms
pub fn windowSystem() WindowSystem {
    const platform = glfw.getPlatform();
    return switch (platform) {
        .null => .headless,
        .win32 => .win32,
        .cocoa => .cocoa,
        .x11 => .x11,
        .wayland => .wayland,
        else => unreachable,
    };
}

fn windowErrorCallback(error_code: c_int, description: ?[*:0]const u8) callconv(.c) void {
    std.log.err("GLFW error 0x{x}: {s}", .{ error_code, description.? });
    @breakpoint();
}

var __glfw_initialized = false;
var __glfw_deinitialized = false;
var __windows_opened: i32 = 0;
