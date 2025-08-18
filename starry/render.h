/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/render.h
 * The renderer duh. This is an internal header that shouldn't have to be
 * used by the application itself.
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

#ifndef _ST_RENDER_H
#define _ST_RENDER_H

#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/math.h>
#include <trippin/string.h>

// shit up
struct sg_sampler_desc;

namespace st {

enum class RenderErrorType
{
	UNKNOWN,
	RESOURCE_CREATION_FAILED,
	RESOURCE_INVALID,
};

// GPUs are great, until they suck.
class RenderError : public tr::Error
{
	RenderErrorType _type;

public:
	RenderError(RenderErrorType type)
		: _type(type)
	{
	}

	tr::String message() const override;
};

#define SG_RANGE_TR_ARRAY(Array) {*(Array), (Array).len() * sizeof(decltype(Array)::Type)}

sg_sampler_desc& sampler_desc();

// from https://github.com/zeromake/learnopengl-examples/blob/master/libs/sokol/sokol_helper.h
void sg_image_alloc_smp(int image_idx, int sampler_idx);

static inline uint32 pack_texture_id(uint16 texture, uint16 texcoord)
{
	return static_cast<uint32>(texture << 16) | texcoord;
}

// It's like a vertex, but for terrain.
struct TerrainVertex
{
	tr::Vec3<float32> position;
	uint32 packed_texture_id;

	TerrainVertex(float32 x, float32 y, float32 z, uint16 texture_id, uint16 texcoord)
		: position(x, y, z)
		, packed_texture_id(st::pack_texture_id(texture_id, texcoord))
	{
	}
};

void _upload_atlas();

}

#endif
