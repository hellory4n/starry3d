package studio

import stapp "../starryapp"
import "../starryapp/gpu"
import "../starryapp/imgui_impl_starry"
import st "../starrylib"
import im "../thirdparty/imgui"

app_init :: proc()
{
	im.CHECKVERSION()
	im.CreateContext()
	io := im.GetIO()
	io.ConfigFlags += {.DockingEnable}
	imgui_impl_starry.init()

	// dockspacing it
	im.DockSpaceOverViewport(0, im.GetMainViewport(), {.PassthruCentralNode})
}

app_free :: proc()
{
	imgui_impl_starry.shutdown()
	im.DestroyContext()
}

app_update :: proc(dt: f32)
{
	imgui_impl_starry.new_frame()
	im.NewFrame()

	// TODO fucking ui stuff here
	im.ShowDemoWindow()
}

app_render :: proc(dt: f32, dev: gpu.Device)
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
		app_name = "Starry Studio " + st.VERSION_STR,
		app_version = {st.VERSION_MAJOR, st.VERSION_MINOR, st.VERSION_PATCH},
		asset_dir = "studio",
		init_proc = app_init,
		free_proc = app_free,
		update_proc = app_update,
		render_proc = app_render,
	)
}
