package starryexe

import vmem "core:mem/virtual"

global: struct {
	init_arena: vmem.Arena,
	exe_dir:    string,
	app:        App,
}
