package starry

import lua "../thirdparty/luajit"
import "base:runtime"
import vmem "core:mem/virtual"
import "gpu"

global: struct {
	// pre-init
	ctx:          runtime.Context,
	args:         Args,
	init_arena:   vmem.Arena,
	exe_dir:      string,

	// app
	lua:          ^lua.State,
	config:       Config,
	config_flags: Config_Flags,

	// window
	windows:      [dynamic]^Window,
	start_time:   f64,
	current_time: f64,
	prev_time:    f64,
	running:      bool,

	// graphics
	device:       gpu.Device,
}
