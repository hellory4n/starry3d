package sandbox

import "../starryrt"
import "core:fmt"

app_init :: proc()
{
	fmt.println("hehe")
}

app_free :: proc()
{
	fmt.println("hihi")
}

app_update :: proc(dt: f32)
{
	starryrt.debug_text_print("It's giving thanks.\nI support the death penalty.")
	if starryrt.is_mouse_button_just_pressed(starryrt.main_window(), .LEFT) {
		fmt.println("Fuh")
	}
}

main :: proc()
{
	starryrt.run(
		app_name = "sandbox",
		init_proc = app_init,
		free_proc = app_free,
		update_proc = app_update,
	)
}
