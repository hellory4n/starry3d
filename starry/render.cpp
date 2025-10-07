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
	if (!chunk.new_this_frame) {
		return;
	}

	tr::Vec3<int32> start = pos * CHUNK_SIZE;
	[[maybe_unused]]
	tr::Vec3<int32> end = start + CHUNK_SIZE_VEC;

	// TODO
}

inline void st::_render_chunk(st::Chunk& chunk, tr::Vec3<int32> pos)
{
	(void)chunk;
	(void)pos;
	// TODO
}

void st::_render_terrain()
{
	tr::Vec3<int32> start = st::current_chunk() - (RENDER_DISTANCE / 2);
	tr::Vec3<int32> end = st::current_chunk() + (RENDER_DISTANCE / 2);

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
