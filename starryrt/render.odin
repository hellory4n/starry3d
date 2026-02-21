package starryrt

import "core:log"

Renderer_Frame :: struct {
	cmds:             Command_Buffer,
	render_semaphore: Semaphore,
	render_fence:     Fence,
}

Renderer :: struct {
	gpu:           Gpu,
	gpu_info:      Gpu_Info,
	swapchain:     Swapchain,
	graphics_port: Command_Port,
	frames:        [2]Renderer_Frame,
}

@(private)
render_frame :: proc(renderer: ^Renderer) -> ^Renderer_Frame
{
	return &renderer.frames[frames() % 2]
}

@(private)
init_render_subsystem :: proc(
	window: ^Window,
	app_name: string,
	app_version: [3]u32,
) -> (
	render: Renderer,
	err: Gpu_Error,
)
{
	render.gpu = new_gpu(
		window,
		app_name = app_name,
		engine_name = "Starry3D",
		app_version = app_version,
		engine_version = {VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH},
	) or_return
	log.infof("initialized GPU context for %s", DEFAULT_BACKEND)

	render.gpu_info = query_gpu_info(&render.gpu)
	log.infof("using %#v", render.gpu_info)

	render.graphics_port = get_command_port(&render.gpu, .GRAPHICS_AND_TRANSFER) or_return
	log.infof("all required ports available")

	render.swapchain = new_swapchain(&render.gpu, framebuffer_sizeu(window)) or_return
	log.infof("created swapchain")

	render.frames[0].cmds = new_command_buffer(&render.gpu, .GRAPHICS_AND_TRANSFER) or_return
	render.frames[1].cmds = new_command_buffer(&render.gpu, .GRAPHICS_AND_TRANSFER) or_return
	log.infof("created command buffers")

	render.frames[0].render_semaphore = new_semaphore(&render.gpu) or_return
	render.frames[1].render_semaphore = new_semaphore(&render.gpu) or_return
	render.frames[0].render_fence = new_fence(&render.gpu) or_return
	render.frames[1].render_fence = new_fence(&render.gpu) or_return
	log.infof("created sync primitives")

	return
}

@(private)
free_render_subsytem :: proc(render: ^Renderer)
{
	wait_for_gpu(&render.gpu)

	free_fence(&render.gpu, &render.frames[0].render_fence)
	free_fence(&render.gpu, &render.frames[1].render_fence)
	free_semaphore(&render.gpu, &render.frames[0].render_semaphore)
	free_semaphore(&render.gpu, &render.frames[1].render_semaphore)
	free_command_buffer(&render.gpu, &render.frames[0].cmds)
	free_command_buffer(&render.gpu, &render.frames[1].cmds)
	free_swapchain(&render.gpu, &render.swapchain)
	free_gpu(&render.gpu)

	log.infof("freed renderer")
}

@(private)
render_loop :: proc(render: ^Renderer) -> (err: Gpu_Error)
{
	frame := render_frame(render)
	wait_for_fence(&render.gpu, &frame.render_fence) or_return

	return
}
