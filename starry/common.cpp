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

#include "window.hpp"
#include "common.hpp"

namespace st {
	// it has to live somewhere
	Starry3D engine;
}

void st::init()
{
	st::engine.key_state = tr::Array<InputState>(st::engine.arena, int(st::Key::LAST) + 1);
	st::engine.key_prev_down = tr::Array<bool>(st::engine.arena, int(st::Key::LAST) + 1);
	st::engine.mouse_state = tr::Array<InputState>(st::engine.arena, int(st::MouseButton::LAST) + 1);
	st::engine.mouse_prev_down = tr::Array<bool>(st::engine.arena, int(st::MouseButton::LAST) + 1);

	tr::info("initialized starry3d %s", st::VERSION);
}

void st::free()
{
	tr::info("deinitialized starry3d");
}
