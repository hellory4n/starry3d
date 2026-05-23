package hello

import strt "../../starryrt"
import gpu "../../starryrt/gpu"
import "core:log"

new_app :: proc()
{
	log.infof("Hello, world!")
}

free_app :: proc()
{
	// TODO
}

update_app :: proc(dt: f32)
{
	// TODO
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	// TODO
}

main :: proc()
{
	strt.run(
		app_name = "hello starry",
		app_version = {0, 1, 0},
		asset_dir = "examples/hello",
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
	)
}
