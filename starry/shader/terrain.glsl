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
// ./tools/mrshader/mrshader.lua starry/shader/basic.glsl starry/shader/basic.glsl.h
#version 430 core
#pragma mrshader name ST_TERRAIN_SHADER

#pragma mrshader vertex
// vertices are hyper optimized to safe space
layout (location = 0) in uvec2 vs_packed;

// TODO add includes to mrshader
struct Vertex {
	uvec3 position;
	uint normal;
	uint quad;
	bool shaded;
	bool using_texture;
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

Vertex unpack_vertex(uvec2 packed)
{
	uint low = packed.x;
	uint high = packed.y;
	Vertex v;

	v.position.x = low & 0xFFu;
	v.position.y = (low >> 8)  & 0xFFu;
	v.position.z = (low >> 16) & 0xFFu;

	v.normal = (low >> 24) & 0xFu;
	v.quad = (low >> 28) & 0x3u;
	v.shaded = ((low >> 30) & 0x1u) != 0u;
	v.using_texture = ((low >> 31) & 0x1u) != 0u;

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

out vec2 fs_texcoords;

#pragma mrshader define U_MODEL "u_model"
uniform mat4 u_model;
#pragma mrshader define U_VIEW "u_view"
uniform mat4 u_view;
#pragma mrshader define U_PROJECTION "u_projection"
uniform mat4 u_projection;

void main()
{
	gl_Position = u_projection * u_view * u_model * vec4(vs_position, 1.0);
	fs_texcoords = vs_texcoords;
}

#pragma mrshader fragment
in vec2 fs_texcoords;

out vec4 frag_color;

uniform sampler2D u_texture;

void main()
{
	frag_color = texture(u_texture, fs_texcoords);
}
