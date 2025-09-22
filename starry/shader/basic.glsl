/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/basic.glsl
 * It's a basic shader :)
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
// ./tools/mrshader/mrshader.lua starry/shader/basic.glsl starry/shader/basic.glsl.h ST_BASIC_SHADER
#version 430 core

#pragma mrshader vertex
layout (location = 0) in vec3 vs_position;
layout (location = 1) in vec2 vs_texcoords;

out vec2 fs_texcoords;

uniform mat4 u_model;
uniform mat4 u_view;
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
