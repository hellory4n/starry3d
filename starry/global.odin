package starry

import lua "../thirdparty/luajit"
import "base:runtime"
import hm "core:container/handle_map"
import vmem "core:mem/virtual"
import "gpu"

global: struct {
	// pre-init
	ctx:           runtime.Context,
	args:          Args,
	init_arena:    vmem.Arena,
	exe_dir:       string,
	exe_name:      string,

	// app
	lua:           ^lua.State,
	config:        Config,
	config_flags:  ConfigFlags,

	// window
	windows:       [dynamic]^Window,
	start_time:    f64,
	current_time:  f64,
	prev_time:     f64,
	running:       bool,

	// graphics
	device:        gpu.Device,

	// string ids
	strdb:         struct {
		arena:       vmem.Arena,
		str_to_id:   map[string]StringId,
		id_to_str:   map[StringId]string,
		initialized: bool,
	},
}
