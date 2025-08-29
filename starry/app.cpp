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

#include "starry/internal.h"

#ifdef ST_IMGUI
// #include "starry/optional/imgui.h"
#endif

namespace st {

static void _init_window();

static void _pre_input();
static void _post_input();

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
	_st->application->init().unwrap();

	while (!st::window_should_close()) {
		st::_pre_input();

		_st->application->update(st::delta_time_sec()).unwrap();

		st::_post_input();
	}

	_st->application->free().unwrap();
	st::_free_window();
	st::_postfree();
}

static void st::_init_window()
{
	// renderdoc doesn't work on wayland
#if defined(__linux__) && defined(DEBUG)
	glfwInitHint(GLFW_PLATFORM, GLFW_PLATFORM_X11);
#endif

	if (glfwInit() == 0) {
		tr::panic("couldn't initialize glfw");
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
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
		tr::panic("GL error %i: %s", error_code, description);
#else
		tr::error("GL error %i: %s", error_code, description);
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
		platform_str = "null";
		break;
	default:
		TR_UNREACHABLE();
		break;
	}
	tr::info("created window for %s", platform_str.buf());

	if (glfwRawMouseMotionSupported() == 0) {
		tr::warn("warning: raw mouse motion is not supported");
	}

	gladLoadGL(glfwGetProcAddress);

	// apparently windows is shit so we have to do this immediately
	glViewport(0, 0, _st->settings.window_size.x, _st->settings.window_size.y);
	_st->window_size = _st->settings.window_size;

	tr::info("initialized OpenGL");
	tr::info("- GL vendor:    %s", glGetString(GL_VENDOR));
	tr::info("- GL renderer:  %s", glGetString(GL_RENDERER));
	tr::info("- GL version:   %s", glGetString(GL_VERSION));
	tr::info("- GLSL version: %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
}

static void st::_free_window()
{
	glfwDestroyWindow(_st->window);
	glfwTerminate();
	tr::info("destroyed window");
}

static void st::_pre_input()
{
	glfwPollEvents();
}

static void st::_post_input()
{
	// handle the extra fancy key/mouse states
	// it gets mad if you try to check for anything before space
	// also why the FUCK isn't a cast from an enum class to it's EXACT UNDERLYING TYPE implicit
	// what good does that bring to the world
	// what would dennis ritchie think
	// TODO shut the FUCK up
	for (uint8 key = uint8(Key::SPACE); key <= uint8(Key::LAST); key++) {
		bool is_down = glfwGetKey(_st->window, key) == GLFW_PRESS;

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

	// YOU UNDERSTAND MECHANICAL HANDS ARE THE RULER OF EVERYTHING
	// ah
	// RULER OF EVERYTHING
	// ah
	// IM THE RULER OF EVERYTHING
	// in the end...
	_st->current_time = st::time_sec();
	_st->delta_time = _st->current_time - _st->prev_time;
	_st->prev_time = _st->current_time;

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
	return _st->key_state[usize(key)].state != InputState::State::NOT_PRESSED;
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
	return _st->mouse_state[usize(btn)].state != InputState::State::NOT_PRESSED;
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
