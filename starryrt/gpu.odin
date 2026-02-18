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
	OUT_OF_GPU_MEMORY,
	INCOMPATIBLE_GPU,
	TOO_MANY_HANDLES,
	BROKEN_HANDLE,
	SHADER_COMPILATION_FAILED,
	PIPELINE_COMPILATION_FAILED,
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
	}
	unreachable()
}

// gpu context crapfrick
when DEFAULT_BACKEND == .VULKAN {
	Gpu :: struct {
		using _: Vulkan_Gpu,
	}
}
when DEFAULT_BACKEND == .OPENGL4 {
	Gpu :: struct {}
}

// - init & free gpu ctx
// - choose device at startup
// - command buffer
// - swapchain
// - render passes
// - shaders
// - pipelines
// - gpu malloc
// - buffer views
