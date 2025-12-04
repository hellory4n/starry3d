//! API-specific state, shouldn't be used outside of the `gpu` module
const vk = @import("vulkan");

// we have to use these to call vulkan functions i guess
pub var vkb: vk.BaseWrapper = undefined;
pub var vki: vk.InstanceWrapper = undefined;
pub var vkd: vk.DeviceWrapper = undefined;

pub var instance: vk.Instance = undefined;
pub var device: vk.Device = undefined;
pub var graphics_queue: vk.Queue = undefined;
