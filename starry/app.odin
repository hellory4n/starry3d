package starry

import lua "../thirdparty/luajit"
import "core:c"
import "core:encoding/json"
import "core:fmt"
import "core:math"
import vmem "core:mem/virtual"
import "core:os"
import "core:strings"
import "core:time"
import "gpu"
import "vendor:glfw"

Config :: struct {
	name:   string,
	main:   string,
	width:  int,
	height: int,
	flags:  []string,
}

// unpacked from the string array
ConfigFlags :: struct {
	no_resize:      bool,
	no_high_dpi:    bool,
	engine_testing: bool,
}

load_app_config :: proc()
{
	init_alloc := vmem.arena_allocator(&global.init_arena)

	config_bytes, ferr := read_from_app_dir("app.json", init_alloc)
	if ferr != nil {
		// TODO move this out into a custom panic() or whatever

		// if the exe == starry then this is from a starry release, not an
		// exported game
		user_is_dev := strings.ends_with(
			global.exe_name,
			"starry" when ODIN_OS != .Windows else "starry.exe",
		)
		msg: string

		if user_is_dev {
			msg = fmt.tprintf(
				"Couldn't read app.json: %s\nNote: starry.exe isn't meant to be run directly, run studio.exe or one of the samples instead",
				os.error_string(ferr),
			)
		} else {
			// horrible error message but will do for now
			msg = fmt.tprintf(
				"Couldn't read app.json: %s\nIs the app installation corrupted?",
				os.error_string(ferr),
			)
		}
		message_box(.ERROR, msg)

		fmt.panicf("couldn't read app.json: %s", os.error_string(ferr))
	}

	jerr := json.unmarshal(config_bytes, &global.config, .JSON5, init_alloc)
	if jerr != nil {
		fmt.panicf("error parsing app.json: %s", jerr)
	}

	if global.config.width == 0 {
		global.config.width = 800
	}
	if global.config.height == 0 {
		global.config.height = 600
	}

	for flag in global.config.flags {
		switch flag {
		case "no_resize":
			global.config_flags.no_resize = true
		case "no_high_dpi":
			global.config_flags.no_high_dpi = true
		case "engine_testing":
			global.config_flags.engine_testing = true
		case:
			fmt.printfln("unknown flag %q", flag)
		}
	}
}

init_app :: proc()
{
	L := global.lua
	lua_run(L, global.config.main)
	call_lua_function(L, "app_init")
}

init_app_window :: proc()
{
	// TODO more than 2050 rewrites and i still can't make this part of initialization
	// look nice
	global.running = true
	global.start_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0

	if is_headless() {
		return
	}

	// TODO window_desktop.odin was written to support multiple windows but i can't be
	// bothered to support multiple windows everywhere else
	global.windows = make([dynamic]^Window)

	open_window(
		title = global.config.name,
		width = global.config.width,
		height = global.config.height,
		resizable = !global.config_flags.no_resize,
		high_dpi = !global.config_flags.no_high_dpi,
		setup_gl_ctx = true,
	)

	// gpu crap
	gpu.init_instance()

	ok: bool
	global.device, ok = gpu.new_device(gpu.Gl_Init_Glue {
		window = main_window(),
		get_proc_address_proc = proc(p: rawptr, name: cstring)
		{
			_proc := cast(^rawptr)p
			_proc^ = glfw.GetProcAddress(name)
		},
		swap_buffers_proc = proc(w: rawptr)
		{
			window := cast(^Window)w
			glfw.SwapBuffers(window.glfw)
		},
	})
	if !ok {
		fmt.panicf("couldn't create GPU device")
	}

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
	if !is_headless() {
		gpu.free_device(global.device)
		gpu.free_instance()
		close_window(main_window())
		delete(global.windows)
	}
}

main_loop :: proc(update_proc: proc())
{
	defer free_all(context.temp_allocator)

	if !is_headless() {
		if is_closing() {
			global.running = false
			return
		}

		// gpuing it
		gpu.begin_frame(global.device)
	} else {
		if global.config_flags.engine_testing {
			global.running = false
		}
	}

	// timing it
	global.current_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
	delta_time := math.clamp(global.current_time - global.prev_time, 0.0001, 1)
	global.prev_time = global.current_time

	// running it
	if update_proc != nil {
		update_proc()
	}

	// gpuing it 2
	if !is_headless() {
		gpu.end_frame(global.device)
		gpu.present_and_swap_buffers(global.device)
		poll_events()
	}
}

update_lua_app :: proc()
{
	L := global.lua

	if (key_held(.LEFT_ALT) || key_held(.RIGHT_ALT)) && key_just_pressed(.R) {
		lua_run(L, global.config.main)
		fmt.printfln("reloaded lua scripts")
	}

	call_lua_function(L, "app_update", lua.Number(delta_time()), can_be_nil = true)
}

// Returns the time since the engine started, in seconds
// Lua: `app.now_secs`
now_secs :: proc() -> f64
{
	return global.current_time - global.start_time
}

// Returns the time between the current frame and last frame
// Lua: `app.delta_time`
delta_time :: proc() -> f64
{
	return math.clamp(global.current_time - global.prev_time, 0.0001, 1)
}

// Returns the current GPU device
gpu_device :: proc() -> gpu.Device
{
	return global.device
}

// Returns true if the engine is in headless mode (no window or GPU context)
// Lua: `app.is_headless`
is_headless :: proc() -> bool
{
	return global.config_flags.engine_testing
}
