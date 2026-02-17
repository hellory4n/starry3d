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
{  }

main :: proc()
{
	starryrt.run(
		app_name = "sandbox",
		init_fn = app_init,
		free_fn = app_free,
		update_fn = app_update,
	)
}
