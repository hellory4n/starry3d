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

	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_MODEL, tr::Matrix4x4::identity());
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_VIEW, tr::Matrix4x4::identity());
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_PROJECTION, tr::Matrix4x4::identity());
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_CHUNK, tr::Vec3<uint32>{});

	_st->atlas_ssbo = StorageBuffer(ST_TERRAIN_SHADER_SSBO_ATLAS);
	_st->terrain_vertex_ssbo = StorageBuffer(ST_TERRAIN_SHADER_SSBO_VERTICES);
	// this calculation is explained in uniforms.glsl
	// and i dont wanna duplicate that comment
	_st->terrain_vertex_ssbo.update(
		nullptr, sizeof(PackedTerrainVertex) * 6 * CHUNK_SIZE * RENDER_DISTANCE.x *
				 RENDER_DISTANCE.x * RENDER_DISTANCE.x / 2
	);

	tr::info("renderer initialized");
}

void st::_free_renderer()
{
	_st->terrain_shader->free();
	_st->atlas_ssbo.free();
	_st->terrain_vertex_ssbo.free();
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

inline void st::_refresh_chunk(st::Chunk& chunk, tr::Vec3<int32> pos)
{
	(void)pos;
	if (!chunk.new_this_frame) {
		return;
	}
	// TODO use this probably
	chunk.new_this_frame = false;
}

inline void st::_update_terrain_vertex_ssbo()
{
	// RUST DEVELOPERS CRY OVER THIS BEAUTIFUL POINTER FUCKING
	// TOUCHING MEMORY IN PLACES IT COULDN'T EVEN IMAGINE
	// not funny
	void* ptr = _st->terrain_vertex_ssbo.map_buffer(MapBufferAccess::WRITE);
	TR_DEFER(_st->terrain_vertex_ssbo.unmap_buffer());

	auto* ssbo = static_cast<PackedTerrainVertex*>(ptr);

	tr::Vec3<int32> start = (st::current_chunk() - (RENDER_DISTANCE / 2)) * CHUNK_SIZE_VEC;
	tr::Vec3<int32> end = (st::current_chunk() + (RENDER_DISTANCE / 2)) * CHUNK_SIZE_VEC;

	for (int32 x = start.x; x < end.x; x++) {
		for (int32 y = start.y; y < end.y; y++) {
			for (int32 z = start.z; z < end.z; z++) {
				tr::Maybe<Block&> block = _st->terrain_blocks.try_get({x, y, z});
				if (!block.is_valid()) {
					continue;
				}

				// hmmm
				ModelSpec model_spec = block.unwrap().model().model_spec().unwrap();
				ModelCube cube = model_spec.meshes[0].cube;
				tr::Vec3<int32> local_pos_32 =
					tr::Vec3<int32>{x, y, z} -
					st::block_to_chunk_pos(tr::Vec3<int32>{x, y, z});
				tr::Vec3<uint8> local_pos = {
					static_cast<uint8>(local_pos_32.x),
					static_cast<uint8>(local_pos_32.y),
					static_cast<uint8>(local_pos_32.z),
				};

				// TODO culling
				TerrainVertex base_vertex = {
					.position = local_pos,
					.shaded = model_spec.meshes[0].cube.shaded,
					.billboard = false,
					.texture_id = 0, // clang-tidy shut up
				};

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
	*(ssbo++) = (Face);

				CUBE_FACE(front, TerrainVertex::Normal::FRONT);
				CUBE_FACE(back, TerrainVertex::Normal::BACK);
				CUBE_FACE(left, TerrainVertex::Normal::LEFT);
				CUBE_FACE(right, TerrainVertex::Normal::RIGHT);
				CUBE_FACE(top, TerrainVertex::Normal::TOP);
				CUBE_FACE(bottom, TerrainVertex::Normal::BOTTOM);

// yea²
#undef VERTEX
			}
		}
	}
}

inline void st::_render_chunk(st::Chunk& chunk, tr::Vec3<int32> pos)
{
	(void)chunk;
	(void)pos;
	// TODO
	// note: chunks have to be individually rendered even tho the shader has 16*16*16 chunks at
	// the same time
	// this is so u_chunk can be set between draw calls
}

void st::_render_terrain()
{
	tr::Vec3<int32> start = st::current_chunk() - (RENDER_DISTANCE / 2);
	tr::Vec3<int32> end = st::current_chunk() + (RENDER_DISTANCE / 2);

	if (st::current_chunk() != _st->prev_chunk) {
		st::_update_terrain_vertex_ssbo();
	}

	// :(
	for (int32 x = start.x; x < end.x; x++) {
		for (int32 y = start.y; y < end.y; y++) {
			for (int32 z = start.z; z < end.z; z++) {
				tr::Maybe<Chunk&> chunk = _st->chunks.try_get({x, y, z});
				if (!chunk.is_valid()) {
					continue;
				}
				Chunk& chunk_but_unwrapped = chunk.unwrap();

				st::_refresh_chunk(chunk_but_unwrapped, {x, y, z});
				st::_render_chunk(chunk_but_unwrapped, {x, y, z});

				chunk_but_unwrapped.new_this_frame = false;
			}
		}
	}

	_st->prev_chunk = st::current_chunk();
}

void st::set_wireframe_mode(bool val)
{
	glPolygonMode(GL_FRONT_AND_BACK, val ? GL_LINE : GL_FILL);
}

st::PackedTerrainVertex::PackedTerrainVertex(TerrainVertex src)
{
	x = src.position.x;
	y = src.position.y;
	z = src.position.z;
	normal = static_cast<uint8>(src.normal);
	using_texture = src.using_texture;
	billboard = src.billboard;
	shaded = src.shaded;
	if (src.using_texture) {
		texture_id = src.texture_id;
	}
	else {
		color = src.color;
	}

	// to make clang-tidy happy
	_reserved = 0;
}

st::PackedTerrainVertex::operator tr::Vec2<uint32>() const
{
	// FIXME this probably (definitely) only works on little endian who gives a shit
	// FIXME this is definitely undefined behavior
	uint64 bits = *reinterpret_cast<const uint64*>(this);
	return {static_cast<uint32>(bits & 0xFFFFFFFFu),
		static_cast<uint32>((bits >> 32) & 0xFFFFFFFFu)};
}
