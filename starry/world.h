/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/world.h
 * The API for the voxel world and stuff.
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

#ifndef _ST_WORLD_H
#define _ST_WORLD_H

#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/string.h>
#include <trippin/util.h>

#include "starry/gpu.h"

namespace st {

enum class CameraProjection
{
	ORTHOGRAPHIC,
	PERSPECTIVE
};

// It's a camera lmao.
struct Camera
{
	// idk man
	static constexpr tr::Vec3<float32> FORWARD = {0, 0, -1};
	static constexpr tr::Vec3<float32> RIGHT = {+1, 0, 0};
	static constexpr tr::Vec3<float32> UP = {0, +1, 0};

	tr::Vec3<float32> position = {0, 0, -5};
	// In degrees
	tr::Vec3<float32> rotation = {};
	union {
		// In degrees
		float32 fov = 70;
		float32 zoom;
	};
	// How near can objects be before they get clipped
	float32 near = 0.01f;
	// How far can objects be before they get clipped
	float32 far = 1'000;
	CameraProjection projection = CameraProjection::PERSPECTIVE;

	tr::Matrix4x4 view_matrix() const;
	tr::Matrix4x4 projection_matrix() const;

	// Returns the current camera :)
	static Camera& current();
};

// Refers to a texture on a texture atlas
using TextureId = uint16;
constexpr TextureId MAX_ATLAS_TEXTURES = UINT16_MAX;

// Wrapper for putting multiple textures on the same texture, whch makes it faster, and
// stuff.
class TextureAtlas
{
	Texture _source = {};
	tr::HashMap<TextureId, tr::Rect<uint32>> _textures = {};

	friend void _upload_atlas(TextureAtlas atlas);

public:
	// Loads a texture atlas from an image file.
	static tr::Result<TextureAtlas&> load(tr::String path);

	// The engine calls this for you :)))))))))))))))))))
	void free();

	// Adds a texture to the atlas
	void add(TextureId id, tr::Rect<uint32> coords);

	// It's the one and only Mr. Atlas himself
	void set_current() const;

	// In pixels
	tr::Vec2<uint32> size() const
	{
		return _source.size();
	}

	// Literally just returns the internal texture
	Texture texture() const
	{
		return _source;
	}
};

// you'll never guess what this is
struct TextureOrColor
{
	union {
		TextureId texture = 0;
		tr::Color color;
	};
	bool using_texture = false;

	TextureOrColor() {}
	TextureOrColor(TextureId texture)
		: texture(texture)
		, using_texture(true)
	{
	}
	TextureOrColor(tr::Color color)
		: color(color)
		, using_texture(false)
	{
	}
};

// A cube in a model. Revolutionary.
struct ModelCube
{
	tr::Vec3<uint8> position = {};
	tr::Vec3<uint8> size = {};
	TextureOrColor front = {};
	TextureOrColor back = {};
	TextureOrColor left = {};
	TextureOrColor right = {};
	TextureOrColor top = {};
	TextureOrColor bottom = {};
	// If false, the cube ignores lighting and becomes pure color
	bool shaded = true;
};

// A plane in a model. Revolutionary.
struct ModelPlane
{
	tr::Vec3<uint8> top_left = {};
	tr::Vec3<uint8> top_right = {};
	tr::Vec3<uint8> bottom_left = {};
	tr::Vec3<uint8> bottom_right = {};
	TextureOrColor texture_or_color = {};
	// If false, the plane ignores lighting and becomes pure color
	bool shaded = true;
	// If true, the plane always faces the camera which is kinda cool sometimes
	bool billboard = false;
};

enum class ModelMeshType
{
	// shut up <3
	UNINITIALIZED,
	CUBE,
	PLANE,
};

// you could use inheritance too but idc
struct ModelMesh
{
	ModelMeshType type = ModelMeshType::UNINITIALIZED;
	union {
		ModelCube cube;
		ModelPlane plane;
	};

	ModelMesh() {}
	ModelMesh(ModelCube cube)
		: type(ModelMeshType::CUBE)
		, cube(cube)
	{
	}
	ModelMesh(ModelPlane plane)
		: type(ModelMeshType::PLANE)
		, plane(plane)
	{
	}
};

// A list of meshes which may either be a cube or plane because real voxels are too slow unless you
// do evil fuckery which I would rather not do at the moment. A fascinating endeavour.
struct ModelSpec;

// A handle to the real model (`st::ModelSpec`)
struct Model
{
	uint16 id;

	constexpr Model()
		: id(0)
	{
	}

	constexpr Model(uint16 id)
		: id(id)
	{
	}

	constexpr operator uint16() const
	{
		return id;
	}

	// Returns the `st::ModelSpec` from which this piece of crap originates from, or null if the
	// id is invalid
	tr::Maybe<const ModelSpec&> model_spec() const;

	// The model name duh (or null if it doesn't exist)
	tr::Maybe<tr::String> name() const;
};

// There is simply nothing. There is simply nothing. There is simply nothing. There is simply
// nothing. There is simply nothing. There is simply nothing. There is simply nothing. There is
// simply nothing.
constexpr Model MODEL_AIR = 0;

// A list of meshes which may either be a cube or plane because real voxels are too slow unless you
// do evil fuckery which I would rather not do at the moment. A fascinating endeavour.
struct ModelSpec
{
	tr::String name = "";
	tr::Array<ModelMesh> meshes = {};

	// shutu p
	ModelSpec() {}

	// Registers the model so that now you can use it with that ID and stuff HOW COOL IS THAT
	ModelSpec(Model id, tr::String name, tr::Array<ModelMesh> meshes);

	// Terrain blocks are rendered differently :))))))))))))))))
	bool is_terrain() const;
};

// using a constructor for that is kinda weird lmao
// TODO this is stupid

// Registers the model so that now you can use it with that ID and stuff HOW COOL IS THAT
inline void register_model_spec(Model id, tr::String name, tr::Array<ModelMesh> meshes)
{
	[[maybe_unused]]
	ModelSpec man = ModelSpec(id, name, meshes);
}

constexpr int32 CHUNK_SIZE = 16;
constexpr tr::Vec3<int32> CHUNK_SIZE_VEC{CHUNK_SIZE}; // makes some math cleaner

// You'll never guess what this does
constexpr tr::Vec3<int32> block_to_chunk_pos(tr::Vec3<int32> block_pos)
{
	tr::Vec3<float32> fpos = block_pos.cast<float32>();
	tr::Vec3<float32> fchunk = fpos / static_cast<float32>(CHUNK_SIZE);
	fchunk.x = floorf(fchunk.x);
	fchunk.y = floorf(fchunk.y);
	fchunk.z = floorf(fchunk.z);
	return fchunk.cast<int32>();
}

// You'll never guess what this does
constexpr tr::Vec3<int32> block_to_chunk_pos(tr::Vec3<float32> block_pos)
{
	tr::Vec3<float32> fchunk = block_pos / static_cast<float32>(CHUNK_SIZE);
	fchunk.x = floorf(fchunk.x);
	fchunk.y = floorf(fchunk.y);
	fchunk.z = floorf(fchunk.z);
	return fchunk.cast<int32>();
}

// As the name implies, it returns the current chunk, as in whatever chunk the player's currently
// at.
inline tr::Vec3<int32> current_chunk()
{
	return st::block_to_chunk_pos(Camera::current().position);
}

enum class BlockType : uint8
{
	TERRAIN,
	STATIC,
	DYNAMIC,
};

// Probably a static block except this represents dynamic blocks sometimes too. Note this struct
// isn't actually used by the renderer this is just the public API :)))))))))))))))))) hepl
struct Block;

// This dynamic-ed my block.
struct DynamicBlock
{
	tr::Vec3<float32> position = {};
	// In radians
	tr::Vec3<float32> rotation = {};
	// Multiplier (:
	tr::Vec3<float32> scale = {1.0, 1.0, 1.0};
	tr::Color tint = tr::COLOR_WHITE;

	Model model() const
	{
		return _model;
	}

	// Yeah.
	operator Block() const;

private:
	Model _model = MODEL_AIR;
};

// Probably a static block except this represents dynamic blocks sometimes too. Note this struct
// isn't actually used by the renderer this is just the public API :)))))))))))))))))) hepl
struct Block
{
	// If it's a dynamic block then the position gets rounded
	tr::Vec3<int32> position() const
	{
		return _position;
	}

	Model model() const
	{
		return _model;
	}

	BlockType type() const
	{
		return _type;
	}

	// If the block is dynamic, returns a `st::DynamicBlock&`. Else, returns null.
	tr::Maybe<DynamicBlock&> to_dynamic_block() const;

	// Annihilates the block there
	void destroy();

private:
	tr::Vec3<int32> _position = {};
	Model _model = MODEL_AIR;
	BlockType _type;

	Block()
		: _type(BlockType::TERRAIN)
	{
	}

	Block(tr::Vec3<int32> position, Model model, BlockType type)
		: _position(position)
		, _model(model)
		, _type(type)
	{
	}

	// blocks have lots of friends
	// all of them can touch block's private parts
	friend DynamicBlock;
	friend tr::Maybe<Block> get_static_block(tr::Vec3<int32> pos);
	friend tr::Maybe<Block> _get_terrain_block(tr::Vec3<int32> pos);
	friend Block place_static_block(tr::Vec3<int32> pos, Model model);
	friend tr::HashMap<tr::Vec3<int32>, Block>; // ???????
};

// Returns the static block in that position. Note that not all blocks have a position, to
// check that use the `st::Block.exists()` function
tr::Maybe<Block> get_static_block(tr::Vec3<int32> pos);

// Places a static block somewhere, and returns the placed block.
Block place_static_block(tr::Vec3<int32> pos, Model model);

// util functions, just to make things shorter/easier to read
inline bool block_exists_at(tr::Vec3<int32> pos)
{
	return st::get_static_block(pos).is_valid();
}

inline tr::Maybe<Model> get_model_from_pos(tr::Vec3<int32> pos)
{
	tr::Maybe<Block> block = st::get_static_block(pos);
	if (block.is_valid()) {
		return block.unwrap().model();
	}
	return {};
}

// Removes a static/terrain block somewhere, and returns true if the original block existed.
inline bool break_static_block(tr::Vec3<int32> pos)
{
	tr::Maybe<Block> block = st::get_static_block(pos);
	if (block.is_valid()) {
		block.unwrap().destroy();
		return true;
	}
	return false;
}

// Places a dynamic block somewhere, and returns the placed dynamic block.
DynamicBlock& place_dynamic_block(Model model);

// Sets the values for lighting and stuff
struct Environment
{
	tr::Vec3<float32> sun_direction = {0.5, 1.0, -0.75};
	tr::Color sky_color = tr::Color::rgb(0x009ccf); // weezer blue
	tr::Color sun_color = tr::COLOR_WHITE;
	tr::Color ambient_color = tr::Vec4<float32>{0.5f, 0.55f, 0.5f, 1.0f};
};

// Returns the current environment. This is also how you set the environment vars
Environment& environment();

// Like st::get_static_block but it skips checking for static blocks; for use in the renderer
tr::Maybe<Block> _get_terrain_block(tr::Vec3<int32> pos);

}

#endif
