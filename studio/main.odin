package studio

import st "../starry"
import "../starry/gpu"
import "../starry/imgui_impl_starry"
import im "../thirdparty/imgui"

app_init :: proc()
{
	im.CHECKVERSION()
	im.CreateContext()
	io := im.GetIO()
	io.ConfigFlags += {.DockingEnable}
	imgui_impl_starry.init()

}

app_free :: proc()
{
	imgui_impl_starry.shutdown()
	im.DestroyContext()
}

app_update :: proc()
{
	imgui_impl_starry.new_frame()
	im.NewFrame()

	{
		// crap
		im.ShowDemoWindow()
	}

	im.Render()

	dev := st.gpu_device()
	gpu.begin_render_pass(
		dev,
		gpu.default_framebuffer(dev),
		color_load_op = .CLEAR,
		clear_color = {0, 0, 0, 1},
	)
	imgui_impl_starry.render_draw_data(dev, im.GetDrawData())
	gpu.end_render_pass(dev)
}

main :: proc()
{
	st.run(init_proc = app_init, free_proc = app_free, update_proc = app_update)
}
