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

#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/string.h>

namespace st {

// TODO figure out how to make opengl work multithreaded (maybe the renderer is in its own thread?)
// TODO this whole API is questionable at best

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

enum class MeshUsage : uint8
{
	// Set once, used many times. The default option. Equivalent to `GL_STATIC_DRAW`
	READONLY,
	// Modified several times and used many times. Equivalent to `GL_DYNAMIC_DRAW`
	MUTABLE,
	// Modified very often and not used many times (because it's being modified often).
	// Equivalent to `GL_STREAM_DRAW`
	STREAMED,
};

// Represents a mesh in the GPU.
class Mesh
{
	uint32 _vao = 0;
	uint32 _vbo = 0;
	uint32 _ebo = 0;
	uint32 _index_count = 0;
	MeshUsage _usage = MeshUsage::READONLY;

public:
	Mesh() {}

	// `elem_size` is the size of the type you're using for vertices. `readonly`
	// allows you to update the mesh later. You can also use null for the pointers so that it's
	// just reserving data on VRAM for future use. You should probably use the other
	// constructors (pointer scary! arrays are nicer)
	Mesh(tr::Array<const VertexAttribute> format, const void* buffer, usize length,
	     const Triangle* indices, usize triangle_count, MeshUsage usage);

	// Creates a mesh duh
	template<typename T>
	Mesh(tr::Array<const VertexAttribute> format, tr::Array<T> vertices,
	     tr::Array<const Triangle> indices, MeshUsage usage = MeshUsage::READONLY)
		: Mesh(format, *vertices, sizeof(T) * vertices.len(), *indices, indices.len(),
		       usage)
	{
	}

	// Reserves space in VRAM so that you can put stuff in it later
	Mesh(tr::Array<const VertexAttribute> format, MeshUsage usage)
		: Mesh(format, nullptr, 0, nullptr, 0, usage)
	{
		if (tr::is_debug() && usage == MeshUsage::READONLY) {
			tr::warn(
				"creating readonly mesh without uploading data first. do you know "
				"what 'readonly' means?"
			);
		}
	}

	void free();

	// man
	bool is_valid() const
	{
		return _vao != 0 && _vbo != 0 && _ebo != 0 && _index_count != 0;
	}

	// Draws the mesh. This doesn't handle position, you're gonna have to figure
	// that out yourself with shader uniforms and shit. Just look at
	// learnopengl.com or some shit.
	void draw(uint32 instances = 1) const;

	// Updates the data :) (requires mesh usage to NOT be readonly)
	void update_data(
		const void* buffer, usize length, const Triangle* indices, usize triangle_count
	);

	// Updates the data :) (requires mesh usage to NOT be readonly)
	template<typename T>
	void update_data(tr::Array<T> vertices, tr::Array<Triangle> indices)
	{
		update_data(*vertices, vertices.len() * sizeof(T), *indices, indices.len());
	}

	// TODO partially_update_data()
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
	void attach(const Shader& shader);
	void link();
	// Uses the program for rendering crap.
	void use();

	// TODO string names are slower
	void set_uniform(tr::String name, bool value);
	void set_uniform(tr::String name, int32 value);
	void set_uniform(tr::String name, uint32 value);
	void set_uniform(tr::String name, float32 value);
	void set_uniform(tr::String name, tr::Vec2<float32> value);
	void set_uniform(tr::String name, tr::Vec3<float32> value);
	void set_uniform(tr::String name, tr::Vec4<float32> value);
	void set_uniform(tr::String name, tr::Vec2<int32> value);
	void set_uniform(tr::String name, tr::Vec3<int32> value);
	void set_uniform(tr::String name, tr::Vec4<int32> value);
	void set_uniform(tr::String name, tr::Vec2<uint32> value);
	void set_uniform(tr::String name, tr::Vec3<uint32> value);
	void set_uniform(tr::String name, tr::Vec4<uint32> value);
	void set_uniform(tr::String name, tr::Matrix4x4 value);
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
	bool mipmaps = true;
};

// It's an image on the GPU :)
class Texture
{
	uint32 _id = 0;
	tr::Vec2<uint32> _size = {};

public:
	// Loads a texture duh. Supported formats are .png, .jpeg, .gif (no animation) .bmp, .tga,
	// .psd (composited view only), .hdr (radiance rgbE format), .pic (Softimage pic), and
	// .ppm/.pgm binary
	static tr::Result<Texture> load(tr::String path, TextureSettings settings = {});
	void free();

	// It sets the texture to be the current texture texturing all over the place.
	void use() const;

	// In pixels
	tr::Vec2<uint32> size() const
	{
		return _size;
	}
};

enum class MapBufferAccess
{
	READ,
	WRITE,
	READ_WRITE,
};

// Wrapper for an OpenGL SSBO, useful for sending metric buttloads of data to shaders.
class StorageBuffer
{
	uint32 _buffer = 0;

public:
	StorageBuffer() {}
	StorageBuffer(uint32 binding);
	void free();

	// Updates the data :)))))))
	void update(const void* data, usize len);

	// Only updates *some* of the data
	void partial_update(usize offset, const void* data, usize len);

	// Reserves VRAM to be used later
	void reserve(usize len)
	{
		update(nullptr, len);
	}

	// Literally just `glMapBuffer` (no intermediate buffer required, just directly poke the
	// pointer that opengl gives you)
	void* map_buffer(MapBufferAccess access);

	// Literally just `glUnmapBuffer`
	void unmap_buffer();
};

} // namespace st

#endif
