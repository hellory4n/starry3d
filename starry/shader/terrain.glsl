/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/terrain.glsl
 * The shader for the terrain duh
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

// compile with:
// ./tools/mrshader/mrshader.lua starry/shader/terrain.glsl starry/shader/terrain.glsl.h
#version 430 core
#pragma mrshader name ST_TERRAIN_SHADER

#pragma mrshader vertex
// TODO add includes to mrshader
struct Vertex {
	uvec3 position;
	uint normal;
	uint quad_corner;
	bool shaded;
	bool using_texture;
	bool billboard;
	uint texture_id;
	uvec4 color;
};

#define NORMAL_FORWARD 0u
#define NORMAL_BACK 1u
#define NORMAL_LEFT 2u
#define NORMAL_RIGHT 3u
#define NORMAL_UP 4u
#define NORMAL_DOWN 5u

#define QUAD_CORNER_TOP_LEFT 0u
#define QUAD_CORNER_TOP_RIGHT 1u
#define QUAD_CORNER_BOTTOM_LEFT 2u
#define QUAD_CORNER_BOTTOM_RIGHT 3u

Vertex unpack_vertex(uvec2 src)
{
	uint low = src.x;
	uint high = src.y;
	Vertex v;

	v.position.x = low & 0xFFu;
	v.position.y = (low >> 8)  & 0xFFu;
	v.position.z = (low >> 16) & 0xFFu;

	v.normal = (low >> 24) & 0xFu;
	v.quad_corner = (low >> 27) & 0x3u;
	v.shaded = ((low >> 29) & 0x1u) != 0u;
	v.using_texture = ((low >> 30) & 0x1u) != 0u;
	v.billboard = ((low >> 31) & 0x1u) != 0u;

	if (v.using_texture) {
		v.texture_id = high & 0x3FFFu;
		v.color = uvec4(0);
	}
	else {
		v.color.r = (high >> 0) & 0xFFu;
		v.color.g = (high >> 8) & 0xFFu;
		v.color.b = (high >> 16) & 0xFFu;
		v.color.a = (high >> 24) & 0xFFu;
		v.texture_id = 0u;
	}

	return v;
}

struct Rect {
	uint x;
	uint y;
	uint width;
	uint height;
};

// vertices are hyper optimized to safe space
layout (location = 0) in uvec2 vs_packed;

out vec2 fs_texcoords;
out vec4 fs_color;
// you can't pass a bool here :DDDDD
flat out int fs_using_texture;
flat out int fs_shaded;

#pragma mrshader define U_MODEL "u_model"
uniform mat4 u_model;
#pragma mrshader define U_VIEW "u_view"
uniform mat4 u_view;
#pragma mrshader define U_PROJECTION "u_projection"
uniform mat4 u_projection;

#define CHUNK_SIZE 32
#pragma mrshader define U_CHUNK "u_chunk"
uniform uvec3 u_chunk;
#pragma mrshader define U_ATLAS_SIZE "u_atlas_size"
uniform uvec2 u_atlas_size;

#pragma mrshader define SSBO_ATLAS 0
layout(binding = 0, std430) readonly buffer atlas {
	// storing the whole 16k rects is faster than implementing hashmaps on the gpu
	Rect u_atlas_textures[];
};

// get texcoords (it's faster to calculate it in the vertex shader since it runs less times)
vec2 get_texcoords(Vertex v)
{
	vec2 texcoords;
	Rect texture_rect = u_atlas_textures[v.texture_id];

	switch (v.quad_corner) {
	case QUAD_CORNER_TOP_LEFT:
		texcoords = vec2(float(texture_rect.x), float(texture_rect.y));
		break;
	case QUAD_CORNER_TOP_RIGHT:
		texcoords = vec2(float(texture_rect.x + texture_rect.width), float(texture_rect.y));
		break;
	case QUAD_CORNER_BOTTOM_LEFT:
		texcoords = vec2(float(texture_rect.x), float(texture_rect.y + texture_rect.height));
		break;
	case QUAD_CORNER_BOTTOM_RIGHT:
		texcoords = vec2(float(texture_rect.x + texture_rect.width),
			float(texture_rect.y + texture_rect.height)
		);
		break;
	}

	return texcoords / vec2(u_atlas_size);
}

void main()
{
	Vertex v = unpack_vertex(vs_packed);

	vec3 position = vec3(v.position) * vec3(u_chunk + uvec3(1, 1, 1)) * CHUNK_SIZE;
	gl_Position = u_projection * u_view * u_model * vec4(position, 1.0);

	if (v.using_texture) {
		fs_texcoords = get_texcoords(v);
		fs_color = vec4(1, 1, 1, 1);
	}
	else {
		fs_texcoords = vec2(0, 0);
		fs_color = vec4(v.color) / 255;
	}
	fs_using_texture = int(v.using_texture);
	fs_shaded = int(v.shaded);
}

#pragma mrshader fragment
in vec2 fs_texcoords;
in vec4 fs_color;
flat in int fs_using_texture;
flat in int fs_shaded;

out vec4 frag_color;

uniform sampler2D u_texture;

void main()
{
	// TODO lighting
	if (bool(fs_using_texture)) {
		frag_color = texture(u_texture, fs_texcoords);
	}
	else {
		frag_color = fs_color;
	}
}
