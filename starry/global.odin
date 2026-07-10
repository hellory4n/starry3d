package starry

import lua "../thirdparty/luajit"
import "base:runtime"
import vmem "core:mem/virtual"

global: struct {
	// pre-init
	ctx:        runtime.Context,
	args:       Args,
	init_arena: vmem.Arena,
	exe_dir:    string,

	// app
	lua:        ^lua.State,
	config:     Config,
}
