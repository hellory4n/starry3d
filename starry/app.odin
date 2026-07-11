package starry

import lua "../thirdparty/luajit"
import "core:c"
import "core:encoding/json"
import "core:fmt"
import "core:math"
import vmem "core:mem/virtual"
import "core:os"
import "core:time"
import "vendor:glfw"

Config :: struct {
	name:   string,
	main:   string,
	width:  int,
	height: int,
	// options: "noresize"
	flags:  []string,
}

// unpacked from the string array
Config_Flags :: struct {
	noresize: bool,
}

load_app_config :: proc()
{
	init_alloc := vmem.arena_allocator(&global.init_arena)

	config_bytes, ferr := read_from_exe_dir("app.json", init_alloc)
	if ferr != nil {
		fmt.panicf("couldn't read app.json: %s", os.error_string(ferr))
	}

	jerr := json.unmarshal(config_bytes, &global.config, .JSON5, init_alloc)
	if jerr != nil {
		fmt.panicf("error parsing app.json: %s", jerr)
	}

	for flag in global.config.flags {
		switch flag {
		case "noresize":
			global.config_flags.noresize = true
		case:
			fmt.printfln("unknown flag %q", flag)
		}
	}
}

init_app :: proc()
{
	main_script, ferr := read_from_exe_dir(global.config.main, context.temp_allocator)
	if ferr != nil {
		fmt.panicf("couldn't read %q: %s", global.config.main, os.error_string(ferr))
	}

	L := global.lua
	lua_run(L, main_script, temp_cstr(global.config.main))
	call_lua_function(L, "app_init")
}

init_app_window :: proc()
{
	// TODO more than 2050 rewrites and i still can't make this part of initialization
	// look nice
	global.running = true
	global.start_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
	// TODO window_desktop.odin was written to support multiple windows but i can't be
	// bothered to support multiple windows everywhere else
	global.windows = make([dynamic]^Window)

	open_window(global.config.name)

	glfw.SetFramebufferSizeCallback(
		main_window().glfw,
		proc "c" (window: glfw.WindowHandle, width, height: c.int)
		{
			context = global.ctx
			L := global.lua
			call_lua_function(
				L,
				"app_on_resize",
				lua.Integer(width),
				lua.Integer(height),
				can_be_nil = true,
			)
		},
	)
}

free_app_window :: proc()
{
	delete(global.windows)
}

main_loop :: proc()
{
	defer free_all(context.temp_allocator)
	if is_closing() {
		global.running = false
		return
	}

	// timing it
	global.current_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
	delta_time := math.clamp(global.current_time - global.prev_time, 0.0001, 1)
	global.prev_time = global.current_time

	// running it
	L := global.lua
	call_lua_function(L, "app_update", lua.Number(delta_time), can_be_nil = true)

	poll_events()
}
