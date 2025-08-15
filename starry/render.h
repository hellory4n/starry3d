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

#include <sokol/sokol_gfx.h>

#include "trippin/string.h"

namespace st {

// The renderer's state. Not in the main engine
struct Renderer
{
	tr::MaybePtr<sg_pipeline> pipeline = {};
	sg_pipeline basic_pipeline = {};

	sg_bindings bindings = {};
	sg_pass_action pass_action = {};
};

extern Renderer renderer;

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

// TODO update to c++20 you cunt
static inline sg_sampler_desc& sampler_desc()
{
	static sg_sampler_desc sampling_it = {};
	sampling_it.wrap_u = SG_WRAP_REPEAT;
	sampling_it.wrap_v = SG_WRAP_REPEAT;
	sampling_it.min_filter = SG_FILTER_LINEAR;
	sampling_it.mag_filter = SG_FILTER_LINEAR;
	sampling_it.compare = SG_COMPAREFUNC_NEVER;
	return sampling_it;
}

// from https://github.com/zeromake/learnopengl-examples/blob/master/libs/sokol/sokol_helper.h
static inline void sg_image_alloc_smp(int image_idx, int sampler_idx)
{
	st::renderer.bindings.images[image_idx] = sg_alloc_image();
	st::renderer.bindings.samplers[sampler_idx] = sg_alloc_sampler();
	sg_init_sampler(st::renderer.bindings.samplers[sampler_idx], st::sampler_desc());
}

// internal :)
void _init_renderer();
void _free_renderer();
void _draw();

} // namespace st

#endif
