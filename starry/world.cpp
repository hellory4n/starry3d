/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/world.cpp
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

#include "starry/world.h"

#include <trippin/collection.h>
#include <trippin/error.h>
#include <trippin/log.h>
#include <trippin/math.h>

#include "starry/app.h"
#include "starry/gpu.h"
#include "starry/internal.h"

tr::Matrix4x4 st::Camera::view_matrix() const
{
	tr::Matrix4x4 position_mat =
		tr::Matrix4x4::translate(-position.x, -position.y, -position.z);

	tr::Matrix4x4 rotation_mat = tr::Matrix4x4::identity();
	rotation_mat = rotation_mat.rotate_x(tr::deg2rad(rotation.x));
	rotation_mat = rotation_mat.rotate_y(tr::deg2rad(rotation.y));
	rotation_mat = rotation_mat.rotate_z(tr::deg2rad(rotation.z));

	return rotation_mat * position_mat;
}

tr::Matrix4x4 st::Camera::projection_matrix() const
{
	tr::Vec2<uint32> window_size = st::window_size();
	float32 aspect = float32(window_size.x) / float32(window_size.y);

	if (projection == CameraProjection::PERSPECTIVE) {
		return tr::Matrix4x4::perspective(tr::deg2rad(fov), aspect, near, far);
	}

	// TODO this may be fucked im not sure
	float32 left = -zoom / 2.f;
	float32 right = zoom / 2.f;

	float32 height = this->zoom * (float32(window_size.y) / float32(window_size.x));
	float32 bottom = -height / 2.f;
	float32 top = height / 2.f;

	return tr::Matrix4x4::orthographic(left, right, bottom, top, near, far);
}

st::Camera& st::Camera::current()
{
	return _st->camera;
}

tr::Result<st::TextureAtlas&> st::TextureAtlas::load(tr::String path)
{
	TextureAtlas atlas = {};
	TR_TRY_ASSIGN(atlas._source, Texture::load(path));
	atlas._textures = tr::HashMap<TextureId, tr::Rect<float32>>(_st->asset_arena);
	return atlas;
}

void st::TextureAtlas::free()
{
	_source.free();
}

void st::TextureAtlas::add(st::TextureId id, tr::Rect<uint32> coords)
{
	TR_ASSERT(coords.position < size())
	TR_ASSERT_MSG(
		id < MAX_ATLAS_TEXTURES, "texture id %i must be below %i", id, MAX_ATLAS_TEXTURES
	);

	if (_textures.contains(id)) {
		tr::warn("texture atlas already has id %i; overwriting original texture", id);
	}

	// i am remapping it i am remapping it i am remapping it you need to remap mark
	_textures[id] = tr::Rect<float32>{
		tr::remap<float32>(coords.position.x, 0, size().x, 0.0, 1.0),
		tr::remap<float32>(coords.position.y, 0, size().y, 0.0, 1.0),
		tr::remap<float32>(coords.size.x, 0, size().x, 0.0, 1.0),
		tr::remap<float32>(coords.size.y, 0, size().y, 0.0, 1.0),
	};
}

void st::TextureAtlas::set_current() const
{
	_st->atlas = *this;
}
