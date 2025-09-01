/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/app.cpp
 * Manages the app's window and input, as well as `st::run` which is quite
 * important innit mate.
 *
 * Copyright (c) 2025 hellory4n <hellory4n@gmail.com>
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 */

#include "starry/app.h"

#include <trippin/common.h>
#include <trippin/iofs.h>
#include <trippin/log.h>
#include <trippin/math.h>

// fun!
TR_GCC_IGNORE_WARNING(-Wold-style-cast)
TR_GCC_IGNORE_WARNING(-Wsign-conversion)
#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>
TR_GCC_RESTORE()
TR_GCC_RESTORE()
#include <GLFW/glfw3.h>

// windows.h being a bitch
#ifdef _WIN32
	#undef near
	#undef far
	#undef min
	#undef max
#endif

#include "starry/internal.h"
#include "starry/render.h"

#ifdef ST_IMGUI
// #include "starry/optional/imgui.h"
#endif

namespace st {

static void _init_window();

static void _poll_events();
static void _end_window_app_stuff(); // TODO a better name

static void _free_window();

}

void st::run(st::Application& app, st::ApplicationSettings settings)
{
	tr::Arena arena = {};
	tr::Arena asset_arena = {};
	_st = &arena.make<Starry>(arena, asset_arena);

	_st->application = &app;
	_st->settings = settings;
	_st->window_size = settings.window_size;

	st::_preinit();
	st::_init_window();
	st::_test_pipeline();
	_st->application->init().unwrap();

	while (!st::window_should_close()) {
		st::_poll_events();

		_st->application->update(st::delta_time_sec()).unwrap();

		st::_end_window_app_stuff();
	}

	_st->application->free().unwrap();
	st::_free_window();
	st::_postfree();
}

static void st::_init_window()
{
// renderdoc doesn't work on wayland
// TODO this sucks
#if defined(__linux__) && defined(DEBUG)
	glfwInitHint(GLFW_PLATFORM, GLFW_PLATFORM_X11);
#endif

	if (glfwInit() == 0) {
		tr::panic("couldn't initialize glfw");
	}

	// TODO OpenGL 4.3 doesn't work on macOS
	// fuck apple
	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_RESIZABLE, int(_st->settings.resizable));
#ifdef DEBUG
	glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, 1);
#endif

	_st->window = glfwCreateWindow(
		int(_st->settings.window_size.x), int(_st->settings.window_size.y),
		_st->settings.name, nullptr, nullptr
	);
	TR_ASSERT_MSG(_st->window != nullptr, "couldn't create window");
	glfwMakeContextCurrent(_st->window);

	glfwSwapInterval(_st->settings.vsync ? 1 : 0); // TODO is that the only options?

	// some callbacks
	glfwSetFramebufferSizeCallback(_st->window, [](GLFWwindow*, int w, int h) -> void {
		glViewport(0, 0, w, h);
		_st->window_size = {uint32(w), uint32(h)};
	});

	glfwSetErrorCallback([](int error_code, const char* description) -> void {
#ifdef DEBUG
		tr::panic("GLFW error %i: %s", error_code, description);
#else
		tr::error("GLFW error %i: %s", error_code, description);
#endif
	});

	// a bit more annoyment in the logs
	int platform = glfwGetPlatform();
	tr::String platform_str;
	switch (platform) {
	case GLFW_PLATFORM_WIN32:
		platform_str = "Win32";
		break;
	case GLFW_PLATFORM_X11:
		platform_str = "X11";
		break;
	case GLFW_PLATFORM_WAYLAND:
		platform_str = "Wayland";
		break;
	case GLFW_PLATFORM_COCOA:
		platform_str = "Cocoa";
		break;
	case GLFW_PLATFORM_NULL:
		platform_str = "null/headless";
		break;
	default:
		TR_UNREACHABLE();
		break;
	}
	tr::info("created window for %s", platform_str.buf());
	tr::info("using glfw %s", glfwGetVersionString());

	if (glfwRawMouseMotionSupported() == 0) {
		tr::warn("warning: raw mouse motion is not supported");
	}

	gladLoadGL(glfwGetProcAddress);

	// apparently windows is shit so we have to do this immediately
	glViewport(0, 0, int(_st->settings.window_size.x), int(_st->settings.window_size.y));
	_st->window_size = _st->settings.window_size;

	// more debug crap
	int flags;
	glGetIntegerv(GL_CONTEXT_FLAGS, &flags);
	if ((flags & GL_CONTEXT_FLAG_DEBUG_BIT) != 0) {
		glEnable(GL_DEBUG_OUTPUT);
		glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
		// TODO this is ugly as fuck
		glDebugMessageCallback(
			[](GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length,
			   const GLchar* msg, const void* data) {
				(void)data;
				(void)length;
				const char* src_str;
				const char* type_str;

				switch (source) {
				case GL_DEBUG_SOURCE_API:
					src_str = "GL_DEBUG_SOURCE_API";
					break;
				case GL_DEBUG_SOURCE_WINDOW_SYSTEM:
					src_str = "GL_DEBUG_SOURCE_WINDOW_SYSTEM";
					break;
				case GL_DEBUG_SOURCE_SHADER_COMPILER:
					src_str = "GL_DEBUG_SOURCE_SHADER COMPILER";
					break;
				case GL_DEBUG_SOURCE_THIRD_PARTY:
					src_str = "GL_DEBUG_SOURCE_THIRD PARTY";
					break;
				case GL_DEBUG_SOURCE_APPLICATION:
					src_str = "GL_DEBUG_SOURCE_APPLICATION";
					break;
				case GL_DEBUG_SOURCE_OTHER:
					src_str = "GL_DEBUG_SOURCE_OTHER";
					break;
				default:
					src_str = "unknown";
					break;
				}

				switch (type) {
				case GL_DEBUG_TYPE_ERROR:
					type_str = "GL_DEBUG_TYPE_ERROR";
					break;
				case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR:
					type_str = "GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR";
					break;
				case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR:
					type_str = "GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR";
					break;
				case GL_DEBUG_TYPE_PORTABILITY:
					type_str = "GL_DEBUG_TYPE_PORTABILITY";
					break;
				case GL_DEBUG_TYPE_PERFORMANCE:
					type_str = "GL_DEBUG_TYPE_PERFORMANCE";
					break;
				case GL_DEBUG_TYPE_OTHER:
					type_str = "GL_DEBUG_TYPE_OTHER";
					break;
				case GL_DEBUG_TYPE_MARKER:
					type_str = "GL_DEBUG_TYPE_MARKER";
					break;
				default:
					type_str = "unknown";
					break;
				}

				switch (severity) {
				case GL_DEBUG_SEVERITY_HIGH:
					tr::panic(
						"OpenGL error %i: type: %s, source: %s: %s", id,
						type_str, src_str, msg
					);
					break;
				case GL_DEBUG_SEVERITY_MEDIUM:
				case GL_DEBUG_SEVERITY_LOW:
					tr::warn(
						"OpenGL error %i: type: %s, source: %s: %s", id,
						type_str, src_str, msg
					);
					break;
				default:
					tr::info(
						"OpenGL error %i: type: %s, source: %s: %s", id,
						type_str, src_str, msg
					);
					break;
				}
			},
			nullptr
		);
		glDebugMessageControl(
			GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, nullptr, GL_TRUE
		);
	}

	tr::info("initialized OpenGL");
	tr::info("- GL vendor:    %s", glGetString(GL_VENDOR));
	tr::info("- GL renderer:  %s", glGetString(GL_RENDERER));
	tr::info("- GL version:   %s", glGetString(GL_VERSION));
	tr::info("- GLSL version: %s", glGetString(GL_SHADING_LANGUAGE_VERSION));

	// just so st::delta_mouse_position() doesn't immediately return something massive...
	_st->delta_mouse_pos = st::mouse_position();
}

static void st::_free_window()
{
	glfwDestroyWindow(_st->window);
	glfwTerminate();
	tr::info("destroyed window");
}

static void st::_poll_events()
{
	glfwPollEvents();

	// handle the extra fancy key/mouse states
	// it gets mad if you try to check for anything before space
	// also why the FUCK isn't a cast from an enum class to it's EXACT UNDERLYING TYPE implicit
	// what good does that bring to the world
	// what would dennis ritchie think
	// TODO shut the FUCK up
	for (unsigned key = unsigned(Key::SPACE); key <= unsigned(Key::LAST); key++) {
		bool is_down = glfwGetKey(_st->window, int(key)) == GLFW_PRESS;

		bool& was_down = _st->key_state[key].pressed;
		if (!was_down && is_down) {
			_st->key_state[key].state = InputState::State::JUST_PRESSED;
		}
		else if (was_down && is_down) {
			_st->key_state[key].state = InputState::State::HELD;
		}
		else if (was_down && !is_down) {
			_st->key_state[key].state = InputState::State::JUST_RELEASED;
		}
		else {
			_st->key_state[key].state = InputState::State::NOT_PRESSED;
		}

		was_down = is_down;
	}

	// christ
	for (uint8 btn = uint8(MouseButton::BTN_1); btn <= uint8(MouseButton::LAST); btn++) {
		bool is_down = glfwGetMouseButton(_st->window, btn) == GLFW_PRESS;

		// help
		bool& was_down = _st->mouse_state[btn].pressed;
		if (!was_down && is_down) {
			_st->mouse_state[btn].state = InputState::State::JUST_PRESSED;
		}
		else if (was_down && is_down) {
			_st->mouse_state[btn].state = InputState::State::HELD;
		}
		else if (was_down && !is_down) {
			_st->mouse_state[btn].state = InputState::State::JUST_RELEASED;
		}
		else {
			_st->mouse_state[btn].state = InputState::State::NOT_PRESSED;
		}

		was_down = is_down;
	}
}

static void st::_end_window_app_stuff()
{
	// YOU UNDERSTAND MECHANICAL HANDS ARE THE RULER OF EVERYTHING
	// ah
	// RULER OF EVERYTHING
	// ah
	// IM THE RULER OF EVERYTHING
	// in the end...
	_st->current_time = st::time_sec();
	_st->delta_time = _st->current_time - _st->prev_time;
	_st->prev_time = _st->current_time;

	// do something similar for the mouse position :)
	_st->current_mouse_pos = st::mouse_position();
	_st->delta_mouse_pos = _st->current_mouse_pos - _st->prev_mouse_pos;
	_st->prev_mouse_pos = _st->current_mouse_pos;

	glfwSwapBuffers(_st->window);
}

void st::close_window()
{
	glfwSetWindowShouldClose(_st->window, 1);
}

bool st::window_should_close()
{
	return glfwWindowShouldClose(_st->window) != 0;
}

bool st::is_key_just_pressed(st::Key key)
{
	return _st->key_state[usize(key)].state == InputState::State::JUST_PRESSED;
}

bool st::is_key_just_released(st::Key key)
{
	return _st->key_state[usize(key)].state == InputState::State::JUST_RELEASED;
}

bool st::is_key_held(st::Key key)
{
	return _st->key_state[usize(key)].state == InputState::State::JUST_PRESSED ||
	       _st->key_state[usize(key)].state == InputState::State::HELD;
}

bool st::is_key_not_pressed(st::Key key)
{
	return _st->key_state[usize(key)].state == InputState::State::NOT_PRESSED;
}

bool st::is_mouse_just_pressed(st::MouseButton btn)
{
	return _st->mouse_state[usize(btn)].state == InputState::State::JUST_PRESSED;
}

bool st::is_mouse_just_released(st::MouseButton btn)
{
	return _st->mouse_state[usize(btn)].state == InputState::State::JUST_RELEASED;
}

bool st::is_mouse_held(st::MouseButton btn)
{
	return _st->mouse_state[usize(btn)].state == InputState::State::JUST_PRESSED ||
	       _st->mouse_state[usize(btn)].state == InputState::State::HELD;
}

bool st::is_mouse_not_pressed(st::MouseButton btn)
{
	return _st->mouse_state[usize(btn)].state == InputState::State::NOT_PRESSED;
}

tr::Vec2<float64> st::mouse_position()
{
	float64 x, y;
	glfwGetCursorPos(_st->window, &x, &y);
	return {x, y};
}

tr::Vec2<float64> st::delta_mouse_position()
{
	// calculated in st::_post_input()
	return _st->delta_mouse_pos;
}

void st::set_mouse_enabled(bool val)
{
	glfwSetInputMode(_st->window, GLFW_CURSOR, val ? GLFW_CURSOR_NORMAL : GLFW_CURSOR_DISABLED);
}

float64 st::time_sec()
{
	return glfwGetTime();
}

float64 st::delta_time_sec()
{
	// it's calculated in st::_post_input()
	return _st->delta_time;
}

float64 st::fps()
{
	return 1.0 / st::delta_time_sec();
}

tr::Vec2<uint32> st::window_size()
{
	return _st->window_size;
}
