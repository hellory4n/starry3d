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
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/util.h>

#include <GLFW/glfw3.h>

#include "starry/app.h"
#include "starry/gpu.h"
#include "starry/render.h"
#include "starry/world.h"

namespace st {

struct Starry
{
	// i know this order is horrible for alignment, i don't care

	tr::Arena& arena;
	tr::Arena& asset_arena;
	tr::Arena& world_arena;
	tr::Arena& render_arena;
	Application* application = nullptr;
	ApplicationSettings settings = {};

	// timing
	float64 prev_time = 0;
	float64 current_time = 0;
	float64 delta_time = 0;

	// window
	GLFWwindow* window = nullptr;
	tr::Vec2<uint32> window_size = {};

	// input
	tr::Array<InputState> key_state;
	tr::Array<InputState> mouse_state;
	tr::Vec2<float64> prev_mouse_pos = {};
	tr::Vec2<float64> current_mouse_pos = {};
	tr::Vec2<float64> delta_mouse_pos = {};

	// rendering
	ShaderProgram* terrain_shader = nullptr;
	StorageBuffer atlas_ssbo = {};
	StorageBuffer terrain_vertex_ssbo = {};
	tr::HashMap<tr::Vec3<int32>, Chunk> chunks;
	tr::Vec3<int32> prev_chunk;

	// assets
	tr::Maybe<TextureAtlas> atlas = {};
	tr::HashMap<Model, ModelSpec> models;

	// world
	Camera camera = {};
	tr::Vec3<uint8> grid_size = {8, 8, 8};
	tr::HashMap<tr::Vec3<int32>, Block> terrain_blocks;
	tr::HashMap<tr::Vec3<int32>, Block> static_blocks;
	// TODO how tf do you store the dynamic blocks

	Starry(tr::Arena& arena, tr::Arena& asset_arena, tr::Arena& world_arena,
	       tr::Arena& render_arena)
		: arena(arena)
		, asset_arena(asset_arena)
		, world_arena(world_arena)
		, render_arena(render_arena)
	{
		key_state = tr::Array<InputState>(arena, int(st::Key::LAST) + 1);
		mouse_state = tr::Array<InputState>(arena, int(st::MouseButton::LAST) + 1);
		models = tr::HashMap<Model, ModelSpec>(asset_arena);
		terrain_blocks = tr::HashMap<tr::Vec3<int32>, Block>(world_arena);
		static_blocks = tr::HashMap<tr::Vec3<int32>, Block>(world_arena);
		chunks = tr::HashMap<tr::Vec3<int32>, Chunk>(render_arena);
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
