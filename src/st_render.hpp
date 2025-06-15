/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * st_render.hpp
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

#ifndef _ST_RENDER_H
#define _ST_RENDER_H

#include <libtrippin.hpp>

namespace st {

// It clears the screen lmao.
void clear_screen(tr::Color color);

// As the name implies, it ends drawing.
void end_drawing();

enum class CameraProjection { ORTHOGRAPHIC, PERSPECTIVE };

// It's a camera lmao.
struct Camera
{
	tr::Vec3<float64> position;
	// In degrees
	tr::Vec3<float64> rotation;
	union {
		// In degrees
		float64 fov;
		float64 zoom;
	};
	// How near can objects be before they get clipped
	float64 near;
	// How far can objects be before they get clipped
	float64 far;
	CameraProjection projection;

	tr::Matrix4x4 view_matrix();
	tr::Matrix4x4 projection_matrix();
};

// Returns the current camera :)
Camera* camera();

// It's vertex attribute types lmao. Note this is just the types GLSL supports (no 64 bit ints because GLSL
// doesn't have them)
enum class VertexAttributeType {
	INT32, UINT32, FLOAT32, FLOAT64,
	VEC2_INT32, VEC2_UINT32, VEC2_FLOAT32, VEC2_FLOAT64,
	VEC3_INT32, VEC3_UINT32, VEC3_FLOAT32, VEC3_FLOAT64,
	VEC4_INT32, VEC4_UINT32, VEC4_FLOAT32, VEC4_FLOAT64,
};

// Represents the vertex layout in memory.
struct VertexAttribute
{
	// Name. This isn't actually used for anything, but it just makes things a bit clearer, and I may use it
	// later too
	tr::String name;
	// Type.
	VertexAttributeType type;
	// Just use this with `offsetof`
	const void* offset;
};

// It's a triangle lmao.
struct Triangle {
	uint32 v1;
	uint32 v2;
	uint32 v3;
};

// Represents a mesh in the GPU.
class Mesh : public tr::RefCounted
{
	uint32 vao;
	uint32 vbo;
	uint32 ebo;
	uint32 index_count;

public:
	// `elem_size` is the size of the type you're using for vertices. `readonly` allows you to update the
	// mesh later.
	Mesh(tr::Array<VertexAttribute> format, void* buffer, usize elem_size, usize length,
		tr::Array<Triangle> indices, bool readonly);

	// not really necessary idc
	template<typename T> Mesh(tr::Array<VertexAttribute> format, tr::Array<T> vertices,
		tr::Array<Triangle> indices, bool readonly)
		: Mesh(format, vertices.buffer(), sizeof(T), vertices.length(), indices, readonly) {}

	~Mesh();

	// Draws the mesh anywhere you want with the MVP matrices.
	void draw(tr::Matrix4x4 model, tr::Matrix4x4 view, tr::Matrix4x4 projection);

	// Draws the mesh using a custom model matrix and the default view/projection matrices.
	void draw(tr::Matrix4x4 matrix);

	// Draws the mesh in the 3D world. Rotation is in degrees
	void draw(tr::Vec3<float64> pos, tr::Vec3<float64> rot);

	// TODO draw_instanced(), update_data()
};

// A program on the GPU©®¢™¢™¢™©®©®©®™™™©®©®™™™©®©®™™¢®¢™™
class ShaderProgram;

// Shader. There's different shader classes just in case I decide to add compute shaders for some fucking reason.
class Shader
{
protected:
	uint32 shader;
	// you stupid piece of shit get away from me and dont come back again until you learn to be a tougher kind of man whos master of his plan and doesnt need to leech off others sanity until then i dont ever wanna see your face it makes me sick just thinking of your lack of grace whenever you demand that someone hold your hand your weakest bet is just to put your fight in place so thats right right yeah the kind of games you play are for a five year old who doesnt wanna do the things that shes been told at first he wont submit and then he throws a fit and screams at all the world that it it wrong to scold a sweet and innocent bystander of a man is rising up to meet the challenges at hand and doesnt have the time to listen to him whine or change his diapie when hes crapped himself again thats right right yeah youre such a sad pathetic fool ive caught you playing with your stool
	friend class ShaderProgram;

public:
	void check_compilation(const char* shader_type);
};

// A vertex shader is a shader that fucks with vertices.
class VertexShader : public Shader, public tr::RefCounted
{
public:
	VertexShader(tr::String src);
	~VertexShader();
};

// A fragment shader is a shader that fucks with fragments.
class FragmentShader : public Shader, public tr::RefCounted
{
public:
	FragmentShader(tr::String src);
	~FragmentShader();
};

// A program on the GPU©®¢™¢™¢™©®©®©®™™™©®©®™™™©®©®™™¢®¢™™
class ShaderProgram : public tr::RefCounted
{
	uint32 program;

public:
	ShaderProgram();
	~ShaderProgram();

	// Le
	void attach(tr::Ref<Shader> shader);
	void link();
	// Uses the program for rendering crap.
	void use();
};

}

#endif