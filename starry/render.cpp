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
#include <trippin/memory.h>
#include <trippin/math.h>

#include "starry/configs/sokol.h" // IWYU pragma: keep
#define SOKOL_GFX_IMPL
#include <sokol/sokol_gfx.h>
#include <sokol/sokol_app.h>
#define SOKOL_GLUE_IMPL
#include <sokol/sokol_glue.h>

#ifdef ST_IMGUI
	#include "starry/optional/imgui.h"
#endif
#include "starry/shader/basic.glsl.h"
#include "starry/render.h"

namespace st {
	// didn't want to include sokol in common.hpp
	struct Renderer
	{
		sg_pipeline pipeline = {};
		sg_bindings bindings = {};
		sg_pass_action pass_action = {};
	};

	static Renderer renderer;

	// it's a hassle
	// implemented in common.cpp
	void __sokol_log(const char* tag, uint32 level, uint32 item_id, const char* msg_or_null,
		uint32 line_nr, const char* filename_or_null, void* user_data
	);
}

void st::__init_renderer()
{
	sg_desc sg_desc = {};
	sg_desc.environment = sglue_environment();
	sg_desc.logger.func = st::__sokol_log;
	sg_setup(sg_desc);
}

void st::__free_renderer()
{
	sg_shutdown();
}

void st::__draw()
{
	sg_pass pass = {};
	pass.action = st::renderer.pass_action;
	pass.swapchain = sglue_swapchain();
	sg_begin_pass(pass);

	sg_apply_pipeline(st::renderer.pipeline);
	sg_apply_bindings(st::renderer.bindings);
	sg_draw(0, 3, 1);

	#ifdef ST_IMGUI
	st::imgui::render();
	#endif

	sg_end_pass();
	sg_commit();
}

void st::init_triangle()
{
	// idfk what am i doing
	sg_shader shader = sg_make_shader(basic_shader_desc(sg_query_backend()));

	tr::Array<float32> verts = {
		-0.5f, -0.5f, 0.0f, // bottom left
		 0.5f, -0.5f, 0.0f, // bottom right
		 0.0f,  0.5f, 0.0f, // top
	};

	sg_buffer_desc buffer_desc = {};
	buffer_desc.size = verts.len() * sizeof(float32);
	// SG_RANGE doesn't work with tr::Array<T>
	buffer_desc.data = {verts.buf(), verts.len() * sizeof(float32)};
	buffer_desc.label = "triangle_vertices";
	st::renderer.bindings.vertex_buffers[0] = sg_make_buffer(buffer_desc);

	// first the alt-right pipeline
	// now there's the render pipeline :(
	sg_pipeline_desc pipeline_desc = {};
	pipeline_desc.shader = shader;
	pipeline_desc.layout.attrs[ATTR_basic_position].format = SG_VERTEXFORMAT_FLOAT3;
	pipeline_desc.label = "triangle_pipeline";
	st::renderer.pipeline = sg_make_pipeline(pipeline_desc);

	// what the fuck is a render pass
	st::renderer.pass_action.colors[0].load_action = SG_LOADACTION_CLEAR;
	st::renderer.pass_action.colors[0].clear_value = {0, 0, 0, 1};
}

void st::draw_triangle() {}

void st::free_triangle() {}
