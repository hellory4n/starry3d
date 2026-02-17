package starryrt

import "core:fmt"
import "core:log"
import "core:os"

VERSION_NUM :: 00_08_00 // 0.8.0
VERSION_STR :: "v0.8.0-dev"
VERSION_MAJOR :: 0
VERSION_MINOR :: 8
VERSION_PATCH :: 0

// NOTE: avoid putting stuff here and instead put state into the subsystem's structs
// starryrt.run() will then manage that state properly
@(private)
global: struct {
	main_window: Window,
}

// takes over control of the application and runs the app with the engine. may allocate,
// may exit, may panic, all that fun stuff.
run :: proc(
	app_name: string,
	init_fn: proc(),
	free_fn: proc(),
	update_fn: proc(dt: f32),
	width: int = 800,
	height: int = 600,
	log_to_file: bool = true,
) {
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

	log_to_file := log_to_file
	file_logger: log.Logger
	logtxt: os.Handle
	err: os.Error
	if log_to_file {
		logtxt, err = os.open("log.txt", os.O_CREATE, 0o644)
		if err != nil {
			fmt.printfln("couldn't open log.txt: %s", os.error_string(err))
			log_to_file = false
		} else {
			file_logger = log.create_file_logger(
				logtxt,
				lowest = .Debug when ODIN_DEBUG else .Info,
			)
		}
	}
	defer if err != nil {
		os.close(logtxt)
	}

	console_logger := log.create_console_logger(lowest = .Debug when ODIN_DEBUG else .Info)
	if log_to_file {
		context.logger = log.create_multi_logger(console_logger, file_logger)
	} else {
		context.logger = console_logger
	}

	log.infof("starry engine %s", VERSION_STR)
	defer log.infof("deinitialized starry")

	init_window_subsystem()
	defer free_window_subsystem()

	global.main_window = open_window(
		title = app_name,
		init_ctx_for = .OPENGL4,
		width = width,
		height = height,
	)
	defer close_window(&global.main_window)

	init_fn()
	defer free_fn()

	for !is_window_closing(global.main_window) {
		update_fn(dt = 1)

		poll_events(&global.main_window)
		swap_gl_buffers(global.main_window)
	}
}
