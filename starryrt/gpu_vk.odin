package starryrt

import vkb "../thirdparty/vkbootstrap"
import "core:log"
import "vendor:glfw"
import vk "vendor:vulkan"

MIN_VULKAN_VERSION :: vk.API_VERSION_1_3
REQUIRED_VULKAN_12_FEATURES :: vk.PhysicalDeviceVulkan12Features {
	bufferDeviceAddress = true,
	descriptorIndexing  = true,
}
REQUIRED_VULKAN_13_FEATURES :: vk.PhysicalDeviceVulkan13Features {
	dynamicRendering = true,
	synchronization2 = true,
}

Vk_Gpu :: struct {
	instance:        vk.Instance,
	physical_device: vk.PhysicalDevice,
	surface:         vk.SurfaceKHR,
	device:          vk.Device,
	vkb:             struct {
		instance:        ^vkb.Instance,
		physical_device: ^vkb.Physical_Device,
		device:          ^vkb.Device,
	},
	device_info:     Gpu_Info,
}

@(private)
is_vk_ok :: proc(src: vk.Result) -> bool
{
	// TODO may be questionable
	// this is based on the official vulkan docs
	switch src {
	case .SUCCESS:
	case .NOT_READY:
	case .TIMEOUT:
	case .EVENT_SET:
	case .EVENT_RESET:
	case .INCOMPLETE:
	case .SUBOPTIMAL_KHR:
	case .THREAD_IDLE_KHR:
	case .THREAD_DONE_KHR:
	case .OPERATION_DEFERRED_KHR:
	case .OPERATION_NOT_DEFERRED_KHR:
	case .PIPELINE_COMPILE_REQUIRED:
	case .PIPELINE_BINARY_MISSING_KHR:
	case .INCOMPATIBLE_SHADER_BINARY_EXT:
		return true
	case .ERROR_OUT_OF_HOST_MEMORY:
	case .ERROR_OUT_OF_DEVICE_MEMORY:
	case .ERROR_INITIALIZATION_FAILED:
	case .ERROR_DEVICE_LOST:
	case .ERROR_MEMORY_MAP_FAILED:
	case .ERROR_LAYER_NOT_PRESENT:
	case .ERROR_EXTENSION_NOT_PRESENT:
	case .ERROR_FEATURE_NOT_PRESENT:
	case .ERROR_INCOMPATIBLE_DRIVER:
	case .ERROR_TOO_MANY_OBJECTS:
	case .ERROR_FORMAT_NOT_SUPPORTED:
	case .ERROR_FRAGMENTED_POOL:
	case .ERROR_SURFACE_LOST_KHR:
	case .ERROR_NATIVE_WINDOW_IN_USE_KHR:
	case .ERROR_OUT_OF_DATE_KHR:
	case .ERROR_INCOMPATIBLE_DISPLAY_KHR:
	case .ERROR_INVALID_SHADER_NV:
	case .ERROR_OUT_OF_POOL_MEMORY:
	case .ERROR_INVALID_EXTERNAL_HANDLE:
	case .ERROR_FRAGMENTATION:
	case .ERROR_INVALID_DEVICE_ADDRESS_EXT:
	case .ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT:
	case .ERROR_VALIDATION_FAILED_EXT:
	case .ERROR_COMPRESSION_EXHAUSTED_EXT:
	case .ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR:
	case .ERROR_INVALID_VIDEO_STD_PARAMETERS_KHR:
	case .ERROR_NOT_PERMITTED:
	case .ERROR_NOT_ENOUGH_SPACE_KHR:
	case .ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT:
	case .ERROR_UNKNOWN:
		return false
	}
	unreachable()
}

@(private)
vk_error_to_gpu_error :: proc(src: vk.Result) -> Gpu_Error
{
	switch src {
	case .SUCCESS:
	case .NOT_READY:
	case .TIMEOUT:
	case .EVENT_SET:
	case .EVENT_RESET:
	case .INCOMPLETE:
	case .SUBOPTIMAL_KHR:
	case .THREAD_IDLE_KHR:
	case .THREAD_DONE_KHR:
	case .OPERATION_DEFERRED_KHR:
	case .OPERATION_NOT_DEFERRED_KHR:
	case .PIPELINE_COMPILE_REQUIRED:
	case .PIPELINE_BINARY_MISSING_KHR:
	case .INCOMPATIBLE_SHADER_BINARY_EXT:
		return .OK
	case .ERROR_OUT_OF_HOST_MEMORY:
		return .OUT_OF_CPU_MEMORY
	case .ERROR_OUT_OF_DEVICE_MEMORY:
		return .OUT_OF_GPU_MEMORY
	case .ERROR_INITIALIZATION_FAILED:
		return .DRIVER_ERROR
	case .ERROR_DEVICE_LOST:
		return .HARDWARE_ERROR
	case .ERROR_MEMORY_MAP_FAILED:
		return .DRIVER_ERROR
	case .ERROR_LAYER_NOT_PRESENT:
	case .ERROR_EXTENSION_NOT_PRESENT:
	case .ERROR_FEATURE_NOT_PRESENT:
	case .ERROR_INCOMPATIBLE_DRIVER:
	case .ERROR_FORMAT_NOT_SUPPORTED:
		return .INCOMPATIBLE_GPU
	case .ERROR_TOO_MANY_OBJECTS:
		return .TOO_MANY_HANDLES
	case .ERROR_FRAGMENTED_POOL:
		return .OUT_OF_GPU_MEMORY
	case .ERROR_SURFACE_LOST_KHR:
	case .ERROR_NATIVE_WINDOW_IN_USE_KHR:
	case .ERROR_OUT_OF_DATE_KHR:
	case .ERROR_INCOMPATIBLE_DISPLAY_KHR:
	case .ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT:
		return .WINDOW_ERROR
	case .ERROR_INVALID_SHADER_NV:
		return .SHADER_COMPILATION_FAILED
	case .ERROR_OUT_OF_POOL_MEMORY:
		return .OUT_OF_GPU_MEMORY
	case .ERROR_INVALID_EXTERNAL_HANDLE:
		return .BROKEN_HANDLE
	case .ERROR_FRAGMENTATION:
		return .OUT_OF_GPU_MEMORY
	case .ERROR_INVALID_DEVICE_ADDRESS_EXT:
		return .INVALID_ADDRESS
	case .ERROR_VALIDATION_FAILED_EXT:
		return .DRIVER_ERROR
	case .ERROR_COMPRESSION_EXHAUSTED_EXT:
		return .OUT_OF_GPU_MEMORY // questionable
	case .ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR:
	case .ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR:
		return .INCOMPATIBLE_GPU
	case .ERROR_INVALID_VIDEO_STD_PARAMETERS_KHR:
		return .DRIVER_ERROR
	case .ERROR_NOT_PERMITTED:
		return .DRIVER_ERROR
	case .ERROR_NOT_ENOUGH_SPACE_KHR:
		return .OUT_OF_CPU_MEMORY
	case .ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT:
	case .ERROR_UNKNOWN:
		return .UNKNOWN
	}
	unreachable()
}

@(private)
vkb_error_to_gpu_error :: proc(src: vkb.Error) -> Gpu_Error
{
	switch v in src {
	case vkb.General_Error:
		return vk_error_to_gpu_error(v.result)
	case vkb.Instance_Error:
		log.errorf("%s", v.kind)
		return vk_error_to_gpu_error(v.result)
	case vkb.Physical_Device_Error:
		log.errorf("%s", v.kind)
		return .INCOMPATIBLE_GPU
	case vkb.Queue_Error:
		log.errorf("%s", v.kind)
		return .INCOMPATIBLE_GPU
	case vkb.Device_Error:
		log.errorf("%s", v.kind)
		return vk_error_to_gpu_error(v.result)
	case vkb.Swapchain_Error:
		log.errorf("%s", v.kind)
		return vk_error_to_gpu_error(v.result)
	case vkb.Surface_Support_Error:
		log.errorf("%s", v.kind)
		return .INCOMPATIBLE_GPU
	}
	unreachable()
}

vk_init_gpu :: proc(
	window: ^Window,
	app_name: string,
	engine_name: string,
	app_version: [3]u32,
	engine_version: [3]u32,
	min_required_device: Maybe(Gpu_Info),
) -> (
	gpu: Gpu,
	err: Gpu_Error,
)
{
	// TODO it'd be nice to print the GPU info when it's incompatible
	// but idk if vkbootstrap gives that information

	// instance fuckery
	instance_builder := vkb.create_instance_builder()
	defer vkb.destroy_instance_builder(instance_builder)

	vkb.instance_builder_require_api_version(instance_builder, MIN_VULKAN_VERSION)
	vkb.instance_builder_set_app_name(instance_builder, app_name)
	vkb.instance_builder_set_app_version(
		instance_builder,
		vk.MAKE_VERSION(app_version.x, app_version.y, app_version.z),
	)
	vkb.instance_builder_set_engine_name(instance_builder, engine_name)
	vkb.instance_builder_set_engine_version(
		instance_builder,
		vk.MAKE_VERSION(engine_version.x, engine_version.y, engine_version.z),
	)

	when ODIN_DEBUG {
		vkb.instance_builder_request_validation_layers(instance_builder)

		// TODO it'd be nice to have a debug messenger here but i don't really care
		// + it's only on debug so you don't really need these errors to go into log.txt?
	}

	vkb_err: vkb.Error
	gpu.vkb.instance, vkb_err = vkb.instance_builder_build(instance_builder)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}
	gpu.instance = gpu.vkb.instance.instance
	defer if err != .OK {
		vkb.destroy_instance(gpu.vkb.instance)
	}

	// surface fuckery
	vk_err := glfw.CreateWindowSurface(gpu.instance, window.glfw, nil, &gpu.surface)
	if vk_err != .SUCCESS {
		err = vk_error_to_gpu_error(vk_err)
		return
	}

	// physical device fuckery
	selector := vkb.create_physical_device_selector(gpu.vkb.instance)
	defer vkb.destroy_physical_device_selector(selector)

	vkb.physical_device_selector_set_minimum_version(selector, MIN_VULKAN_VERSION)
	vkb.physical_device_selector_set_required_features_12(
		selector,
		REQUIRED_VULKAN_12_FEATURES,
	)
	vkb.physical_device_selector_set_required_features_13(
		selector,
		REQUIRED_VULKAN_13_FEATURES,
	)
	vkb.physical_device_selector_set_surface(selector, gpu.surface)

	gpu.vkb.physical_device, vkb_err = vkb.physical_device_selector_select(selector)
	if vkb_err != nil {
		err = .INCOMPATIBLE_GPU
		return
	}
	gpu.vk.physical_device = gpu.vkb.physical_device.physical_device
	defer if err != .OK {
		vkb.destroy_physical_device(gpu.vkb.physical_device)
	}

	// device fuckery
	device_builder := vkb.create_device_builder(gpu.vkb.physical_device)
	defer vkb.destroy_device_builder(device_builder)

	gpu.vkb.device, vkb_err = vkb.device_builder_build(device_builder)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}
	defer if err != .OK {
		vkb.destroy_device(gpu.vkb.device)
	}
	gpu.device = gpu.vkb.device.device

	return
}

vk_free_gpu :: proc(gpu: ^Gpu)
{
	vk.DestroySurfaceKHR(gpu.instance, gpu.surface, nil)
	vkb.destroy_device(gpu.vkb.device)

	vkb.destroy_physical_device(gpu.vkb.physical_device)
	vkb.destroy_instance(gpu.vkb.instance)

	gpu^ = {}
}

// vk_gpu_query :: proc() -> Gpu_Info
// {  }

Vk_Swapchain :: struct {
	swapchain:   vk.SwapchainKHR,
	extent:      vk.Extent2D,
	format:      vk.Format,
	images:      []vk.Image,
	image_views: []vk.ImageView,
	vkb:         struct {
		swapchain: ^vkb.Swapchain,
	},
}

vk_init_swapchain :: proc(gpu: ^Gpu, size: [2]u32) -> (swapchain: Swapchain, err: Gpu_Error)
{
	builder := vkb.create_swapchain_builder(gpu.vkb.device)
	defer vkb.destroy_swapchain_builder(builder)

	vkb.swapchain_builder_set_desired_format(
		builder,
		{format = .B8G8R8_UNORM, colorSpace = .SRGB_NONLINEAR},
	)
	vkb.swapchain_builder_set_desired_present_mode(builder, .MAILBOX)
	vkb.swapchain_builder_set_desired_extent(builder, size.x, size.y)
	vkb.swapchain_builder_set_image_usage_flags(builder, {.TRANSFER_DST, .COLOR_ATTACHMENT})

	vkb_err: vkb.Error
	swapchain.vkb.swapchain, vkb_err = vkb.swapchain_builder_build(builder)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}
	swapchain.swapchain = swapchain.vkb.swapchain.swapchain // insanity
	swapchain.extent = swapchain.vkb.swapchain.extent

	swapchain.images, vkb_err = vkb.swapchain_get_images(swapchain.vkb.swapchain)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}
	swapchain.image_views, vkb_err = vkb.swapchain_get_image_views(swapchain.vkb.swapchain)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}

	return
}

vk_free_swapchain :: proc(swapchain: ^Swapchain)
{
	vkb.swapchain_destroy_image_views(swapchain.vkb.swapchain, swapchain.image_views)
	vkb.destroy_swapchain(swapchain.vkb.swapchain)
	delete(swapchain.image_views)
	delete(swapchain.images)
}
