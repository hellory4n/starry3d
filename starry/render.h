/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/render.h
 * The renderer's name is Kyler. Be nice to Kyler. Thanks.
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

#ifndef _ST_RENDER_H
#define _ST_RENDER_H

#include <trippin/math.h>
#include <trippin/memory.h>

#include "starry/world.h"

namespace st {

enum class CubeNormal : uint8
{
	FRONT = 0,
	BACK = 1,
	LEFT = 2,
	RIGHT = 3,
	TOP = 4,
	BOTTOM = 5,
};

// #pragma pack is supported by gcc, clang, and msvc :)
#pragma pack(push, 1)
// Hyper optimized blazingly fast "vertex" format for terrain
struct TerrainVertex
{
	uint8 x : 4 = 0;
	uint8 y : 4 = 0;
	uint8 z : 4 = 0;
	CubeNormal normal : 3 = CubeNormal::FRONT;
	// flags
	uint8 using_texture : 1 = false;
	uint8 billboard : 1 = false;
	uint8 shaded : 1 = true;

private:
	// TODO use it
	// we could use 5+5 bits for lengths when we add greedy meshing
	// +4 extra flags
	[[maybe_unused]]
	uint32 _reserved1 : 14 = 0;

public:
	union {
		TextureId texture_id = 0;
		tr::Color color;
	};

	uint16 chunk_pos_idx = 0;

private:
	// use for more material settings? idfk
	[[maybe_unused]]
	uint16 _reserved2 = 0;
};
#pragma pack(pop)

// just in case
static_assert(sizeof(TerrainVertex) == 12, "too bad");

// Di?h
struct Chunk
{
	// regenerating the mesh for every chunk every frame is really wasteful
	bool new_this_frame = false;
};

// TODO setting the render distance
constexpr int32 RENDER_DISTANCE = 8;
constexpr tr::Vec3<int32> RENDER_DISTANCE_VEC{RENDER_DISTANCE};

// 6 faces for a cube * chunk size^3 for a cube * render distance^3 for another cube
constexpr usize TERRAIN_VERTEX_SSBO_SIZE =
	(sizeof(TerrainVertex) * 6 * CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE /* / 2 */) *
	RENDER_DISTANCE * RENDER_DISTANCE * RENDER_DISTANCE;

void set_wireframe_mode(bool val);

// a lot of private functions
// please do not touch unless you're a friend
// (did you get the reference, do you need any pointers)

// renderer lifecycle
void _init_renderer();
void _free_renderer();
void _render();

// pipelines (setting the opengl state)
void _base_pipeline();
void _terrain_pipeline();

// actual rendering stuff
void _render_terrain();
void _update_terrain_ssbos_chunk(
	tr::Vec3<int32> pos, TerrainVertex* ssbo, Chunk chunk, uint16& chunk_pos_idx,
	uint32& instances
);
// returns the amount of quad instances required to render the current terrain
uint32 _update_terrain_ssbos();

// housekeeping / interop with the rest of the engine
void _upload_atlas(TextureAtlas atlas);

}

#endif
