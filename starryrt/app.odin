package starryrt

import "core:fmt"

App_Config :: struct {
	name:      string,
	init_fn:   proc(),
	free_fn:   proc(),
	update_fn: proc(dt: f32),
}

// takes over control of the application and runs the app. may allocate, may exit, may panic,
// all that fun stuff.
run :: proc(conf: App_Config) {
	fmt.printfln("i sure love %s", conf.name)
	conf.init_fn()
	defer conf.free_fn()

	conf.update_fn(dt = 1)
}
