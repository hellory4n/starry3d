package starry

import "core:flags"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"
import "core:strings"

DISABLE_DEV_TOOLS :: #config(ST_DISABLE_DEV_TOOLS, !ODIN_DEBUG)

Args :: struct {
	app_dir:      string `usage:"Defaults to the executable directory (where starry.exe is placed)"`,
	version:      bool `usage:"Outputs the engine version and quits."`,
	gen_lua_bind: bool `args:"hidden" usage:"Automagically generates Odin code to bind the engine to Lua"`,
}

main :: proc()
{
	// starry is importable as an Odin library
	// but why would you do that
	// TODO don't
	run(init_proc = init_app, free_proc = nil, update_proc = update_lua_app)
}

run :: proc(init_proc: proc(), free_proc: proc(), update_proc: proc())
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

	global.ctx = context

	flags.parse_or_exit(&global.args, os.args, allocator = init_alloc)
	if global.args.version {
		fmt.printfln("Starry runtime %s", VERSION_STR)
		return
	}
	if global.args.gen_lua_bind {
		when DISABLE_DEV_TOOLS {
			fmt.println("unsupported")
			return
		} else {
			bindgen()
			return
		}
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
	init_lua()
	if init_proc != nil do init_proc()

	defer free_string_ids()
	defer free_app_window()
	defer free_lua()
	defer if free_proc != nil do free_proc()

	for global.running {
		main_loop(update_proc)
	}
}
