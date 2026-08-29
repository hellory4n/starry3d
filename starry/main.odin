package starry

import "base:runtime"
import "core:flags"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:strings"

Args :: struct {
	app_dir: string `usage:"Defaults to the executable directory (where starry.exe is placed)"`,
	version: bool `usage:"Outputs the engine version and quits."`,
}

main :: proc()
{
	context = init_starry_context()
	global.ctx = context

	aerr := vmem.arena_init_growing(&global.init_arena)
	defer vmem.arena_destroy(&global.init_arena)
	assert(aerr == .None)
	init_alloc := vmem.arena_allocator(&global.init_arena)

	flags.parse_or_exit(&global.args, os.args, allocator = init_alloc)
	if global.args.version {
		fmt.printfln("Starry runtime %s", VERSION_STR)
		return
	}

	ferr: os.Error
	global.exe_dir, ferr = os.get_executable_directory(init_alloc)
	if ferr != nil {
		fmt.panicf("couldn't get exe directory: %s", os.error_string(ferr))
	}
	global.exe_name, ferr = os.get_executable_path(init_alloc)
	if ferr != nil {
		fmt.panicf("couldn't get exe directory: %s", os.error_string(ferr))
	}

	// don't mix forward slashes with backslashes
	// windows has supported forward slashes since 1995, it doesn't matter
	global.exe_dir, _ = strings.replace_all(
		global.exe_dir,
		old = "\\",
		new = "/",
		allocator = init_alloc,
	)
	global.exe_name, _ = strings.replace_all(
		global.exe_name,
		old = "\\",
		new = "/",
		allocator = init_alloc,
	)

	fmt.printfln("starry %s", VERSION_STR)
	fmt.printfln("app directory: %s", app_dir())

	init_string_ids()
	load_app_config()
	init_app_window()
	init_2d_renderer()
	init_lua()
	init_app()

	defer free_string_ids()
	defer free_app_window()
	defer free_2d_renderer()
	defer free_lua()

	for global.running {
		main_loop()
	}
}
