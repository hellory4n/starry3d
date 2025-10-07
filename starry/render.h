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

#include "starry/gpu.h"
#include "starry/world.h"

namespace st {

// As the name implies, it's the vertex for terrain. Note this is actually not the real vertex
// format though, the real format is `st::PackedModelVertex` which puts everything together into an
// `uint64` (as a normal struct would have padding and waste space, it'd also be incompatible with
// glsl which only has 32-bit ints)
struct TerrainVertex
{
	// Using a Vec3<float32> would take up too much space
	enum class Normal : uint8
	{
		FRONT = 0,
		BACK = 1,
		LEFT = 2,
		RIGHT = 3,
		TOP = 4,
		BOTTOM = 5,
	};

	tr::Vec3<uint8> position = {};
	Normal normal = Normal::FRONT;
	bool shaded = true;
	bool using_texture = false;
	bool billboard = false;
	union {
		TextureId texture_id;
		tr::Color color = tr::COLOR_WHITE;
	};
};

// #pragma pack is supported by gcc, clang, and msvc :)
#pragma pack(push, 1)
// Like a TerrainVertex, but more packed (uses less space (blazingly fast (money mouth emoji)))
struct PackedTerrainVertex
{
	uint8 x : 5, y : 5, z : 5;
	uint8 normal : 3;
	// flags
	uint8 using_texture : 1;
	uint8 billboard : 1;
	uint8 shaded : 1;

private:
	// TODO use it
	// we could use 5+5 bits for lengths when we add greedy meshing
	// +1 extra flag
	uint32 _reserved : 11;

public:
	union {
		TextureId texture_id = 0;
		tr::Color color;
	};

	PackedTerrainVertex(TerrainVertex src);
	operator tr::Vec2<uint32>() const;
};
#pragma pack(pop)

// just in case
static_assert(sizeof(PackedTerrainVertex) == 8, "uh oh");

// Di?h
struct Chunk
{
	Mesh mesh = {};
	// regenerating the mesh for every chunk every frame is really wasteful
	bool new_this_frame = false;
};

// TODO setting the render distance
constexpr tr::Vec3<int32> RENDER_DISTANCE{16};

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
void _render_chunk(Chunk& chunk, tr::Vec3<int32> pos);

// housekeeping / interop with the rest of the engine
void _upload_atlas(TextureAtlas atlas);
void _refresh_chunk(Chunk& chunk, tr::Vec3<int32> pos);

void set_wireframe_mode(bool val);

}

#endif
