/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/render.cpp
 * The renderer duh
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

// TODO this is still a insane mess

#include <trippin/common.h>
#include <trippin/math.h>
#include <trippin/memory.h>

#include "starry/internal.h"
#include "starry/world.h"

// :(
TR_GCC_IGNORE_WARNING(-Wold-style-cast)
TR_GCC_IGNORE_WARNING(-Wimplicit-int-conversion)
TR_GCC_IGNORE_WARNING(-Wcast-qual)
TR_GCC_IGNORE_WARNING(-Wextra) // this is why clang is better
#include <sokol/sokol_app.h>
#define SOKOL_GFX_IMPL
#include <sokol/sokol_gfx.h>

#ifdef ST_IMGUI
	#include "starry/optional/imgui.h"
#endif
#include "starry/render.h"
#define SOKOL_GLUE_IMPL
#include <sokol/sokol_glue.h>
#include <stb/stb_image.h>

#include "starry/shader/terrain.glsl.h"
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()

namespace st {

static inline sg_color tr_color_to_sg_color(tr::Color color)
{
	auto colorf = static_cast<tr::Vec4<float32>>(color);
	return {colorf.x, colorf.y, colorf.z, colorf.w};
}

static inline void make_terrain_pipeline()
{
	// idfk what am i doing
	sg_shader shader = sg_make_shader(terrain_shader_desc(sg_query_backend()));

	sg_pipeline_desc pipeline_desc = {};

	pipeline_desc.shader = shader;
	pipeline_desc.layout.attrs[ATTR_terrain_vs_position].format = SG_VERTEXFORMAT_FLOAT3;
	pipeline_desc.layout.attrs[ATTR_terrain_vs_texture_id].format = SG_VERTEXFORMAT_UINT;

	pipeline_desc.depth.compare = SG_COMPAREFUNC_LESS_EQUAL;
	pipeline_desc.depth.write_enabled = true;
	// pipeline_desc.cull_mode = SG_CULLMODE_BACK;
	pipeline_desc.cull_mode = SG_CULLMODE_NONE;
	pipeline_desc.face_winding = SG_FACEWINDING_CCW;

	pipeline_desc.label = "terrain_pipeline";
	engine.terrain_pipeline = sg_make_pipeline(pipeline_desc);
}

}

void st::_upload_atlas()
{
	// new arena to not fill up tr::scratchpad with crap :)
	tr::Arena scratch(tr::mb_to_bytes(1));
	TR_DEFER(scratch.free());

	TextureAtlas atlas = engine.current_atlas.unwrap();

	// glsl doesn't have hashmaps, so we just make one giant array
	// the size is UINT16_MAX * sizeof(tr::Rect<uint32>) = 1 MB
	// which is not that much
	// and it is faster than linear probing in glsl
	tr::Array<tr::Rect<uint32>> man(scratch, UINT16_MAX);
	for (auto [key, value] : atlas._textures) {
		man[key] = value;
	}

	fs_params_t uniform = {};
	// apparently you can't use an uvec2 on a uniform
	// why the fuck??????????????
	uniform.u_atlas_size[0] = static_cast<int32>(atlas.size().x);
	uniform.u_atlas_size[1] = static_cast<int32>(atlas.size().y);
	sg_apply_uniforms(UB_fs_params, SG_RANGE(uniform));

	sg_buffer_desc buffer_desc = {};
	buffer_desc.usage.storage_buffer = true;
	buffer_desc.data = SG_RANGE_TR_ARRAY(man);
	buffer_desc.label = "texture_atlas";
	engine.bindings.storage_buffers[SBUF_fs_atlas] = sg_make_buffer(buffer_desc);

	tr::info("uploaded texture atlas");
}

void st::_init::render()
{
	// YOU CAN'T EVEN GET TRUE TO BECOME 1????? LITERALLY 1984
	// NOLINTBEGIN(readability-implicit-bool-conversion)
	stbi_set_flip_vertically_on_load(true);
	// NOLINTEND(readability-implicit-bool-conversion)

	// yeah
	engine.camera.position = {0, 0, -5};
	engine.camera.projection = CameraProjection::ORTHOGRAPHIC;
	engine.camera.zoom = 5;

	sg_desc sg_desc = {};
	sg_desc.environment = sglue_environment();
	sg_desc.logger.func = st::_sokol_log;
	sg_setup(&sg_desc);

	/* clang-format off */
	tr::Array<TerrainVertex> verts = {
		// position            // texture id
		{0.0f,  0.5f,  0.0f,   0, 0}, // top
		{0.5f,  -0.5f, 0.0f,   0, 2}, // bottom right
		{-0.5f, -0.5f, 0.0f,   1, 3}, // bottom left
	};
	/* clang-format on */

	sg_buffer_desc buffer_desc = {};
	buffer_desc.size = verts.len() * sizeof(TerrainVertex);
	// SG_RANGE doesn't work with tr::Array<T>
	buffer_desc.data = SG_RANGE_TR_ARRAY(verts);
	buffer_desc.usage.vertex_buffer = true;
	engine.bindings.vertex_buffers[0] = sg_make_buffer(buffer_desc);

	// first the alt-right pipeline
	// now there's the render pipeline :(
	st::make_terrain_pipeline();
	// that's how you set the current pipeline
	engine.pipeline = engine.terrain_pipeline;

	// what the fuck is a render pass
	engine.pass_action.colors[0].load_action = SG_LOADACTION_CLEAR;
	engine.pass_action.colors[0].clear_value =
		tr_color_to_sg_color(tr::Color::rgb(0x06062d)); // color fresh from my ass <3

	// it screams in pain and agony if there's no texture set yet
	// so we have to make some placeholder bullshit
	sg_image_alloc_smp(IMG__u_texture, SMP__u_texture_smp);
}

void st::_free::render()
{
	sg_shutdown();
}

void st::_update::render()
{
	sg_pass pass = {};
	pass.action = engine.pass_action;
	pass.swapchain = sglue_swapchain();
	sg_begin_pass(pass);

	sg_apply_pipeline(engine.pipeline.unwrap_ref());

	// i know
	if (engine.pls_upload_the_atlas_to_the_gpu) {
		st::_upload_atlas();
		engine.pls_upload_the_atlas_to_the_gpu = false;
	}

	// we do have to update the uniforms
	vs_params_t uniform = {};
	uniform.u_model = tr::Matrix4x4::identity();
	uniform.u_view = Camera::current().view_matrix();
	uniform.u_projection = Camera::current().projection_matrix();
	sg_apply_uniforms(UB_vs_params, SG_RANGE(uniform));

	sg_apply_bindings(engine.bindings);

	sg_draw(0, 3, 1);

#ifdef ST_IMGUI
	st::imgui::render();
#endif

	sg_end_pass();
	sg_commit();
}

tr::String st::RenderError::message() const
{
	// TODO could have more detail
	switch (_type) {
	case RenderErrorType::RESOURCE_CREATION_FAILED:
		return "resource creation failed";
	case RenderErrorType::RESOURCE_INVALID:
		return "resource is invalid";
	default:
		return "error type seems to be invalid";
	}
}

sg_sampler_desc& st::sampler_desc()
{
	// TODO update to c++20 you cunt
	static sg_sampler_desc sampling_it = {};
	sampling_it.wrap_u = SG_WRAP_REPEAT;
	sampling_it.wrap_v = SG_WRAP_REPEAT;
	sampling_it.min_filter = SG_FILTER_LINEAR;
	sampling_it.mag_filter = SG_FILTER_LINEAR;
	sampling_it.compare = SG_COMPAREFUNC_NEVER;
	return sampling_it;
}

void st::sg_image_alloc_smp(int image_idx, int sampler_idx)
{
	engine.bindings.images[image_idx] = sg_alloc_image();
	engine.bindings.samplers[sampler_idx] = sg_alloc_sampler();
	sg_init_sampler(engine.bindings.samplers[sampler_idx], st::sampler_desc());
}
