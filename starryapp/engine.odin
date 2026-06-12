package starryapp

import st "../starrylib"
import "core:c"
import "core:log"
import "core:math"
import "core:time"
import "gpu"
import "vendor:glfw"

Graphics_Profile :: enum {
	// Targets OpenGL 3.3, can't run the voxel renderer.
	COMPATIBILITY,
	// Targets OpenGL 4.3, supports the voxel renderer.
	MODERN,
}

run :: proc(
	app_name: string,
	init_proc: proc(),
	free_proc: proc(),
	update_proc: proc(dt: f32) = nil,
	render_proc: proc(dt: f32, dev: gpu.Device) = nil,
	asset_dir: string = ".",
	app_version: [3]i32 = {0, 0, 0},
	width: int = 800,
	height: int = 600,
	graphics_profile := Graphics_Profile.MODERN,
)
{
	// TODO split into 5 billion trillion functions for Clean™ Code®
	when ODIN_OS != .Windows && ODIN_OS != .Linux {
		log.warnf("platform %s not officially supported", ODIN_OS)
	}
	when ODIN_PLATFORM_SUBTARGET != .Default {
		log.warnf("platform %s not officially supported", ODIN_PLATFORM_SUBTARGET)
	}

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
		gl_version = .CORE_33 if graphics_profile == .COMPATIBILITY else .CORE_43,
	)
	defer close_window(window)

	// gpu crap
	gpu.init_instance()
	defer gpu.free_instance()

	ok: bool
	engine.device, ok = gpu.new_device(gpu.Gl_Init_Glue {
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
		log.panic("couldn't create GPU device")
	}
	defer gpu.free_device(engine.device)

	on_resize(proc(userdata: rawptr, window: ^Window)
	{
		size := framebuffer_sizei()
		gpu.resize_swapchain(engine.device, size)
		gpu.set_viewport(engine.device, pos = {0, 0}, size = size)
	})

	// init other crap systems
	init_assets(asset_dir)
	defer free_assets()

	// IT'S ALIVE!
	if init_proc != nil do init_proc()
	defer if free_proc != nil do free_proc()

	// main loop
	for engine.running {
		defer free_all(context.temp_allocator)
		if is_closing() {
			engine.running = false
			break
		}

		// gpuing it
		gpu.begin_frame(engine.device)

		// timing it
		engine.current_time = f64(time.time_to_unix_nano(time.now())) / 1_000_000_000.0
		delta_time := math.clamp(engine.current_time - engine.prev_time, 0.0001, 1)
		engine.prev_time = engine.current_time

		// running it
		if update_proc != nil do update_proc(f32(delta_time))
		if render_proc != nil do render_proc(f32(delta_time), get_gpu())

		// gpuing it 2
		gpu.end_frame(engine.device)
		gpu.present_and_swap_buffers(engine.device)
		poll_events()
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
	return math.clamp(engine.current_time - engine.prev_time, 0.0001, 1)
}

// Returns the current GPU device
get_gpu :: proc() -> gpu.Device
{
	return engine.device
}
