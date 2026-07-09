package starry

import lua "../thirdparty/luajit"
import vmem "core:mem/virtual"

global: struct {
	// pre-init
	init_arena: vmem.Arena,
	exe_dir:    string,

	// app
	lua:        ^lua.State,
	config:     Config,
}
