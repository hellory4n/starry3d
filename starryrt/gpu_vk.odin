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
	instance:              vk.Instance,
	physical_device:       vk.PhysicalDevice,
	surface:               vk.SurfaceKHR,
	device:                vk.Device,
	graphics_queue_family: u32,
	compute_queue_family:  u32,
	transfer_queue_family: u32,
	vkb:                   struct {
		instance:        ^vkb.Instance,
		physical_device: ^vkb.Physical_Device,
		device:          ^vkb.Device,
	},
	device_info:           Gpu_Info,
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

@(private)
vk_new_gpu :: proc(
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
	if !is_vk_ok(vk_err) {
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

	// queue fuckery
	gpu.graphics_queue_family, vkb_err = vkb.device_get_queue_index(gpu.vkb.device, .Graphics)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}
	gpu.compute_queue_family, vkb_err = vkb.device_get_queue_index(gpu.vkb.device, .Compute)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}
	gpu.transfer_queue_family, vkb_err = vkb.device_get_queue_index(gpu.vkb.device, .Transfer)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}

	return
}

@(private)
vk_free_gpu :: proc(gpu: ^Gpu)
{
	vk.DestroySurfaceKHR(gpu.instance, gpu.surface, nil)
	vkb.destroy_device(gpu.vkb.device)

	vkb.destroy_physical_device(gpu.vkb.physical_device)
	vkb.destroy_instance(gpu.vkb.instance)

	gpu^ = {}
}

@(private)
vk_query_gpu_info :: proc(gpu: ^Gpu) -> (info: Gpu_Info)
{
	info.name = gpu.vkb.physical_device.name

	for i: u32 = 0; i < gpu.vkb.physical_device.memory_properties.memoryHeapCount; i += 1 {
		info.total_vram += u64(
			gpu.vkb.physical_device.memory_properties.memoryHeaps[i].size,
		)
	}

	info.max_image_2d_size.x = gpu.vkb.physical_device.properties.limits.maxImageDimension2D
	info.max_image_2d_size.y = gpu.vkb.physical_device.properties.limits.maxImageDimension2D
	info.max_storage_buffer_size = u64(
		gpu.vkb.physical_device.properties.limits.maxStorageBufferRange,
	)
	info.max_storage_buffer_bindings =
		gpu.vkb.physical_device.properties.limits.maxDescriptorSetStorageBuffers
	info.max_compute_workgroup_size =
		gpu.vkb.physical_device.properties.limits.maxComputeWorkGroupCount
	info.max_compute_workgroup_threads =
		gpu.vkb.physical_device.properties.limits.maxComputeWorkGroupInvocations

	info.shader_f64 = bool(gpu.vkb.physical_device.features.shaderFloat64)
	info.shader_i64 = bool(gpu.vkb.physical_device.features.shaderInt64)
	info.shader_i16 = bool(gpu.vkb.physical_device.features.shaderInt16)

	return info
}

Vk_Command_Port :: struct {
	queue: vk.Queue,
}

@(private)
vk_get_command_port :: proc(
	gpu: ^Gpu,
	type: Command_Port_Type,
) -> (
	port: Command_Port,
	err: Gpu_Error,
)
{
	vkb_queue_type: vkb.Queue_Type
	switch type {
	case .GRAPHICS_AND_TRANSFER:
		vkb_queue_type = .Graphics
	case .COMPUTE_AND_TRANSFER:
		vkb_queue_type = .Compute
	case .TRANSFER_ONLY:
		vkb_queue_type = .Transfer
	}

	vkb_err: vkb.Error
	port.queue, vkb_err = vkb.device_get_queue(gpu.vkb.device, vkb_queue_type)
	if vkb_err != nil {
		err = vkb_error_to_gpu_error(vkb_err)
		return
	}

	return
}

Vk_Command_Buffer :: struct {
	buffer: vk.CommandBuffer,
	pool:   vk.CommandPool,
}

@(private)
vk_new_command_buffer :: proc(
	gpu: ^Gpu,
	port: Command_Port_Type,
	lifespan: Command_Buffer_Lifespan,
) -> (
	cmds: Command_Buffer,
	err: Gpu_Error,
)
{
	queue_family_idx: u32
	switch port {
	case .GRAPHICS_AND_TRANSFER:
		queue_family_idx = gpu.graphics_queue_family
	case .COMPUTE_AND_TRANSFER:
		queue_family_idx = gpu.compute_queue_family
	case .TRANSFER_ONLY:
		queue_family_idx = gpu.transfer_queue_family
	}

	cmd_pool_info := vk.CommandPoolCreateInfo {
		sType            = .COMMAND_POOL_CREATE_INFO,
		flags            = vk.CommandPoolCreateFlags{.TRANSIENT} if lifespan == .SHORT_LIVED else {},
		queueFamilyIndex = queue_family_idx,
	}
	vk_err := vk.CreateCommandPool(gpu.device, &cmd_pool_info, nil, &cmds.pool)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}

	cmd_alloc_info := vk.CommandBufferAllocateInfo {
		sType              = .COMMAND_BUFFER_ALLOCATE_INFO,
		commandPool        = cmds.pool,
		commandBufferCount = 1,
		level              = .PRIMARY,
	}
	vk_err = vk.AllocateCommandBuffers(gpu.device, &cmd_alloc_info, &cmds.buffer)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}

	return
}

@(private)
vk_free_command_buffer :: proc(gpu: ^Gpu, cmds: ^Command_Buffer)
{
	vk.DestroyCommandPool(gpu.device, cmds.pool, nil)
}

@(private)
vk_clear_command_buffer :: proc(gpu: ^Gpu, cmds: ^Command_Buffer)
{
	vk.ResetCommandPool(gpu.device, cmds.pool, {})
}

@(private)
vk_start_commands :: proc(
	gpu: ^Gpu,
	cmds: ^Command_Buffer,
	used_once: bool = true, // as in this specific state of commands is submitted once
	used_simultaneously: bool = false,
) -> (
	err: Gpu_Error,
)
{
	flags: vk.CommandBufferUsageFlags
	if used_once {
		flags |= {.ONE_TIME_SUBMIT}
	}
	if used_simultaneously {
		flags |= {.SIMULTANEOUS_USE}
	}

	begin_info := vk.CommandBufferBeginInfo {
		sType = .COMMAND_BUFFER_BEGIN_INFO,
		flags = {},
	}

	vk_err := vk.BeginCommandBuffer(cmds.buffer, &begin_info)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}

	return
}

@(private)
vk_end_commands :: proc(gpu: ^Gpu, cmds: ^Command_Buffer) -> (err: Gpu_Error)
{
	vk_err := vk.EndCommandBuffer(cmds.buffer)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}
	return
}

@(private)
vk_submit_commands :: proc(
	gpu: ^Gpu,
	cmds: ^Command_Buffer,
	port: ^Command_Port,
	signal_semaphore: ^Semaphore,
	wait_semaphore: ^Semaphore,
) -> (
	err: Gpu_Error,
)
{
	cmd_info := vk.CommandBufferSubmitInfo {
		sType         = .COMMAND_BUFFER_SUBMIT_INFO,
		commandBuffer = cmds.buffer,
	}
	signal_info := vk.SemaphoreSubmitInfo {
		sType     = .SEMAPHORE_SUBMIT_INFO,
		semaphore = signal_semaphore.semaphore,
		stageMask = {.ALL_GRAPHICS}, // FIXME most definitely wrong but im tired
		value     = 1,
	}
}

@(private)
vk_wait_for_gpu :: proc(gpu: ^Gpu)
{
	vk.DeviceWaitIdle(gpu.device)
}

Vk_Fence :: struct {
	fence: vk.Fence,
}

@(private)
vk_new_fence :: proc(gpu: ^Gpu) -> (fence: Fence, err: Gpu_Error)
{
	fence_info := vk.FenceCreateInfo {
		sType = .FENCE_CREATE_INFO,
		flags = {.SIGNALED},
	}
	vk_err := vk.CreateFence(gpu.device, &fence_info, nil, &fence.fence)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}
	return
}

@(private)
vk_free_fence :: proc(gpu: ^Gpu, fence: ^Fence)
{
	vk.DestroyFence(gpu.device, fence.fence, nil)
}

@(private)
vk_wait_for_fence :: proc(gpu: ^Gpu, fence: ^Fence, timeout_ns: u64 = 1e9) -> (err: Gpu_Error)
{
	vk_err := vk.WaitForFences(gpu.device, 1, &fence.fence, true, timeout_ns)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}

	// reset immediately otherwise you can't do shit with it
	// TODO is this stupid?
	vk_err = vk.ResetFences(gpu.device, 1, &fence.fence)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}

	return
}

@(private)
vk_is_fence_running :: proc(gpu: ^Gpu, fence: ^Fence) -> bool
{
	// TODO no idea if this works
	vk_err := vk.WaitForFences(gpu.device, 1, &fence.fence, true, 0)
	if vk_err == .NOT_READY || vk_err == .TIMEOUT {
		return true
	} else if vk_err == .SUCCESS {
		return false
	} else if !is_vk_ok(vk_err) {
		return false
	} else {
		// idk lol
		return false
	}
}

Vk_Semaphore :: struct {
	semaphore: vk.Semaphore,
}

@(private)
vk_new_semaphore :: proc(gpu: ^Gpu) -> (semaphore: Semaphore, err: Gpu_Error)
{
	semaphore_info := vk.SemaphoreCreateInfo {
		sType = .SEMAPHORE_CREATE_INFO,
		flags = {},
	}
	vk_err := vk.CreateSemaphore(gpu.device, &semaphore_info, nil, &semaphore.semaphore)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}
	return
}

@(private)
vk_free_semaphore :: proc(gpu: ^Gpu, semaphore: ^Semaphore)
{
	vk.DestroySemaphore(gpu.device, semaphore.semaphore, nil)
}

Vk_Gpu_Image :: struct {
	image: vk.Image,
}

@(private)
vk_transition_image :: proc(
	cmd: vk.CommandBuffer,
	image: vk.Image,
	current_layout: vk.ImageLayout,
	new_layout: vk.ImageLayout,
)
{
	// TODO learn wtf is this shit
	image_barrier := vk.ImageMemoryBarrier2 {
		sType = .IMAGE_MEMORY_BARRIER_2,
	}

	image_barrier.srcStageMask = {.ALL_COMMANDS}
	image_barrier.srcAccessMask = {.MEMORY_WRITE}
	image_barrier.dstStageMask = {.ALL_COMMANDS}
	image_barrier.dstAccessMask = {.MEMORY_WRITE, .MEMORY_READ}

	image_barrier.oldLayout = current_layout
	image_barrier.newLayout = new_layout

	aspect_mask: vk.ImageAspectFlags =
		{.DEPTH} if new_layout == .DEPTH_ATTACHMENT_OPTIMAL else {.COLOR}

	image_barrier.subresourceRange = vk.ImageSubresourceRange {
		aspectMask = aspect_mask,
		levelCount = vk.REMAINING_MIP_LEVELS,
		layerCount = vk.REMAINING_ARRAY_LAYERS,
	}
	image_barrier.image = image

	dep_info := vk.DependencyInfo {
		sType                   = .DEPENDENCY_INFO,
		imageMemoryBarrierCount = 1,
		pImageMemoryBarriers    = &image_barrier,
	}

	vk.CmdPipelineBarrier2(cmd, &dep_info)
}

Vk_Swapchain :: struct {
	swapchain:      vk.SwapchainKHR,
	extent:         vk.Extent2D,
	format:         vk.Format,
	images:         []vk.Image,
	image_views:    []vk.ImageView,
	vkb:            struct {
		swapchain: ^vkb.Swapchain,
	},
	semaphore:      Semaphore,
	next_image_idx: u32,
}

@(private)
vk_new_swapchain :: proc(gpu: ^Gpu, size: [2]u32) -> (swapchain: Swapchain, err: Gpu_Error)
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

	swapchain.semaphore = vk_new_semaphore(gpu) or_return

	return
}

@(private)
vk_free_swapchain :: proc(gpu: ^Gpu, swapchain: ^Swapchain)
{
	vk_free_semaphore(gpu, &swapchain.semaphore)
	vkb.swapchain_destroy_image_views(swapchain.vkb.swapchain, swapchain.image_views)
	vkb.destroy_swapchain(swapchain.vkb.swapchain)
	delete(swapchain.image_views)
	delete(swapchain.images)
	swapchain^ = {}
}

@(private)
vk_next_swapchain_image :: proc(
	gpu: ^Gpu,
	swapchain: ^Swapchain,
) -> (
	img: Gpu_Image,
	err: Gpu_Error,
)
{
	vk_err := vk.AcquireNextImageKHR(
		gpu.device,
		swapchain.swapchain,
		1e9,
		swapchain.semaphore.semaphore,
		0,
		&swapchain.next_image_idx,
	)
	if !is_vk_ok(vk_err) {
		err = vk_error_to_gpu_error(vk_err)
		return
	}

	img = Gpu_Image {
		image = swapchain.images[swapchain.next_image_idx],
	}
	return
}

@(private)
vk_cmd_start_render_pass :: proc(
	cmd: ^Command_Buffer,
	color_target: Gpu_Image,
	clear_color: Maybe([4]f32) = nil,
)
{
	vk_transition_image(cmd.buffer, color_target.image, .UNDEFINED, .GENERAL)

	if clear_color != nil {
		clear_color_fr := clear_color.([4]f32)
		clear_color_frfr := vk.ClearColorValue {
			float32 = clear_color_fr,
		}

		clear_range := vk.ImageSubresourceRange {
			aspectMask = {.COLOR},
			levelCount = vk.REMAINING_MIP_LEVELS,
			layerCount = vk.REMAINING_ARRAY_LAYERS,
		}

		vk.CmdClearColorImage(
			cmd.buffer,
			color_target.image,
			.GENERAL,
			&clear_color_frfr,
			1,
			&clear_range,
		)
	}
}

@(private)
vk_cmd_end_render_pass :: proc(cmd: ^Command_Buffer, color_target: Gpu_Image)
{
	vk_transition_image(cmd.buffer, color_target.image, .GENERAL, .PRESENT_SRC_KHR)
}
