/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/voxel.glsl
 * The shader that shades voxels shader shading it.
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

// compile with: ./sokol-shdc -i starry/shader/terrain.glsl -o starry/shader/terrain.glsl.h -l glsl430:metal_macos

@include defs.glsl

@vs vs
in vec3 vs_position;
in int vs_texture_id;

flat out int fs_texture_id;
flat out ivec2 fs_atlas_size;

layout(binding = 0) uniform params {
	mat4 u_model;
	mat4 u_view;
	mat4 u_projection;
	ivec2 u_atlas_size;
};

void main()
{
	gl_Position = u_projection * u_view * u_model * vec4(vs_position, 1.0);
	fs_texture_id = vs_texture_id;
	fs_atlas_size = u_atlas_size;
}
@end

@fs fs
// this is actually 2 uint16s together
// the high part is the index
// the low part is which texcoord to use
flat in int fs_texture_id;
flat in ivec2 fs_atlas_size;

out vec4 frag_color;

struct Rect {
	int x;
	int y;
	int w;
	int h;
};

struct Texture {
	uint id;
	uint texcoord;
};

layout(binding = 0) uniform texture2D _u_texture;
layout(binding = 0) uniform sampler _u_texture_smp;
#define u_texture sampler2D(_u_texture, _u_texture_smp)

layout(std430, binding = 0) readonly buffer fs_atlas {
	Rect u_atlas[];
};

// green on success, red on fail
void assert(bool x)
{
	if (x) frag_color = vec4(1, 0, 0, 1);
	else frag_color = vec4(0, 1, 0, 1);
}

Texture unpack_texture_id(uint src)
{
	uint high = src >> 16;
	uint low = src & 0xFFFF;
	return Texture(high, low);
}

vec2 get_texcoord(Texture t)
{
	Rect rect = u_atlas[t.id];

	float u0 = float(rect.x) / float(fs_atlas_size.x);
	float v0 = float(rect.y) / float(fs_atlas_size.y);
	float u1 = float(rect.x + rect.w) / float(fs_atlas_size.x);
	float v1 = float(rect.y + rect.h) / float(fs_atlas_size.y);

	switch (t.texcoord) {
	case 0: // top left
		return vec2(u0, v0);
	case 1: // top right
		return vec2(u1, v0);
	case 2: // bottom right
		return vec2(u1, v1);
	case 3: // bottom left
		return vec2(u0, v1);
	default:
		return vec2(0, 0);
	}
}

void main()
{
	// frag_color = texture(u_texture, get_texcoord(unpack_texture_id(fs_texture_id)));
	vec2 fick = get_texcoord(unpack_texture_id(fs_texture_id));
	// frag_color = vec4(fick.x, 0, fick.y, 1);
	// assert(u_atlas[2].x == 32 && u_atlas[2].y == 0 && u_atlas[2].w == 16);
	assert(u_atlas[0].w == 16 && fs_texture_id >= 0);
}
@end

@program terrain vs fs
