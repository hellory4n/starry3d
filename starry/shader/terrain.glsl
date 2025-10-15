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
#pragma mrshader include starry/shader/vertex.glsl
#pragma mrshader include starry/shader/atlas.glsl
#pragma mrshader include starry/shader/uniforms.glsl

// literally just filler
// the actual vertex data is calculated with gl_VertexID and the terrain ssbo
// TODO probably unnecessary
layout(location = 0) in int vs_filler;

out vec2 fs_texcoords;
out vec4 fs_color;
flat out uint fs_normal;
// you can't pass a bool here :DDDDD
flat out int fs_using_texture;
flat out int fs_shaded;

void main()
{
	// procedurally generated quad
	vec3 quad_position;
	switch (gl_VertexID) {
	case 0: // bottom left
		quad_position = vec3(-0.5, -0.5, 0);
		break;
	case 1: // top right
		quad_position = vec3(0.5, 0.5, 0);
		break;
	case 2: // top left
		quad_position = vec3(-0.5, 0.5, 0);
		break;
	case 3: // top right
		quad_position = vec3(0.5, 0.5, 0);
		break;
	case 4: // bottom right
		quad_position = vec3(0.5, -0.5, 0);
		break;
	case 5: // bottom left
		quad_position = vec3(-0.5, -0.5, 0);
		break;
	}

	TerrainVertex v = unpack_vertex(u_vertices[gl_InstanceID]);

	// the quad is facing front, rotate it for all the other faces
	switch (v.normal) {
	case NORMAL_FRONT:
		quad_position = vec3(quad_position.x, quad_position.y, 0.5);
		break;
	case NORMAL_BACK:
		quad_position = vec3(-quad_position.x, quad_position.y, -0.5);
		break;
	case NORMAL_LEFT:
		quad_position = vec3(-0.5, quad_position.y, quad_position.x);
		break;
	case NORMAL_RIGHT:
		quad_position = vec3(0.5, quad_position.y, -quad_position.x);
		break;
	case NORMAL_TOP:
		quad_position = vec3(quad_position.x, 0.5, -quad_position.y);
		break;
	case NORMAL_BOTTOM:
		quad_position = vec3(quad_position.x, -0.5, quad_position.y);
		break;
	}

	ivec3 chunk = u_chunk_positions[int(v.chunk_pos_idx)].xyz;
	vec3 position = (vec3(chunk) * CHUNK_SIZE) + (vec3(v.position) + quad_position);
	gl_Position = u_projection * u_view * vec4(position, 1.0);

	if (v.using_texture) {
		fs_texcoords = get_texcoords(v, gl_VertexID);
		fs_color = vec4(1, 1, 1, 1);
	}
	else {
		fs_texcoords = vec2(0, 0);
		fs_color = vec4(v.color) / 255;
	}
	fs_normal = v.normal;
	fs_using_texture = int(v.using_texture);
	fs_shaded = int(v.shaded);
}

#pragma mrshader fragment
#pragma mrshader include starry/shader/uniforms.glsl
#pragma mrshader include starry/shader/light.glsl

in vec2 fs_texcoords;
in vec4 fs_color;
flat in uint fs_normal;
flat in int fs_using_texture;
flat in int fs_shaded;

out vec4 frag_color;

uniform sampler2D u_texture;

void main()
{
	if (u_atlas_size == uvec2(0, 0)) {
		frag_color = vec4(1, 0, 0, 1);
		return;
	}
	const vec3 REAL_NORMALS[6] = {
		vec3(0, 0, -1),
		vec3(0, 0, 1),
		vec3(-1, 0, 0),
		vec3(1, 0, 0),
		vec3(0, 1, 0),
		vec3(0, -1, 0),
	};
	vec3 real_normal = REAL_NORMALS[fs_normal];

	vec4 base_color;
	if (bool(fs_using_texture)) {
		base_color = texture(u_texture, fs_texcoords);
	}
	else {
		// TODO decent transparency (tricky)
		base_color = vec4(fs_color.rgb, 1);
	}
	frag_color = vec4(light(base_color, real_normal).rgb, 1);
}
