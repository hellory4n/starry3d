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

#include <thread>

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
	_st->terrain_vertex_ssbo.reserve(
		st::_terrain_ssbo_size(_st->render_distance) * sizeof(tr::Vec3<uint32>)
	);
	_st->chunk_positions_ssbo = StorageBuffer(ST_TERRAIN_SHADER_SSBO_CHUNK_POSITIONS); // catchy
	_st->chunk_positions_ssbo.reserve(
		sizeof(tr::Vec4<int32>) * _st->render_distance * _st->render_distance *
		_st->render_distance
	);

	// the actual data is calculated in the vertex shader
	const tr::Array<const VertexAttribute> attrs = {
		{"filler", VertexAttributeType::VEC3_INT32, 0},
	};
	const tr::Array<const int32> verts = {0, 0, 0, 0, 0, 0};
	const tr::Array<const Triangle> tris = {
		{0, 1, 2},
		{5, 4, 3},
	};
	_st->base_plane = Mesh(attrs, verts, tris);

	// im threading it
	_st->terrain_update_thread = std::thread(st::_terrain_update_thread);
	_st->terrain_update_thread.detach();

	tr::info("renderer initialized");
}

void st::_free_renderer()
{
	_st->terrain_update_thread_running = false;
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
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_ATLAS_SIZE, atlas.size());
}

void st::_base_pipeline()
{
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	glFrontFace(GL_CCW);

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
	st::clear_screen(_st->environment.sky_color);

	// straight up setting uniforms
	_st->terrain_shader->set_uniform(ST_TERRAIN_SHADER_U_VIEW, Camera::current().view_matrix());
	_st->terrain_shader->set_uniform(
		ST_TERRAIN_SHADER_U_PROJECTION, Camera::current().projection_matrix()
	);
	_st->terrain_shader->set_uniform(
		ST_TERRAIN_SHADER_U_SUN_DIR, _st->environment.sun_direction
	);
	_st->terrain_shader->set_uniform(
		ST_TERRAIN_SHADER_U_SUN_COLOR,
		static_cast<tr::Vec4<float32>>(_st->environment.sun_color)
	);
	_st->terrain_shader->set_uniform(
		ST_TERRAIN_SHADER_U_AMBIENT_COLOR,
		static_cast<tr::Vec4<float32>>(_st->environment.ambient_color)
	);

	st::_render_terrain();

	// reset this frame's state
	_st->prev_chunk = st::current_chunk();
}

void st::_terrain_update_thread()
{
	while (_st->terrain_update_thread_running) {
		// if there are no updates just keep idle
		if (!_st->chunk_updates_in_your_area) {
			using namespace std::literals::chrono_literals;
			std::this_thread::sleep_for(0.01s); // just so cpu usage isn't insalubrious
			continue;
		}

		// actually update
		tr::Stopwatch sw = {};
		sw.start();
		_st->terrain_updating_it = true;
		TR_DEFER(_st->terrain_updating_it = false);
		st::_terrain_update_thread_write_ssbo();

		// the w is for padding otherwise std430 shits itself
		uint32 chunk_pos_idx = 0;

		tr::Vec3<int32> start = st::current_chunk() -
					(tr::Vec3<uint32>{_st->render_distance} / 2).cast<int32>();
		tr::Vec3<int32> end = start + tr::Vec3<uint32>{_st->render_distance}.cast<int32>();

		for (int32 z = start.z; z < end.z; z++) {
			for (int32 y = start.y; y < end.y; y++) {
				for (int32 x = start.x; x < end.x; x++) {
					_st->chunk_pos_buffer[chunk_pos_idx] = {x, y, z, 0};
					chunk_pos_idx++;
				}
			}
		}

		_st->pls_upload_buffers = true;
		_st->chunk_updates_in_your_area = false;
		sw.stop();
		sw.print_time_us("terrain update thread");
	}
}

void st::_terrain_update_thread_write_ssbo()
{
	tr::Vec3<int32> start =
		st::current_chunk() - (tr::Vec3<uint32>{_st->render_distance} / 2).cast<int32>();
	tr::Vec3<int32> end = start + tr::Vec3<uint32>{_st->render_distance}.cast<int32>();
	uint16 chunk_pos_idx = 0;
	uint32 instances = 0;

	// TODO this can be parallelized
	for (int32 z = start.z; z < end.z; z++) {
		for (int32 y = start.y; y < end.y; y++) {
			for (int32 x = start.x; x < end.x; x++) {
				tr::Maybe<Chunk&> chunk = _st->terrain_chunks.try_get({x, y, z});

				// chunk has never been accessed, so it never had any blocks, no
				// need to render air
				if (!chunk.is_valid()) {
					chunk_pos_idx++;
					continue;
				}

				st::_terrain_update_thread_write_chunk(
					{x, y, z}, chunk.unwrap(), chunk_pos_idx, instances
				);

				// updating the chunk position ssbo goes in the exact same order
				// so it's safe to assume we can just increment the idx
				// FIXME this WILL break
				chunk_pos_idx++;
			}
		}
	}

	_st->instances = instances;
}

void st::_terrain_update_thread_write_chunk(
	tr::Vec3<int32> pos, st::Chunk chunk, uint16& chunk_pos_idx, uint32& instances
)
{
	tr::Vec3<int32> start = pos * CHUNK_SIZE;
	tr::Vec3<int32> end = start + CHUNK_SIZE_VEC;

	for (int32 z = start.z; z < end.z; z++) {
		for (int32 y = start.y; y < end.y; y++) {
			for (int32 x = start.x; x < end.x; x++) {
				auto model = chunk.try_get(tr::Vec3<int32>{x, y, z});
				if (!model.is_valid()) {
					continue;
				}
				if (model.unwrap() == MODEL_AIR) {
					continue;
				}

				st::_terrain_update_thread_write_block(
					{x, y, z}, chunk, model.unwrap(), chunk_pos_idx, instances
				);
			}
		}
	}
}

void st::_terrain_update_thread_write_block(
	tr::Vec3<int32> pos, st::Chunk chunk, st::Model model, uint16 chunk_pos_idx,
	uint32& instances
)
{
	tr::Vec3<uint8> local_pos =
		(pos - (st::block_to_chunk_pos(pos) * CHUNK_SIZE)).cast<uint8>();

	// anything higher than 15 will overflow
	// / 2 - 4 so that the lod is less noticeable
	// TODO lod that doesn't suck (this one doesn't save enough triangles to be worth the
	// quality loss)
	uint32 lod = static_cast<uint32>(tr::clamp(
		st::block_to_chunk_pos(pos).distance(st::current_chunk()) / 2 - 3, 1.0, 15.0
	));
	// %i blocks for the price of 1! saucy
	if (local_pos.x % lod != 0) {
		return;
	}
	if (local_pos.y % lod != 0) {
		return;
	}
	if (local_pos.z % lod != 0) {
		return;
	}

	// is this block visible at all?
	// chunk borders are a bit fucky to check for
	int32 lodi = static_cast<int32>(lod);
	bool front_visible;
	bool back_visible;
	bool left_visible;
	bool right_visible;
	bool top_visible;
	bool bottom_visible;
	bool is_on_chunk_border = local_pos.x == 0 || local_pos.y == 0 || local_pos.z == 0 ||
				  local_pos.x >= CHUNK_SIZE - 1 || local_pos.y >= CHUNK_SIZE - 1 ||
				  local_pos.z >= CHUNK_SIZE - 1;

	// st::_get_terrain_block is slower as it's going through 9838952 hashmap doohickeys, while
	// st::Chunk is just an array of numbers
	if (is_on_chunk_border) {
		front_visible =
			!st::_get_terrain_block(pos - tr::Vec3<int32>{0, 0, -lodi}).is_valid();
		back_visible =
			!st::_get_terrain_block(pos - tr::Vec3<int32>{0, 0, lodi}).is_valid();
		left_visible =
			!st::_get_terrain_block(pos + tr::Vec3<int32>{-lodi, 0, 0}).is_valid();
		right_visible =
			!st::_get_terrain_block(pos + tr::Vec3<int32>{lodi, 0, 0}).is_valid();
		top_visible = !st::_get_terrain_block(pos + tr::Vec3<int32>{0, lodi, 0}).is_valid();
		bottom_visible =
			!st::_get_terrain_block(pos - tr::Vec3<int32>{0, -lodi, 0}).is_valid();
	}
	else {
		Model air_but_as_an_lvalue = MODEL_AIR;
		front_visible = chunk.try_get(pos - tr::Vec3<int32>{0, 0, -lodi})
					.value_or(air_but_as_an_lvalue) == MODEL_AIR;
		back_visible = chunk.try_get(pos - tr::Vec3<int32>{0, 0, lodi})
				       .value_or(air_but_as_an_lvalue) == MODEL_AIR;
		left_visible = chunk.try_get(pos + tr::Vec3<int32>{-lodi, 0, 0})
				       .value_or(air_but_as_an_lvalue) == MODEL_AIR;
		right_visible = chunk.try_get(pos + tr::Vec3<int32>{lodi, 0, 0})
					.value_or(air_but_as_an_lvalue) == MODEL_AIR;
		top_visible = chunk.try_get(pos + tr::Vec3<int32>{0, lodi, 0})
				      .value_or(air_but_as_an_lvalue) == MODEL_AIR;
		bottom_visible = chunk.try_get(pos - tr::Vec3<int32>{0, -lodi, 0})
					 .value_or(air_but_as_an_lvalue) == MODEL_AIR;
	}

	bool visible = front_visible || back_visible || left_visible || right_visible ||
		       top_visible || bottom_visible;
	if (!visible) {
		return;
	}

	ModelSpec model_spec = model.model_spec().unwrap();
	ModelCube cube = model_spec.meshes[0].cube;

	TerrainVertex base_vertex = {};
	base_vertex.x = local_pos.x;
	base_vertex.y = local_pos.y;
	base_vertex.z = local_pos.z;
	base_vertex.shaded = model_spec.meshes[0].cube.shaded;
	base_vertex.billboard = false;
	base_vertex.chunk_pos_idx = chunk_pos_idx;
	base_vertex.lod = static_cast<uint8>(lod);

// i love exploiting the compiler
#define CUBE_FACE(Face, FaceEnum)                                                            \
	if (Face##_visible) {                                                                \
		TerrainVertex Face = base_vertex;                                            \
		(Face).normal = FaceEnum;                                                    \
		if (cube.Face.using_texture) {                                               \
			(Face).texture_id = cube.Face.texture;                               \
		}                                                                            \
		else {                                                                       \
			(Face).color = cube.Face.color;                                      \
		}                                                                            \
		(Face).using_texture = cube.Face.using_texture;                              \
		_st->terrain_vertex_buffer[instances] = static_cast<tr::Vec3<uint32>>(Face); \
		instances++;                                                                 \
	}

	CUBE_FACE(front, CubeNormal::FRONT);
	CUBE_FACE(back, CubeNormal::BACK);
	CUBE_FACE(left, CubeNormal::LEFT);
	CUBE_FACE(right, CubeNormal::RIGHT);
	CUBE_FACE(top, CubeNormal::TOP);
	CUBE_FACE(bottom, CubeNormal::BOTTOM);

// yea
#undef CUBE_FACE
}

void st::_render_terrain()
{
	if (st::current_chunk() != _st->prev_chunk) {
		_st->chunk_updates_in_your_area = true;
	}

	// opengl stuff has to be on the main thread lmao
	// TODO vulkan is looking tantalizing...
	if (_st->pls_upload_buffers) {
		tr::Stopwatch sw = {};
		sw.start();
		_st->terrain_vertex_ssbo.update(
			*_st->terrain_vertex_buffer,
			_st->terrain_vertex_buffer.len() * sizeof(tr::Vec3<uint32>)
		);
		_st->chunk_positions_ssbo.update(
			*_st->chunk_pos_buffer,
			_st->chunk_pos_buffer.len() * sizeof(tr::Vec4<int32>)
		);
		_st->pls_upload_buffers = false;
		sw.stop();
		sw.print_time_us("ssbo updating");
	}

	tr::Stopwatch sw = {};
	sw.start();
	_st->base_plane.draw(_st->instances);
	sw.stop();
	sw.print_time_us("drawing");
}

void st::set_wireframe_mode(bool val)
{
	glPolygonMode(GL_FRONT_AND_BACK, val ? GL_LINE : GL_FILL);
}

void st::set_render_distance(uint32 chunks)
{
	TR_ASSERT_MSG(chunks <= 40, "render distance must be <= 40 due to technical limitations");
	if (chunks == 0) {
		tr::warn("render distance is 0, ignoring st::set_render_distance call");
		return;
	}

	// it would be pretty unfortunate if we set this while the terrain update thread is updating
	// it, so just wait until it's done
	if (_st->terrain_updating_it) {
		while (true) {
			if (!_st->terrain_updating_it) {
				break;
			}
		}
	}

	_st->render_distance = chunks;

	// resize buffers
	_st->terrain_vertex_ssbo.update(nullptr, st::_terrain_ssbo_size(chunks));
	_st->chunk_positions_ssbo.update(
		nullptr, sizeof(tr::Vec4<int32>) * chunks * chunks * chunks
	);

	// make a new arena to not waste memory
	_st->render_arena.free();
	_st->render_arena = _st->arena.make_ref<tr::Arena>();
	_st->terrain_vertex_buffer =
		tr::Array<tr::Vec3<uint32>>(_st->render_arena, st::_terrain_ssbo_size(chunks));

	_st->chunk_updates_in_your_area = true; // pls update
}

st::Chunk::Chunk()
{
	blocks = {_st->world_arena, CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE};
}

tr::Maybe<st::Model&> st::Chunk::try_get(tr::Vec3<uint8> local_pos)
{
	// weird race condition thing with the terrain update thread, just assume it's not there so
	// it stops horrifically crashing
	// FIXME it doesn't even work??? (bcuz .buf() just *can't* return null)
	// just fix the real bug
	// TR_GCC_IGNORE_WARNING(-Wtautological-pointer-compare) if (&blocks == nullptr) {
	// 	return {};
	// }
	// TR_GCC_RESTORE()
	// if (blocks.buf() == nullptr) {
	// 	return {};
	// }

	// basically a 3D array
	return blocks.try_get(
		local_pos.x * CHUNK_SIZE * CHUNK_SIZE + local_pos.y * CHUNK_SIZE + local_pos.z
	);
}
