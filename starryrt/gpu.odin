package starryrt

Gpu_Backend :: enum {
	OPENGL4,
	VULKAN,
}

DEFAULT_BACKEND :: Gpu_Backend.VULKAN
when DEFAULT_BACKEND == .OPENGL4 {
	#panic("TODO: OpenGL backend")
}

Gpu_Error :: enum {
	OK,
	OUT_OF_CPU_MEMORY,
	OUT_OF_GPU_MEMORY,
	INCOMPATIBLE_GPU,
	TOO_MANY_HANDLES,
	BROKEN_HANDLE,
	SHADER_COMPILATION_FAILED,
	PIPELINE_COMPILATION_FAILED,
	WINDOW_ERROR,
	INVALID_ADDRESS,
	HARDWARE_ERROR,
	DRIVER_ERROR,
	UNKNOWN,
}

gpu_error_string :: proc(err: Gpu_Error) -> string
{
	switch err {
	case .OK:
		return "ok"
	case .OUT_OF_GPU_MEMORY:
		return "out of GPU memory"
	case .INCOMPATIBLE_GPU:
		return "incompatible GPU"
	case .TOO_MANY_HANDLES:
		return "too many handles"
	case .BROKEN_HANDLE:
		return "broken handle (dangling handle?)"
	case .SHADER_COMPILATION_FAILED:
		return "shader compilation failed"
	case .PIPELINE_COMPILATION_FAILED:
		return "pipeline compilation failed"
	case .OUT_OF_CPU_MEMORY:
		return "out of CPU memory"
	case .WINDOW_ERROR:
		return "window system error"
	case .INVALID_ADDRESS:
		return "invalid error"
	case .HARDWARE_ERROR:
		return "hardware error"
	case .DRIVER_ERROR:
		return "driver error"
	case .UNKNOWN:
		return "unknown"
	}
	unreachable()
}

// gpu context crapfrick
Gpu :: struct {
	using vk: Vk_Gpu,
}
VALIDATION_ENABLED :: ODIN_DEBUG

Gpu_Info :: struct {
	name:                          string,
	// note that gpus may have multiple types of memory, this may be shared with this cpu, and,
	// most importantly, that it's not very nice to use all the memory at once
	total_vram:                    u64,
	// in pixels
	max_image_2d_size:             [2]u32,
	// applies to a single storage buffer block; in bytes.
	// note that in vulkan, this doesn't apply if `shader_64bit_addresses` is enabled
	max_storage_buffer_size:       u64,
	// how many storage buffers can be bound at the same time
	max_storage_buffer_bindings:   u32,
	// the GPU doesn't have infinite cores unfortunately
	max_compute_workgroup_size:    [3]u32,
	max_compute_workgroup_threads: u32,
	// can float64s be used in shaders
	shader_f64:                    bool,
	// can int64s be used in shaders
	shader_i64:                    bool,
	// can int16s be used in shaders
	shader_i16:                    bool,
}

@(require_results)
new_gpu :: proc(
	window: ^Window,
	app_name: string = "",
	engine_name: string = "",
	app_version: [3]u32 = {0, 0, 0},
	engine_version: [3]u32 = {0, 0, 0},
	min_required_device: Maybe(Gpu_Info) = nil,
) -> (
	gpu: Gpu,
	err: Gpu_Error,
)
{
	when DEFAULT_BACKEND == .VULKAN {
		return vk_new_gpu(
			window,
			app_name,
			engine_name,
			app_version,
			engine_version,
			min_required_device,
		)
	} else {
		#panic("TODO")
	}
}

free_gpu :: proc(gpu: ^Gpu)
{
	when DEFAULT_BACKEND == .VULKAN {
		vk_free_gpu(gpu)
	} else {
		#panic("TODO")
	}
}

// get info about the selected device
query_gpu_info :: proc(gpu: ^Gpu) -> Gpu_Info
{
	when DEFAULT_BACKEND == .VULKAN {
		return vk_query_gpu_info(gpu)
	} else {
		#panic("TODO")
	}
}

Swapchain :: struct {
	using vk: Vk_Swapchain,
}

// swap my chain<3
new_swapchain :: proc(gpu: ^Gpu, size: [2]u32) -> (swapchain: Swapchain, err: Gpu_Error)
{
	when DEFAULT_BACKEND == .VULKAN {
		return vk_new_swapchain(gpu, size)
	} else {
		#panic("TODO")
	}
}

free_swapchain :: proc(swapchain: ^Swapchain)
{
	when DEFAULT_BACKEND == .VULKAN {
		vk_free_swapchain(swapchain)
	} else {
		#panic("TODO")
	}
}

Command_Port_Type :: enum {
	GRAPHICS_AND_TRANSFER,
	COMPUTE_AND_TRANSFER,
	TRANSFER_ONLY,
	PRESENT_ONLY,
}

// port/queue used for submitting commands
Command_Port :: struct {
	type:     Command_Port_Type,
	using vk: Vk_Command_Port,
}

get_command_port :: proc(
	gpu: ^Gpu,
	type: Command_Port_Type,
) -> (
	port: Command_Port,
	err: Gpu_Error,
)
{
	when DEFAULT_BACKEND == .VULKAN {
		return vk_get_command_port(gpu, type)
	} else {
		#panic("TODO")
	}
}

Command_Buffer :: struct {
	using vk: Vk_Command_Buffer,
}

Command_Buffer_Lifespan :: enum {
	SHORT_LIVED,
	REUSED,
}

new_command_buffer :: proc(
	gpu: ^Gpu,
	port: Command_Port_Type,
	lifespan: Command_Buffer_Lifespan,
) -> (
	cmds: Command_Buffer,
	err: Gpu_Error,
)
{
	when DEFAULT_BACKEND == .VULKAN {
		return vk_new_command_buffer(gpu, port, lifespan)
	} else {
		#panic("TODO")
	}
}

free_command_buffer :: proc(gpu: ^Gpu, cmds: ^Command_Buffer)
{
	when DEFAULT_BACKEND == .VULKAN {
		vk_free_command_buffer(gpu, cmds)
	} else {
		#panic("TODO")
	}
}

clear_command_buffer :: proc(gpu: ^Gpu, cmds: ^Command_Buffer)
{
	when DEFAULT_BACKEND == .VULKAN {
		vk_clear_command_buffer(gpu, cmds)
	} else {
		#panic("TODO")
	}
}

// blocks this thread until the gpu is done running commands
wait_for_gpu :: proc(gpu: ^Gpu)
{
	when DEFAULT_BACKEND == .VULKAN {
		vk_wait_for_gpu(gpu)
	} else {
		#panic("TODO")
	}
}
