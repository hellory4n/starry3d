package starryrt

import "core:log"
import "vendor:wgpu"

@(private)
Renderer :: struct {
	instance: wgpu.Instance,
}

@(private)
init_render_subsystem :: proc(
	window: ^Window,
	app_name: string,
	app_version: [3]u32,
) -> (
	render: Renderer,
)
{
	render.instance = wgpu.CreateInstance(nil)
	if render.instance == nil {
		log.panicf("WebGPU isn't supported by this device")
	}
	return
}

@(private)
free_render_subsytem :: proc(render: ^Renderer)
{
	log.infof("freed renderer")
}

@(private)
render_loop :: proc(render: ^Renderer) -> (err: Gpu_Error)
{
	return
}
