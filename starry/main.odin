package starry

import lua "../thirdparty/luajit"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"

main :: proc()
{
	// setup some basic things, shared by parts of the engines when initializing
	// TODO better context:
	// - custom logger (output to console, file, and internal buffer)
	// - custom assertion failure proc (love2d-like, or using MessageBox)
	// - use mem.Tracking_Allocator everywhere
	aerr := vmem.arena_init_growing(&global.init_arena)
	defer vmem.arena_destroy(&global.init_arena)
	assert(aerr == .None)
	init_alloc := vmem.arena_allocator(&global.init_arena)

	ferr: os.Error
	global.exe_dir, ferr = os.get_executable_directory(init_alloc)
	if ferr != nil {
		fmt.panicf("couldn't get exe directory: %s", os.error_string(ferr))
	}

	init_lua()
	init_app()
	defer free_lua()
	defer free_app()
}
