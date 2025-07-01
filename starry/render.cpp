/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * st_render.cpp
 * Mostly wrappers around OpenGL
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

#include <glad/gl.h>
#include <GLFW/glfw3.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
#include <trippin/log.hpp>

#include "common.hpp"
#include "window.hpp"
#include "render.hpp"

namespace st {
	tr::Ref<ShaderProgram> current_shader;
}

void st::clear_screen(tr::Color color)
{
	tr::Vec4<float32> vec4_color = color;
	glClearColor(vec4_color.x, vec4_color.y, vec4_color.z, vec4_color.w);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void st::end_drawing()
{
	glfwSwapBuffers(st::engine.window);
}

tr::Matrix4x4 st::Camera::view_matrix()
{
	auto pos = tr::Matrix4x4::translate(-this->position.x, -this->position.y, -this->position.z);

	auto rot = tr::Matrix4x4::identity();
	rot = rot * rot.rotate_x(tr::deg2rad(this->rotation.x));
	rot = rot * rot.rotate_y(tr::deg2rad(this->rotation.y));
	rot = rot * rot.rotate_z(tr::deg2rad(this->rotation.z));

	return rot * pos;
}

tr::Matrix4x4 st::Camera::projection_matrix()
{
	tr::Vec2<uint32> winsize = st::window_size();

	if (this->projection == CameraProjection::PERSPECTIVE) {
		return tr::Matrix4x4::perspective(tr::deg2rad(this->fov), static_cast<float32>(winsize.x) /
			winsize.y, this->near, this->far
		);
	}
	else {
		// TODO this may be fucked im not sure
		float32 left = -this->zoom / 2.f;
		float32 right = this->zoom / 2.f;

		float32 height = this->zoom * (static_cast<float32>(winsize.y) / winsize.x);
		float32 bottom = -height / 2.f;
		float32 top = height / 2.f;

		return tr::Matrix4x4::orthographic(left, right, bottom, top, this->near, this->far);
	}
}

st::Camera* st::camera()
{
	return &st::engine.camera;
}

st::Mesh::Mesh(tr::Array<VertexAttribute> format, void* buffer, usize elem_size, usize length,
	tr::Array<st::Triangle> indices, bool readonly)
{
	this->index_count = indices.length() * 3;

	// vao
	glGenVertexArrays(1, &this->vao);
	glBindVertexArray(this->vao);

	// vbo
	glGenBuffers(1, &this->vbo);
	glBindBuffer(GL_ARRAY_BUFFER, this->vbo);

	glBufferData(GL_ARRAY_BUFFER, length * elem_size, buffer, readonly ? GL_STATIC_DRAW : GL_DYNAMIC_DRAW);

	// figure out the format :DDDD
	for (tr::ArrayItem<VertexAttribute> attrib : format) {
		uint32 size = 0;
		switch (attrib.val.type) {
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
		switch (attrib.val.type) {
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
			glVertexAttribIPointer(attrib.i, size, type, elem_size, reinterpret_cast<const void*>(attrib.val.offset));
		}
		else {
			glVertexAttribPointer(attrib.i, size, type, false, elem_size, reinterpret_cast<const void*>(attrib.val.offset));
		}
		glEnableVertexAttribArray(attrib.i);
	}

	// ebo
	glGenBuffers(1, &this->ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, this->ebo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length() * sizeof(Triangle), indices.buffer(),
		readonly ? GL_STATIC_DRAW : GL_DYNAMIC_DRAW);

	// unbind vao
	glBindVertexArray(0);

	tr::info("uploaded mesh (vao %u, vbo %u, ebo %u)", this->vao, this->vbo, this->ebo);
	tr::info("- vertices:  %zu (%zu KB)", length, tr::bytes_to_kb(length * elem_size));
	tr::info("- triangles: %zu (%zu KB)", indices.length(), tr::bytes_to_kb(indices.length() *
		sizeof(st::Triangle))
	);
}

st::Mesh::~Mesh()
{
	glDeleteVertexArrays(1, &this->vao);
	glDeleteBuffers(1, &this->vbo);
	glDeleteBuffers(1, &this->ebo);

	tr::info("freed mesh (vao %u)", this->vao);
}

void st::Mesh::draw(tr::Matrix4x4 model, tr::Matrix4x4 view, tr::Matrix4x4 projection)
{
	st::current_shader->set_uniform(st::engine.model_uniform, model);
	st::current_shader->set_uniform(st::engine.view_uniform, view);
	st::current_shader->set_uniform(st::engine.proj_uniform, projection);

	if (this->texture != nullptr) {
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, this->texture->id);
	}

	glBindVertexArray(this->vao);
	glDrawElements(GL_TRIANGLES, this->index_count, GL_UNSIGNED_INT, 0);
	glBindVertexArray(0);
}

void st::Mesh::draw(tr::Matrix4x4 matrix)
{
	this->draw(matrix, st::engine.camera.view_matrix(), st::engine.camera.projection_matrix());
}

void st::Mesh::draw(tr::Vec3<float64> pos, tr::Vec3<float64> rot)
{
	auto pos_matrix = tr::Matrix4x4::translate(pos.x, pos.y, pos.z);

	auto rot_x_matrix = tr::Matrix4x4::identity().rotate_x(tr::deg2rad(rot.x));
	auto rot_y_matrix = tr::Matrix4x4::identity().rotate_y(tr::deg2rad(rot.y));
	auto rot_z_matrix = tr::Matrix4x4::identity().rotate_z(tr::deg2rad(rot.z));
	tr::Matrix4x4 rot_matrix = rot_x_matrix * rot_y_matrix * rot_z_matrix;

	this->draw(rot_matrix * pos_matrix);
}

void st::Mesh::set_texture(tr::Ref<st::Texture> texture)
{
	TR_ASSERT_MSG(texture->id != 0, "texture id is 0, did you initialize it?");
	this->texture = tr::MaybeRef<Texture>(texture);
}

void st::Shader::check_compilation(const char* shader_type)
{
	int32 success;
	glGetShaderiv(this->shader, GL_COMPILE_STATUS, &success);
	if (!success) {
		char infolog[512];
		glGetShaderInfoLog(this->shader, 512, nullptr, infolog);
		tr::panic("couldn't compile %s shader: %s", shader_type, infolog);
	}
}

st::VertexShader::VertexShader(tr::String src)
{
	this->shader = glCreateShader(GL_VERTEX_SHADER);
	char* whythefuck = src.buffer();
	glShaderSource(this->shader, 1, &whythefuck, nullptr);
	glCompileShader(this->shader);

	this->check_compilation("vertex");
	tr::info("created vertex shader (id %u)", this->shader);
}

st::VertexShader::~VertexShader()
{
	glDeleteShader(this->shader);
	tr::info("deleted vertex shader (id %u)", this->shader);
}

st::FragmentShader::FragmentShader(tr::String src)
{
	this->shader = glCreateShader(GL_FRAGMENT_SHADER);
	char* whythefuck = src.buffer();
	glShaderSource(this->shader, 1, &whythefuck, nullptr);
	glCompileShader(this->shader);

	this->check_compilation("fragment");
	tr::info("created fragment shader (id %u)", this->shader);
}

st::FragmentShader::~FragmentShader()
{
	glDeleteShader(this->shader);
	tr::info("deleted fragment shader (id %u)", this->shader);
}

st::ShaderProgram::ShaderProgram()
{
	this->program = glCreateProgram();
	tr::info("created shader program (id %u)", this->program);
}

st::ShaderProgram::~ShaderProgram()
{
	glDeleteProgram(this->program);
	tr::info("deleted shader program (id %u)", this->program);
}

void st::ShaderProgram::attach(tr::Ref<Shader> shader)
{
	glAttachShader(this->program, shader->shader);
}

void st::ShaderProgram::link()
{
	glLinkProgram(this->program);

	int32_t success;
	glGetProgramiv(this->program, GL_LINK_STATUS, &success);
	if (!success) {
		char infolog[512];
		glGetProgramInfoLog(this->program, 512, nullptr, infolog);
		tr::panic("gpu program linking error: %s", infolog);
	}

	tr::info("linked shader program (id %u)", this->program);
}

void st::ShaderProgram::use()
{
	glUseProgram(this->program);
	st::current_shader = this;
}

st::Texture::Texture(tr::String path)
{
	tr::Ref<tr::Arena> tmp = new tr::Arena(tr::kb_to_bytes(1));
	tr::String real_path = st::path(tmp, path);

	// TODO texture cache
	int32 width, height, channels;
	uint8* data = stbi_load(real_path, &width, &height, &channels, 0);
	if (data == nullptr) {
		tr::panic("couldn't load texture from %s", path.buffer());
	}

	// TODO there's no way this is correct but i can't be bothered to check
	GLenum format;
	switch (channels) {
		case 1:  format = GL_R;    break;
		case 2:  format = GL_RG;   break;
		case 3:  format = GL_RGB;  break;
		case 4:  format = GL_RGBA; break;
		default: format = GL_RGB;  break;
	}

	// help
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	this->size = {static_cast<uint32>(width), static_cast<uint32>(height)};

	// actually make the texture
	glGenTextures(1, &this->id);
	glBindTexture(GL_TEXTURE_2D, this->id);
	glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
	// TODO there should be a setting for this probably
	glGenerateMipmap(GL_TEXTURE_2D);

	stbi_image_free(data);
	tr::info("loaded texture from %s (id %u)", path.buffer(), this->id);
}

st::Texture::~Texture()
{
	glDeleteTextures(1, &this->id);
	tr::info("deleted texture (id %u)", this->id);
}

void st::ShaderProgram::set_uniform(tr::String name, bool value)
{
	glUniform1i(glGetUniformLocation(this->program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, int32 value)
{
	glUniform1i(glGetUniformLocation(this->program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, float32 value)
{
	glUniform1f(glGetUniformLocation(this->program, name), value);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec2<float32> value)
{
	glUniform2f(glGetUniformLocation(this->program, name), value.x, value.y);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec3<float32> value)
{
	glUniform3f(glGetUniformLocation(this->program, name), value.x, value.y, value.z);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Vec4<float32> value)
{
	glUniform4f(glGetUniformLocation(this->program, name), value.x, value.y, value.z, value.w);
}

void st::ShaderProgram::set_uniform(tr::String name, tr::Matrix4x4 value)
{
	// man
	glUniformMatrix4fv(glGetUniformLocation(this->program, name), 1, false,
		reinterpret_cast<float32*>(&value)
	);
}
