package hello

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import "../../starryapp/imgui_impl_starry"
import st "../../starrylib"
import im "../../thirdparty/imgui"
import "core:log"

new_app :: proc()
{
	im.CHECKVERSION()
	im.CreateContext()
	io := im.GetIO()
	io.ConfigFlags += {.DockingEnable}

	imgui_impl_starry.init()
}

free_app :: proc()
{
	imgui_impl_starry.shutdown()
	im.DestroyContext()
}

update_app :: proc(dt: f32)
{
	imgui_impl_starry.new_frame()
	im.NewFrame()

	// your imgui code goes here
	im.ShowDemoWindow()
}

render_app :: proc(dt: f32, dev: gpu.Device)
{
	im.Render()

	gpu.begin_render_pass(
		dev,
		gpu.default_framebuffer(dev),
		color_load_op = .CLEAR,
		clear_color = {0.1, 0.2, 0.5, 1},
	)
	imgui_impl_starry.render_draw_data(dev, im.GetDrawData())
	gpu.end_render_pass(dev)
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
