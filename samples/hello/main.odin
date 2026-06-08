package hello

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import st "../../starrylib"
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
	ctx := st.init_better_context()
	defer st.free_better_context(&ctx)
	context = ctx.ctx

	stapp.run(
		app_name = "hello starry",
		app_version = {0, 1, 0},
		asset_dir = "samples/hello",
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
	)
}
