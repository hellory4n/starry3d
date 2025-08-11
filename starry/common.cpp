/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/common.cpp
 * Utilities, engine initialization/deinitialization, and the engine's
 * global state.
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

#include "starry/common.h"

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
#include "starry/render.h"

namespace st {

// it has to live somewhere
Starry3D engine;
tr::Signal<void> on_close(engine.arena);

// sokol callbacks
static void _init();
static void _update();
static void _free();
static void _on_event(const sapp_event* event);

} // namespace st

void st::run(st::Application& app, st::ApplicationSettings settings)
{
	st::engine.application = &app;
	st::engine.settings = settings;
	st::engine.window_size = settings.window_size;

	// hehe
	stm_setup();

	// how the app is initialized:
	// main -> st::init -> sapp_run -> st::init_starry -> Application.init
	// quite the pickle
	sapp_desc sokol_app = {};

	sokol_app.init_cb = st::_init;
	sokol_app.frame_cb = st::_update;
	sokol_app.cleanup_cb = st::_free;
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

static void st::_init()
{
	// TODO this function is kinda ugly
	if (st::engine.settings.user_dir == "") {
		st::engine.settings.user_dir = st::engine.settings.name;
	}
	tr::set_paths(st::engine.settings.app_dir, st::engine.settings.user_dir);

	// TODO this could be a thing in libtrippin
	for (auto [_, path] : st::engine.settings.logfiles) {
		tr::use_log_file(path);
	}

	tr::init();
	// we have to do this fuckery so there's no fuckery of sokol calling st::__free which calls
	// tr::free which calls st::__free
	// this should only happen on panic (sokol will handle it when quitting normally)
	// TODO i updated tr::call_on_quit for this but i can't be bothered to make it work like
	// that
	tr::call_on_quit([](bool) {
		if (!st::engine.exiting) {
			st::_free();
		}
	});

	tr::info("initialized starry3d %s", st::VERSION);
	// some debug info
	// TODO sokol supports more but i doubt i'll support them any time soon
#ifdef ST_WINDOWS
	tr::info("windowing backend: Win32");
#elif defined(ST_APPLE)
	tr::info("windowing backend: Cocoa");
#else
	tr::info("windowing backend: X11");
#endif

#ifdef SOKOL_GLCORE
	tr::info("graphics backend: OpenGL Core");
#elif defined(SOKOL_GLES)
	tr::info("graphics backend: OpenGL ES");
#elif defined(SOKOL_D3D11)
	tr::info("graphics bakend: Direct3D 11");
#elif defined(SOKOL_METAL)
	tr::info("graphics backend: Metal");
#endif

	tr::info("app:// pointing to %s", *tr::path(tr::scratchpad(), "app://"));
	tr::info("user:// pointing to %s", *tr::path(tr::scratchpad(), "user://"));

	// make sure user:// and app:// exists
	tr::String userdir = tr::path(tr::scratchpad(), "user://");
	tr::create_dir(userdir).unwrap();
	TR_ASSERT_MSG(tr::file_exists(userdir), "couldn't create user://");
	TR_ASSERT_MSG(
		tr::file_exists(tr::path(tr::scratchpad(), "app://")),
		"app:// is pointing to an invalid directory, are you sure this is the right path?"
	);

	st::_init_renderer();
#ifdef ST_IMGUI
	st::imgui::init();
#endif
	st::engine.application->init().unwrap();
}

static void st::_update()
{
	// uh
	if (!st::engine.mouse_moved_this_frame) {
		st::engine.relative_mouse_position = {};
	}
	st::engine.mouse_moved_this_frame = false;

#ifdef ST_IMGUI
	st::imgui::update();
#endif

	st::engine.application->update(sapp_frame_duration()).unwrap();
	st::_draw();

	// update key states
	for (auto [_, key] : st::engine.key_state) {
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
	for (auto [_, mouse] : st::engine.mouse_state) {
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

static void st::_free()
{
	st::engine.exiting = true;

	tr::info("freeing application...");
	st::engine.application->free().unwrap();

#ifdef ST_IMGUI
	st::imgui::free();
#endif
	st::_free_renderer();
	tr::info("deinitialized starry3d");
	// TODO libtrippin deinitializes twice on panic
	// i should just add some way of checking if it's panicking on tr::call_on_quit()
	tr::free();
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
		st::engine.key_state[event->key_code].pressed = true;
		st::engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_KEY_UP:
		st::engine.key_state[event->key_code].pressed = false;
		st::engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_MOUSE_DOWN:
		st::engine.mouse_state[event->mouse_button].pressed = true;
		st::engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_MOUSE_UP:
		st::engine.mouse_state[event->mouse_button].pressed = false;
		st::engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_MOUSE_MOVE:
		st::engine.mouse_position = {event->mouse_x, event->mouse_y};
		st::engine.relative_mouse_position = {event->mouse_dx, event->mouse_dy};
		st::engine.mouse_moved_this_frame = true;
		st::engine.current_modifiers =
			static_cast<Modifiers>(event->modifiers); // the values are the same
		break;

	case SAPP_EVENTTYPE_QUIT_REQUESTED:
		st::on_close.emit();
		break;

	case SAPP_EVENTTYPE_RESIZED:
		st::engine.window_size = {
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

void st::_sokol_log(
	const char* tag, uint32 level, uint32 item_id, const char* msg_or_null, uint32 line_nr,
	const char* filename_or_null, void* user_data
)
{
	// shut up
	(void)tag;
	(void)user_data;
	(void)filename_or_null;
	(void)line_nr;

	const char* msg = msg_or_null == nullptr ? "unknown message" : msg_or_null;

	switch (level) {
	case 0:
		tr::panic("sokol panic (item id %u): %s", item_id, msg);
		break;
	case 1:
		tr::error("sokol error (item id %u): %s", item_id, msg);
		break;
	case 2:
		tr::warn("sokol warning (item id %u): %s", item_id, msg);
		break;
	default:
		tr::info("sokol (item id %u): %s", item_id, msg);
		break;
	}
}

void st::close_window()
{
	sapp_request_quit();
}

bool st::is_key_just_pressed(st::Key key)
{
	return st::engine.key_state[static_cast<usize>(key)].state ==
	       InputState::State::JUST_PRESSED;
}

bool st::is_key_just_released(st::Key key)
{
	return st::engine.key_state[static_cast<usize>(key)].state ==
	       InputState::State::JUST_RELEASED;
}

bool st::is_key_held(st::Key key)
{
	return st::engine.key_state[static_cast<usize>(key)].state !=
	       InputState::State::NOT_PRESSED;
}

bool st::is_key_not_pressed(st::Key key)
{
	return st::engine.key_state[static_cast<usize>(key)].state ==
	       InputState::State::NOT_PRESSED;
}

bool st::is_mouse_just_pressed(st::MouseButton btn)
{
	return st::engine.mouse_state[static_cast<usize>(btn)].state ==
	       InputState::State::JUST_PRESSED;
}

bool st::is_mouse_just_released(st::MouseButton btn)
{
	return st::engine.mouse_state[static_cast<usize>(btn)].state ==
	       InputState::State::JUST_RELEASED;
}

bool st::is_mouse_held(st::MouseButton btn)
{
	return st::engine.mouse_state[static_cast<usize>(btn)].state !=
	       InputState::State::NOT_PRESSED;
}

bool st::is_mouse_not_pressed(st::MouseButton btn)
{
	return st::engine.mouse_state[static_cast<usize>(btn)].state ==
	       InputState::State::NOT_PRESSED;
}

tr::Vec2<float32> st::mouse_position()
{
	return st::engine.mouse_position;
}

tr::Vec2<float32> st::relative_mouse_position()
{
	return st::engine.relative_mouse_position;
}

st::Modifiers st::modifiers()
{
	return st::engine.current_modifiers;
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
	return st::engine.window_size;
}
