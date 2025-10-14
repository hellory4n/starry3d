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

#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/iofs.h>
#include <trippin/log.h>
#include <trippin/memory.h>

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
	tr::Array<const st::VertexAttribute> format, const void* buffer, usize length,
	const st::Triangle* indices, usize triangle_count, st::MeshUsage usage
)
{
	_index_count = uint32(triangle_count * 3);
	_usage = usage;

	// vao
	glGenVertexArrays(1, &_vao);
	glBindVertexArray(_vao);

	// vbo
	glGenBuffers(1, &_vbo);
	glBindBuffer(GL_ARRAY_BUFFER, _vbo);

	GLenum glusage;
	switch (usage) {
	case MeshUsage::READONLY:
		glusage = GL_STATIC_DRAW;
		break;
	case MeshUsage::MUTABLE:
		glusage = GL_DYNAMIC_DRAW;
		break;
	case MeshUsage::STREAMED:
		glusage = GL_STREAM_DRAW;
		break;
	};
	glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(length), buffer, glusage);

	// figure out the format :DDDD
	// vertex size
	// TODO will padding completely ruin this?
	usize sizeof_vert = 0; // in bytes
	for (auto [_, attrib] : format) {
		switch (attrib.type) {
		case VertexAttributeType::INT32:
			sizeof_vert += sizeof(int32);
			break;
		case VertexAttributeType::UINT32:
			sizeof_vert += sizeof(uint32);
			break;
		case VertexAttributeType::FLOAT32:
			sizeof_vert += sizeof(float32);
			break;
		case VertexAttributeType::FLOAT64:
			sizeof_vert += sizeof(float64);
			break;
		case VertexAttributeType::VEC2_INT32:
			sizeof_vert += sizeof(int32) * 2;
			break;
		case VertexAttributeType::VEC2_UINT32:
			sizeof_vert += sizeof(uint32) * 2;
			break;
		case VertexAttributeType::VEC2_FLOAT32:
			sizeof_vert += sizeof(float32) * 2;
			break;
		case VertexAttributeType::VEC2_FLOAT64:
			sizeof_vert += sizeof(float64) * 2;
			break;
		case VertexAttributeType::VEC3_INT32:
			sizeof_vert += sizeof(int32) * 3;
			break;
		case VertexAttributeType::VEC3_UINT32:
			sizeof_vert += sizeof(uint32) * 3;
			break;
		case VertexAttributeType::VEC3_FLOAT32:
			sizeof_vert += sizeof(float32) * 3;
			break;
		case VertexAttributeType::VEC3_FLOAT64:
			sizeof_vert += sizeof(float64) * 3;
			break;
		case VertexAttributeType::VEC4_INT32:
			sizeof_vert += sizeof(int32) * 4;
			break;
		case VertexAttributeType::VEC4_UINT32:
			sizeof_vert += sizeof(uint32) * 4;
			break;
		case VertexAttributeType::VEC4_FLOAT32:
			sizeof_vert += sizeof(float32) * 4;
			break;
		case VertexAttributeType::VEC4_FLOAT64:
			sizeof_vert += sizeof(float64) * 4;
			break;
		};
	}

	// vertex attribs
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
				uint32(i), GLint(size), type, GLsizei(sizeof_vert),
				reinterpret_cast<const void*>(attrib.offset)
			);
		}
		else {
			glVertexAttribPointer(
				uint32(i), GLint(size), type, 0u, GLsizei(sizeof_vert),
				reinterpret_cast<const void*>(attrib.offset)
			);
		}
		glEnableVertexAttribArray(uint32(i));
	}

	// ebo
	glGenBuffers(1, &_ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
	glBufferData(
		GL_ELEMENT_ARRAY_BUFFER, GLsizeiptr(triangle_count * sizeof(Triangle)), indices,
		glusage
	);

	// unbind vao
	glBindVertexArray(0);

	// TODO this might get too noisy
	tr::info("uploaded mesh (vao %u, vbo %u, ebo %u)", _vao, _vbo, _ebo);
}

void st::Mesh::free()
{
	glDeleteVertexArrays(1, &_vao);
	glDeleteBuffers(1, &_vbo);
	glDeleteBuffers(1, &_ebo);
	tr::info("freed mesh (vao %u)", _vao);

	_vao = 0;
	_vbo = 0;
	_ebo = 0;
	_index_count = 0;
}

void st::Mesh::draw(uint32 instances) const
{
	TR_ASSERT_MSG(_vao != 0, "you doofus initialize the mesh");
	glBindVertexArray(_vao);
	glDrawElementsInstanced(
		GL_TRIANGLES, GLsizei(_index_count), GL_UNSIGNED_INT, nullptr, GLsizei(instances)
	);
	glBindVertexArray(0);
}

void st::Mesh::update_data(
	const void* buffer, usize length, const Triangle* indices, usize triangle_count
)
{
	if (_usage == MeshUsage::READONLY) {
		tr::panic("trying to update readonly mesh. do you know what readonly means?");
	}

	GLenum glusage;
	switch (_usage) {
	case MeshUsage::READONLY:
		glusage = GL_STATIC_DRAW;
		break;
	case MeshUsage::MUTABLE:
		glusage = GL_DYNAMIC_DRAW;
		break;
	case MeshUsage::STREAMED:
		glusage = GL_STREAM_DRAW;
		break;
	};

	glBindBuffer(GL_ARRAY_BUFFER, _vbo);
	glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(length), buffer, glusage);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _ebo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLsizeiptr(triangle_count * 3), indices, glusage);
}

void st::Shader::_check_compilation(const char* shader_type) const
{
	int success;
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
	const char* whythefuck = src.buf();
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
	tr::info("deleted shader program (id %u)", _program);
	_program = 0;
}

// 'Method can be made const'
// nuh uh they are, in fact, changing state
// NOLINTBEGIN(readability-make-member-function-const)
void st::ShaderProgram::attach(const st::Shader& shader)
{
	glAttachShader(_program, shader._shader);
}

void st::ShaderProgram::link()
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
}

void st::ShaderProgram::set_uniform(tr::String name, bool value)
{
	use();
	glUniform1i(glGetUniformLocation(_program, name), int(value));
}

void st::ShaderProgram::set_uniform(tr::String name, int32 value)
{
	use();
	glUniform1i(glGetUniformLocation(_program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, uint32 value)
{
	use();
	glUniform1ui(glGetUniformLocation(_program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, float32 value)
{
	use();
	glUniform1f(glGetUniformLocation(_program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec2<float32> value)
{
	use();
	glUniform2f(glGetUniformLocation(_program, name), value.x, value.y);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec3<float32> value)
{
	use();
	glUniform3f(glGetUniformLocation(_program, name), value.x, value.y, value.z);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec4<float32> value)
{
	use();
	glUniform4f(glGetUniformLocation(_program, name), value.x, value.y, value.z, value.w);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec2<int32> value)
{
	use();
	glUniform2i(glGetUniformLocation(_program, name), value.x, value.y);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec3<int32> value)
{
	use();
	glUniform3i(glGetUniformLocation(_program, name), value.x, value.y, value.z);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec4<int32> value)
{
	use();
	glUniform4i(glGetUniformLocation(_program, name), value.x, value.y, value.z, value.w);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec2<uint32> value)
{
	use();
	glUniform2ui(glGetUniformLocation(_program, name), value.x, value.y);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec3<uint32> value)
{
	use();
	glUniform3ui(glGetUniformLocation(_program, name), value.x, value.y, value.z);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec4<uint32> value)
{
	use();
	glUniform4ui(glGetUniformLocation(_program, name), value.x, value.y, value.z, value.w);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Matrix4x4 value)
{
	use();
	// man
	glUniformMatrix4fv(
		glGetUniformLocation(_program, name), 1, 0u, reinterpret_cast<float32*>(&value)
	);
}
// NOLINTEND(readability-make-member-function-const)

tr::Result<st::Texture> st::Texture::load(tr::String path, TextureSettings settings)
{
	Texture texture = {};

	TR_TRY_ASSIGN(
		tr::File& file, tr::File::open(
					_st->asset_arena, tr::path(_st->asset_arena, path),
					tr::FileMode::READ_BINARY
				)
	);
	TR_DEFER(file.close());
	TR_TRY_ASSIGN(tr::Array<uint8> bytes, file.read_all_bytes(_st->asset_arena));

	// TODO texture cache
	// TODO st::Texture::from_memory()
	int width = 0;
	int height = 0;
	int channels = 0;
	uint8* data = stbi_load_from_memory(*bytes, bytes.len(), &width, &height, &channels, 4);
	if (data == nullptr) {
		return tr::StringError("couldn't load texture from %s", *path);
	}
	TR_DEFER(stbi_image_free(data));
	TR_ASSERT(width > 0 && height > 0 && channels > 0);

	glGenTextures(1, &texture._id);
	glBindTexture(GL_TEXTURE_2D, texture._id);

	// help
	switch (settings.wrap) {
	case TextureWrap::TILE:
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		break;
	case TextureWrap::MIRRORED_TILE:
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
		break;
	case TextureWrap::CLAMP_TO_EDGE:
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		break;
	case TextureWrap::CLAMP_TO_BORDER:
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
		break;
	default:
		TR_UNREACHABLE();
	}

	// TODO you're probably doing this wrong
	switch (settings.filter) {
	case TextureFilter::NEAREST_NEIGHBOR:
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		break;
	case TextureFilter::BILINEAR_FILTER:
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		break;
	default:
		TR_UNREACHABLE();
	}

	texture._size = {uint32(width), uint32(height)};
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);

	if (settings.mipmaps) {
		glGenerateMipmap(GL_TEXTURE_2D);
	}

	tr::info("loaded texture from %s (id %u)", *path, texture._id);
	return texture;
}

void st::Texture::free()
{
	glDeleteTextures(1, &_id);
	tr::info("deleted texture (id %u)", _id);
	_id = 0;
}

void st::Texture::use() const
{
	TR_ASSERT_MSG(_id != 0, "you doofus initialize the texture")
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, _id);
}

st::StorageBuffer::StorageBuffer(uint32 binding)
{
	uint32 ssbo = 0;
	glGenBuffers(1, &ssbo);
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo);
	glBindBufferBase(GL_SHADER_STORAGE_BUFFER, binding, ssbo);
	_buffer = ssbo;
}

void st::StorageBuffer::free()
{
	glDeleteBuffers(1, &_buffer);
	_buffer = 0;
}

// 'Method can be made const'
// nuh uh they are, in fact, changing state
// NOLINTBEGIN(readability-make-member-function-const)
void st::StorageBuffer::update(const void* data, usize len)
{
	TR_ASSERT_MSG(_buffer != 0, "you doofus initialize the storage buffer")
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, _buffer);
	glBufferData(GL_SHADER_STORAGE_BUFFER, len, data, GL_DYNAMIC_DRAW);
}

void st::StorageBuffer::partial_update(usize offset, const void* data, usize len)
{
	TR_ASSERT_MSG(_buffer != 0, "you doofus initialize the storage buffer")
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, _buffer);
	glBufferSubData(GL_SHADER_STORAGE_BUFFER, offset, len, data);
}

void* st::StorageBuffer::map_buffer(st::MapBufferAccess access)
{
	GLenum glaccess = 0;
	switch (access) {
	case MapBufferAccess::READ:
		glaccess = GL_READ_ONLY;
		break;
	case MapBufferAccess::WRITE:
		glaccess = GL_WRITE_ONLY;
		break;
	case MapBufferAccess::READ_WRITE:
		glaccess = GL_READ_WRITE;
		break;
	}
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, _buffer);
	return glMapBuffer(GL_SHADER_STORAGE_BUFFER, glaccess);
}

void st::StorageBuffer::unmap_buffer()
{
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, _buffer);
	glUnmapBuffer(GL_SHADER_STORAGE_BUFFER);
	// sync with the gpu or some shit
	glMemoryBarrier(GL_SHADER_STORAGE_BARRIER_BIT);
}
// NOLINTEND(readability-make-member-function-const)
