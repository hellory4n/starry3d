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
#include <trippin/log.h>
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
// #include "starry/optional/imgui.h"
#endif
#include "starry/render.h"
#define SOKOL_GLUE_IMPL
#include <sokol/sokol_glue.h>
#include <stb/stb_image.h>

#include "starry/shader/basic.glsl.h"
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()

namespace st {

// TODO should this be disabled in debug mode?
#if false
	#define ST_CHECK_GL()                                                                   \
		TR_ASSERT_MSG(                                                                  \
			glGetError() == GL_NO_ERROR, "oh no OpenGL is busted: %u", glGetError() \
		)
#else
	#define ST_CHECK_GL()
#endif

static inline void setup_buffers()
{
	glVertexAttribPointer(
		ATTR_basic_vs_position, 3, GL_FLOAT, GL_FALSE, sizeof(tr::Vec3<float32>),
		reinterpret_cast<const void*>(offsetof(BasicVertex, position))
	);
	ST_CHECK_GL();
	glEnableVertexAttribArray(ATTR_basic_vs_position);
	ST_CHECK_GL();

	glVertexAttribPointer(
		ATTR_basic_vs_color, 4, GL_FLOAT, GL_FALSE, sizeof(tr::Vec4<float32>),
		reinterpret_cast<const void*>(offsetof(BasicVertex, color))
	);
	ST_CHECK_GL();
	glEnableVertexAttribArray(ATTR_basic_vs_color);
	ST_CHECK_GL();

	// whatever clang format is trying to do makes no sense
	/* clang-format off */
	tr::Array<BasicVertex> vertices = {
		{{0, 0.5, 0.0}, {1, 0, 0, 1}}, // top
		{{-0.5, -0.5, 0.0}, {0, 1, 0, 1}}, // left
		{{0.5, -0.5, 0.0}, {0, 0, 1, 1}}, // right
	};
	/* clang-format on */

	tr::Array<Triangle> indices = {
		{0, 1, 2},
	};

	GLuint vao;
	glGenVertexArrays(1, &vao);
	ST_CHECK_GL();
	glBindVertexArray(vao);
	ST_CHECK_GL();

	uint vbo;
	glGenBuffers(1, &vbo);
	ST_CHECK_GL();
	glBindBuffer(GL_ARRAY_BUFFER, vbo);
	ST_CHECK_GL();
	glBufferData(
		GL_ARRAY_BUFFER, static_cast<GLsizeiptr>(vertices.len() * sizeof(BasicVertex)),
		*vertices, GL_STATIC_DRAW
	);
	ST_CHECK_GL();

	uint ebo;
	glGenBuffers(1, &ebo);
	ST_CHECK_GL();
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
	ST_CHECK_GL();

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
	ST_CHECK_GL();
	glBufferData(
		GL_ELEMENT_ARRAY_BUFFER, static_cast<GLsizeiptr>(indices.len() * sizeof(Triangle)),
		*indices, GL_STATIC_DRAW
	);
	ST_CHECK_GL();

	engine.mesh.vao = vao;
	engine.mesh.vbo = vbo;
	engine.mesh.ebo = ebo;
	engine.mesh.indices = indices.len() * 3;
}

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

	// FUCK ME
	engine.basic_shader =
		Shader(tr::String(reinterpret_cast<const char*>(vs_source_glsl430)),
		       tr::String(reinterpret_cast<const char*>(fs_source_glsl430)));
	st::setup_buffers();
}

void st::_free::render()
{
	sg_shutdown();
}

void st::_update::render()
{
	engine.basic_shader.bind();

	glBindVertexArray(engine.mesh.vao);
	ST_CHECK_GL();

	glDrawElements(GL_TRIANGLES, engine.mesh.indices, GL_UNSIGNED_INT, nullptr);
	ST_CHECK_GL();
	glBindVertexArray(0);
	ST_CHECK_GL();
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

st::Shader::Shader(tr::String vert_src, tr::String frag_src)
{
	GLuint vert_shader = glCreateShader(GL_VERTEX_SHADER);
	const char* FUCKYOU = *vert_src;
	glShaderSource(vert_shader, 1, &FUCKYOU, nullptr);
	glCompileShader(vert_shader);

	int success;
	glGetShaderiv(vert_shader, GL_COMPILE_STATUS, &success);
	if (!success) { // NOLINT
		char info[512];
		glGetShaderInfoLog(vert_shader, sizeof(info), nullptr, info);
	}

	GLuint frag_shader = glCreateShader(GL_FRAGMENT_SHADER);
	FUCKYOU = *frag_src;
	glShaderSource(frag_shader, 1, &FUCKYOU, nullptr);
	glCompileShader(frag_shader);

	glGetShaderiv(frag_shader, GL_COMPILE_STATUS, &success);
	if (!success) { // NOLINT
		char info[512];
		glGetShaderInfoLog(frag_shader, sizeof(info), nullptr, info);
	}

	program = glCreateProgram();
	glAttachShader(program, vert_shader);
	glAttachShader(program, frag_shader);
	glLinkProgram(program);

	glGetProgramiv(program, GL_LINK_STATUS, &success);
	if (!success) { // NOLINT
		char info[512];
		glGetProgramInfoLog(program, sizeof(info), nullptr, info);
	}

	glDeleteShader(vert_shader);
	glDeleteShader(frag_shader);
	bind();

	tr::info("created shader program (id %u)", program);
}

void st::Shader::free()
{
	glDeleteProgram(program);
	ST_CHECK_GL();
	tr::info("deleted shader program (id %u)", program);
	program = 0;
}

void st::Shader::bind() const
{
	glUseProgram(program);
	ST_CHECK_GL();
}
