/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * st_window.cpp
 * Manages windowing, input, and initializing OpenGL
 *
 * Copyright (C) 2025 by hellory4n <hellory4n@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this
 * software for any purpose with or without fee is hereby
 * granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <trippin/log.hpp>

#include "common.hpp"
#include "window.hpp"

void st::open_window(st::WindowOptions options)
{
	// renderdoc doesn't work on wayland
	#if defined(ST_LINUX) && defined(DEBUG)
	glfwInitHint(GLFW_PLATFORM, GLFW_PLATFORM_X11);
	#endif

	if (!glfwInit()) {
		tr::panic("couldn't initialize glfw");
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_RESIZABLE, options.resizable);
	#ifdef DEBUG
	glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, true);
	#endif

	st::engine.window = glfwCreateWindow(options.size.x, options.size.y, options.title, nullptr, nullptr);
	TR_ASSERT_MSG(st::engine.window != nullptr, "couldn't create window");
	glfwMakeContextCurrent(st::engine.window);

	glfwSwapInterval(options.vsync ? 1 : 0); // TODO is that the only options?

	// some callbacks
	glfwSetFramebufferSizeCallback(st::engine.window, [](GLFWwindow*, int w, int h) -> void {
		glViewport(0, 0, w, h);
		st::engine.window_size = {static_cast<uint32>(w), static_cast<uint32>(h)};
	});

	glfwSetErrorCallback([](int error_code, const char* description) -> void {
		#ifdef DEBUG
		tr::panic("GL error %i: %s", error_code, description);
		#else
		tr::error("GL error %i: %s", error_code, description);
		#endif
	});

	// a bit more annoyment in the logs
	int32 platform = glfwGetPlatform();
	tr::String platform_str = "unknown platform";
	switch (platform) {
		case GLFW_PLATFORM_WIN32:   platform_str = "Win32";   break;
		case GLFW_PLATFORM_X11:     platform_str = "X11";     break;
		case GLFW_PLATFORM_WAYLAND: platform_str = "Wayland"; break;
		case GLFW_PLATFORM_COCOA:   platform_str = "Cocoa";   break;
	}
	tr::info("created window for %s", platform_str.buf());

	if (!glfwRawMouseMotionSupported()) {
		tr::warn("warning: raw mouse motion is not supported");
	}

	gladLoadGL(glfwGetProcAddress);

	// apparently windows is shit so we have to do this immediately
	glViewport(0, 0, options.size.x, options.size.y);
	st::engine.window_size = options.size;

	tr::info("initialized OpenGL");
	tr::info("- GL vendor:       %s", glGetString(GL_VENDOR));
	tr::info("- GL renderer:     %s", glGetString(GL_RENDERER));
	tr::info("- GL version:      %s", glGetString(GL_VERSION));
	tr::info("- GLSL version:    %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
}

void st::free_window()
{
	glfwDestroyWindow(st::engine.window);
	glfwTerminate();
	tr::info("destroyed window");
}

void st::close_window()            { glfwSetWindowShouldClose(st::engine.window, true); }
bool st::is_window_closing()       { return glfwWindowShouldClose(st::engine.window); }
tr::Vec2<uint32> st::window_size() { return st::engine.window_size; }

void st::poll_events()
{
	glfwPollEvents();

	// handle the extra fancy key/mouse states

	// it gets mad if you try to check for anything before space
	for (int32 key = int32(Key::SPACE); key <= int32(Key::LAST); key++) {
		bool is_down = glfwGetKey(st::engine.window, key) == GLFW_PRESS;

		// help
		bool& was_down = st::engine.key_prev_down[key];
		if (!was_down && is_down) {
			st::engine.key_state[key] = InputState::JUST_PRESSED;
		}
		else if (was_down && is_down) {
			st::engine.key_state[key] = InputState::HELD;
		}
		else if (was_down && !is_down) {
			st::engine.key_state[key] = InputState::JUST_RELEASED;
		}
		else {
			st::engine.key_state[key] = InputState::NOT_PRESSED;
		}

		was_down = is_down;
	}

	// christ
	for (int32 btn = int32(MouseButton::BTN_1); btn <= int32(MouseButton::LAST); btn++) {
		bool is_down = glfwGetMouseButton(st::engine.window, btn) == GLFW_PRESS;

		// help
		bool& was_down = st::engine.mouse_prev_down[btn];
		if (!was_down && is_down) {
			st::engine.mouse_state[btn] = InputState::JUST_PRESSED;
		}
		else if (was_down && is_down) {
			st::engine.mouse_state[btn] = InputState::HELD;
		}
		else if (was_down && !is_down) {
			st::engine.mouse_state[btn] = InputState::JUST_RELEASED;
		}
		else {
			st::engine.mouse_state[btn] = InputState::NOT_PRESSED;
		}

		was_down = is_down;
	}

	// YOU UNDERSTAND MECHANICAL HANDS ARE THE RULER OF EVERYTHING
	// ah
	// RULER OF EVERYTHING
	// ah
	// IM THE RULER OF EVERYTHING
	// in the end...
	st::engine.current_time = st::time();
	st::engine.delta_time = st::engine.current_time - st::engine.prev_time;
	st::engine.prev_time = st::engine.current_time;
}

// help
bool st::is_key_just_pressed(st::Key key) {
	return st::engine.key_state[usize(key)] == InputState::JUST_PRESSED;
}
bool st::is_key_just_released(st::Key key) {
	return st::engine.key_state[usize(key)] == InputState::JUST_RELEASED;
}
bool st::is_key_not_pressed(st::Key key) {
	return st::engine.key_state[usize(key)] == InputState::NOT_PRESSED;
}
bool st::is_key_held(st::Key key) {
	return st::engine.key_state[usize(key)] != InputState::NOT_PRESSED;
}

bool st::is_mouse_just_pressed(st::MouseButton key) {
	return st::engine.mouse_state[usize(key)] == InputState::JUST_PRESSED;
}
bool st::is_mouse_just_released(st::MouseButton key) {
	return st::engine.mouse_state[usize(key)] == InputState::JUST_RELEASED;
}
bool st::is_mouse_not_pressed(st::MouseButton key) {
	return st::engine.mouse_state[usize(key)] == InputState::NOT_PRESSED;
}
bool st::is_mouse_held(st::MouseButton key) {
	return st::engine.mouse_state[usize(key)] != InputState::NOT_PRESSED;
}

tr::Vec2<float64> st::mouse_position()
{
	float64 x, y;
	glfwGetCursorPos(st::engine.window, &x, &y);
	return {x, y};
}

void st::set_mouse_enabled(bool val)
{
	glfwSetInputMode(st::engine.window, GLFW_CURSOR, val ? GLFW_CURSOR_NORMAL : GLFW_CURSOR_DISABLED);
}

float64 st::time()       { return glfwGetTime(); }
float64 st::delta_time() { return st::engine.delta_time; }
float64 st::fps()        { return 1.0 / st::engine.delta_time; }
