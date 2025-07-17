/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * common.cpp
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
#define SOKOL_APP_IMPL
// it's one single line
// TODO i'll definitely forget to remove this when it's fixed
TR_GCC_IGNORE_WARNING(-Wmissing-field-initializers)
#include <sokol/sokol_app.h>
TR_GCC_RESTORE()
#define SOKOL_TIME_IMPL
#include <sokol/sokol_time.h>

#include "common.hpp"
#include "imgui.hpp"
#include "render.hpp"

namespace st {
	// it has to live somewhere
	Starry3D engine;

	// sokol callbacks
	static void __init();
	static void __update();
	static void __free();
	static void __event(const sapp_event* event);
	// it's a hassle
	void __sokol_log(const char* tag, uint32 level, uint32 item_id, const char* msg_or_null,
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
	sokol_app.enable_clipboard = true;

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
	// TODO this fails bcuz sokol calls st::__free, which calls tr::free, which calls st::__free
	// i only wanted for it to be called on panic
	// tr::call_on_quit(st::__free);

	tr::info("initialized starry3d %s", st::VERSION);

	st::__init_renderer();
	#ifdef ST_IMGUI
	st::imgui::init();
	#endif
	st::engine.application->init();
}

static void st::__update()
{
	#ifdef ST_IMGUI
	st::imgui::update();
	#endif

	st::engine.application->update(sapp_frame_duration());
	st::__draw();
}

static void st::__free()
{
	st::engine.application->free();
	#ifdef ST_IMGUI
	st::imgui::free();
	#endif
	st::__free_renderer();
	tr::free();
}

static void st::__event(const sapp_event* event)
{
	// TODO do something with it
	(void)event;
	#ifdef ST_IMGUI
	st::imgui::on_event(event);
	#endif
}

void st::__sokol_log(const char* tag, uint32 level, uint32 item_id, const char* msg_or_null,
	uint32 line_nr, const char* filename_or_null, void* user_data)
{
	// shut up
	(void)tag;
	(void)user_data;
	(void)filename_or_null;
	(void)line_nr;

	const char* msg = msg_or_null == nullptr ? "unknown message" : msg_or_null;

	switch (level) {
		case 0: tr::panic("sokol panic (item id %u): %s", item_id, msg); break;
		case 1: tr::error("sokol error (item id %u): %s", item_id, msg); break;
		case 2: tr::warn("sokol warning (item id %u): %s", item_id, msg); break;
		case 3: tr::info("sokol (item id %u): %s", item_id, msg); break;
	}
}
