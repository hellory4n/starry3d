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

#include <trippin/collection.h>
#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/string.h>

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
constexpr TextureId MAX_ATLAS_TEXTURES = 1 << 14; // 16384

// Wrapper for putting multiple textures on the same texture, whch makes it faster, and
// stuff.
class TextureAtlas
{
public: // TODO don't
	Texture _source = {};
	tr::HashMap<TextureId, tr::Rect<uint32>> _textures = {};

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

// You know how in pixel art you usually have a grid size and everything snaps to that? This is just
// that but in 3D.
void set_grid_size(tr::Vec3<uint8> size);

// A cube in a model. Revolutionary.
struct ModelCube
{
	tr::Vec3<uint8> position = {};
	tr::Vec3<uint8> size = {};
	struct
	{
		TextureId forward = 0;
		TextureId back = 0;
		TextureId left = 0;
		TextureId right = 0;
		TextureId up = 0;
		TextureId down = 0;
	} texture;
	// If false, the cube ignores lighting and becomes pure color
	bool shaded = true;
};

// A plane in a model. Revolutionary.
struct ModelPlane
{
	tr::Vec3<uint8> from = {};
	tr::Vec3<uint8> to = {};
	TextureId texture = 0;
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
};

// A handle to the real model (`st::ModelSpec`)
struct Model
{
	uint16 id;

	constexpr Model(uint16 id)
		: id(id)
	{
	}

	operator uint16() const
	{
		return id;
	}
};

// There is simply nothing. There is simply nothing. There is simply nothing. There is simply
// nothing. There is simply nothing. There is simply nothing. There is simply nothing. There is
// simply nothing.
constexpr Model MODEL_AIR = 0;

// A list of meshes which may either be a cube or plane because real voxels are too slow unless you
// do evil fuckery which I would rather not do at the moment. A fascinating endeavour.
struct ModelSpec
{
	tr::Array<ModelMesh> meshes = {};

	// Registers the model so that now you can use it with that ID and stuff HOW COOL IS THAT
	ModelSpec(Model id, tr::Array<ModelMesh> meshes);
};

enum class BlockType : uint8
{
	AIR,
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
	tr::Color tint = tr::palette::WHITE;

	// Yeah.
	operator Block() const;
};

// Probably a static block except this represents dynamic blocks sometimes too. Note this struct
// isn't actually used by the renderer this is just the public API :)))))))))))))))))) hepl
struct Block
{
	// If it's a dynamic block then the position gets rounded
	const tr::Vec3<int32> position = {};
	const Model model = 0;
	const BlockType type;

	// If the block is dynamic, returns a `st::DynamicBlock&`. Else, returns null.
	tr::Maybe<DynamicBlock&> to_dynamic_block() const;

	// Annihilates the block there
	void destroy();

	bool exists() const
	{
		return model != 0;
	}

private:
	Block(tr::Vec3<int32> position, Model model, BlockType type)
		: position(position)
		, model(model)
		, type(type)
	{
	}

	// TODO add the renderer as a friend
};

// Returns the static block in that position. Note that not all blocks have a position, to
// check that use the `st::Block.exists()` function
Block& get_static_block(tr::Vec3<int32> pos);

// Places a static block somewhere, and returns the placed block.
Block& place_static_block(tr::Vec3<int32> pos, Model model);

// util functions, just to make things shorter/easier to read
static inline bool block_exists_at(tr::Vec3<int32> pos)
{
	return st::get_static_block(pos).exists();
}

static inline Model get_model_from_pos(tr::Vec3<int32> pos)
{
	return st::get_static_block(pos).model;
}

// Removes a static/terrain block somewhere.
static inline void break_static_block(tr::Vec3<int32> pos)
{
	st::get_static_block(pos).destroy();
}

// Places a dynamic block somewhere, and returns the placed dynamic block.
DynamicBlock& place_dynamic_block(Model model);

}

#endif
