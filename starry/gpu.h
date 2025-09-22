/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/gpu.h
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

#ifndef _ST_GPU_H
#define _ST_GPU_H

#include <trippin/error.h>
#include <trippin/math.h>
#include <trippin/string.h>

namespace st {

// It clears the screen lmao.
void clear_screen(tr::Color color);

// It's vertex attribute types lmao. Note this is just the types GLSL supports
// (no int64/uint64 because GLSL doesn't have them, blame Mr. OpenGL)
enum class VertexAttributeType
{
	INT32,
	UINT32,
	FLOAT32,
	FLOAT64,
	VEC2_INT32,
	VEC2_UINT32,
	VEC2_FLOAT32,
	VEC2_FLOAT64,
	VEC3_INT32,
	VEC3_UINT32,
	VEC3_FLOAT32,
	VEC3_FLOAT64,
	VEC4_INT32,
	VEC4_UINT32,
	VEC4_FLOAT32,
	VEC4_FLOAT64,
};

// Represents the vertex layout in memory.
struct VertexAttribute
{
	// Name. This isn't actually used for anything, but it just makes things a bit
	// clearer, and I may use it later too
	tr::String name;
	// Type.
	VertexAttributeType type;
	// Just use this with `offsetof`
	usize offset;

	VertexAttribute(tr::String name, VertexAttributeType type, usize offset)
		: name(name)
		, type(type)
		, offset(offset)
	{
	}
};

// It's a triangle lmao.
struct Triangle
{
	uint32 v1 = 0;
	uint32 v2 = 0;
	uint32 v3 = 0;
};

// Represents a mesh in the GPU.
class Mesh
{
	uint32 _vao = 0;
	uint32 _vbo = 0;
	uint32 _ebo = 0;
	uint32 _index_count = 0;

public:
	Mesh() {}

	// `elem_size` is the size of the type you're using for vertices. `readonly`
	// allows you to update the mesh later.
	Mesh(tr::Array<const VertexAttribute> format, const void* buffer, usize elem_size,
	     usize length, tr::Array<const Triangle> indices, bool readonly);

	// not really necessary but it's nice to have
	template<typename T>
	Mesh(tr::Array<const VertexAttribute> format, tr::Array<T> vertices,
	     tr::Array<const Triangle> indices, bool readonly = true)
		: Mesh(format, vertices.buf(), sizeof(T), vertices.len(), indices, readonly)
	{
	}

	void free();

	// Draws the mesh. This doesn't handle position, you're gonna have to figure
	// that out yourself with shader uniforms and shit. Just look at
	// learnopengl.com or some shit.
	void draw(uint32 instances = 1) const;

	// TODO update_data()
};

// A program on the GPU©®¢™¢™¢™©®©®©®™™™©®©®™™™©®©®™™¢®¢™™
class ShaderProgram;

// Shader. There's different shader classes just in case I decide to add compute
// shaders for some fucking reason.
class Shader
{
protected:
	uint32 _shader = 0;
	friend class ShaderProgram;

	void _check_compilation(const char* shader_type) const;
};

// A vertex shader is a shader that fucks with vertices.
class VertexShader : public Shader
{
public:
	VertexShader(tr::String src);
	void free();
};

// A fragment shader is a shader that fucks with fragments.
class FragmentShader : public Shader
{
public:
	FragmentShader(tr::String src);
	void free();
};

// A program on the GPU©®¢™¢™¢™©®©®©®™™™©®©®™™™©®©®™™¢®¢™™
class ShaderProgram
{
	uint32 _program = 0;

public:
	ShaderProgram();
	void free();

	// Le
	// TODO wtf is le
	void attach(const Shader& shader) const;
	void link() const;
	// Uses the program for rendering crap.
	void use();

	void set_uniform(tr::String name, bool value) const;
	void set_uniform(tr::String name, int32 value) const;
	void set_uniform(tr::String name, float32 value) const;
	void set_uniform(tr::String name, tr::Vec2<float32> value) const;
	void set_uniform(tr::String name, tr::Vec3<float32> value) const;
	void set_uniform(tr::String name, tr::Vec4<float32> value) const;
	void set_uniform(tr::String name, tr::Matrix4x4 value) const;
};

// What should happen when texture coordinates go beyond 0-1. See [this
// image](https://learnopengl.com/img/getting-started/texture_wrapping.png) for
// a visual example
enum class TextureWrap
{
	TILE,
	MIRRORED_TILE,
	CLAMP_TO_EDGE,
	CLAMP_TO_BORDER,
};

enum class TextureFilter
{
	NEAREST_NEIGHBOR,
	BILINEAR_FILTER,
};

struct TextureSettings
{
	TextureWrap wrap = TextureWrap::TILE;
	TextureFilter filter = TextureFilter::NEAREST_NEIGHBOR;
	bool mipmaps = false;
};

// It's an image on the GPU :)
class Texture
{
	uint32 _id = 0;
	tr::Vec2<uint32> _size;

public:
	static tr::Result<Texture> load(tr::String path, TextureSettings settings = {});
	void free();

	// It sets the texture to be the current texture texturing all over the place.
	void use() const;
};

// TODO ShaderStorageBuffer (SSBOs)

} // namespace st

#endif
