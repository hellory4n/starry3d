package sandbox

import "../starryrt"
import "core:fmt"

app_init :: proc() {
	fmt.println("hehe")
}

app_free :: proc() {
	fmt.println("hihi")
}

app_update :: proc(dt: f32) {
	fmt.println("haha")
}

main :: proc() {
	conf := starryrt.App_Config {
		name      = "sandbox",
		init_fn   = app_init,
		free_fn   = app_free,
		update_fn = app_update,
	}
	starryrt.run(conf)
}
