//! Vulkan implemenation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo Daquavious
//! II Sr. Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE aka
//! Joel Pablo aka QuejaPalronicador aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka QuejaGontificador

const std = @import("std");
const builtin = @import("builtin");
const log = std.log.scoped(.starrygpu);
const glfw = @import("zglfw");
const vk = @import("vulkan");
const ScratchAllocator = @import("sunshine").ScratchAllocator;
const app = @import("app.zig");
const version = @import("root.zig").version;
const gpu = @import("gpu.zig");
const gpubk = @import("gpu_backend.zig");

var ctx: struct {
    // we have to use these to call vulkan functions i guess
    vkb: vk.BaseWrapper = undefined,
    vki: vk.InstanceWrapper = undefined,
    vkd: vk.DeviceWrapper = undefined,

    instance: vk.Instance = undefined,
} = .{};

pub fn init(comptime settings: app.Settings) gpu.Error!void {
    // vulkan tends to be insalubrious
    initInstance(settings) catch return gpu.Error.DeviceUnsupported;
}

pub fn deinit() void {
    // luckily deinitializing is less insalubrious
    ctx.vki.destroyInstance(ctx.instance, null);
    std.log.info("deinitialized Vulkan", .{});
}

fn initInstance(comptime settings: app.Settings) !void {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    ctx.vkb = vk.BaseWrapper.load(getInstanceProcAddress);

    // usual insalubrious vulkan boilerplate to get an instance
    const app_info = vk.ApplicationInfo{
        .p_application_name = settings.name ++ "\x00",
        .application_version = @bitCast(vk.makeApiVersion(
            0,
            settings.version.major,
            settings.version.minor,
            settings.version.patch,
        )),
        .p_engine_name = "Starry3D",
        .engine_version = @bitCast(vk.makeApiVersion(0, version.major, version.minor, version.patch)),
        .api_version = @bitCast(vk.API_VERSION_1_2),
    };

    // extending it
    const required_instance_exts = try glfw.getRequiredInstanceExtensions();
    const extra_instance_exts = [_][*:0]const u8{
        // required on macOS
        vk.extensions.khr_portability_enumeration.name,
        vk.extensions.khr_get_physical_device_properties_2.name,
    };
    const instance_exts = try scratch.allocator().alloc(
        [*:0]const u8,
        required_instance_exts.len + extra_instance_exts.len,
    );
    @memcpy(instance_exts[0..required_instance_exts.len], required_instance_exts);
    @memcpy(instance_exts[required_instance_exts.len..], &extra_instance_exts);

    // validation layer fuckery
    const enable_validation_layers = switch (builtin.mode) {
        .Debug => true,
        .ReleaseSafe => true,
        else => false,
    };
    var validation_layers_supported: bool = undefined;
    if (gpu.validationEnabled() and try hasValidationLayers()) {
        validation_layers_supported = true;
        log.info("using validation layers", .{});
    } else if (enable_validation_layers) {
        log.warn("validation layers requested but not supported", .{});
    } else {
        validation_layers_supported = false;
    }
    const use_validation_layers = enable_validation_layers and validation_layers_supported;
    const validation_layers = [_][*:0]const u8{"VK_LAYER_KHRONOS_validation"};
    // TODO debug messenger or whatever the fuck

    const instance_create_info = vk.InstanceCreateInfo{
        .p_application_info = &app_info,
        .pp_enabled_extension_names = instance_exts.ptr,
        .enabled_extension_count = @intCast(instance_exts.len),
        .pp_enabled_layer_names = if (use_validation_layers) (&validation_layers).ptr else null,
        .enabled_layer_count = if (use_validation_layers) 1 else 0,
        // also required on macOS
        .flags = .{ .enumerate_portability_bit_khr = true },
    };

    // unfortunately vulkan-zig makes the boilerplate more esoteric
    // just look at the vulkan-zig docs i cant be bothered
    ctx.instance = try ctx.vkb.createInstance(&instance_create_info, null);
    ctx.vki = vk.InstanceWrapper.load(ctx.instance, ctx.vkb.dispatch.vkGetInstanceProcAddr.?);
    errdefer ctx.vki.destroyInstance(ctx.instance, null);
    log.info("initialized Vulkan instance", .{});
}

/// glfw and vulkan-zig have different definitions of vk.Instance but they're the fucking same
fn getInstanceProcAddress(instance: vk.Instance, procname: [*:0]const u8) ?glfw.VulkanFn {
    return glfw.getInstanceProcAddress(@ptrFromInt(@intFromEnum(instance)), procname);
}

fn hasValidationLayers() !bool {
    var layer_count: u32 = undefined;
    _ = try ctx.vkb.enumerateInstanceLayerProperties(&layer_count, null);

    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    const layers = try scratch.allocator().alloc(vk.LayerProperties, layer_count);
    _ = try ctx.vkb.enumerateInstanceLayerProperties(&layer_count, layers.ptr);

    for (layers) |layer| {
        // get the real length otherwise std.mem.eql shits itself
        const layer_len = std.mem.indexOfSentinel(u8, 0, @ptrCast(&layer.layer_name));
        const layer_name = layer.layer_name[0..layer_len];

        if (std.mem.eql(u8, layer_name, "VK_LAYER_KHRONOS_validation")) {
            return true;
        }
    }
    return false;
}
