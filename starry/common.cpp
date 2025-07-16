/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * st_common.cpp
 * Utilities, engine initialization/deinitialization, and the
 * engine's global state
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

#include <trippin/common.hpp>
#include <trippin/log.hpp>
#include <trippin/iofs.hpp>

// help.
#define SOKOL_GLCORE
#define SOKOL_ASSERT(X) TR_ASSERT(X)
#define SOKOL_UNREACHABLE() tr::panic("unreachable code from sokol")
#define SOKOL_NO_ENTRY
#define SOKOL_IMPL
// it's one single line
// TODO i'll definitely forget to remove this when it's fixed
TR_GCC_IGNORE_WARNING(-Wmissing-field-initializers)
#include <thirdparty/sokol/sokol_app.h>
TR_GCC_RESTORE()
#include <thirdparty/sokol/sokol_time.h>

#include "common.hpp"

namespace st {
	// it has to live somewhere
	Starry3D engine;

	// sokol callbacks
	static void __init();
	static void __update();
	static void __free();
	static void __event(const sapp_event* event);
	// it's a hassle
	static void __sokol_log(const char* tag, uint32 level, uint32 item_id, const char* msg_or_null,
		uint32 line_nr, const char* filename_or_null, void* user_data
	);
}

void st::run(st::Application& app, st::ApplicationSettings settings)
{
	st::engine.application = &app;
	st::engine.settings = settings;

	// hehe
	stm_setup();

	// how the app is initialized:
	// main -> st::init -> sapp_run -> st::init_starry -> Application.init
	// quite the pickle
	sapp_desc sokol_app = {};

	sokol_app.init_cb = st::__init;
	sokol_app.frame_cb = st::__update;
	sokol_app.cleanup_cb = st::__free;
	sokol_app.event_cb = st::__event;
	sokol_app.logger.func = st::__sokol_log;

	sokol_app.width = settings.window_size.x;
	sokol_app.height = settings.window_size.y;
	sokol_app.window_title = settings.name;
	sokol_app.swap_interval = settings.vsync ? 1 : 0;
	sokol_app.high_dpi = settings.high_dpi;
	sokol_app.fullscreen = settings.fullscreen;

	// we need SSBOs :)
	// TODO does sokol support that?
	sokol_app.gl_major_version = 4;
	sokol_app.gl_minor_version = 3;

	sapp_run(sokol_app);
}

static void st::__init()
{
	// st::engine.key_state = tr::Array<InputState>(st::engine.arena, int(st::Key::LAST) + 1);
	// st::engine.key_prev_down = tr::Array<bool>(st::engine.arena, int(st::Key::LAST) + 1);
	// st::engine.mouse_state = tr::Array<InputState>(st::engine.arena, int(st::MouseButton::LAST) + 1);
	// st::engine.mouse_prev_down = tr::Array<bool>(st::engine.arena, int(st::MouseButton::LAST) + 1);

	if (st::engine.settings.user_dir == "") {
		st::engine.settings.user_dir = st::engine.settings.name;
	}
	tr::set_paths(st::engine.settings.app_dir, st::engine.settings.user_dir);

	// TODO this could be a thing in libtrippin
	for (auto [_, path] : st::engine.settings.logfiles) {
		tr::use_log_file(path);
	}

	tr::init();

	tr::info("initialized starry3d %s", st::VERSION);
	st::engine.application->init();
}

static void st::__update()
{
	st::engine.prev_time = st::engine.current_time;
	st::engine.current_time = stm_sec(stm_now());
	float64 delta_time = st::engine.current_time - st::engine.prev_time;

	st::engine.application->update(delta_time);
}

static void st::__free()
{
	st::engine.application->free();
	tr::free();
}

static void st::__event(const sapp_event* event)
{
	// TODO do something with it
	(void)event;
}

static void st::__sokol_log(const char* tag, uint32 level, uint32 item_id, const char* msg_or_null,
	uint32 line_nr, const char* filename_or_null, void* user_data)
{
	// shut up
	(void)tag;
	(void)user_data;
	(void)filename_or_null;
	(void)line_nr;

	const char* msg = msg_or_null == nullptr ? "unknown message" : msg_or_null;

	// i could convert the item id to readable messages but i don't want to
	switch (level) {
		case 0: tr::panic("sokol panic (item id %u): %s", item_id, msg); break;
		case 1: tr::error("sokol error (item id %u): %s", item_id, msg); break;
		case 2: tr::warn("sokol warning (item id %u): %s", item_id, msg); break;
		case 3: tr::info("sokol (item id %u): %s", item_id, msg); break;
	}
}
