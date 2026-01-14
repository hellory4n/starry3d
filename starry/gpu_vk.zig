//! Vulkan implemenation for starry.gpu aka Emerson Victor Kyler Gandalf Joel Pablo Daquavious
//! II Sr. Jr. OBE aka Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OBE aka
//! Joel Pablo aka QuejaPalronicador aka Qurjs fhycmjjjjjjjjjjjjjjjjjç aka QuejaGontificador

const std = @import("std");
const builtin = @import("builtin");
const log = std.log.scoped(.starrygpu);
const glfw = @import("zglfw");
const vk = @import("vulkan");
const vkk = @import("vk-kickstart");
const ScratchAllocator = @import("sunshine").ScratchAllocator;
const app = @import("app.zig");
const version = @import("root.zig").version;
const gpu = @import("gpu.zig");
const gpubk = @import("gpu_backend.zig");

const Instance = vk.InstanceProxy;
const Device = vk.DeviceProxy;
const Queue = vk.QueueProxy;
const CommandBuffer = vk.CommandBufferProxy;

var ctx: struct {
    alloc: std.mem.Allocator = undefined,
    instance: Instance = undefined,
    debug_messenger: ?vk.DebugUtilsMessengerEXT = null,
    device: Device = undefined,
    physical_device: vkk.PhysicalDevice = undefined,
    surface: vk.SurfaceKHR = undefined,
    graphics_queue_index: u32 = undefined,
    present_queue_index: u32 = undefined,
    graphics_queue: Queue = undefined,
    present_queue: Queue = undefined,
} = .{};

pub fn init(alloc: std.mem.Allocator, comptime settings: app.Settings) gpu.Error!void {
    ctx.alloc = alloc;

    // vulkan tends to be insalubrious
    // so instead we use vk-kickstart to provide a more salubrious experience
    ctx.instance = vkk.instance.create(
        ctx.alloc,
        getInstanceProcAddress,
        .{
            .app_name = settings.name,
            .engine_name = "Starry3D",
            // apparently 'vk.Version' and 'vk.Version' are different types
            .app_version = @bitCast(vk.makeApiVersion(
                0,
                settings.version.major,
                settings.version.minor,
                settings.version.patch,
            )),
            .engine_version = @bitCast(vk.makeApiVersion(
                0,
                version.major,
                version.minor,
                version.patch,
            )),
            .required_api_version = @bitCast(vk.API_VERSION_1_3),
            .enable_validation = gpu.validationEnabled(),
            .debug_messenger = .{ .enable = false }, // TODO
            .enabled_validation_features = &.{.best_practices_ext},
        },
        null,
    ) catch |err| {
        switch (err) {
            .ValidationLayersNotAvailable => {
                log.warn("validation layers requested but not available");
            },
            else => {
                log.err("{s}", .{@errorName(err)});
                return err;
            },
        }
    };
    errdefer ctx.instance.destroyInstance(null);
    log.info("created Vulkan instance", .{});
}

pub fn deinit() void {
    // luckily deinitializing is less insalubrious
    ctx.instance.destroyInstance(null);
    std.log.info("deinitialized Vulkan", .{});
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
