package starryrt

import st "../starrylib"
import "core:log"
import "core:mem"
import "core:time"

@(private)
engine: struct {
	windows:      [dynamic]^Window,
	start_time:   f64,
	current_time: f64,
	prev_time:    f64,
	running:      bool,
}

run :: proc(
	app_name: string,
	init_proc: proc(),
	free_proc: proc(),
	update_proc: proc(dt: f32) = nil,
	render_proc: proc() = nil,
	app_version: [3]i32 = {0, 0, 0},
	width: int = 800,
	height: int = 600,
)
{
	when ODIN_OS != .Windows || ODIN_OS != .Linux {
		log.warnf("platform %s not officially supported", ODIN_OS)
	}
	when ODIN_PLATFORM_SUBTARGET != .Default {
		log.warnf("platform %s not officially supported", ODIN_PLATFORM_SUBTARGET)
	}

	lazy_logger, _ := st.new_lazy_logger()
	context.logger = lazy_logger.logger
	defer st.free_lazy_logger(&lazy_logger)

	// we have valgrind at home
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			st.poor_mans_valgrind(track)
			mem.tracking_allocator_destroy(&track)
		}
	}

	log.infof("starry engine %s for %s", st.VERSION_STR, ODIN_OS)
	engine.running = true
	engine.start_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
	engine.windows = make([dynamic]^Window)
	defer delete(engine.windows)

	// setup required systems
	window := open_window(app_name, width, height, resizable = true, high_dpi = true)
	defer close_window(window)

	if init_proc != nil do init_proc()
	defer if free_proc != nil do free_proc()

	// main loop
	for engine.running {
		if is_closing() {
			engine.running = false
			break
		}
		poll_events()

		// timing it
		engine.current_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
		delta_time := engine.current_time - engine.prev_time
		engine.prev_time = engine.current_time

		if update_proc != nil do update_proc(f32(delta_time))
		if render_proc != nil do render_proc()
	}
}

// Returns the current time since the engine started, in seconds
now_in_seconds :: proc() -> f64
{
	return engine.current_time - engine.start_time
}
