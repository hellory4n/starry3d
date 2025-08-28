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

#include <glad/gl.h>
#define RGFW_OPENGL
#define RGFW_BOOL_DEFINED
typedef bool RGFW_bool; // cmon
#ifdef DEBUG
	#define RGFW_DEBUG
#endif
#define RGFW_IMPLEMENTATION
#include <rgfw/RGFW.h>
#undef RGFW_IMPLEMENTATION
// where the FUCK did RGFW_getTime() go
#define SOKOL_TIME_IMPL
#include <sokol/sokol_time.h>

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

// TODO a lot of this was written for glfw and i'm not sure how much of it still applies to rgfw

static void st::_init_window()
{
	RGFW_glHints* hints = RGFW_getGlobalHints_OpenGL();
	// TODO opengl 4.3 doesn't work on mac
	// fuck apple
	// i'm not gonna buy a fucking Mac Mini® for an arm and a leg despite being the cheapest one
	// bcuz i live in a shithole (brazil) just so i can run Apple Clang™ and develop a custom
	// backend just for your shit ass Metal© graphics api using the Objective-C++©®™ language
	// just so i can have a slightly bigger buffer natively for like 4 people who don't want to
	// make a vm or whatever the fuck mac users do when they need windows-specific software
	// fuck off
	// you have a trillion dollars and you can't support the rest of the opengl versions??
	hints->major = 4;
	hints->minor = 3;
#ifdef DEBUG
	hints->debug = true;
#endif
	hints->profile = RGFW_glCompatibility; // TODO don't
	RGFW_setGlobalHints_OpenGL(hints);

	RGFW_windowFlags flags = RGFW_windowCenter;
	if (_st->settings.resizable) {
		flags |= RGFW_windowNoResize;
	}
	else {
		flags |= RGFW_windowFloating;
	}

	if (_st->settings.fullscreen) {
		flags |= RGFW_windowedFullscreen; // true fullscreen sucks
	}

	_st->window = RGFW_createWindow(
		"a window", 0, 0, static_cast<int>(_st->settings.window_size.x),
		static_cast<int>(_st->settings.window_size.y), flags
	);
	TR_ASSERT(_st->window);
	RGFW_window_swapInterval_OpenGL(_st->window, _st->settings.vsync ? 1 : 0);
	RGFW_window_createContext_OpenGL(_st->window, hints);

	// callbacks
	// TODO does RGFW already handle that?
	RGFW_setWindowResizedCallback([](RGFW_window*, int32 w, int32 h) {
		glViewport(0, 0, w, h);
		_st->window_size = {static_cast<uint32>(w), static_cast<uint32>(h)};
	});

	RGFW_setDebugCallback([](RGFW_debugType debug_type, RGFW_errorCode error, const char* msg) {
		switch (debug_type) {
		case RGFW_typeError:
			tr::panic("RGFW error %i: %s", error, msg);
			break;
		case RGFW_typeWarning:
			tr::warn("RGFW warning %i: %s", error, msg);
			break;
		case RGFW_typeInfo:
			tr::info("RGFW info %i: %s", error, msg);
			break;
		default:
			TR_UNREACHABLE();
			break;
		}
	});

// a bit more annoyment in the logs
#if defined(RGFW_X11)
	tr::info("created window for X11/unix-like");
#elif defined(RGFW_WAYLAND)
	tr::info("created window for Wayland/unix-like");
#elif defined(_WIN32)
	tr::info("created window for Win32/Windows");
#elif defined(__APPLE__)
	tr::info("created window for Cocoa/macOS");
#else
	tr::info("created window for unknown backend");
#endif

	TR_ASSERT(gladLoadGL(RGFW_getProcAddress_OpenGL));

	// apparently windows is shit so we have to do this immediately
	_st->window_size = _st->settings.window_size;
	glViewport(
		0, 0, static_cast<int>(_st->window_size.x), static_cast<int>(_st->window_size.y)
	);

	tr::info("initialized OpenGL");
	tr::info("- GL vendor:    %s", glGetString(GL_VENDOR));
	tr::info("- GL renderer:  %s", glGetString(GL_RENDERER));
	tr::info("- GL version:   %s", glGetString(GL_VERSION));
	tr::info("- GLSL version: %s", glGetString(GL_SHADING_LANGUAGE_VERSION));

	// they see me timin... they hatin...
	stm_setup();
}

static void st::_free_window()
{
	RGFW_window_close(_st->window);
	tr::info("destroyed window");
}

static void st::_pre_input()
{
	// funni way to poll event :)
	RGFW_event event;
	while (RGFW_window_checkEvent(_st->window, &event)) { }
}

static void st::_post_input()
{
	// handle the extra fancy key/mouse states
	// TODO MY BALS!!!!!!!! it gets mad if you try to check for anything before space
	// why the FUCK isn't a cast from an enum class to it's EXACT UNDERLYING TYPE implicit
	// what good does that bring to the world
	// what would dennis ritchie think
	// TODO using a functional-style cast won't fool the compiler when it gets smarter
	// (-Wold-style-casts), oh well
	// TODO shut the FUCK up
	for (uint8 key = uint8(Key::UNKNOWN); key <= uint8(Key::LAST); key++) {
		bool is_down = RGFW_isKeyPressed(key);

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
	for (uint8 btn = uint8(MouseButton::LEFT); btn <= uint8(MouseButton::LAST); btn++) {
		bool is_down = RGFW_isMousePressed(btn);

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

	RGFW_window_swapBuffers_OpenGL(_st->window);
}

void st::close_window()
{
	RGFW_window_setShouldClose(_st->window, true);
}

bool st::window_should_close()
{
	return RGFW_window_shouldClose(_st->window);
}

bool st::is_key_just_pressed(st::Key key)
{
	return _st->key_state[static_cast<usize>(key)].state == InputState::State::JUST_PRESSED;
}

bool st::is_key_just_released(st::Key key)
{
	return _st->key_state[static_cast<usize>(key)].state == InputState::State::JUST_RELEASED;
}

bool st::is_key_held(st::Key key)
{
	return _st->key_state[static_cast<usize>(key)].state != InputState::State::NOT_PRESSED;
}

bool st::is_key_not_pressed(st::Key key)
{
	return _st->key_state[static_cast<usize>(key)].state == InputState::State::NOT_PRESSED;
}

bool st::is_mouse_just_pressed(st::MouseButton btn)
{
	return _st->mouse_state[static_cast<usize>(btn)].state == InputState::State::JUST_PRESSED;
}

bool st::is_mouse_just_released(st::MouseButton btn)
{
	return _st->mouse_state[static_cast<usize>(btn)].state == InputState::State::JUST_RELEASED;
}

bool st::is_mouse_held(st::MouseButton btn)
{
	return _st->mouse_state[static_cast<usize>(btn)].state != InputState::State::NOT_PRESSED;
}

bool st::is_mouse_not_pressed(st::MouseButton btn)
{
	return _st->mouse_state[static_cast<usize>(btn)].state == InputState::State::NOT_PRESSED;
}

tr::Vec2<int32> st::mouse_position()
{
	int32 x, y;
	RGFW_window_getMouse(_st->window, &x, &y);
	return {x, y};
}

void st::set_mouse_enabled(bool val)
{
	if (val) {
		RGFW_window_holdMouse(_st->window);
	}
	else {
		RGFW_window_unholdMouse(_st->window);
	}
}

float64 st::time_sec()
{
	return stm_sec(stm_now());
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
