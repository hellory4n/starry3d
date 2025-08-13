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

#include <trippin/common.h>
#include <trippin/math.h>
#include <trippin/memory.h>

#include "starry/common.h" // IWYU pragma: keep

// :(
// TODO this whole file is a mess and sucks
TR_GCC_IGNORE_WARNING(-Wold-style-cast)
TR_GCC_IGNORE_WARNING(-Wimplicit-int-conversion)
TR_GCC_IGNORE_WARNING(-Wcast-qual)
TR_GCC_IGNORE_WARNING(-Wextra) // this is why clang is better
#define SOKOL_GFX_IMPL // sokol_gfx.h is included in render.h
#include <sokol/sokol_app.h>

#ifdef ST_IMGUI
	#include "starry/optional/imgui.h"
#endif
#include "starry/render.h"
#define SOKOL_GLUE_IMPL
#include <sokol/sokol_glue.h>

#include "starry/shader/basic.glsl.h"
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()

namespace st {

// it has to live somewhere
Renderer renderer;

static inline sg_color tr_color_to_sg_color(tr::Color color)
{
	auto colorf = static_cast<tr::Vec4<float32>>(color);
	return {colorf.x, colorf.y, colorf.z, colorf.w};
}

static inline void make_basic_pipeline()
{
	// idfk what am i doing
	sg_shader shader = sg_make_shader(basic_shader_desc(sg_query_backend()));

	sg_pipeline_desc pipeline_desc = {};

	pipeline_desc.shader = shader;
	pipeline_desc.layout.attrs[ATTR_basic_vs_position].format = SG_VERTEXFORMAT_FLOAT3;
	pipeline_desc.layout.attrs[ATTR_basic_vs_texcoord].format = SG_VERTEXFORMAT_FLOAT2;

	pipeline_desc.depth.compare = SG_COMPAREFUNC_LESS_EQUAL;
	pipeline_desc.depth.write_enabled = true;
	// pipeline_desc.cull_mode = SG_CULLMODE_BACK;
	pipeline_desc.cull_mode = SG_CULLMODE_NONE;
	pipeline_desc.face_winding = SG_FACEWINDING_CCW;

	pipeline_desc.label = "basic_pipeline";
	st::renderer.basic_pipeline = sg_make_pipeline(pipeline_desc);
}

} // namespace st

void st::_init_renderer()
{
	// Man
	st::engine.camera.position = {0, 0, -5};
	st::engine.camera.projection = CameraProjection::ORTHOGRAPHIC;
	st::engine.camera.zoom = 5;

	sg_desc sg_desc = {};
	sg_desc.environment = sglue_environment();
	sg_desc.logger.func = st::_sokol_log;
	sg_setup(&sg_desc);

	tr::Array<float32> verts = {
		0.0f,  0.5f,  0.0f, 0.0f, 0.0f, 1.0f, 1.0f, // top
		0.5f,  -0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, // bottom right
		-0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // bottom left
	};

	sg_buffer_desc buffer_desc = {};
	buffer_desc.size = verts.len() * sizeof(float32);
	// SG_RANGE doesn't work with tr::Array<T>
	buffer_desc.data = {*verts, verts.len() * sizeof(float32)};
	buffer_desc.usage.vertex_buffer = true;
	st::renderer.bindings.vertex_buffers[0] = sg_make_buffer(buffer_desc);

	// first the alt-right pipeline
	// now there's the render pipeline :(
	st::make_basic_pipeline();
	// that's how you set the current pipeline
	st::renderer.pipeline = st::renderer.basic_pipeline;

	// what the fuck is a render pass
	st::renderer.pass_action.colors[0].load_action = SG_LOADACTION_CLEAR;
	st::renderer.pass_action.colors[0].clear_value =
		tr_color_to_sg_color(tr::Color::rgb(0x06062d)); // color fresh from my ass <3
}

void st::_free_renderer()
{
	sg_shutdown();
}

void st::_draw()
{
	sg_pass pass = {};
	pass.action = st::renderer.pass_action;
	pass.swapchain = sglue_swapchain();
	sg_begin_pass(pass);

	sg_apply_pipeline(st::renderer.pipeline.unwrap_ref());
	sg_apply_bindings(st::renderer.bindings);

	// we do have to update the uniforms
	vs_params_t uniform = {};
	uniform.u_model = tr::Matrix4x4::identity();
	uniform.u_view = Camera::current().view_matrix();
	uniform.u_projection = Camera::current().projection_matrix();
	sg_apply_uniforms(UB_vs_params, SG_RANGE(uniform));

	sg_draw(0, 3, 1);

#ifdef ST_IMGUI
	st::imgui::render();
#endif

	sg_end_pass();
	sg_commit();
}
