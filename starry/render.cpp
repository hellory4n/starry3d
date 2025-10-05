/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/render.cpp
 * The renderer's name is Kyler. Be nice to Kyler. Thanks.
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

#include "starry/render.h"

#include <trippin/common.h>
#include <trippin/math.h>
#include <trippin/memory.h>

#include <glad/gl.h>

#include "starry/gpu.h"
#include "starry/internal.h"
#include "starry/shader/terrain.glsl.h"
#include "starry/world.h"
#include "trippin/log.h"
#include "trippin/util.h"

void st::_init_renderer()
{
	auto terrain_vert = VertexShader(ST_TERRAIN_SHADER_VERTEX);
	auto terrain_frag = FragmentShader(ST_TERRAIN_SHADER_FRAGMENT);
	TR_DEFER(terrain_vert.free());
	TR_DEFER(terrain_frag.free());

	_st->terrain_shader = _st->arena.make_ptr<ShaderProgram>();
	_st->terrain_shader->attach(terrain_vert);
	_st->terrain_shader->attach(terrain_frag);
	_st->terrain_shader->link();
	_st->terrain_shader->use();

	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_MODEL, tr::Matrix4x4::identity());
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_VIEW, tr::Matrix4x4::identity());
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_PROJECTION, tr::Matrix4x4::identity());
	// TODO
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_CHUNK, tr::Vec3<uint32>{});

	_st->atlas_ssbo = st::StorageBuffer(ST_TERRAIN_SHADER_SSBO_ATLAS);

	tr::info("renderer initialized");
}

void st::_free_renderer()
{
	_st->terrain_shader->free();
	_st->atlas_ssbo.free();
	tr::info("renderer deinitialized");
}

void st::_upload_atlas(st::TextureAtlas atlas)
{
	// it's faster to just copy everything (256 kb) than it is to do hashing on the gpu
	tr::Array<tr::Rect<uint32>> ssbo_data{tr::scratchpad(), MAX_ATLAS_TEXTURES};
	for (auto [id, rect] : atlas._textures) {
		ssbo_data[id] = rect;
	}
	_st->atlas_ssbo.update(*ssbo_data, ssbo_data.len() * sizeof(tr::Rect<uint32>));
}

void st::_refresh_chunk_state()
{
	// TODO make this location-based
	// no need to regen a chunk mesh in the middle of nowhere
	for (auto [pos, chunk] : _st->chunks) {
		if (chunk.new_this_frame) {
			st::_regen_chunk_mesh(pos);
		}
		chunk.new_this_frame = false;
	}
}

void st::_base_pipeline()
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// glEnable(GL_CULL_FACE);
	// glCullFace(GL_BACK);
	// glFrontFace(GL_CCW);

	glEnable(GL_DEPTH_TEST);

	glLineWidth(2.5);
}

void st::_terrain_pipeline()
{
	st::_base_pipeline();
	_st->terrain_shader->use();
}

void st::_render()
{
	st::_terrain_pipeline();
	// TODO st::Environment/st::Skybox/whatever
	st::clear_screen(tr::Color::rgb(0x009ccf)); // weezer blue

	// straight up setting uniforms
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_VIEW, Camera::current().view_matrix());
	_st->terrain_shader->set_uniform(
		ST_TERRAIN_SHADER_U_PROJECTION, Camera::current().projection_matrix()
	);

	st::_refresh_chunk_state();
	st::_render_terrain();
}

void st::_regen_chunk_mesh(tr::Vec3<int32> pos)
{
	tr::Vec3<int32> start = pos * CHUNK_SIZE;
	tr::Vec3<int32> end = start + CHUNK_SIZE_VEC;
	// TODO this is a memory leak
	// memory usage will only increase while the old data isn't used
	// maybe poke with the buffer directly? (glMapBuffer)
	tr::Array<PackedModelVertex> vertices{_st->render_arena};
	tr::Array<Triangle> triangles{_st->render_arena};

	// :(
	for (auto x : tr::range<int32>(start.x, end.x)) {
		for (auto y : tr::range<int32>(start.y, end.y)) {
			for (auto z : tr::range<int32>(start.z, end.z)) {
				tr::Maybe<Model> model = st::get_model_from_pos({x, y, z});
				if (!model.is_valid()) {
					continue;
				}

				if (model.unwrap().id == MODEL_AIR) {
					tr::warn(
						"why is block %i, %i, %i air?? that's not how you "
						"destroy blocks",
						x, y, z
					);
					continue;
				}

				ModelMeshData mesh = _st->model_mesh_data[model.unwrap()];
				// TODO tr::Array<T>::concat(Array<T> other)
				for (auto [_, vert] : mesh.vertices) {
					vertices.add(vert);
				}
				for (auto [_, tri] : mesh.triangles) {
					triangles.add(tri);
				}
			}
		}
	}

	if (vertices.len() == 0) {
		return;
	}

	if (_st->chunks[pos].mesh.is_valid()) {
		_st->chunks[pos].mesh.update_data(vertices, triangles);
	}
	else {
		const tr::Array<VertexAttribute> attrs = {
			{"packed", VertexAttributeType::VEC2_UINT32, 0},
		};
		_st->chunks[pos].mesh = Mesh(attrs, vertices, triangles, MeshUsage::MUTABLE);
		tr::info(
			"new chunk at %i, %i, %i (chunk pos %i, %i, %i)", pos.x * CHUNK_SIZE,
			pos.y * CHUNK_SIZE, pos.z * CHUNK_SIZE, pos.x, pos.y, pos.z
		);
	}
}

void st::_render_terrain()
{
	// TODO setting the render distance
	constexpr tr::Vec3<int32> RENDER_DISTANCE{16};
	tr::Vec3<int32> start = st::current_chunk() - (RENDER_DISTANCE / 2);
	tr::Vec3<int32> end = st::current_chunk() + (RENDER_DISTANCE / 2);

	// :(
	for (auto x : tr::range<int32>(start.x, end.x)) {
		for (auto y : tr::range<int32>(start.y, end.y)) {
			for (auto z : tr::range<int32>(start.z, end.z)) {
				if (!_st->chunks[{x, y, z}].mesh.is_valid()) {
					continue;
				}
				_st->chunks[{x, y, z}].mesh.draw();
			}
		}
	}
}

void st::set_wireframe_mode(bool val)
{
	glPolygonMode(GL_FRONT_AND_BACK, val ? GL_LINE : GL_FILL);
}

st::PackedModelVertex::PackedModelVertex(ModelVertex src)
{
	// TODO this probably (definitely) only works in little endian who gives a shit
	// the format is helpfully documented in the header (so read that if you're confused)
	uint64 bits = 0;

	bits |= uint64(src.position.x & 0xFF) << 0;
	bits |= uint64(src.position.y & 0xFF) << 8;
	bits |= uint64(src.position.z & 0xFF) << 16;

	bits |= uint64(int(src.normal) & 0xF) << 24;
	bits |= uint64(int(src.corner) & 0x3) << 27;
	bits |= uint64(int(src.shaded) & 0x1) << 29;
	bits |= uint64(int(src.using_texture) & 0x1) << 30;
	bits |= uint64(int(src.billboard) & 0x1) << 31;

	// unioning all over the plcae
	if (src.using_texture) {
		bits |= uint64(src.texture_id & 0x3FFF) << 32;
	}
	else {
		bits |= uint64(src.color.r & 0xFF) << 32;
		bits |= uint64(src.color.g & 0xFF) << 40;
		bits |= uint64(src.color.b & 0xFF) << 48;
		bits |= uint64(src.color.a & 0xFF) << 56;
	}

	x = uint32(bits & 0xFFFFFFFFu);
	y = uint32((bits >> 32) & 0xFFFFFFFFu);
}
