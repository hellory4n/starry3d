/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/internal.cpp
 * Internal parts of the library :)
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

#include "starry/internal.h"

#include <trippin/common.h>
#include <trippin/iofs.h>
#include <trippin/log.h>

#include "starry/app.h"
#ifdef ST_IMGUI
	#include "starry/optional/imgui.h"
#endif

namespace st {

// it has to live somewhere
Starry3D engine = {};
tr::Signal<void> on_close(engine.arena);

}

void st::_init_engine()
{
	st::_init::preinit();
	st::_init::app();
	st::_init::render();
#ifdef ST_IMGUI
	st::imgui::init();
#endif
	st::_init::asset();
	st::_init::world();
	engine.application->init().unwrap();
}

void st::_free_engine()
{
	engine.application->free().unwrap();
	st::_free::world();
	st::_free::asset();
#ifdef ST_IMGUI
	st::imgui::free();
#endif
	st::_free::render();
	st::_free::app();
	st::_free::postfree();
}

void st::_update_engine()
{
	// TODO are you sure about this order
	st::_update::pre_input();
#ifdef ST_IMGUI
	st::imgui::update();
#endif
	engine.application->update(st::delta_time_sec()).unwrap();
	st::_update::render();
#ifdef ST_IMGUI
	st::imgui::render();
#endif
	st::_update::post_input();
}

void st::_init::preinit()
{
	if (engine.settings.user_dir == "") {
		engine.settings.user_dir = engine.settings.name;
	}
	tr::set_paths(engine.settings.app_dir, engine.settings.user_dir);

	// TODO this could be a thing in libtrippin
	for (auto [_, path] : engine.settings.logfiles) {
		tr::use_log_file(path);
	}

	tr::init();
	tr::call_on_quit([](bool is_panic) {
		// sokol handles calling st::_free_engine when quitting safely ;)
		if (!is_panic) {
			st::_free_engine();
		}
	});

	tr::info("starry3d %s", st::VERSION);
	// some debug info
	// TODO sokol supports more but i doubt i'll support them any time soon
#ifdef _WIN32
	tr::info("windowing backend: Win32");
#elif defined(__APPLE__)
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
	TR_ASSERT_MSG(tr::path_exists(userdir), "couldn't create user://");
	TR_ASSERT_MSG(
		tr::path_exists(tr::path(tr::scratchpad(), "app://")),
		"app:// is pointing to an invalid directory, are you sure this is the right path?"
	);

	engine.key_state = tr::Array<InputState>(engine.arena, static_cast<int>(st::Key::LAST) + 1);
	engine.mouse_state =
		tr::Array<InputState>(engine.arena, static_cast<int>(st::MouseButton::LAST) + 1);
	engine.textures = tr::HashMap<tr::String, Texture>(engine.asset_arena);

	tr::info("preinitialized successfully");
}

void st::_free::postfree()
{
	engine.arena.free();
	engine.asset_arena.free();
}

void st::_sokol_log(
	const char* tag, uint32 level, uint32 item_id, const char* msg_or_null, uint32 line_nr,
	const char* filename_or_null, void* user_data
)
{
	// shut up
	(void)tag;
	(void)user_data;

	const char* msg = msg_or_null == nullptr ? "unknown message" : msg_or_null;
	const char* file = filename_or_null == nullptr ? "unknown" : filename_or_null;

	switch (level) {
	case 0:
		tr::panic("sokol panic @ %s:%u (item id %u): %s", file, line_nr, item_id, msg);
		break;
	case 1:
// tr::panic is more useful than tr::error when developing the library
#ifndef DEBUG
		tr::error("sokol error @ %s:%u (item id %u): %s", file, line_nr, item_id, msg);
#else
		tr::panic("sokol error @ %s:%u (item id %u): %s", file, line_nr, item_id, msg);
#endif
		break;
	case 2:
		tr::warn("sokol warning @ %s:%u (item id %u): %s", file, line_nr, item_id, msg);
		break;
	default:
		tr::info("sokol @ %s:%u (item id %u): %s", file, line_nr, item_id, msg);
		break;
	}
}
