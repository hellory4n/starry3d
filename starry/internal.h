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

// sokol config
#if defined(_WIN32)
	#define SOKOL_D3D11
#elif defined(__APPLE__)
	#define SOKOL_METAL
#else
	#define SOKOL_GLCORE
#endif

#define SOKOL_ASSERT(X) TR_ASSERT(X)
#define SOKOL_UNREACHABLE TR_UNREACHABLE()
#define SOKOL_NO_ENTRY

#include <trippin/common.h>
#include <trippin/memory.h>

#include <sokol/sokol_gfx.h>

#include "starry/app.h"
#include "starry/asset.h"
#include "starry/world.h"

namespace st {

struct Starry3D
{
	// i know this order is horrible for alignment, i don't care

	tr::Arena arena = {};
	tr::Arena asset_arena = {};
	Application* application = nullptr;
	ApplicationSettings settings = {};
	// i wanted it to free on panic using libtrippin's `tr::call_on_quit` it's complicated
	// TODO this sucks, fix it
	// bool exiting = false;

	// input
	tr::Array<InputState> key_state = {};
	tr::Array<InputState> mouse_state = {};
	Modifiers current_modifiers = {};
	tr::Vec2<float32> mouse_position = {};
	tr::Vec2<float32> relative_mouse_position = {};
	bool mouse_moved_this_frame = false;
	tr::Vec2<uint32> window_size = {};

	// renderer
	tr::MaybePtr<sg_pipeline> pipeline = {};
	sg_pipeline terrain_pipeline = {};
	sg_bindings bindings = {};
	sg_pass_action pass_action = {};
	tr::Maybe<TextureAtlas> current_atlas = {};
	// you can't set uniforms any time you want
	// so TextureAtlas sets this to true, the renderer looks at it, uploads the atlas, and sets
	// it back to false
	// i don't think anyone is gonna be setting the atlas multiple times but i don't care
	bool pls_upload_the_atlas_to_the_gpu = false;

	// world
	Camera camera = {};

	// assets
	tr::HashMap<tr::String, Texture> textures = {};
};

// This is where the engine's internal state goes. You probably shouldn't use this directly.
extern Starry3D engine;

// the life of a game engine <3
// this should be in the order in which they are called
namespace _init {
	// inits:
	// - libtrippin
	// - the engine's state
	// - app:// and user:// (as well as checking if they exist)
	void preinit();

	// implemented in starry/app.cpp
	void app();

	// implemented in starry/render.cpp
	void render();

	// implemented in starry/asset.cpp
	void asset();

	// implemented in starry/world.cpp
	void world();
}

void _init_engine();

// of course it has to be deinitialized too
// this should be in the reverse order as _init
namespace _free {
	// implemented in starry/world.cpp
	void world();
	// implemented in starry/asset.cpp
	void asset();
	// implemented in starry/render.cpp
	void render();
	// implemented in starry/app.cpp
	void app();
	// stupid name i know
	void postfree();
}

void _free_engine();

// update the engine lol
// this runs every frame
namespace _update {
	// implemented in starry/app.cpp
	void pre_input();

	// implemented in starry/render.cpp
	void render();

	// implemented in starry/app.cpp
	void post_input();
}

void _update_engine();

// Internal function so sokol uses libtrippin's logging functions :)
void _sokol_log(
	const char* tag, uint32 level, uint32 item_id, const char* msg_or_null, uint32 line_nr,
	const char* filename_or_null, void* user_data
);

}

#endif
