package starryrt

import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"
import "vendor:glfw"

VERSION_NUM :: 00_08_00 // 0.8.0
VERSION_STR :: "v0.8.0-dev"
VERSION_MAJOR :: 0
VERSION_MINOR :: 8
VERSION_PATCH :: 0

// NOTE: avoid putting stuff here and instead put state into the subsystem's structs
// starryrt.run() will then manage that state properly
@(private)
global: struct {
	main_window:  Window,
	frame_count:  u64,
	second_count: f64,
	prev_time:    f64,
}

// takes over control of the application and runs the app with the engine. may allocate,
// may exit, may panic, all that fun stuff.
run :: proc(
	app_name: string,
	init_proc: proc(),
	free_proc: proc(),
	update_proc: proc(dt: f32),
	width: int = 800,
	height: int = 600,
	log_to_file: bool = true,
	app_version: [3]u32 = {0, 0, 0},
)
{
	// officially supported platforms:
	// - linux x64
	// - windows x64
	// mac, bsd, and arm64 can probably work too
	when ODIN_OS != .Windows && ODIN_OS != .Linux {
		log.warnf("platform '%s' not officially supported", ODIN_OS_STRING)
	}
	when ODIN_ARCH != .amd64 {
		log.warnf("architecture '%s' not officially supported", ODIN_ARCH_STRING)
	}

	// a bunch of logging shit
	term_options :: log.Options{.Time, .Terminal_Color}
	log_options :: log.Options{.Time, .Level, .Procedure, .Thread_Id}

	log_to_file := log_to_file
	file_logger: log.Logger
	logtxt: os.Handle
	err: os.Error

	if log_to_file {
		logtxt, err = os.open("log.txt", os.O_CREATE | os.O_WRONLY, 0o644)
		if err != nil {
			fmt.printfln("couldn't open log.txt: %s", os.error_string(err))
			log_to_file = false
		} else {
			file_logger = log.create_file_logger(
				logtxt,
				lowest = .Debug when ODIN_DEBUG else .Info,
				opt = log_options,
			)
		}
	}
	defer if err != nil {
		// also closes the file
		log.destroy_file_logger(file_logger)
	}

	console_logger := log.create_console_logger(
		lowest = .Debug when ODIN_DEBUG else .Info,
		opt = term_options,
	)
	defer log.destroy_console_logger(console_logger)

	logger: log.Logger
	if log_to_file {
		logger = log.create_multi_logger(console_logger, file_logger)
	} else {
		logger = console_logger
	}
	defer if log_to_file {
		log.destroy_multi_logger(logger)
	}
	context.logger = logger

	// we have valgrind at home
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				log.errorf(
					"=== %v allocations not freed: ===",
					len(track.allocation_map),
				)
				for _, entry in track.allocation_map {
					log.debugf("%v bytes @ %v", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				log.errorf(
					"=== %v incorrect frees: ===",
					len(track.bad_free_array),
				)
				for entry in track.bad_free_array {
					log.debugf("%p @ %v", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	log.infof("starry engine %s %s", VERSION_STR, "debug" when ODIN_DEBUG else "")
	defer log.infof("deinitialized starry")

	init_window_subsystem()
	defer free_window_subsystem()

	// this doesn't really have to depend on glfw who cares
	global.second_count = glfw.GetTime()
	global.prev_time = global.second_count

	global.main_window = open_window(
		title = app_name,
		init_ctx_for = .VULKAN,
		width = width,
		height = height,
	)
	log.infof(
		"created window for %s on %s %s",
		window_system(),
		ODIN_ARCH_STRING,
		ODIN_OS_STRING,
	)
	defer {
		close_window(&global.main_window)
		log.infof("closed main window")
	}

	renderer := init_render_subsystem(
		&global.main_window,
		app_name = app_name,
		app_version = app_version,
	)
	defer free_render_subsytem(&renderer)

	init_proc()
	defer free_proc()

	for !is_window_closing(global.main_window) {
		// f32 is used more often in games in than f64
		// just avoids having to convert too many times
		update_proc(f32(delta_time()))

		render_loop(&renderer)

		global.prev_time = global.second_count
		global.second_count = glfw.GetTime()
		global.frame_count += 1

		poll_events(&global.main_window)
		swap_gl_buffers(global.main_window)
	}
}

// returns the main (and probably only) window
main_window :: proc() -> ^Window
{
	return &global.main_window
}

// returns the number of frames since the engine started
frames :: proc() -> u64
{
	return global.frame_count
}

// returns the number of seconds since the engine started
seconds :: proc() -> f64
{
	return global.second_count
}

// returns how long it took for the last frame to run
delta_time :: proc() -> f64
{
	return global.second_count - global.prev_time
}
