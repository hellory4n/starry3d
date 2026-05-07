package sandbox

import strt "../starryrt"
import gpu "../starryrt/gpu"
import "core:fmt"

new_app :: proc()
{
	fmt.println("hehe")
}

free_app :: proc()
{
	fmt.println("hihi")
}

update_app :: proc(dt: f32)
{
	if strt.window_is_mouse_button_just_pressed(strt.main_window(), .LEFT) {
		fmt.println("Fuh")
	}
}

render_app :: proc()
{
	dev := strt.get_gpu()
	swap := strt.get_swapchain()

	gpu.begin_render_pass(dev, swap, [4]f32{1, 0, 0, 1})
	gpu.end_render_pass(dev)
}

main :: proc()
{
	strt.run(
		app_name = "sandbox",
		app_version = {0, 1, 0},
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
	)
}
