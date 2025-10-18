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

#include <trippin/common.h>
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
	// +4 extra flags
	[[maybe_unused]]
	uint32 _reserved1 : 4 = 0;

public:
	union {
		TextureId texture_id = 0;
		tr::Color color;
	};

	uint16 chunk_pos_idx = 0;
	// level of detail
	uint8 lod : 4 = 0;

private:
	// yea
	[[maybe_unused]]
	uint16 _reserved2 : 12 = 0;

public:
	// bit fields are fucked :(
	operator tr::Vec3<uint32>() const
	{
		tr::Vec3<uint32> p = {};

		// lower 32 bits
		p.x |= (x & 0xFu) << 0;
		p.x |= (y & 0xFu) << 4;
		p.x |= (z & 0xFu) << 8;
		p.x |= (static_cast<uint32>(normal) & 0x7u) << 12;
		p.x |= (using_texture & 0x1u) << 15;
		p.x |= (billboard & 0x1u) << 16;
		p.x |= (shaded & 0x1u) << 17;

		// next 32 bits
		// texture_id is conveniently copied here too since it's a union
		p.y |= (color.r & 0xFFu) << 0;
		p.y |= (color.g & 0xFFu) << 8;
		p.y |= (color.b & 0xFFu) << 16;
		p.y |= (color.a & 0xFFu) << 24;

		// last 32 bits
		p.z |= (chunk_pos_idx & 0xFFFFu) << 0;
		p.z |= (lod & 0xFu) << 16;

		return p;
	}
};

// just in case
static_assert(sizeof(tr::Vec3<uint32>) == 12, "too bad");

// Di?h
struct Chunk
{
	tr::Array<Model> blocks = {};
	// regenerating the mesh for every chunk every frame is really wasteful
	bool new_this_frame = false;

	Chunk();
	Model& operator[](tr::Vec3<uint8> local_pos);
	Model& operator[](tr::Vec3<int32> pos)
	{
		// catchy
		return (*this)[(pos - (st::block_to_chunk_pos(pos) * CHUNK_SIZE)).cast<uint8>()];
	}

	tr::Maybe<Model&> try_get(tr::Vec3<uint8> local_pos);
	tr::Maybe<Model&> try_get(tr::Vec3<int32> pos)
	{
		return try_get((pos - (st::block_to_chunk_pos(pos) * CHUNK_SIZE)).cast<uint8>());
	}
};

inline usize _terrain_ssbo_size(uint32 render_distance)
{
	// 6 faces for a cube * chunk size^3 for a cube / 2 bcuz that's the max you can fit before
	// it gets culled * render distance^3 for another cube
	// FIXME this is most likely *more* than the standard's SSBO size limit of 128 MB, it is up
	// to the drivers to accept more than that
	return (6 * CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE / 2) * render_distance * render_distance *
	       render_distance;
}

void set_wireframe_mode(bool val);
// Sets the render distnace :))))) (default = 16)
void set_render_distance(uint32 chunks);

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
// waits on a loop for updates from the main thread
void _terrain_update_thread();
void _terrain_update_thread_write_ssbo();
void _terrain_update_thread_write_chunk(
	tr::Vec3<int32> pos, Chunk chunk, uint16& chunk_pos_idx, uint32& instances
);
void _terrain_update_thread_write_block(
	tr::Vec3<int32> pos, Chunk chunk, Model model, uint16 chunk_pos_idx, uint32& instances
);

// housekeeping / interop with the rest of the engine
void _upload_atlas(TextureAtlas atlas);

}

#endif
