//! API-specific state, shouldn't be used outside of the `gpu` module
const vk = @import("vulkan");

// we have to use these to call vulkan functions i guess
pub var vkb: vk.BaseWrapper = undefined;
pub var vki: vk.InstanceWrapper = undefined;
pub var vkd: vk.DeviceWrapper = undefined;

pub var instance: vk.Instance = .null_handle;
pub var device: vk.Device = .null_handle;

pub var graphics_queue: vk.Queue = .null_handle;
pub var present_queue: vk.Queue = .null_handle;

pub var surface: vk.SurfaceKHR = .null_handle;
pub var swapchain: vk.SwapchainKHR = .null_handle;
pub var swapchain_images: []vk.Image = &.{};
pub var swapchain_image_views: []vk.ImageView = &.{};
pub var swapchain_image_format: vk.Format = undefined;
pub var swapchain_extent: vk.Extent2D = undefined;
