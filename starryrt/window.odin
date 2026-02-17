package starryrt

import "core:c"
import "core:log"
import "core:strings"
import "vendor:glfw"

// TODO this would work horribly with multiple windows but fortunately i don't need multiple windows

Window :: struct {
	glfw: glfw.WindowHandle,
}

Graphics_Context :: enum {
	OPENGL4,
}

// must be run before creating any window
init_window_subsystem :: proc()
{
	// renderdoc consider unshitting yourself
	when ODIN_OS == .Linux && ODIN_DEBUG {
		glfw.InitHint(glfw.PLATFORM, glfw.PLATFORM_X11)
	}

	if !glfw.Init() {
		log.panicf("couldn't initialize GLFW")
	}

	log.infof("initialized GLFW %s", glfw.GetVersionString())
}

free_window_subsystem :: proc()
{
	glfw.Terminate()
	log.info("deinitialized GLFW")
}

open_window :: proc(
	title: string,
	init_ctx_for: Graphics_Context,
	width: int = 800,
	height: int = 600,
	resizable: bool = true,
	high_dpi: bool = true,
) -> Window
{
	title_cstr := strings.clone_to_cstring(title)

	if init_ctx_for == .OPENGL4 {
		glfw.WindowHint(glfw.CLIENT_API, glfw.OPENGL_API)
		glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
		glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
		glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 5)
	} else {
		glfw.WindowHint(glfw.CLIENT_API, glfw.NO_API)
	}

	glfw.WindowHint(glfw.RESIZABLE, b32(resizable))
	// TODO idk if high dpi works lmao
	glfw.WindowHint(glfw.SCALE_TO_MONITOR, b32(!high_dpi))
	glfw.WindowHint(glfw.SCALE_FRAMEBUFFER, b32(!high_dpi))

	glfw.WindowHintString(glfw.X11_CLASS_NAME, title_cstr)
	glfw.WindowHintString(glfw.WAYLAND_APP_ID, title_cstr)

	window := glfw.CreateWindow(c.int(width), c.int(height), title_cstr, nil, nil)
	if window == nil {
		errstr, _ := glfw.GetError()
		log.panicf("couldn't create window: %s", errstr)
	}

	// TODO this breaks down with multiple windows but idrc
	if init_ctx_for == .OPENGL4 {
		glfw.MakeContextCurrent(window)
	}
	// disable vsync on debug so that you can see the true fps
	// which is useful for making renderers and shit
	glfw.SwapInterval(1 when ODIN_DEBUG else 0)

	return Window{glfw = window}
}

close_window :: proc(window: ^Window)
{
	if window.glfw == nil {
		return
	}
	glfw.DestroyWindow(window.glfw)
	window.glfw = nil
}

is_window_closing :: proc(window: Window) -> bool
{
	return bool(glfw.WindowShouldClose(window.glfw))
}

poll_events :: proc(window: ^Window)
{
	glfw.PollEvents()
}

swap_gl_buffers :: proc(window: Window)
{
	// afaik this is only for opengl
	// every other graphics api has an explicit swapchain
	glfw.SwapBuffers(window.glfw)
}
