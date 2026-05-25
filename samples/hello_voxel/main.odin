package hello

import strt "../../starryrt"
import "../../starryrt/gpu"
import stvx "../../voxel"

new_app :: proc()
{
	stvx.init_renderer(strt.get_gpu())
}

free_app :: proc()
{
	stvx.free_renderer(strt.get_gpu())
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	stvx.render(dev, swap)
}

update_app :: proc(dt: f32)
{
	// TODO
}

main :: proc()
{
	strt.run(
		app_name = "hello voxel",
		app_version = {0, 1, 0},
		asset_dir = "samples/hello_voxel",
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
	)
}
