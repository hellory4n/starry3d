//! Gets information about the GPU and stuff
const std = @import("std");
const vk = @import("vulkan");
const util = @import("../util.zig");

/// Queries information about the GPU and stuff. All `Device`s can be assumed to have graphics support
/// (if there's none then the engine crashes)
pub const Device = struct {
    /// The GPU's full legal birth name.
    name: []const u8,
    vendor_id: u32,
    device_id: u32,
    type: DeviceType,

    /// Maximimum dimension (width) that is guaranteed to be supported by all 1D images.
    max_image_dimension_1d: u32,
    /// Maximimum dimension (width or height) that is guaranteed to be supported by all 2D images.
    max_image_dimension_2d: u32,
    /// Maximimum dimension (width, height, or depth) that is guaranteed to be supported by all 3D images.
    max_image_dimension_3d: u32,
    /// The maximum size, in bytes, of the pool of push constant memory
    max_push_constants_size: u32,
    /// The maximum amount of memory allocations that can simultaneously exist
    max_memory_allocations: u32,
    /// The maximum amount of samplers that can simultaneously exist
    max_samplers: u32,
    /// The maximum amount of uniform buffers that can be accessible to a single shader stage
    max_uniform_buffers_per_stage: u32,
    /// The maximum amount of storage buffers that can be accessible to a single shader stage
    max_storage_buffers_per_stage: u32,
    /// The maximum amount of sampled images that can be accessible to a single shader stage
    max_sampled_images_per_stage: u32,

    /// Returns the current device, or crashes because you called this before Vulkan gets initialized
    /// dumbass.
    pub fn current() Device {
        if (current_dev) |current_fr| {
            return current_fr;
        }
        std.log.err("can't get GPU, vulkan hasn't been initialized yet", .{});
        @panic("tragic");
    }

    /// Internal crap used by the GPU module
    pub fn isVkPhysicalDeviceSupported(
        props: vk.PhysicalDeviceProperties,
        features: vk.PhysicalDeviceFeatures,
        memory: vk.PhysicalDeviceMemoryProperties,
    ) bool {}

    /// Internal crap used by the GPU module
    pub fn fromVkPhysicalDevice(
        props: vk.PhysicalDeviceProperties,
        features: vk.PhysicalDeviceFeatures,
        memory: vk.PhysicalDeviceMemoryProperties,
    ) Device {
        return .{
            .name = props.device_name[0..util.strnlen(props.device_name, vk.MAX_PHYSICAL_DEVICE_NAME_SIZE)],
            .vendor_id = props.vendor_id,
            .device_id = props.device_id,
            .type = switch (props.device_type) {
                .integrated_gpu => .integrated,
                .discrete_gpu => .dedicated,
                .virtual_gpu => .virtual,
                .cpu => .cpu,
                else => .other,
            },

            .max_image_dimension_1d = props.limits.max_image_dimension_1d,
            .max_image_dimension_2d = props.limits.max_image_dimension_2d,
            .max_image_dimension_3d = props.limits.max_image_dimension_3d,
            .max_push_constants_size = props.limits.max_push_constants_size,
            .max_memory_allocations = props.limits.max_memory_allocation_count,
            .max_samplers = props.limits.max_sampler_allocation_count,
            .max_uniform_buffers_per_stage = props.limits.max_per_stage_descriptor_uniform_buffers,
            .max_storage_buffers_per_stage = props.limits.max_per_stage_descriptor_storage_buffers,
            .max_sampled_images_per_stage = props.limits.max_per_stage_descriptor_sampled_images,
        };
    }
};

pub const DeviceType = enum {
    /// It's a mystery.
    other,
    /// It's a bit like a GPU, except integrated.
    integrated,
    /// Big gpu
    dedicated,
    /// Used inside VMs
    virtual,
    /// Not even a GPU, also absolute dogshit
    cpu,
};

pub var current_dev: ?Device = null;
