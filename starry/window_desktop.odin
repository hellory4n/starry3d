package starry

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:strings"
import "vendor:glfw"

// TODO this was originally written to support multiple windows, but it's untested,
// and not exposed anywhere (also opengl contexts will make this obnoxious)

Window :: struct {
	glfw:             glfw.WindowHandle,
	key_state:        #sparse[Key]InputState,
	mouse_state:      #sparse[MouseButton]InputState,
	current_mouse:    [2]f32,
	delta_mouse:      [2]f32,
	prev_mouse:       [2]f32,
	scroll:           [2]f32,
	idx:              int,
	high_dpi_enabled: bool,
}

open_window :: proc(
	title: string,
	width: int = 800,
	height: int = 600,
	resizable: bool = true,
	high_dpi: bool = true,
	setup_gl_ctx: bool = false,
	allocator := context.allocator,
) -> ^Window
{
	if len(global.windows) == 0 {
		if !glfw.Init() {
			fmt.panicf("couldn't initialize GLFW")
		}

		glfw.SetErrorCallback(proc "c" (error: i32, description: cstring)
		{
			context = runtime.default_context()
			fmt.printfln("GLFW [%d]: %s", error, description)
		})
	}

	title_cstr := strings.clone_to_cstring(title, context.temp_allocator)

	if setup_gl_ctx {
		glfw.WindowHint(glfw.CLIENT_API, glfw.OPENGL_API)
		glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
		// TODO OpenGL 4.3 not supported everywhere
		glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
		glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	} else {
		glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	}

	glfw.WindowHint(glfw.RESIZABLE, b32(resizable))
	// TODO idk if high dpi works lmao
	glfw.WindowHint(glfw.SCALE_TO_MONITOR, b32(!high_dpi))
	glfw.WindowHint(glfw.SCALE_FRAMEBUFFER, b32(!high_dpi))

	// completely unnecessary :)
	glfw.WindowHintString(glfw.X11_CLASS_NAME, title_cstr)
	glfw.WindowHintString(glfw.WAYLAND_APP_ID, title_cstr)

	glfw_window := glfw.CreateWindow(c.int(width), c.int(height), title_cstr, nil, nil)
	if glfw_window == nil {
		errstr, _ := glfw.GetError()
		fmt.panicf("couldn't create window: %s", errstr)
	}

	if setup_gl_ctx {
		// TODO this breaks down with multiple windows but idrc
		// set the current context during the render pass????????????
		glfw.MakeContextCurrent(glfw_window)

		// disable vsync on debug so that you can see the true fps
		// which is useful for making renderers and shit
		glfw.SwapInterval(0 when ODIN_DEBUG else 1)
	}

	window := new(Window, allocator)
	window.glfw = glfw_window
	window.high_dpi_enabled = high_dpi
	window.idx = len(global.windows)
	glfw.SetWindowUserPointer(glfw_window, window)
	append(&global.windows, window)

	glfw.SetScrollCallback(
		glfw_window,
		proc "c" (glfw_window: glfw.WindowHandle, xoffset, yoffset: f64)
		{
			context = global.ctx
			window := cast(^Window)glfw.GetWindowUserPointer(glfw_window)
			window.scroll = {f32(xoffset), f32(yoffset)}
		},
	)

	return window
}

close_window :: proc(window: ^Window, allocator := context.allocator)
{
	if window.glfw == nil {
		return
	}
	glfw.DestroyWindow(window.glfw)

	unordered_remove(&global.windows, window.idx)
	free(window, allocator)

	if len(global.windows) == 0 {
		glfw.Terminate()
	}
}

poll_events :: proc()
{
	for window in global.windows {
		window.scroll = {}
	}
	glfw.PollEvents()
	for window in global.windows {
		poll_window_events(window)
	}
}

@(private = "file")
poll_window_events :: proc(window: ^Window)
{
	window.current_mouse = window_mouse_pos(window)
	window.delta_mouse = window.current_mouse - window.prev_mouse
	window.prev_mouse = window.current_mouse

	// glfw has 2 input states: pressed and not pressed
	// we need some extra faffery to get our fancy 4 states
	// TODO text repeat state could be handled separately (polling glfw directly)

	for key in Key.SPACE ..< Key.LAST {
		is_down := glfw.GetKey(window.glfw, c.int(key)) == glfw.PRESS
		was_down :=
			window.key_state[key] != .NOT_PRESSED &&
			window.key_state[key] != .JUST_RELEASED

		if !was_down && is_down {
			window.key_state[key] = .JUST_PRESSED
		} else if was_down && is_down {
			window.key_state[key] = .HELD
		} else if was_down && !is_down {
			window.key_state[key] = .JUST_RELEASED
		} else {
			window.key_state[key] = .NOT_PRESSED
		}
	}

	for btn in MouseButton(0) ..< MouseButton.LAST {
		is_down := glfw.GetMouseButton(window.glfw, c.int(btn)) == glfw.PRESS
		was_down :=
			window.mouse_state[btn] != .NOT_PRESSED &&
			window.mouse_state[btn] != .JUST_RELEASED

		if !was_down && is_down {
			window.mouse_state[btn] = .JUST_PRESSED
		} else if was_down && is_down {
			window.mouse_state[btn] = .HELD
		} else if was_down && !is_down {
			window.mouse_state[btn] = .JUST_RELEASED
		} else {
			window.mouse_state[btn] = .NOT_PRESSED
		}
	}
}

main_window :: proc() -> ^Window
{
	if len(global.windows) == 0 {
		return nil
	}
	return global.windows[0]
}

window_is_closing :: proc(window: ^Window) -> bool
{
	return bool(glfw.WindowShouldClose(window.glfw))
}

// aligned to the top left of the screen
window_mouse_pos :: proc(window: ^Window) -> [2]f32
{
	x, y := glfw.GetCursorPos(window.glfw)
	return {f32(x), f32(y)}
}

// returns how much the mouse position changed in the last frame, aligned to the top left of
// the screen
window_delta_mouse_pos :: proc(window: ^Window) -> [2]f32
{
	return window.delta_mouse
}

window_key_just_pressed :: proc(window: ^Window, key: Key) -> bool
{
	return window.key_state[key] == .JUST_PRESSED
}

window_key_just_released :: proc(window: ^Window, key: Key) -> bool
{
	return window.key_state[key] == .JUST_RELEASED
}

window_key_held :: proc(window: ^Window, key: Key) -> bool
{
	return window.key_state[key] == .HELD || window.key_state[key] == .JUST_PRESSED
}

window_key_not_pressed :: proc(window: ^Window, key: Key) -> bool
{
	return !window_key_held(window, key)
}

window_mouse_just_pressed :: proc(window: ^Window, btn: MouseButton) -> bool
{
	return window.mouse_state[btn] == .JUST_PRESSED
}

window_mouse_just_released :: proc(window: ^Window, btn: MouseButton) -> bool
{
	return window.mouse_state[btn] == .JUST_RELEASED
}

window_mouse_held :: proc(window: ^Window, btn: MouseButton) -> bool
{
	return window.mouse_state[btn] == .HELD || window.mouse_state[btn] == .JUST_PRESSED
}

window_mouse_not_pressed :: proc(window: ^Window, btn: MouseButton) -> bool
{
	return !window_mouse_held(window, btn)
}

window_frame_sizei :: proc(window: ^Window) -> [2]i32
{
	x, y := glfw.GetFramebufferSize(window.glfw)
	return {i32(x), i32(y)}
}

window_frame_sizeu :: proc(window: ^Window) -> [2]u32
{
	x, y := glfw.GetFramebufferSize(window.glfw)
	return {u32(x), u32(y)}
}

window_sizef :: proc(window: ^Window) -> [2]f32
{
	x, y := glfw.GetFramebufferSize(window.glfw)
	return {f32(x), f32(y)}
}

window_aspect_ratio :: proc(window: ^Window) -> f32
{
	size := window_sizef(window)
	return size.x / size.y
}

// returns true if high DPI is enabled and the app is actually running in a high DPI setting
window_high_dpi :: proc(window: ^Window) -> bool
{
	xscale, yscale := glfw.GetWindowContentScale(window.glfw)
	return window.high_dpi_enabled && approx_eql(xscale, 1) && approx_eql(yscale, 1)
}

window_scale_factor :: proc(window: ^Window) -> f32
{
	// TODO pretty sure all platforms use the same scale horizontally and vertically
	// but i'm not sure
	xscale, yscale := glfw.GetWindowContentScale(window.glfw)
	return (xscale + yscale) / 2 // get the average (completely unnecessary)
}

// if true, locks the mouse inside the window and enables raw mouse input, otherwise unlocks it.
window_lock_mouse :: proc(window: ^Window, lock: bool)
{
	glfw.SetInputMode(
		window.glfw,
		glfw.CURSOR,
		glfw.CURSOR_DISABLED if lock else glfw.CURSOR_NORMAL,
	)
}

window_mouse_locked :: proc(window: ^Window) -> bool
{
	return glfw.GetInputMode(window.glfw, glfw.CURSOR) == glfw.CURSOR_DISABLED
}

// asks nicely for the window to close (you can handle it and not actually quit)
window_request_quit :: proc(window: ^Window)
{
	glfw.SetWindowShouldClose(window.glfw, true)
}

// cancel a pending quit from `request_quit` or the OS
window_cancel_quit :: proc(window: ^Window)
{
	glfw.SetWindowShouldClose(window.glfw, false)
}

window_set_title :: proc(window: ^Window, title: string)
{
	glfw.SetWindowTitle(window.glfw, temp_cstr(title))
}

window_mouse_scroll :: proc(window: ^Window) -> [2]f32
{
	return window.scroll
}

// man

// lua: `app.is_closing`
is_closing :: proc() -> bool
{
	if main_window() == nil do return false
	return window_is_closing(main_window())
}

// aligned to the top left of the screen
// lua: `app.mouse_pos`
mouse_pos :: proc() -> [2]f32
{
	if main_window() == nil do return {}
	return window_mouse_pos(main_window())
}

// returns how much the mouse position changed in the last frame, aligned to the top left of
// the screen
// lua: `app.delta_mouse_pos`
delta_mouse_pos :: proc() -> [2]f32
{
	if main_window() == nil do return {}
	return window_delta_mouse_pos(main_window())
}

// lua: `app.key_just_pressed`
key_just_pressed :: proc(key: Key) -> bool
{
	if main_window() == nil do return false
	return window_key_just_pressed(main_window(), key)
}

// lua: `app.key_held`
key_held :: proc(key: Key) -> bool
{
	if main_window() == nil do return false
	return window_key_held(main_window(), key)
}

// lua: `app.key_just_released`
key_just_released :: proc(key: Key) -> bool
{
	if main_window() == nil do return false
	return window_key_just_released(main_window(), key)
}

// lua: `app.key_not_pressed`
key_not_pressed :: proc(key: Key) -> bool
{
	if main_window() == nil do return false
	return window_key_not_pressed(main_window(), key)
}

// lua: `app.mouse_just_pressed`
mouse_just_pressed :: proc(btn: MouseButton) -> bool
{
	if main_window() == nil do return false
	return window_mouse_just_pressed(main_window(), btn)
}

// lua: `app.mouse_held`
mouse_held :: proc(btn: MouseButton) -> bool
{
	if main_window() == nil do return false
	return window_mouse_held(main_window(), btn)
}

// lua: `app.mouse_just_released`
mouse_just_released :: proc(btn: MouseButton) -> bool
{
	if main_window() == nil do return false
	return window_mouse_just_released(main_window(), btn)
}

// lua: `app.mouse_not_pressed`
mouse_not_pressed :: proc(btn: MouseButton) -> bool
{
	if main_window() == nil do return false
	return window_mouse_not_pressed(main_window(), btn)
}

frame_sizei :: proc() -> [2]i32
{
	if main_window() == nil do return {}
	return window_frame_sizei(main_window())
}

frame_sizeu :: proc() -> [2]u32
{
	if main_window() == nil do return {}
	return window_frame_sizeu(main_window())
}

// lua: `app.frame_size`
frame_sizef :: proc() -> [2]f32
{
	if main_window() == nil do return {}
	return window_sizef(main_window())
}

// lua: `app.aspect_ratio`
aspect_ratio :: proc() -> f32
{
	if main_window() == nil do return 0
	return window_aspect_ratio(main_window())
}

// returns true if high DPI is enabled and the app is actually running in a high DPI setting
// lua: `app.high_dpi`
high_dpi :: proc() -> bool
{
	if main_window() == nil do return false
	return window_high_dpi(main_window())
}

// lua: `app.scale_factor`
scale_factor :: proc() -> f32
{
	if main_window() == nil do return 0
	return window_scale_factor(main_window())
}

// if true, locks the mouse inside the window and enables raw mouse input, otherwise unlocks it.
// lua: `app.lock_mouse`
lock_mouse :: proc(lock: bool)
{
	if main_window() == nil do return
	window_lock_mouse(main_window(), lock)
}

// lua: `app.mouse_locked`
mouse_locked :: proc() -> bool
{
	if main_window() == nil do return false
	return window_mouse_locked(main_window())
}

// asks nicely for the window to close (you can handle it and not actually quit)
// lua: `app.request_quit`
request_quit :: proc()
{
	if main_window() == nil {
		global.running = false
		return
	}
	window_request_quit(main_window())
}

// cancel a pending quit from `request_quit` or the OS
// lua: `app.cancel_quit`
cancel_quit :: proc()
{
	if main_window() == nil {
		global.running = true
		return
	}
	window_cancel_quit(main_window())
}

// lua: `app.set_title`
set_title :: proc(title: string)
{
	if main_window() == nil do return
	window_set_title(main_window(), title)
}

// lua: `app.mouse_scroll`
mouse_scroll :: proc() -> [2]f32
{
	if main_window() == nil do return {}
	return window_mouse_scroll(main_window())
}
