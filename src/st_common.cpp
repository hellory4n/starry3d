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

// yes this is intentional idc
// at the beginning bcuz it fucks wiht the standard headers on linux
#include <whereami.c>

#include "st_common.hpp"

#include "st_window.hpp"

#include <libtrippin.hpp>

namespace st {
	// it has to live somewhere
	Starry3D engine;
}

void st::init(tr::String app_name, tr::String asset_dir)
{
	st::engine.arena = new tr::Arena(tr::mb_to_bytes(1));

	st::engine.key_state = tr::Array<InputState>(st::engine.arena, static_cast<int>(st::Key::LAST) + 1);
	st::engine.key_prev_down = tr::Array<bool>(st::engine.arena, static_cast<int>(st::Key::LAST) + 1);
	st::engine.mouse_state = tr::Array<InputState>(st::engine.arena, static_cast<int>(st::MouseButton::LAST) + 1);
	st::engine.mouse_prev_down = tr::Array<bool>(st::engine.arena, static_cast<int>(st::MouseButton::LAST) + 1);

	// man
	st::engine.app_dir = tr::String(st::engine.arena, "", 1024);
	int dirname_len;
	wai_getExecutablePath(st::engine.app_dir, st::engine.app_dir.length(), &dirname_len);
	st::engine.app_dir[dirname_len] = '\0';
	st::engine.app_dir = tr::sprintf(st::engine.arena, 1024, "%s/%s", st::engine.app_dir.buffer(),
		asset_dir.buffer()
	);
	tr::info("app:// is pointing to %s", st::engine.app_dir.buffer());

	// woman
	#ifdef ST_WINDOWS
	char* appdata = getenv("APPDATA");
	st::engine.user_dir = tr::sprintf(st::engine.arena, 1024, "%s/%s", appdata, app_name.buffer());
	#else
	char* home = getenv("HOME");
	st::engine.user_dir = tr::sprintf(st::engine.arena, 1024, "%s/.local/share/%s", home, app_name.buffer());
	#endif
	tr::info("user:// is pointing to %s", st::engine.user_dir.buffer());

	tr::info("initialized starry3d %s", st::VERSION);
}

void st::free()
{
	delete st::engine.arena;
	tr::info("deinitialized starry3d");
}

tr::String path(tr::Ref<tr::Arena> arena, tr::String from)
{
	if (from.starts_with("app://")) {
		tr::String pathfrfr = from.substr(arena, 6, from.length() + 1);
		return tr::sprintf(arena, 1024, "%s/%s", st::engine.app_dir.buffer(), pathfrfr.buffer());
	}
	else if (from.starts_with("user://")) {
		tr::String pathfrfr = from.substr(arena, 7, from.length() + 1);
		return tr::sprintf(arena, 1024, "%s/%s", st::engine.user_dir.buffer(), pathfrfr.buffer());
	}

	// justin case
	#ifdef DEBUG
	if (!from.is_absolute()) {
		tr::warn("%s is relative, did you mean \"app://%s\"?", from.buffer(), from.buffer());
	}
	#endif

	// ok there's nothing just duplicate it
	return from.duplicate(arena);
}
