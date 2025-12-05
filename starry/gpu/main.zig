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

const GpuSettings = struct {
    // TODO
};

const required_device_exts = [_][*:0]const u8{
    vk.extensions.khr_swapchain.name,
};

/// Does the bare minimum GPU initialization. To setup the GPU for rendering, you have to call
/// `gpu.initRendering`
pub fn init(comptime app_settings: app.Settings, comptime _: GpuSettings, window: win.Window) !void {
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
        // also required on macOS
        .flags = .{ .enumerate_portability_bit_khr = true },
    };

    // unfortunately vulkan-zig makes the boilerplate more esoteric
    // just look at the vulkan-zig docs i cant be bothered
    impl.instance = try impl.vkb.createInstance(&instance_create_info, null);
    impl.vki = vk.InstanceWrapper.load(impl.instance, impl.vkb.dispatch.vkGetInstanceProcAddr.?);
    errdefer impl.vki.destroyInstance(impl.instance, null);
    std.log.info("initialized Vulkan instance", .{});

    // make a surface
    try glfw.createWindowSurface(
        @ptrFromInt(@intFromEnum(impl.instance)),
        window.__handle.?,
        null,
        &impl.surface,
    );

    // finally create the device
    const physical_device = try pickDevice();

    const queue_families = try findQueueFamilies(physical_device);
    const queue_priority = [_]f32{1.0};
    const queue_create_infos = [_]vk.DeviceQueueCreateInfo{
        .{
            .queue_family_index = queue_families.graphics_family.?,
            .queue_count = 1,
            .p_queue_priorities = &queue_priority,
        },
        .{
            .queue_family_index = queue_families.present_family.?,
            .queue_count = 1,
            .p_queue_priorities = &queue_priority,
        },
    };
    // if the queue create infos point to the same family idx then vulkan farts and dies
    const queue_count: u32 = if (queue_families.graphics_family.? == queue_families.present_family.?)
        1
    else
        2;

    const device_features = vk.PhysicalDeviceFeatures{};
    const device_create_info = vk.DeviceCreateInfo{
        .p_queue_create_infos = &queue_create_infos,
        .queue_create_info_count = queue_count,
        .p_enabled_features = &device_features,
        .pp_enabled_extension_names = (&required_device_exts).ptr,
        .enabled_extension_count = required_device_exts.len,
        .pp_enabled_layer_names = if (use_validation_layers) (&validation_layers).ptr else null,
        .enabled_layer_count = if (use_validation_layers) 1 else 0,
    };
    impl.device = try impl.vki.createDevice(physical_device, &device_create_info, null);
    impl.vkd = vk.DeviceWrapper.load(impl.device, impl.vki.dispatch.vkGetDeviceProcAddr.?);
    errdefer impl.vkd.destroyDevice(impl.device, null);

    impl.graphics_queue = impl.vkd.getDeviceQueue(impl.device, queue_families.graphics_family.?, 0);
    impl.present_queue = impl.vkd.getDeviceQueue(impl.device, queue_families.present_family.?, 0);
    std.log.info("initialized Vulkan device", .{});

    // create swapchain
    const swapchain_support = try querySwapchainSupport(scratch.allocator(), physical_device, impl.surface);
    const surface_format = chooseSurfaceFormat(swapchain_support.formats.?);
    const present_mode = choosePresentMode(swapchain_support.present_modes.?);
    const extent = chooseSwapExtent(swapchain_support.capabilities, window);
    var image_count = swapchain_support.capabilities.min_image_count + 1;
    if (swapchain_support.capabilities.min_image_count > 0 and
        image_count > swapchain_support.capabilities.max_image_count)
    {
        image_count = swapchain_support.capabilities.min_image_count;
    }

    const queue_family_indices = [_]u32{
        queue_families.graphics_family.?,
        queue_families.present_family.?,
    };
    const swapchain_create_info = vk.SwapchainCreateInfoKHR{
        .surface = impl.surface,
        .min_image_count = image_count,
        .image_format = surface_format.format,
        .image_color_space = surface_format.color_space,
        .image_extent = extent,
        .image_array_layers = 1,
        .image_usage = .{ .color_attachment_bit = true },

        .image_sharing_mode = if (queue_families.graphics_family.? != queue_families.present_family.?)
            .concurrent
        else
            .exclusive,

        .queue_family_index_count = if (queue_families.graphics_family.? != queue_families.present_family.?)
            2
        else
            0,

        .p_queue_family_indices = if (queue_families.graphics_family.? != queue_families.present_family.?)
            (&queue_family_indices).ptr
        else
            null,

        .pre_transform = swapchain_support.capabilities.current_transform,
        .composite_alpha = .{ .opaque_bit_khr = true },
        .present_mode = present_mode,
        .clipped = .true,
    };
    impl.swapchain = try impl.vkd.createSwapchainKHR(impl.device, &swapchain_create_info, null);

    std.log.info("Vulkan fully initialized", .{});
}

/// Deinitializes the GPU. This doesn't free GPU resources, you must manage them manually before calling this function. `initRendering` also has a matching `deinitRendering` that you have to call.
pub fn deinit() void {
    impl.vkd.destroySwapchainKHR(impl.device, impl.swapchain, null);
    impl.vkd.destroyDevice(impl.device, null);
    impl.vki.destroySurfaceKHR(impl.instance, impl.surface, null);
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
        var score: u64 = 0;

        // TODO make these accessible to everything else
        const props = impl.vki.getPhysicalDeviceProperties(device);
        // const features = impl.vki.getPhysicalDeviceFeatures(device); TODO use it probably
        const memory = impl.vki.getPhysicalDeviceMemoryProperties(device);
        const queue_families = try findQueueFamilies(device);

        var ext_count: u32 = 0;
        _ = try impl.vki.enumerateDeviceExtensionProperties(device, null, &ext_count, null);
        const exts = try scratch.allocator().alloc(vk.ExtensionProperties, ext_count);
        _ = try impl.vki.enumerateDeviceExtensionProperties(device, null, &ext_count, exts.ptr);

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
            std.log.info("- unsupported, queue families isn't complete:", .{});
            std.log.info("  - graphics family: {s}", .{
                if (queue_families.graphics_family == null) "unsupported" else "ok",
            });
        }

        var required_exts_supported: u32 = 0;
        for (exts) |ext| {
            // get the real length otherwise std.mem.eql shits itself
            const ext_len = util.strnlen(&ext.extension_name, vk.MAX_EXTENSION_NAME_SIZE);
            const ext_name = ext.extension_name[0..ext_len];

            for (required_device_exts) |required_ext| {
                if (std.mem.eql(u8, ext_name, required_ext[0..ext_len])) {
                    required_exts_supported += 1;
                }
            }
        }
        if (required_exts_supported < required_device_exts.len) {
            supported = false;
            std.log.info("- unsupported, doesn't have required device extensions", .{});
        } else {
            const swapchain_support_details = try querySwapchainSupport(
                scratch.allocator(),
                device,
                impl.surface,
            );

            if (swapchain_support_details.formats == null) {
                supported = false;
            }
            if (swapchain_support_details.present_modes == null) {
                supported = false;
            }
            if (!supported) {
                std.log.info("- unsupported, doesn't have any swapchain formats or present modes", .{});
            }
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
    graphics_family: ?u32 = null,
    present_family: ?u32 = null,

    pub fn isComplete(queue_families: QueueFamilies) bool {
        return queue_families.graphics_family != null and queue_families.present_family != null;
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
            indices.graphics_family = @intCast(i);
        }

        const present_support = try impl.vki.getPhysicalDeviceSurfaceSupportKHR(
            dev,
            @intCast(i),
            impl.surface,
        );
        if (present_support == .true) {
            indices.present_family = @intCast(i);
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

const SwapchainSupportDetails = struct {
    capabilities: vk.SurfaceCapabilitiesKHR = undefined,
    formats: ?[]vk.SurfaceFormatKHR = null,
    present_modes: ?[]vk.PresentModeKHR = null,
};

fn querySwapchainSupport(
    alloc: std.mem.Allocator,
    dev: vk.PhysicalDevice,
    surface: vk.SurfaceKHR,
) !SwapchainSupportDetails {
    var details = SwapchainSupportDetails{};
    details.capabilities = try impl.vki.getPhysicalDeviceSurfaceCapabilitiesKHR(dev, surface);

    var format_count: u32 = 0;
    _ = try impl.vki.getPhysicalDeviceSurfaceFormatsKHR(dev, surface, &format_count, null);
    if (format_count != 0) {
        details.formats = try alloc.alloc(vk.SurfaceFormatKHR, format_count);
        _ = try impl.vki.getPhysicalDeviceSurfaceFormatsKHR(
            dev,
            surface,
            &format_count,
            details.formats.?.ptr,
        );
    }

    var present_mode_count: u32 = 0;
    _ = try impl.vki.getPhysicalDeviceSurfacePresentModesKHR(dev, surface, &present_mode_count, null);
    if (present_mode_count != 0) {
        details.present_modes = try alloc.alloc(vk.PresentModeKHR, present_mode_count);
        _ = try impl.vki.getPhysicalDeviceSurfacePresentModesKHR(
            dev,
            surface,
            &present_mode_count,
            details.present_modes.?.ptr,
        );
    }

    return details;
}

fn chooseSurfaceFormat(formats: []const vk.SurfaceFormatKHR) vk.SurfaceFormatKHR {
    const preferred = vk.SurfaceFormatKHR{
        .format = .b8g8r8a8_srgb,
        .color_space = .srgb_nonlinear_khr,
    };

    for (formats) |format| {
        if (std.meta.eql(format, preferred)) {
            return preferred;
        }
    }

    // probably good enough
    return formats[0];
}

fn choosePresentMode(present_modes: []const vk.PresentModeKHR) vk.PresentModeKHR {
    for (present_modes) |present_mode| {
        if (present_mode == .mailbox_khr) {
            return .mailbox_khr;
        }
    }
    // only one guaranteed to be supported
    return .fifo_khr;
}

fn chooseSwapExtent(capabilities: vk.SurfaceCapabilitiesKHR, window: win.Window) vk.Extent2D {
    // idk this entire function is stolen
    if (capabilities.current_extent.width != std.math.maxInt(u32)) {
        return capabilities.current_extent;
    } else {
        var win_width: c_int = 0;
        var win_height: c_int = 0;
        glfw.getFramebufferSize(window.__handle.?, &win_width, &win_height);

        const extent = vk.Extent2D{
            .width = @intCast(win_width),
            .height = @intCast(win_height),
        };
        return .{
            .width = std.math.clamp(
                extent.width,
                capabilities.min_image_extent.width,
                capabilities.max_image_extent.width,
            ),
            .height = std.math.clamp(
                extent.height,
                capabilities.min_image_extent.height,
                capabilities.max_image_extent.height,
            ),
        };
    }
}
