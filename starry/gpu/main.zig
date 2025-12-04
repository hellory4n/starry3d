//! Simplified Vulkan wrapper to reduce human suffering
const std = @import("std");
const builtin = @import("builtin");
const glfw = @import("zglfw");
const vk = @import("vulkan");
const impl = @import("internal.zig");
const win = @import("../window.zig");
const app = @import("../app.zig");
const util = @import("../util.zig");
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

    const enable_validation_layers = switch (builtin.mode) {
        .Debug => true,
        .ReleaseSafe => true,
        else => false,
    };
    var validation_layers_supported: bool = undefined;
    if (enable_validation_layers and try hasValidationLayers()) {
        validation_layers_supported = true;
        std.log.info("using validation layers", .{});
    } else if (enable_validation_layers) {
        std.log.warn("validation layers requested but not supported", .{});
    } else {
        validation_layers_supported = false;
    }
    const use_validation_layers = enable_validation_layers and validation_layers_supported;
    const validation_layers = [_][*:0]const u8{validation_layer_name};
    // TODO debug messenger or smth

    const instance_create_info = vk.InstanceCreateInfo{
        .p_application_info = &app_info,
        .pp_enabled_extension_names = instance_exts.ptr,
        .enabled_extension_count = @intCast(instance_exts.len),
        .pp_enabled_layer_names = if (use_validation_layers) (&validation_layers).ptr else null,
        .enabled_layer_count = if (use_validation_layers) 1 else 0,
    };

    // unfortunately vulkan-zig makes the boilerplate more esoteric
    // just look at the vulkan-zig docs i cant be bothered
    const instance = try impl.vkb.createInstance(&instance_create_info, null);
    impl.vki = vk.InstanceWrapper.load(instance, impl.vkb.dispatch.vkGetInstanceProcAddr.?);
    impl.instance = vk.InstanceProxy.init(instance, &impl.vki);
    errdefer impl.instance.destroyInstance(null);

    std.log.info("initialized Vulkan", .{});
}

/// Deinitializes the GPU for rendering. This doesn't free GPU resources, you must manage them
/// manually before calling this function.
pub fn deinit() void {
    impl.instance.destroyInstance(null);
    std.log.info("deinitialized Vulkan", .{});
}

/// glfw and vulkan-zig have different definitions of vk.Instance but they're the fucking same
fn getInstanceProcAddress(instance: vk.Instance, procname: [*:0]const u8) ?glfw.VulkanFn {
    return glfw.getInstanceProcAddress(@ptrFromInt(@intFromEnum(instance)), procname);
}

const validation_layer_name = "VK_LAYER_KHRONOS_validation";

/// returns true if the vulkan implementation has validation layers
fn hasValidationLayers() !bool {
    var layer_count: u32 = undefined;
    _ = try impl.vkb.enumerateInstanceLayerProperties(&layer_count, null);

    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const layers = try scratch.allocator().alloc(vk.LayerProperties, layer_count);
    _ = try impl.vkb.enumerateInstanceLayerProperties(&layer_count, layers.ptr);

    for (layers) |layer| {
        // get the real length otherwise std.mem.eql shits itself
        const layer_len = util.strnlen(&layer.layer_name, vk.MAX_EXTENSION_NAME_SIZE);
        const layer_name = layer.layer_name[0..layer_len];

        if (std.mem.eql(u8, layer_name, validation_layer_name)) {
            return true;
        }
    }
    return false;
}
