package starryrt

import st "../starrylib"
import "base:runtime"
import "core:c"
import "core:log"
import "core:strings"
import "vendor:glfw"

Window :: struct {
	glfw:             glfw.WindowHandle,
	key_state:        #sparse[Key]Input_State,
	mouse_state:      #sparse[Mouse_Button]Input_State,
	prev_mouse:       [2]f32,
	idx:              int,
	high_dpi_enabled: bool,
	pending_resize:   bool,
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
	if len(engine.windows) == 0 {
		if !glfw.Init() {
			log.panicf("couldn't initialize GLFW")
		}

		glfw.SetErrorCallback(proc "c" (error: i32, description: cstring)
		{
			context = runtime.default_context()
			log.errorf("GLFW [%d]: %s", error, description)
		})
	}

	title_cstr := strings.clone_to_cstring(title, context.temp_allocator)
	defer delete(title_cstr, context.temp_allocator)

	if setup_gl_ctx {
		glfw.WindowHint(glfw.CLIENT_API, glfw.OPENGL_API)
		glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
		glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
		glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	} else {
		glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	}

	glfw.WindowHint(glfw.RESIZABLE, b32(resizable))
	// TODO idk if high dpi works lmao
	glfw.WindowHint(glfw.SCALE_TO_MONITOR, b32(!high_dpi))
	glfw.WindowHint(glfw.SCALE_FRAMEBUFFER, b32(!high_dpi))

	glfw.WindowHintString(glfw.X11_CLASS_NAME, title_cstr)
	glfw.WindowHintString(glfw.WAYLAND_APP_ID, title_cstr)

	glfw_window := glfw.CreateWindow(c.int(width), c.int(height), title_cstr, nil, nil)
	if glfw_window == nil {
		errstr, _ := glfw.GetError()
		log.panicf("couldn't create window: %s", errstr)
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
	window.idx = len(engine.windows)
	glfw.SetWindowUserPointer(glfw_window, window)
	append(&engine.windows, window)

	glfw.SetFramebufferSizeCallback(
		glfw_window,
		proc "c" (glfw_window: glfw.WindowHandle, width, height: i32)
		{
			window := cast(^Window)glfw.GetWindowUserPointer(glfw_window)
			window.pending_resize = true
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
	window.glfw = nil
	unordered_remove(&engine.windows, window.idx)
	free(window, allocator)

	if len(engine.windows) == 0 {
		glfw.Terminate()
	}
}

poll_events :: proc()
{
	glfw.PollEvents()
	for window in engine.windows {
		poll_window_events(window)
	}
}

@(private = "file")
poll_window_events :: proc(window: ^Window)
{
	window.prev_mouse = window_mouse_position(window)

	// glfw has 2 input states: pressed and not pressed
	// we need some extra faffery to get our fancy 4 states
	// TODO text repeat state could be handled separately (polling glfw directly)

	for key in Key(0) ..< Key.LAST {
		is_down := glfw.GetKey(window.glfw, c.int(key)) == glfw.PRESS
		was_down :=
			window.key_state[key] != .NOT_PRESSED &&
			window.key_state[key] != .JUST_RELEASED

		if (!was_down && is_down) {
			window.key_state[key] = .JUST_PRESSED
		} else if (was_down && is_down) {
			window.key_state[key] = .HELD
		} else if (was_down && !is_down) {
			window.key_state[key] = .JUST_RELEASED
		} else {
			window.key_state[key] = .NOT_PRESSED
		}
	}

	for btn in Mouse_Button(0) ..< Mouse_Button.LAST {
		is_down := glfw.GetMouseButton(window.glfw, c.int(btn)) == glfw.PRESS
		was_down :=
			window.mouse_state[btn] != .NOT_PRESSED &&
			window.mouse_state[btn] != .JUST_RELEASED

		if (!was_down && is_down) {
			window.mouse_state[btn] = .JUST_PRESSED
		} else if (was_down && is_down) {
			window.mouse_state[btn] = .HELD
		} else if (was_down && !is_down) {
			window.mouse_state[btn] = .JUST_RELEASED
		} else {
			window.mouse_state[btn] = .NOT_PRESSED
		}
	}
}

main_window :: proc() -> ^Window
{
	return engine.windows[0]
}

window_is_closing :: proc(window: ^Window) -> bool
{
	return bool(glfw.WindowShouldClose(window.glfw))
}

// aligned to the top left of the screen
window_mouse_position :: proc(window: ^Window) -> [2]f32
{
	x, y := glfw.GetCursorPos(window.glfw)
	return {f32(x), f32(y)}
}

// returns how much the mouse position changed in the last frame, aligned to the top left of
// the screen
window_delta_mouse_position :: proc(window: ^Window) -> [2]f32
{
	return window_mouse_position(window) - window.prev_mouse
}

window_is_key_just_pressed :: proc(window: ^Window, key: Key) -> bool
{
	return window.key_state[key] == .JUST_PRESSED
}

window_is_key_just_released :: proc(window: ^Window, key: Key) -> bool
{
	return window.key_state[key] == .JUST_RELEASED
}

window_is_key_held :: proc(window: ^Window, key: Key) -> bool
{
	return window.key_state[key] == .HELD || window.key_state[key] == .JUST_PRESSED
}

window_is_key_not_pressed :: proc(window: ^Window, key: Key) -> bool
{
	return !window_is_key_held(window, key)
}

window_is_mouse_button_just_pressed :: proc(window: ^Window, btn: Mouse_Button) -> bool
{
	return window.mouse_state[btn] == .JUST_PRESSED
}

window_is_mouse_button_just_released :: proc(window: ^Window, btn: Mouse_Button) -> bool
{
	return window.mouse_state[btn] == .JUST_RELEASED
}

window_is_mouse_button_held :: proc(window: ^Window, btn: Mouse_Button) -> bool
{
	return window.mouse_state[btn] == .HELD || window.mouse_state[btn] == .JUST_PRESSED
}

window_is_mouse_button_not_pressed :: proc(window: ^Window, btn: Mouse_Button) -> bool
{
	return !window_is_mouse_button_held(window, btn)
}

window_framebuffer_sizei :: proc(window: ^Window) -> [2]i32
{
	x, y := glfw.GetFramebufferSize(window.glfw)
	return {i32(x), i32(y)}
}

window_framebuffer_sizeu :: proc(window: ^Window) -> [2]u32
{
	x, y := glfw.GetFramebufferSize(window.glfw)
	return {u32(x), u32(y)}
}

window_framebuffer_sizef :: proc(window: ^Window) -> [2]f32
{
	x, y := glfw.GetFramebufferSize(window.glfw)
	return {f32(x), f32(y)}
}

window_aspect_ratio :: proc(window: ^Window) -> f32
{
	size := window_framebuffer_sizef(window)
	return size.x / size.y
}

// returns true if high DPI is enabled and the app is actually running in a high DPI setting
window_is_high_dpi :: proc(window: ^Window) -> bool
{
	xscale, yscale := glfw.GetWindowContentScale(window.glfw)
	return window.high_dpi_enabled && st.approx_eql(xscale, 1) && st.approx_eql(yscale, 1)
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

window_is_mouse_locked :: proc(window: ^Window) -> bool
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
	title_cstr := strings.clone_to_cstring(title, context.temp_allocator)
	defer delete(title_cstr)
	glfw.SetWindowTitle(window.glfw, title_cstr)
}

// keyboard keys on your keyboard which is key. values are the same as GLFW.
Key :: enum u32 {
	INVALID         = 0,
	SPACE           = 32,
	APOSTROPHE      = 39, // '
	COMMA           = 44, // ,
	MINUS           = 45, // -
	PERIOD          = 46, // .
	SLASH           = 47, // /
	NUM_0           = 48,
	NUM_1           = 49,
	NUM_2           = 50,
	NUM_3           = 51,
	NUM_4           = 52,
	NUM_5           = 53,
	NUM_6           = 54,
	NUM_7           = 55,
	NUM_8           = 56,
	NUM_9           = 57,
	SEMICOLON       = 59, // ;
	EQUAL           = 61, // =
	A               = 65,
	B               = 66,
	C               = 67,
	D               = 68,
	E               = 69,
	F               = 70,
	G               = 71,
	H               = 72,
	I               = 73,
	J               = 74,
	K               = 75,
	L               = 76,
	M               = 77,
	N               = 78,
	O               = 79,
	P               = 80,
	Q               = 81,
	R               = 82,
	S               = 83,
	T               = 84,
	U               = 85,
	V               = 86,
	W               = 87,
	X               = 88,
	Y               = 89,
	Z               = 90,
	LEFT_BRACKET    = 91, // [
	BACKSLASH       = 92, // \
	RIGHT_BRACKET   = 93, // ]
	GRAVE_ACCENT    = 96, // `
	INTERNATIONAL_1 = 161, // non-us #1
	INTERNATIONAL_2 = 162, // non-us #2
	ESCAPE          = 256,
	ENTER           = 257,
	TAB             = 258,
	BACKSPACE       = 259,
	INSERT          = 260,
	DELETE          = 261,
	RIGHT           = 262,
	LEFT            = 263,
	DOWN            = 264,
	UP              = 265,
	PAGE_UP         = 266,
	PAGE_DOWN       = 267,
	HOME            = 268,
	END             = 269,
	CAPS_LOCK       = 280,
	SCROLL_LOCK     = 281,
	NUM_LOCK        = 282,
	PRINT_SCREEN    = 283,
	PAUSE           = 284,
	F1              = 290,
	F2              = 291,
	F3              = 292,
	F4              = 293,
	F5              = 294,
	F6              = 295,
	F7              = 296,
	F8              = 297,
	F9              = 298,
	F10             = 299,
	F11             = 300,
	F12             = 301,
	F13             = 302,
	F14             = 303,
	F15             = 304,
	F16             = 305,
	F17             = 306,
	F18             = 307,
	F19             = 308,
	F20             = 309,
	F21             = 310,
	F22             = 311,
	F23             = 312,
	F24             = 313,
	F25             = 314,
	KP_0            = 320,
	KP_1            = 321,
	KP_2            = 322,
	KP_3            = 323,
	KP_4            = 324,
	KP_5            = 325,
	KP_6            = 326,
	KP_7            = 327,
	KP_8            = 328,
	KP_9            = 329,
	KP_DECIMAL      = 330,
	KP_DIVIDE       = 331,
	KP_MULTIPLY     = 332,
	KP_SUBTRACT     = 333,
	KP_ADD          = 334,
	KP_ENTER        = 335,
	KP_EQUAL        = 336,
	LEFT_SHIFT      = 340,
	LEFT_CTRL       = 341,
	LEFT_ALT        = 342,
	LEFT_SUPER      = 343,
	RIGHT_SHIFT     = 344,
	RIGHT_CTRL      = 345,
	RIGHT_ALT       = 346,
	RIGHT_SUPER     = 347,
	MENU            = 348,
	LAST            = MENU,
}

// the buttons located on your pointing device technological artifice. Values are the same as GLFW
Mouse_Button :: enum u32 {
	BTN_1  = 0,
	BTN_2  = 1,
	BTN_3  = 2,
	BTN_4  = 3,
	BTN_5  = 4,
	BTN_6  = 5,
	BTN_7  = 6,
	BTN_8  = 7,
	LEFT   = BTN_1,
	RIGHT  = BTN_2,
	MIDDLE = BTN_3,
	LAST   = BTN_8,
}

Input_State :: enum {
	NOT_PRESSED,
	JUST_PRESSED,
	HELD,
	JUST_RELEASED,
}

// man

is_closing :: proc() -> bool
{ return window_is_closing(main_window()) }

// aligned to the top left of the screen
mouse_position :: proc() -> [2]f32
{ return window_mouse_position(main_window()) }

// returns how much the mouse position changed in the last frame, aligned to the top left of
// the screen
delta_mouse_position :: proc() -> [2]f32
{ return window_delta_mouse_position(main_window()) }

is_key_just_pressed :: proc(key: Key) -> bool
{ return window_is_key_just_pressed(main_window(), key) }

is_key_held :: proc(key: Key) -> bool
{ return window_is_key_held(main_window(), key) }

is_key_just_released :: proc(key: Key) -> bool
{ return window_is_key_just_released(main_window(), key) }

is_key_not_pressed :: proc(key: Key) -> bool
{ return window_is_key_not_pressed(main_window(), key) }

is_mouse_button_just_pressed :: proc(btn: Mouse_Button) -> bool
{ return window_is_mouse_button_just_pressed(main_window(), btn) }

is_mouse_button_held :: proc(btn: Mouse_Button) -> bool
{ return window_is_mouse_button_held(main_window(), btn) }

is_mouse_button_just_released :: proc(btn: Mouse_Button) -> bool
{ return window_is_mouse_button_just_released(main_window(), btn) }

is_mouse_button_not_pressed :: proc(btn: Mouse_Button) -> bool
{ return window_is_mouse_button_not_pressed(main_window(), btn) }

framebuffer_sizei :: proc() -> [2]i32
{ return window_framebuffer_sizei(main_window()) }

framebuffer_sizeu :: proc() -> [2]u32
{ return window_framebuffer_sizeu(main_window()) }

framebuffer_sizef :: proc() -> [2]f32
{ return window_framebuffer_sizef(main_window()) }

aspect_ratio :: proc() -> f32
{ return window_aspect_ratio(main_window()) }

// returns true if high DPI is enabled and the app is actually running in a high DPI setting
is_high_dpi :: proc() -> bool
{ return window_is_high_dpi(main_window()) }

scale_factor :: proc() -> f32
{ return window_scale_factor(main_window()) }

// if true, locks the mouse inside the window and enables raw mouse input, otherwise unlocks it.
lock_mouse :: proc(lock: bool)
{ window_lock_mouse(main_window(), lock) }

is_mouse_locked :: proc() -> bool
{ return window_is_mouse_locked(main_window()) }

// asks nicely for the window to close (you can handle it and not actually quit)
request_quit :: proc()
{ window_request_quit(main_window()) }

// cancel a pending quit from `request_quit` or the OS
cancel_quit :: proc()
{ window_cancel_quit(main_window()) }

set_title :: proc(title: string)
{ window_set_title(main_window(), title) }
