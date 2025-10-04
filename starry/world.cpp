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

namespace st {
static ModelVertex::Normal
_get_plane_normal(tr::Vec3<uint8> p0, tr::Vec3<uint8> p1, tr::Vec3<uint8> p2);

static void _gen_mesh_for_plane(
	ModelPlane plane, tr::Array<PackedModelVertex>& vertices, tr::Array<Triangle>& triangles,
	uint32& vert_count
);

static void _gen_mesh_for_cube(
	ModelCube cube, tr::Array<PackedModelVertex>& vertices, tr::Array<Triangle>& triangles,
	uint32& vert_count
);
}

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

void st::set_grid_size(tr::Vec3<uint8> size)
{
	_st->grid_size = size;
}

const st::ModelSpec& st::Model::model_spec() const
{
	return _st->models[id];
}

st::ModelSpec::ModelSpec(st::Model id, tr::Array<st::ModelMesh> meshes)
	: meshes(meshes)
{
	tr::Array<PackedModelVertex> vertices{_st->asset_arena};
	tr::Array<Triangle> triangles{_st->asset_arena};
	uint32 vert_count = 0;

	for (auto [_, mesh] : meshes) {
		if (mesh.type == ModelMeshType::CUBE) {
			st::_gen_mesh_for_cube(mesh.cube, vertices, triangles, vert_count);
		}
		else if (mesh.type == ModelMeshType::PLANE) {
			st::_gen_mesh_for_plane(mesh.plane, vertices, triangles, vert_count);
		}
		else {
			tr::panic("the fuck?");
		}
	}

	_st->model_mesh_data[id] = {.vertices = vertices, .triangles = triangles};
	_st->models[id] = *this;
	// TODO number ids to string names
	tr::info("registed model with id %u", uint16(id));
}

static st::ModelVertex::Normal
st::_get_plane_normal(tr::Vec3<uint8> p0, tr::Vec3<uint8> p1, tr::Vec3<uint8> p2)
{
	// you can't do vector math on an uint8
	tr::Vec3<float32> p0f = {float32(p0.x), float32(p0.y), float32(p0.z)};
	tr::Vec3<float32> p1f = {float32(p1.x), float32(p1.y), float32(p1.z)};
	tr::Vec3<float32> p2f = {float32(p2.x), float32(p2.y), float32(p2.z)};

	tr::Vec3<float32> a = p1f - p0f;
	tr::Vec3<float32> b = p2f - p0f;
	tr::Vec3<float32> n = a.cross_product(b).normalize();

	float32 ax = fabsf(n.x);
	float32 ay = fabsf(n.y);
	float32 az = fabsf(n.z);

	if (ax >= ay && ax >= az) {
		return (n.x > 0.0f) ? ModelVertex::Normal::RIGHT : ModelVertex::Normal::LEFT;
	}
	else if (ay >= ax && ay >= az) {
		return (n.y > 0.0f) ? ModelVertex::Normal::TOP : ModelVertex::Normal::BOTTOM;
	}
	else {
		return (n.z > 0.0f) ? ModelVertex::Normal::BACK : ModelVertex::Normal::FRONT;
	}
}

static void st::_gen_mesh_for_plane(
	st::ModelPlane plane, tr::Array<st::PackedModelVertex>& vertices,
	tr::Array<st::Triangle>& triangles, uint32& vert_count
)
{
	st::ModelVertex::Normal normal =
		st::_get_plane_normal(plane.top_left, plane.top_right, plane.bottom_left);

	ModelVertex top_left = ModelVertex{
		.position = plane.top_left,
		.normal = normal,
		.corner = ModelVertex::QuadCorner::TOP_LEFT,
		.shaded = plane.shaded,
		.billboard = plane.billboard,
		.texture_id = 0,
	};
	if (plane.texture_or_color.using_texture) {
		top_left.texture_id = plane.texture_or_color.texture;
		top_left.using_texture = true;
	}
	else {
		top_left.color = plane.texture_or_color.color;
		top_left.using_texture = false;
	}
	vertices.add(top_left);

	ModelVertex top_right = top_left;
	top_right.position = plane.top_right;
	top_right.corner = ModelVertex::QuadCorner::TOP_RIGHT;
	vertices.add(top_right);

	ModelVertex bottom_left = top_left;
	bottom_left.position = plane.bottom_left;
	bottom_left.corner = ModelVertex::QuadCorner::BOTTOM_LEFT;
	vertices.add(bottom_left);

	ModelVertex bottom_right = top_left;
	bottom_right.position = plane.bottom_right;
	bottom_right.corner = ModelVertex::QuadCorner::BOTTOM_RIGHT;
	vertices.add(bottom_right);

	triangles.add({vert_count + 2, vert_count + 1, vert_count});
	triangles.add({vert_count + 2, vert_count + 3, vert_count + 1});
	vert_count += 4;
}

static void st::_gen_mesh_for_cube(
	st::ModelCube cube, tr::Array<st::PackedModelVertex>& vertices,
	tr::Array<st::Triangle>& triangles, uint32& vert_count
)
{
	// TODO culling at the model level
	// this could just be optimized a lot more

	// struct thing so that we can use designated initializers :money_mouth:
	struct CubeFace // NOLINT(cppcoreguidelines-pro-type-member-init)
	{
		ModelVertex::Normal normal;
		TextureOrColor texture_or_color;
		tr::Vec3<uint8> top_left;
		tr::Vec3<uint8> top_right;
		tr::Vec3<uint8> bottom_left;
		tr::Vec3<uint8> bottom_right;
	};

	const auto planeificator = [&](CubeFace f) {
		ModelVertex base_vert = {
			.normal = f.normal, .shaded = cube.shaded, .texture_id = 0
		};

		if (f.texture_or_color.using_texture) {
			base_vert.texture_id = f.texture_or_color.texture;
			base_vert.using_texture = true;
		}
		else {
			base_vert.color = f.texture_or_color.color;
			base_vert.using_texture = true;
		}

		ModelVertex tl = base_vert;
		tl.position = f.top_left;
		tl.corner = ModelVertex::QuadCorner::TOP_LEFT;
		vertices.add(tl);

		ModelVertex tr = base_vert;
		tr.position = f.top_right;
		tr.corner = ModelVertex::QuadCorner::TOP_RIGHT;
		vertices.add(tr);

		ModelVertex bl = base_vert;
		bl.position = f.bottom_left;
		bl.corner = ModelVertex::QuadCorner::BOTTOM_LEFT;
		vertices.add(bl);

		ModelVertex br = base_vert;
		br.position = f.bottom_right;
		br.corner = ModelVertex::QuadCorner::BOTTOM_RIGHT;
		vertices.add(br);

		triangles.add({vert_count + 2, vert_count + 1, vert_count});
		triangles.add({vert_count + 2, vert_count + 3, vert_count + 1});
		vert_count += 4;
	};

// c++ police arrest this man
#define PX cube.position.x
#define PY cube.position.y
#define PZ cube.position.z
#define SX cube.size.x
#define SY cube.size.y
#define SZ cube.size.z
#define V0 {PX, PY, PZ}
#define V1 {uint8(tr::clamp(PX + SX, 0, 255)), PY, PZ}
#define V2 {uint8(tr::clamp(PX + SX, 0, 255)), uint8(tr::clamp(PY + SY, 0, 255)), PZ}
#define V3 {PX, uint8(tr::clamp(PY + SY, 0, 255)), PZ}
#define V4 {PX, PY, uint8(tr::clamp(PZ + SZ, 0, 255))}
#define V5 {uint8(tr::clamp(PX + SX, 0, 255)), PY, uint8(tr::clamp(PZ + SZ, 0, 255))}
#define V6                                                                     \
	{uint8(tr::clamp(PX + SX, 0, 255)), uint8(tr::clamp(PY + SY, 0, 255)), \
	 uint8(tr::clamp(PZ + SZ, 0, 255))}
#define V7 {PX, uint8(tr::clamp(PY + SY, 0, 255)), uint8(tr::clamp(PZ + SZ, 0, 255))}

	planeificator({
		.normal = ModelVertex::Normal::FRONT,
		.texture_or_color = cube.front,
		.top_left = V3,
		.top_right = V2,
		.bottom_left = V0,
		.bottom_right = V1,
	});
	planeificator({
		.normal = ModelVertex::Normal::BACK,
		.texture_or_color = cube.back,
		.top_left = V6,
		.top_right = V7,
		.bottom_left = V5,
		.bottom_right = V4,
	});
	planeificator({
		.normal = ModelVertex::Normal::LEFT,
		.texture_or_color = cube.left,
		.top_left = V7,
		.top_right = V3,
		.bottom_left = V4,
		.bottom_right = V0,
	});
	planeificator({
		.normal = ModelVertex::Normal::RIGHT,
		.texture_or_color = cube.right,
		.top_left = V2,
		.top_right = V6,
		.bottom_left = V1,
		.bottom_right = V5,
	});
	planeificator({
		.normal = ModelVertex::Normal::TOP,
		.texture_or_color = cube.top,
		.top_left = V7,
		.top_right = V6,
		.bottom_left = V3,
		.bottom_right = V2,
	});
	planeificator({
		.normal = ModelVertex::Normal::BOTTOM,
		.texture_or_color = cube.bottom,
		.top_left = V0,
		.top_right = V1,
		.bottom_left = V4,
		.bottom_right = V5,
	});

// undoing my crimes
#undef PX
#undef PY
#undef PZ
#undef SX
#undef SY
#undef SZ
#undef V0
#undef V1
#undef V2
#undef V3
#undef V4
#undef V5
#undef V6
#undef V7
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

	if (meshes[0].cube.size != _st->grid_size) {
		return false;
	}

	return true;
}

tr::Maybe<st::Block&> st::get_static_block(tr::Vec3<int32> pos)
{
	if (_st->static_blocks.contains(pos)) {
		return _st->static_blocks[pos];
	}
	else if (_st->terrain_blocks.contains(pos)) {
		return _st->terrain_blocks[pos];
	}
	return {};
}

st::Block& st::place_static_block(tr::Vec3<int32> pos, st::Model model)
{
	bool is_terrain = model.model_spec().is_terrain();
	Block& block = is_terrain ? _st->terrain_blocks[pos] : _st->static_blocks[pos];
	block._model = model;
	block._position = pos;
	block._type = is_terrain ? BlockType::TERRAIN : BlockType::STATIC;

	_st->chunks[st::block_to_chunk_pos(pos)].new_this_frame = true;
	return block;
}

st::DynamicBlock::operator Block() const
{
	tr::Vec3<int32> rounded_position = {
		int32(roundf(position.x)), int32(roundf(position.y)), int32(roundf(position.z))
	};
	return Block{rounded_position, model(), BlockType::DYNAMIC};
}

tr::Maybe<st::DynamicBlock&> st::Block::to_dynamic_block() const // NOLINT
{
	TR_TODO();
}

void st::Block::destroy()
{
	if (model().model_spec().is_terrain()) {
		_st->terrain_blocks.remove(_position);
	}
	else {
		_st->static_blocks.remove(_position);
	}
	_model = MODEL_AIR;

	_st->chunks[st::block_to_chunk_pos(position())].new_this_frame = true;
}

st::DynamicBlock& st::place_dynamic_block(st::Model model)
{
	(void)model;
	TR_TODO();
}
