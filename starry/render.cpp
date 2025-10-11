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

// burger
// 🟧🟩🟥🟫🟧

#include "starry/render.h"

#include <trippin/common.h>
#include <trippin/log.h>
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/util.h>

#include <glad/gl.h>

#include "starry/gpu.h"
#include "starry/internal.h"
#include "starry/shader/terrain.glsl.h"
#include "starry/world.h"

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

	_st->atlas_ssbo = StorageBuffer(ST_TERRAIN_SHADER_SSBO_ATLAS);
	_st->terrain_vertex_ssbo = StorageBuffer(ST_TERRAIN_SHADER_SSBO_VERTICES);
	_st->terrain_vertex_ssbo.update(nullptr, TERRAIN_VERTEX_SSBO_SIZE);
	_st->chunk_positions_ssbo = StorageBuffer(ST_TERRAIN_SHADER_SSBO_CHUNK_POSITIONS); // catchy
	_st->chunk_positions_ssbo.update(
		nullptr,
		sizeof(tr::Vec3<int32>) * RENDER_DISTANCE * RENDER_DISTANCE * RENDER_DISTANCE
	);

	// the actual data is calculated in the vertex shader
	const tr::Array<const VertexAttribute> attrs = {
		{"filler", VertexAttributeType::VEC3_INT32, 0},
	};
	const tr::Array<const int32> verts = {0, 0, 0, 0, 0, 0};
	const tr::Array<const Triangle> tris = {
		{0, 1, 2},
		{3, 4, 5},
	};
	_st->base_plane = Mesh(attrs, verts, tris);

	tr::info("renderer initialized");
}

void st::_free_renderer()
{
	_st->terrain_shader->free();
	_st->base_plane.free();
	_st->atlas_ssbo.free();
	_st->terrain_vertex_ssbo.free();
	_st->chunk_positions_ssbo.free();
	tr::info("renderer deinitialized");
}

void st::_upload_atlas(st::TextureAtlas atlas)
{
	// it's faster to just copy everything (~1 mb) than it is to do hashing on the gpu
	tr::Array<tr::Rect<uint32>> ssbo_data{tr::scratchpad(), MAX_ATLAS_TEXTURES};
	for (auto [id, rect] : atlas._textures) {
		ssbo_data[id] = rect;
	}
	_st->atlas_ssbo.update(*ssbo_data, ssbo_data.len() * sizeof(tr::Rect<uint32>));
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

	st::_render_terrain();
}

uint32 st::_update_terrain_vertex_ssbo()
{
	// RUST DEVELOPERS CRY OVER THIS BEAUTIFUL POINTER FUCKING
	// TOUCHING MEMORY IN PLACES IT COULDN'T EVEN IMAGINE
	// not funny
	void* ptr = _st->terrain_vertex_ssbo.map_buffer(MapBufferAccess::WRITE);
	TR_DEFER(_st->terrain_vertex_ssbo.unmap_buffer());

	auto* ssbo = static_cast<TerrainVertex*>(ptr);

	tr::Vec3<int32> start = st::current_chunk() - (RENDER_DISTANCE_VEC / 2);
	tr::Vec3<int32> end = st::current_chunk() + (RENDER_DISTANCE_VEC / 2);
	uint16 chunk_pos_idx = 0;
	uint32 instances = 0;

	// TODO this can be parallelized
	for (int32 x = start.x; x < end.x; x++) {
		for (int32 y = start.y; y < end.y; y++) {
			for (int32 z = start.z; z < end.z; z++) {
				tr::Maybe<Chunk&> chunk = _st->chunks.try_get({x, y, z});

				// chunk has never been accessed, so it never had any blocks, no
				// need to render air
				if (!chunk.is_valid()) {
					continue;
				}

				st::_update_terrain_vertex_ssbo_chunk(
					{x, y, z}, ssbo, chunk.unwrap(), chunk_pos_idx, instances
				);
			}
		}
	}

	return instances;
}

void st::_update_terrain_vertex_ssbo_chunk(
	tr::Vec3<int32> pos, st::TerrainVertex* ssbo, st::Chunk chunk, uint16& chunk_pos_idx,
	uint32& instances
)
{
	(void)chunk;

	tr::Vec3<int32> start = pos * CHUNK_SIZE;
	tr::Vec3<int32> end = start + CHUNK_SIZE_VEC;
	for (int32 x = start.x; x < end.x; x++) {
		for (int32 y = start.y; y < end.y; y++) {
			for (int32 z = start.z; z < end.z; z++) {
				tr::Maybe<Block&> block = _st->terrain_blocks.try_get({x, y, z});
				if (!block.is_valid()) {
					continue;
				}

				st::_update_terrain_vertex_ssbo_block(
					{x, y, z}, ssbo, block.unwrap(), chunk_pos_idx, instances
				);
			}
		}
	}

	// updating the chunk position ssbo goes in the exact same order
	// so it's safe to assume we can just increment the idx
	// FIXME this WILL break
	chunk_pos_idx++;
}

void st::_update_terrain_vertex_ssbo_block(
	tr::Vec3<int32> pos, st::TerrainVertex* ssbo, st::Block& block, uint16 chunk_pos_idx,
	uint32& instances
)
{
	instances += 6;

	// hmmm
	ModelSpec model_spec = block.model().model_spec().unwrap();
	ModelCube cube = model_spec.meshes[0].cube;
	tr::Vec3<int32> local_pos_32 = pos - st::block_to_chunk_pos(pos);
	tr::Vec3<uint8> local_pos = {
		static_cast<uint8>(local_pos_32.x),
		static_cast<uint8>(local_pos_32.y),
		static_cast<uint8>(local_pos_32.z),
	};

	// TODO culling
	TerrainVertex base_vertex = {};
	base_vertex.x = local_pos.x;
	base_vertex.y = local_pos.y;
	base_vertex.z = local_pos.z;
	base_vertex.shaded = model_spec.meshes[0].cube.shaded;
	base_vertex.billboard = false;
	base_vertex.chunk_pos_idx = chunk_pos_idx;

// yea
#define CUBE_FACE(Face, FaceEnum)                      \
	TerrainVertex Face = base_vertex;              \
	(Face).normal = FaceEnum;                      \
	if (cube.Face.using_texture) {                 \
		(Face).texture_id = cube.Face.texture; \
	}                                              \
	else {                                         \
		(Face).color = cube.Face.color;        \
	}                                              \
	*ssbo = Face;                                  \
	ssbo++;

	CUBE_FACE(front, CubeNormal::FRONT);
	CUBE_FACE(back, CubeNormal::BACK);
	CUBE_FACE(left, CubeNormal::LEFT);
	CUBE_FACE(right, CubeNormal::RIGHT);
	CUBE_FACE(top, CubeNormal::TOP);
	CUBE_FACE(bottom, CubeNormal::BOTTOM);

// yea²
#undef CUBE_FACE
}

void st::_render_terrain()
{
	if (st::current_chunk() != _st->prev_chunk || _st->chunk_updates_in_your_area) {
		_st->instances = st::_update_terrain_vertex_ssbo();

		// update the chunk positions ssbo
		tr::Vec3<int32>* positions = static_cast<tr::Vec3<int32>*>(
			_st->chunk_positions_ssbo.map_buffer(MapBufferAccess::WRITE)
		);
		TR_DEFER(_st->chunk_positions_ssbo.unmap_buffer());

		tr::Vec3<int32> start = st::current_chunk() - (RENDER_DISTANCE_VEC / 2);
		tr::Vec3<int32> end = st::current_chunk() + (RENDER_DISTANCE_VEC / 2);
		for (int32 x = start.x; x < end.x; x++) {
			for (int32 y = start.y; y < end.y; y++) {
				for (int32 z = start.z; z < end.z; z++) {
					*positions = {x, y, z};
					positions++;
				}
			}
		}
	}

	_st->base_plane.draw(_st->instances);

	// reset this frame's state
	_st->prev_chunk = st::current_chunk();
	_st->chunk_updates_in_your_area = false;
}

void st::set_wireframe_mode(bool val)
{
	glPolygonMode(GL_FRONT_AND_BACK, val ? GL_LINE : GL_FILL);
}
