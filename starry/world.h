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
#include <trippin/string.h>

#include "starry/asset.h"

namespace st {

enum class CameraProjection : uint8
{
	PERSPECTIVE,
	ORTHOGRAPHIC
};

struct Camera
{
	// idk man
	static constexpr tr::Vec3<float32> FRONT = {0, 0, -1};
	static constexpr tr::Vec3<float32> UP = {0, 1, 0};

	tr::Vec3<float32> position = {};
	// In degrees
	tr::Vec3<float32> rotation = {};
	union {
		// In degrees
		float32 fov = 45;
		float32 zoom;
	};
	// How near can objects be before they get clipped
	float32 near = 0.001f;
	// How far can objects be before they get clipped
	float32 far = 1000.0f;
	// The projection duh
	CameraProjection projection = CameraProjection::PERSPECTIVE;

	// Calculates and returns the view matrix
	tr::Matrix4x4 view_matrix() const;
	// Calculates and returns the projection matrix
	tr::Matrix4x4 projection_matrix() const;

	// Returns the current camera. This is also how you set the current camera
	static Camera& current();
};

// I love optimization. This refers to a texture on a `st::TextureAtlas`, normal textures are just
// `st::Texture`
using TextureId = uint16;

// Represents a texture atlas :)
class TextureAtlas
{
	// i know you could use an array but this allows arbitrary indexes, instead of being all in
	// order
	// the actual float UVs are calculated in the shader :)
	tr::HashMap<TextureId, tr::Rect<uint32>> _textures = {};
	tr::Maybe<Texture> _source = {};

	friend void _upload_atlas();

public:
	// Makes a texture atlas :)
	static tr::Result<TextureAtlas> load(tr::String path);

	// Adds a texture duh
	void add(TextureId id, tr::Rect<uint32> rect);

	// Makes this the one and only mr. texture atlas himself.
	void set_current() const;

	// Returns the texture size in pixels
	tr::Vec2<uint32> size() const;
};

}

#endif
