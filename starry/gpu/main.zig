//! Simplified Vulkan wrapper to reduce human suffering
const std = @import("std");
const glfw = @import("zglfw");
const vk = @import("vulkan");
const impl = @import("internal.zig");
const win = @import("../window.zig");
const app = @import("../app.zig");
const ScratchAllocator = @import("../scratch.zig").ScratchAllocator;
const version = @import("../root.zig").version;

/// Initializes the GPU for rendering and future `starry.gpu` calls.
pub fn init(comptime app_settings: app.Settings, _: win.Window) !void {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    impl.vkb = vk.BaseWrapper.load(getInstanceProcAddress);

    // usual insalubrious vulkan boilerplate to get an instance
    const app_info = vk.ApplicationInfo{
        .p_application_name = app_settings.name ++ "\x00",
        .application_version = @bitCast(vk.makeApiVersion(
            0,
            app_settings.version.major,
            app_settings.version.minor,
            app_settings.version.patch,
        )),
        .p_engine_name = "Starry3D",
        .engine_version = @bitCast(vk.makeApiVersion(0, version.major, version.minor, version.patch)),
        .api_version = @bitCast(vk.API_VERSION_1_2),
    };

    const required_instance_exts = try glfw.getRequiredInstanceExtensions();
    const extra_instance_exts = [_][*:0]const u8{
        vk.extensions.khr_portability_enumeration.name, // required on macOS
    };
    const instance_exts = try scratch.allocator().alloc(
        [*:0]const u8,
        required_instance_exts.len + extra_instance_exts.len,
    );
    @memcpy(instance_exts[0..required_instance_exts.len], required_instance_exts);
    @memcpy(instance_exts[required_instance_exts.len..], &extra_instance_exts);

    const instance_create_info = vk.InstanceCreateInfo{
        .p_application_info = &app_info,
        .pp_enabled_extension_names = instance_exts.ptr,
        .enabled_extension_count = @intCast(instance_exts.len),
        .enabled_layer_count = 0, // TODO do smth with this
    };

    // unfortunately vulkan-zig makes the boilerplate more esoteric
    // just look at the vulkan-zig docs i cant be bothered
    const instance = try impl.vkb.createInstance(&instance_create_info, null);
    impl.vki = vk.InstanceWrapper.load(instance, impl.vkb.dispatch.vkGetInstanceProcAddr.?);
    impl.instance = vk.InstanceProxy.init(instance, &impl.vki);
    errdefer impl.instance.destroyInstance(null);
}

/// Deinitializes the GPU for rendering. This doesn't free GPU resources, you must manage them
/// manually before calling this function.
pub fn deinit() void {
    impl.instance.destroyInstance(null);
}

/// glfw and vulkan-zig have different definitions of vk.Instance but they're the fucking same
fn getInstanceProcAddress(instance: vk.Instance, procname: [*:0]const u8) ?glfw.VulkanFn {
    return glfw.getInstanceProcAddress(@ptrFromInt(@intFromEnum(instance)), procname);
}
