package starryrt

import st "../starrylib"
import "core:c"
import "core:log"
import "core:math"
import "core:mem"
import "core:time"
import "gpu"
import "vendor:glfw"

run :: proc(
	app_name: string,
	init_proc: proc(),
	free_proc: proc(),
	update_proc: proc(dt: f32) = nil,
	render_proc: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain) = nil,
	asset_dir: string = ".",
	app_version: [3]i32 = {0, 0, 0},
	width: int = 800,
	height: int = 600,
)
{
	// TODO split into 5 billion trillion functions for Clean™ Code®
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

	// IT'S ALIVE!
	log.infof("starry engine %s for %s", st.VERSION_STR, ODIN_OS)
	defer log.infof("exited safely")
	engine.running = true
	engine.ctx = context
	engine.start_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
	engine.windows = make([dynamic]^Window)
	defer delete(engine.windows)

	// window
	window := open_window(
		app_name,
		width,
		height,
		resizable = true,
		high_dpi = true,
		setup_gl_ctx = true,
	)
	defer close_window(window)

	// gpu crap
	ok: bool
	engine.device, ok = gpu.new_device(gpu.Gl_Init_Glue {
		get_proc_address_proc = proc(p: rawptr, name: cstring)
		{
			_proc := cast(^rawptr)p
			_proc^ = glfw.GetProcAddress(name)
		},
	})
	if !ok {
		log.panic("couldn't create GPU device")
	}
	defer gpu.free_device(engine.device)

	engine.swapchain = gpu.new_swapchain(
		engine.device,
		framebuffer_sizeu(),
		gpu.Gl_Swapchain_Glue {
			window = main_window(),
			swap_buffers_proc = proc(w: rawptr)
			{
				window := cast(^Window)w
				glfw.SwapBuffers(window.glfw)
			},
		},
	)
	defer gpu.free_swapchain(engine.swapchain)

	glfw.SetFramebufferSizeCallback(
		main_window().glfw,
		proc "c" (window: glfw.WindowHandle, width, height: c.int)
		{
			context = engine.ctx // shut up
			gpu.resize_swapchain(engine.swapchain, {u32(width), u32(height)})
		},
	)

	// init other crap systems
	init_assets(asset_dir)
	defer free_assets()

	// IT'S ALIVE! (but it's the game this time)
	if init_proc != nil do init_proc()
	defer if free_proc != nil do free_proc()

	// main loop
	for engine.running {
		if is_closing() {
			engine.running = false
			break
		}
		poll_events()

		// gpuing it
		gpu.begin_frame(engine.device)

		// timing it
		engine.current_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
		delta_time := math.clamp(engine.current_time - engine.prev_time, 0.1, 1)
		engine.prev_time = engine.current_time

		if update_proc != nil do update_proc(f32(delta_time))
		if render_proc != nil do render_proc(f32(delta_time), get_gpu(), get_swapchain())

		// gpuing it
		gpu.end_frame(engine.device)
		gpu.present_swapchain(engine.device, engine.swapchain)

		free_all(context.temp_allocator)
	}
}

// Returns the current time since the engine started, in seconds
now_in_seconds :: proc() -> f64
{
	return engine.current_time - engine.start_time
}

// Returns the time between the current frame and last frame
delta_time :: proc() -> f64
{
	return engine.current_time - engine.prev_time
}

// Returns the current GPU device
get_gpu :: proc() -> gpu.Device
{
	return engine.device
}

// Returns the current swapchain
get_swapchain :: proc() -> gpu.Swapchain
{
	return engine.swapchain
}
