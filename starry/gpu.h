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

#ifndef _ST_RENDER_H
#define _ST_RENDER_H

#include <trippin/error.h>
#include <trippin/math.h>
#include <trippin/string.h>

namespace st {

// It clears the screen lmao.
void clear_screen(tr::Color color);

// It's vertex attribute types lmao. Note this is just the types GLSL supports (no 64 bit ints
// because GLSL doesn't have them)
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
	// Name. This isn't actually used for anything, but it just makes things a bit clearer, and
	// I may use it later too
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
	unsigned v1 = 0;
	unsigned v2 = 0;
	unsigned v3 = 0;
};

// Represents a mesh in the GPU.
class Mesh
{
	unsigned _vao = 0;
	unsigned _vbo = 0;
	unsigned _ebo = 0;
	unsigned _index_count = 0;

public:
	Mesh() { }

	// `elem_size` is the size of the type you're using for vertices. `readonly` allows you to
	// update the mesh later.
	Mesh(tr::Array<VertexAttribute> format, void* buffer, usize elem_size, usize length,
	     tr::Array<Triangle> indices, bool readonly);

	// not really necessary idc
	template<typename T>
	Mesh(tr::Array<VertexAttribute> format, tr::Array<T> vertices, tr::Array<Triangle> indices,
	     bool readonly)
		: Mesh(format, vertices.buf(), sizeof(T), vertices.len(), indices, readonly)
	{
	}

	void free();

	// Draws the mesh. This doesn't handle position, you're gonna have to figure that out
	// yourself with shader uniforms and shit. Just look at learnopengl.com or some shit.
	void draw() const;

	// TODO draw_instanced(), update_data()
};

// A program on the GPU©®¢™¢™¢™©®©®©®™™™©®©®™™™©®©®™™¢®¢™™
class ShaderProgram;

// Shader. There's different shader classes just in case I decide to add compute shaders for some
// fucking reason.
class Shader
{
protected:
	unsigned _shader = 0;
	// you stupid piece of shit get away from me and dont come back again until you learn to be
	// a tougher kind of man whos master of his plan and doesnt need to leech off others sanity
	// until then i dont ever wanna see your face it makes me sick just thinking of your lack of
	// grace whenever you demand that someone hold your hand your weakest bet is just to put
	// your fight in place so thats right right yeah the kind of games you play are for a five
	// year old who doesnt wanna do the things that shes been told at first he wont submit and
	// then he throws a fit and screams at all the world that it it wrong to scold a sweet and
	// innocent bystander of a man is rising up to meet the challenges at hand and doesnt have
	// the time to listen to him whine or change his diapie when hes crapped himself again thats
	// right right yeah youre such a sad pathetic fool ive caught you playing with your stool
	// TODO wtf is this comment
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
	unsigned _program = 0;

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

// It's an image on the GPU :)
class Texture
{
	uint32 _id = 0;
	tr::Vec2<uint32> _size;

public:
	static tr::Result<Texture> load(tr::String path);
	void free();

	// It sets the texture to be the current texture texturing all over the place.
	void use() const;
};

// TODO ShaderStorageBuffer (SSBOs)

}

#endif
