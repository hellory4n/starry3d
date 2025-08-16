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

// it has to go before sokol
/* clang-format off */
#include "starry/internal.h"
/* clang-format on */

#include "starry/app.h"

#include <trippin/common.h>
#include <trippin/iofs.h>
#include <trippin/log.h>

#define SOKOL_APP_IMPL
// :(
TR_GCC_IGNORE_WARNING(-Wmissing-field-initializers)
TR_GCC_IGNORE_WARNING(-Wold-style-cast)
TR_GCC_IGNORE_WARNING(-Wshorten-64-to-32)
TR_GCC_IGNORE_WARNING(-Wcast-qual)
TR_GCC_IGNORE_WARNING(-Wconversion)
TR_GCC_IGNORE_WARNING(-Wunknown-pragmas)
TR_GCC_IGNORE_WARNING(-Wextra) // this is why clang is better
#include <sokol/sokol_app.h>
#define SOKOL_TIME_IMPL
#include <sokol/sokol_time.h>
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()

// i fucking love windows
#ifdef _WIN32
	#undef DELETE
	#undef ERROR
	#undef TRANSPARENT
	#undef Key
	#undef MouseButton
#endif

#ifdef ST_IMGUI
	#include "starry/optional/imgui.h"
#endif

namespace st {

// yeah
static void _on_event(const sapp_event* event);

}

void st::run(st::Application& app, st::ApplicationSettings settings)
{
	engine.application = &app;
	engine.settings = settings;
	engine.window_size = settings.window_size;

	// hehe
	stm_setup();

	sapp_desc sokol_app = {};

	sokol_app.init_cb = st::_init_engine;
	sokol_app.frame_cb = st::_update_engine;
	sokol_app.cleanup_cb = st::_free_engine;
	sokol_app.event_cb = st::_on_event;
	sokol_app.logger.func = st::_sokol_log;

	sokol_app.width = static_cast<int32>(settings.window_size.x);
	sokol_app.height = static_cast<int32>(settings.window_size.y);
	sokol_app.window_title = settings.name;
	sokol_app.swap_interval = settings.vsync ? 1 : 0;
	sokol_app.high_dpi = settings.high_dpi;
	sokol_app.fullscreen = settings.fullscreen;
	sokol_app.enable_clipboard = true;

	sapp_run(sokol_app);
}

void st::_update::pre_input()
{
	// uh
	if (!engine.mouse_moved_this_frame) {
		engine.relative_mouse_position = {};
	}
	engine.mouse_moved_this_frame = false;
}

void st::_update::post_input()
{
	// update key states
	for (auto [_, key] : engine.key_state) {
		switch (key.state) {
		case InputState::State::NOT_PRESSED:
			if (key.pressed) {
				key.state = InputState::State::JUST_PRESSED;
			}
			break;

		case InputState::State::JUST_PRESSED:
			key.state = key.pressed ? InputState::State::HELD
						: InputState::State::JUST_RELEASED;
			break;

		case InputState::State::HELD:
			if (!key.pressed) {
				key.state = InputState::State::JUST_RELEASED;
			}
			break;

		case InputState::State::JUST_RELEASED:
			key.state = InputState::State::NOT_PRESSED;
			break;
		}
	}

	// update mouse states
	// that's pretty much the same thing as the key states
	for (auto [_, mouse] : engine.mouse_state) {
		switch (mouse.state) {
		case InputState::State::NOT_PRESSED:
			if (mouse.pressed) {
				mouse.state = InputState::State::JUST_PRESSED;
			}
			break;

		case InputState::State::JUST_PRESSED:
			mouse.state = mouse.pressed ? InputState::State::HELD
						    : InputState::State::JUST_RELEASED;
			break;

		case InputState::State::HELD:
			if (!mouse.pressed) {
				mouse.state = InputState::State::JUST_RELEASED;
			}
			break;

		case InputState::State::JUST_RELEASED:
			mouse.state = InputState::State::NOT_PRESSED;
			break;
		}
	}
}

void st::_init::app()
{
	// TODO use this
}

void st::_free::app()
{
	// sapp handles this for us
	// so no `sapp_shutdown()` or whatever
	// TODO use this
}

static void st::_on_event(const sapp_event* event)
{
// TODO it'll get funky if you have a player controller and a text field
// pretty sure imgui can handle that tho
#ifdef ST_IMGUI
	st::imgui::on_event(event);
#endif

	// 'enumeration values not handled in switch'
	// i know you fucking scoundrel
	TR_GCC_IGNORE_WARNING(-Wswitch)
	switch (event->type) {
	case SAPP_EVENTTYPE_KEY_DOWN:
		engine.key_state[event->key_code].pressed = true;
		engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_KEY_UP:
		engine.key_state[event->key_code].pressed = false;
		engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_MOUSE_DOWN:
		engine.mouse_state[event->mouse_button].pressed = true;
		engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_MOUSE_UP:
		engine.mouse_state[event->mouse_button].pressed = false;
		engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_MOUSE_MOVE:
		engine.mouse_position = {event->mouse_x, event->mouse_y};
		engine.relative_mouse_position = {event->mouse_dx, event->mouse_dy};
		engine.mouse_moved_this_frame = true;
		engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_QUIT_REQUESTED:
		st::on_close.emit();
		break;

	case SAPP_EVENTTYPE_RESIZED:
		engine.window_size = {
			static_cast<uint32>(event->window_width),
			static_cast<uint32>(event->window_height)
		};
		break;

	case SAPP_EVENTTYPE_FOCUSED:
		st::lock_mouse(false);
		st::set_mouse_visible(true);
		break;
	}
	TR_GCC_RESTORE();
}

void st::close_window()
{
	sapp_request_quit();
}

bool st::is_key_just_pressed(st::Key key)
{
	return engine.key_state[static_cast<usize>(key)].state == InputState::State::JUST_PRESSED;
}

bool st::is_key_just_released(st::Key key)
{
	return engine.key_state[static_cast<usize>(key)].state == InputState::State::JUST_RELEASED;
}

bool st::is_key_held(st::Key key)
{
	return engine.key_state[static_cast<usize>(key)].state != InputState::State::NOT_PRESSED;
}

bool st::is_key_not_pressed(st::Key key)
{
	return engine.key_state[static_cast<usize>(key)].state == InputState::State::NOT_PRESSED;
}

bool st::is_mouse_just_pressed(st::MouseButton btn)
{
	return engine.mouse_state[static_cast<usize>(btn)].state == InputState::State::JUST_PRESSED;
}

bool st::is_mouse_just_released(st::MouseButton btn)
{
	return engine.mouse_state[static_cast<usize>(btn)].state ==
	       InputState::State::JUST_RELEASED;
}

bool st::is_mouse_held(st::MouseButton btn)
{
	return engine.mouse_state[static_cast<usize>(btn)].state != InputState::State::NOT_PRESSED;
}

bool st::is_mouse_not_pressed(st::MouseButton btn)
{
	return engine.mouse_state[static_cast<usize>(btn)].state == InputState::State::NOT_PRESSED;
}

tr::Vec2<float32> st::mouse_position()
{
	return engine.mouse_position;
}

tr::Vec2<float32> st::relative_mouse_position()
{
	return engine.relative_mouse_position;
}

st::Modifiers st::modifiers()
{
	return engine.current_modifiers;
}

void st::set_mouse_visible(bool val)
{
	sapp_show_mouse(val);
}

bool st::is_mouse_visible()
{
	return sapp_mouse_shown();
}

void st::lock_mouse(bool val)
{
	sapp_lock_mouse(val);
}

bool st::is_mouse_locked()
{
	return sapp_mouse_locked();
}

float64 st::time_sec()
{
	return stm_sec(stm_now());
}

uint64 st::frames()
{
	return sapp_frame_count();
}

float64 st::delta_time_sec()
{
	return sapp_frame_duration();
}

float64 st::fps()
{
	return 1.0 / st::delta_time_sec();
}

tr::Vec2<uint32> st::window_size()
{
	return engine.window_size;
}
