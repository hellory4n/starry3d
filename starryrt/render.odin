package starryrt

import "core:log"

Renderer :: struct {
	gpu:       Gpu,
	gpu_info:  Gpu_Info,
	swapchain: Swapchain,
}

init_render_subsystem :: proc(
	window: ^Window,
	app_name: string,
	app_version: [3]u32,
) -> (
	render: Renderer,
)
{
	err: Gpu_Error
	render.gpu, err = init_gpu(
		window,
		app_name = app_name,
		engine_name = "Starry3D",
		app_version = app_version,
		engine_version = {VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH},
	)
	if err != .OK {
		log.panicf("couldn't initialize GPU: %s", gpu_error_string(err))
	}
	log.infof("initialized GPU context for %s", DEFAULT_BACKEND)

	render.gpu_info = query_gpu_info(&render.gpu)
	log.infof("using %#v", render.gpu_info)

	render.swapchain, err = init_swapchain(&render.gpu, framebuffer_sizeu(window))
	if err != .OK {
		log.panicf("couldn't initialize GPU: %s", gpu_error_string(err))
	}
	log.infof("created swapchain")

	return
}

free_render_subsytem :: proc(render: ^Renderer)
{
	free_swapchain(&render.swapchain)
	free_gpu(&render.gpu)
	log.infof("freed renderer")
}

render_loop :: proc(render: ^Renderer)
{
	// TODO
}
