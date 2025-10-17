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

#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/log.h>
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/util.h>

#include "starry/app.h"
#include "starry/gpu.h"
#include "starry/internal.h"
#include "starry/render.h"
#include "trippin/string.h"

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
	atlas._textures = tr::HashMap<TextureId, tr::Rect<uint32>>(_st->asset_arena);
	return atlas;
}

void st::TextureAtlas::free()
{
	_source.free();
}

void st::TextureAtlas::add(st::TextureId id, tr::Rect<uint32> coords)
{
	TR_ASSERT_MSG(
		coords.position < size(), "position is %u, %u; size is %u, %u", coords.position.x,
		coords.position.y, size().x, size().y
	)
	TR_ASSERT_MSG(
		id < MAX_ATLAS_TEXTURES, "texture id %i must be below %i", id, MAX_ATLAS_TEXTURES
	);

	if (_textures.contains(id)) {
		tr::warn("texture atlas already has id %i; overwriting original texture", id);
	}

	_textures[id] = coords;
}

void st::TextureAtlas::set_current() const
{
	_st->atlas = *this;
	st::_upload_atlas(*this);
}

tr::Maybe<const st::ModelSpec&> st::Model::model_spec() const
{
	// i could just do return _st->models.try_get(id); but it doesn't want to convert to const
	tr::Maybe<ModelSpec&> model_specma = _st->models.try_get(id);
	if (model_specma.is_valid()) {
		return model_specma.unwrap();
	}
	else {
		return {};
	}
}

tr::Maybe<tr::String> st::Model::name() const
{
	tr::Maybe<ModelSpec&> model_specma = _st->models.try_get(id);
	if (model_specma.is_valid()) {
		return model_specma.unwrap().name;
	}
	else {
		return {};
	}
}

st::ModelSpec::ModelSpec(st::Model id, tr::String name, tr::Array<st::ModelMesh> meshes)
	: name(name)
	, meshes(meshes)
{
	// TODO

	_st->models[id] = *this;
	tr::info("registed model '%s' (id %u)", *name, uint16(id));
}

bool st::ModelSpec::is_terrain() const
{
	if (meshes.len() != 1) {
		return false;
	}

	if (meshes[0].type != ModelMeshType::CUBE) {
		return false;
	}

	if (meshes[0].cube.position != tr::Vec3<uint8>{0, 0, 0}) {
		return false;
	}

	if (meshes[0].cube.size != _st->settings.grid_size) {
		return false;
	}

	return true;
}

tr::Maybe<st::Block> st::get_static_block(tr::Vec3<int32> pos)
{
	if (_st->terrain_chunks.contains(st::block_to_chunk_pos(pos))) {
		Model model = _st->terrain_chunks[st::block_to_chunk_pos(pos)][pos];
		if (model != MODEL_AIR) {
			return Block(pos, model, BlockType::TERRAIN);
		}
	}
	if (_st->static_blocks.contains(pos)) {
		Model model = _st->static_blocks[pos];
		return Block(pos, model, BlockType::STATIC);
	}
	return {};
}

tr::Maybe<st::Block> st::_get_terrain_block(tr::Vec3<int32> pos)
{
	if (_st->terrain_chunks.contains(st::block_to_chunk_pos(pos))) {
		Model model = _st->terrain_chunks[st::block_to_chunk_pos(pos)][pos];
		if (model != MODEL_AIR) {
			return Block(pos, model, BlockType::TERRAIN);
		}
	}
	return {};
}

st::Block st::place_static_block(tr::Vec3<int32> pos, st::Model model)
{
	TR_ASSERT(model.model_spec().is_valid());
	bool is_terrain = model.model_spec().unwrap().is_terrain();

	if (is_terrain) {
		_st->terrain_chunks[st::block_to_chunk_pos(pos)][pos] = model;

		// if a block is placed and no one is around to see it, does it really show up?
		float64 distance = pos.distance(st::current_chunk());
		if (distance < CHUNK_SIZE * _st->render_distance) {
			_st->terrain_chunks[st::block_to_chunk_pos(pos)].new_this_frame = true;
			_st->chunk_updates_in_your_area = true;
		}

		return Block(pos, model, BlockType::TERRAIN);
	}
	else {
		_st->static_blocks[pos] = model;
		return Block(pos, model, BlockType::STATIC);
	}
}

st::DynamicBlock::operator Block() const
{
	tr::Vec3<float32> rounded = {roundf(position.x), roundf(position.y), roundf(position.z)};
	return Block{rounded.cast<int32>(), model(), BlockType::DYNAMIC};
}

tr::Maybe<st::DynamicBlock&> st::Block::to_dynamic_block() const // NOLINT
{
	TR_TODO();
}

void st::Block::destroy()
{
	if (model().model_spec().unwrap().is_terrain()) {
		_st->terrain_chunks[st::block_to_chunk_pos(_position)][_position] = MODEL_AIR;
	}
	else {
		_st->static_blocks.remove(_position);
	}
	_model = MODEL_AIR;

	// if a block is removed and no one is around to see it, does it really show up?
	float64 distance = _position.distance(st::current_chunk());
	if (distance < CHUNK_SIZE * _st->render_distance) {
		_st->terrain_chunks[st::block_to_chunk_pos(_position)].new_this_frame = true;
		_st->chunk_updates_in_your_area = true;
	}
}

st::DynamicBlock& st::place_dynamic_block(st::Model model)
{
	(void)model;
	TR_TODO();
}

st::Environment& st::environment()
{
	return _st->environment;
}
