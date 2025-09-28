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

#include "starry/world.h"

namespace st {

// As the name implies, it's the vertex for models. Note this is actually not the real vertex format
// though, the real format is `st::PackedModelVertex` which puts everything together into an
// `uint64` (as a normal struct would have padding and waste space)
struct ModelVertex
{
	// Using a Vec3<float32> would take up too much space
	enum class Normal : uint8
	{
		FORWARD = 0,
		BACK = 1,
		LEFT = 2,
		RIGHT = 3,
		UP = 4,
		DOWN = 5,
	};

	enum class QuadCorner : uint8
	{
		TOP_LEFT = 0,
		TOP_RIGHT = 1,
		BOTTOM_LEFT = 2,
		BOTTOM_RIGHT = 3,
	};

	tr::Vec3<uint8> position = {};
	Normal normal = Normal::FORWARD;
	QuadCorner corner = QuadCorner::TOP_LEFT;
	bool shaded = true;
	bool using_texture = false;
	bool billboard = false;
	union {
		TextureId texture_id;
		tr::Color color = tr::palette::WHITE;
	};
};

// Like a PackedModelVertex, but more efficient.
// The format is: (roughly)
// ```cpp
// struct ModelVertex {
//	tr::Vec3<uint8> position;
//	uint3 normal;
//	uint2 quad;
//	uint1 shaded;
//	uint1 using_texture;
//	uint1 billboard;
//	union {
//		uint14 texture_id;
//		tr::Color color;
//	};
// };
// ```
struct PackedModelVertex
{
	uint32 x;
	uint32 y;

	PackedModelVertex(ModelVertex src);
};

// some functions to set the opengl state
void _test_pipeline();

void set_wireframe_mode(bool val);

}

#endif
