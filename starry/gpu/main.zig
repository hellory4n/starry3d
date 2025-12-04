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
    impl.instance = try impl.vkb.createInstance(&instance_create_info, null);
    impl.vki = vk.InstanceWrapper.load(impl.instance, impl.vkb.dispatch.vkGetInstanceProcAddr.?);
    errdefer impl.vki.destroyInstance(impl.instance, null);

    // finally setup device
    _ = try pickDevice();

    std.log.info("initialized Vulkan", .{});
}

/// Deinitializes the GPU for rendering. This doesn't free GPU resources, you must manage them
/// manually before calling this function.
pub fn deinit() void {
    impl.vki.destroyInstance(impl.instance, null);
    std.log.info("deinitialized Vulkan", .{});
}

/// glfw and vulkan-zig have different definitions of vk.Instance but they're the fucking same
fn getInstanceProcAddress(instance: vk.Instance, procname: [*:0]const u8) ?glfw.VulkanFn {
    return glfw.getInstanceProcAddress(@ptrFromInt(@intFromEnum(instance)), procname);
}

const DevicePickingError = error{
    NoDeviceWithVulkan,
    NoDeviceGoodEnough,
};

/// Returns the best device for running the most massive engine of all time
fn pickDevice() !vk.PhysicalDevice {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();

    var device_count: u32 = 0;
    _ = try impl.vki.enumeratePhysicalDevices(impl.instance, &device_count, null);
    if (device_count == 0) {
        return error.NoDeviceWithVulkan;
    }

    const devices = try scratch.allocator().alloc(vk.PhysicalDevice, device_count);
    _ = try impl.vki.enumeratePhysicalDevices(impl.instance, &device_count, devices.ptr);

    var best_device: ?vk.PhysicalDevice = null;
    var best_score: u64 = 0;
    var best_device_i: usize = 0;
    for (devices, 0..) |device, i| {
        const props = impl.vki.getPhysicalDeviceProperties(device);
        // const features = impl.vki.getPhysicalDeviceFeatures(device); TODO use it probably
        const memory = impl.vki.getPhysicalDeviceMemoryProperties(device);
        const queue_families = try findQueueFamilies(device);
        var score: u64 = 0;

        std.log.info("device #{d} '{s}':", .{ i, props.device_name });

        // discrete gpus are better
        if (props.device_type == .discrete_gpu) {
            score += 10_000;
        }
        // integrated gpus are the next best thing (there's other types)
        else if (props.device_type == .integrated_gpu) {
            score += 5000;
        }
        std.log.info("- type: {s}", .{@tagName(props.device_type)});

        // more vram is more good
        var total_vram: u64 = 0;
        for (memory.memory_heaps[0..memory.memory_heap_count]) |heap| {
            total_vram += heap.size;
        }
        std.log.info(
            "- vram: {d} MB, ~{d} GB",
            .{ total_vram / 1024 / 1024, total_vram / 1024 / 1024 / 1024 },
        );
        score += total_vram / 1024 / 1024;

        // we do have to check if it's supported
        var supported = true;
        if (!queue_families.isComplete()) {
            supported = false;
            std.log.info("- unsupported:", .{});
            std.log.info("  - graphics family: {s}", .{
                if (queue_families.graphics_family == null) "unsupported" else "ok",
            });
        }

        std.log.info("- score: {d}", .{score});

        if (score > best_score and supported) {
            best_device = device;
            best_score = score;
            best_device_i = i;
        }
    }

    if (best_device) |best_device_real| {
        std.log.info("using device #{d}", .{best_device_i});
        return best_device_real;
    } else {
        return error.NoDeviceGoodEnough;
    }
}

/// Idfk man.
const QueueFamilies = struct {
    graphics_family: ?usize = null,

    pub fn isComplete(queue_families: QueueFamilies) bool {
        return queue_families.graphics_family != null;
    }
};

fn findQueueFamilies(dev: vk.PhysicalDevice) !QueueFamilies {
    var scratch = ScratchAllocator.init();
    defer scratch.deinit();
    var indices = QueueFamilies{};

    var queue_family_count: u32 = undefined;
    impl.vki.getPhysicalDeviceQueueFamilyProperties(dev, &queue_family_count, null);

    const queue_families = try scratch.allocator().alloc(vk.QueueFamilyProperties, queue_family_count);
    impl.vki.getPhysicalDeviceQueueFamilyProperties(dev, &queue_family_count, queue_families.ptr);

    for (queue_families, 0..) |queue_family, i| {
        if (queue_family.queue_flags.contains(.{ .graphics_bit = true })) {
            indices.graphics_family = i;
        }

        if (indices.isComplete()) {
            break;
        }
    }
    return indices;
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
