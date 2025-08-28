/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/internal.h
 * Internal parts of the library. Should NEVER be included by the other
 * library's headers
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

#ifndef _ST_INTERNAL_H
#define _ST_INTERNAL_H

#include <trippin/common.h>
#include <trippin/memory.h>

#include <rgfw/RGFW.h>

#include "starry/app.h"

namespace st {

struct Starry
{
	// i know this order is horrible for alignment, i don't care

	tr::Arena arena;
	tr::Arena asset_arena;
	Application* application = nullptr;
	ApplicationSettings settings = {};

	// timing
	float64 prev_time = 0;
	float64 current_time = 0;
	float64 delta_time = 0;

	// window
	RGFW_window* window = nullptr;
	tr::Vec2<uint32> window_size = {};

	// input
	tr::Array<InputState> key_state = {};
	tr::Array<InputState> mouse_state = {};

	Starry(tr::Arena arena, tr::Arena asset_arena)
		: arena(arena)
		, asset_arena(asset_arena)
	{
		key_state = tr::Array<InputState>(arena, static_cast<int>(st::Key::LAST) + 1);
		mouse_state =
			tr::Array<InputState>(arena, static_cast<int>(st::MouseButton::LAST) + 1);
	}
};

// This is where the engine's internal state goes. You probably shouldn't use this directly.
extern Starry* _st;

// inits:
// - libtrippin
// - the engine's state
// - app:// and user:// (as well as checking if they exist)
void _preinit();

// stupid name i know
void _postfree();

}

#endif
