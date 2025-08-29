/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/gpu.cpp
 * OpenGL wrappers and stuff.
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

#include "starry/gpu.h"

#include <trippin/iofs.h>
#include <trippin/log.h>

#include <glad/gl.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>

#include "starry/internal.h"

void st::clear_screen(tr::Color color)
{
	tr::Vec4<float32> vec4_color = color;
	glClearColor(vec4_color.x, vec4_color.y, vec4_color.z, vec4_color.w);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

st::Mesh::Mesh(
	tr::Array<VertexAttribute> format, void* buffer, usize elem_size, usize length,
	tr::Array<st::Triangle> indices, bool readonly
)
{
	_index_count = unsigned(indices.len() * 3);

	// vao
	glGenVertexArrays(1, &_vao);
	glBindVertexArray(_vao);

	// vbo
	glGenBuffers(1, &_vbo);
	glBindBuffer(GL_ARRAY_BUFFER, _vbo);

	glBufferData(
		GL_ARRAY_BUFFER, length * elem_size, buffer,
		readonly ? GL_STATIC_DRAW : GL_DYNAMIC_DRAW
	);

	// figure out the format :DDDD
	for (auto [i, attrib] : format) {
		uint32 size = 0;
		switch (attrib.type) {
		case VertexAttributeType::INT32:
		case VertexAttributeType::UINT32:
		case VertexAttributeType::FLOAT32:
		case VertexAttributeType::FLOAT64:
			size = 1;
			break;

		case VertexAttributeType::VEC2_INT32:
		case VertexAttributeType::VEC2_UINT32:
		case VertexAttributeType::VEC2_FLOAT32:
		case VertexAttributeType::VEC2_FLOAT64:
			size = 2;
			break;

		case VertexAttributeType::VEC3_INT32:
		case VertexAttributeType::VEC3_UINT32:
		case VertexAttributeType::VEC3_FLOAT32:
		case VertexAttributeType::VEC3_FLOAT64:
			size = 3;
			break;

		case VertexAttributeType::VEC4_INT32:
		case VertexAttributeType::VEC4_UINT32:
		case VertexAttributeType::VEC4_FLOAT32:
		case VertexAttributeType::VEC4_FLOAT64:
			size = 4;
			break;
		}

		bool ipointer = false;
		GLenum type = 0;
		switch (attrib.type) {
		case VertexAttributeType::INT32:
		case VertexAttributeType::VEC2_INT32:
		case VertexAttributeType::VEC3_INT32:
		case VertexAttributeType::VEC4_INT32:
			ipointer = true;
			type = GL_INT;
			break;

		case VertexAttributeType::UINT32:
		case VertexAttributeType::VEC2_UINT32:
		case VertexAttributeType::VEC3_UINT32:
		case VertexAttributeType::VEC4_UINT32:
			ipointer = true;
			type = GL_UNSIGNED_INT;
			break;

		case VertexAttributeType::FLOAT32:
		case VertexAttributeType::VEC2_FLOAT32:
		case VertexAttributeType::VEC3_FLOAT32:
		case VertexAttributeType::VEC4_FLOAT32:
			ipointer = false;
			type = GL_FLOAT;
			break;

		case VertexAttributeType::FLOAT64:
		case VertexAttributeType::VEC2_FLOAT64:
		case VertexAttributeType::VEC3_FLOAT64:
		case VertexAttributeType::VEC4_FLOAT64:
			ipointer = false;
			type = GL_DOUBLE;
			break;
		}

		if (ipointer) {
			glVertexAttribIPointer(
				i, size, type, elem_size,
				reinterpret_cast<const void*>(attrib.offset)
			);
		}
		else {
			glVertexAttribPointer(
				i, size, type, 0u, elem_size,
				reinterpret_cast<const void*>(attrib.offset)
			);
		}
		glEnableVertexAttribArray(i);
	}

	// ebo
	glGenBuffers(1, &_ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
	glBufferData(
		GL_ELEMENT_ARRAY_BUFFER, indices.len() * sizeof(Triangle), indices.buf(),
		readonly ? GL_STATIC_DRAW : GL_DYNAMIC_DRAW
	);

	// unbind vao
	glBindVertexArray(0);

	// TODO this might get too noisy
	tr::info("uploaded mesh (vao %u, vbo %u, ebo %u)", _vao, _vbo, _ebo);
	tr::info("- vertices:  %zu (%zu KB)", length, tr::bytes_to_kb(length * elem_size));
	tr::info(
		"- triangles: %zu (%zu KB)", indices.len(),
		tr::bytes_to_kb(indices.len() * sizeof(st::Triangle))
	);
}

void st::Mesh::free()
{
	glDeleteVertexArrays(1, &_vao);
	glDeleteBuffers(1, &_vbo);
	glDeleteBuffers(1, &_ebo);
	_vao = 0;
	_vbo = 0;
	_ebo = 0;
	_index_count = 0;

	tr::info("freed mesh (vao %u)", _vao);
}

void st::Mesh::draw(tr::Matrix4x4 model, tr::Matrix4x4 view, tr::Matrix4x4 projection) const
{
	// TODO this should be shader-specific, instead of some fancy generic solution
	_st->current_shader.match(
		[&](ShaderProgram& shader) {
			shader.set_uniform("u_model", model);
			shader.set_uniform("u_view", view);
			shader.set_uniform("u_projection", projection);
		},
		[]() { tr::warn("rendering before using a shader, nothing is gonna show up"); }
	);

	glBindVertexArray(_vao);
	glDrawElements(GL_TRIANGLES, _index_count, GL_UNSIGNED_INT, 0);
	glBindVertexArray(0);
}

void st::Mesh::draw(tr::Matrix4x4 matrix) const
{
	draw(matrix, _st->camera.view_matrix(), _st->camera.projection_matrix());
}

void st::Shader::_check_compilation(const char* shader_type) const
{
	int32 success;
	glGetShaderiv(_shader, GL_COMPILE_STATUS, &success);
	if (success == 0) {
		char info_log[512];
		glGetShaderInfoLog(_shader, 512, nullptr, info_log);
		tr::panic("couldn't compile %s shader: %s", shader_type, info_log);
	}
}

st::VertexShader::VertexShader(tr::String src)
{
	_shader = glCreateShader(GL_VERTEX_SHADER);
	char* whythefuck = src.buf();
	glShaderSource(_shader, 1, &whythefuck, nullptr);
	glCompileShader(_shader);

	_check_compilation("vertex");
	tr::info("created vertex shader (id %u)", _shader);
}

void st::VertexShader::free()
{
	glDeleteShader(_shader);
	tr::info("deleted vertex shader (id %u)", _shader);
}

st::FragmentShader::FragmentShader(tr::String src)
{
	_shader = glCreateShader(GL_FRAGMENT_SHADER);
	char* whythefuck = src.buf();
	glShaderSource(_shader, 1, &whythefuck, nullptr);
	glCompileShader(_shader);

	_check_compilation("fragment");
	tr::info("created fragment shader (id %u)", _shader);
}

void st::FragmentShader::free()
{
	glDeleteShader(_shader);
	tr::info("deleted fragment shader (id %u)", _shader);
}

st::ShaderProgram::ShaderProgram()
{
	_program = glCreateProgram();
	tr::info("created shader program (id %u)", _program);
}

void st::ShaderProgram::free()
{
	glDeleteProgram(_program);
	_program = 0;
	tr::info("deleted shader program (id %u)", _program);
}

void st::ShaderProgram::attach(const st::Shader& shader) const
{
	glAttachShader(_program, shader._shader);
}

void st::ShaderProgram::link() const
{
	glLinkProgram(_program);

	int success;
	glGetProgramiv(_program, GL_LINK_STATUS, &success);
	if (success == 0) {
		char infolog[512];
		glGetProgramInfoLog(_program, 512, nullptr, infolog);
		tr::panic("gpu program linking error: %s", infolog);
	}

	tr::info("linked shader program (id %u)", _program);
}

void st::ShaderProgram::use()
{
	glUseProgram(_program);
	_st->current_shader = this;
}

tr::Result<st::Texture> st::Texture::load(tr::String path)
{
	Texture texture = {};
	tr::String real_path = tr::path(tr::scratchpad(), path);

	// TODO texture cache
	int32 width, height, channels;
	uint8* data = stbi_load(real_path, &width, &height, &channels, 4);
	if (data == nullptr) {
		return tr::StringError("couldn't load texture from %s", *path);
	}
	TR_DEFER(stbi_image_free(data));

	// help
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	texture._size = {uint32(width), uint32(height)};

	// actually make the texture
	glGenTextures(1, &texture._id);
	glBindTexture(GL_TEXTURE_2D, texture._id);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	// TODO there should be a setting for this probably
	glGenerateMipmap(GL_TEXTURE_2D);

	tr::info("loaded texture from %s (id %u)", *path, texture._id);
	return texture;
}

void st::Texture::free()
{
	glDeleteTextures(1, &_id);
	_id = 0;
	tr::info("deleted texture (id %u)", _id);
}

void st::Texture::use() const
{
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _id);
}

void st::ShaderProgram::set_uniform(tr::String name, bool value) const
{
	glUniform1i(glGetUniformLocation(_program, name), int(value));
}

void st::ShaderProgram::set_uniform(tr::String name, int32 value) const
{
	glUniform1i(glGetUniformLocation(_program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, float32 value) const
{
	glUniform1f(glGetUniformLocation(_program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec2<float32> value) const
{
	glUniform2f(glGetUniformLocation(_program, name), value.x, value.y);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec3<float32> value) const
{
	glUniform3f(glGetUniformLocation(_program, name), value.x, value.y, value.z);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec4<float32> value) const
{
	glUniform4f(glGetUniformLocation(_program, name), value.x, value.y, value.z, value.w);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Matrix4x4 value) const
{
	// man
	glUniformMatrix4fv(
		glGetUniformLocation(_program, name), 1, 0u, reinterpret_cast<float32*>(&value)
	);
}
