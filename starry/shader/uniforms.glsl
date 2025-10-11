/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/uniforms.glsl
 * Literally just uniforms
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

#ifndef _ST_UNIFORMS_H
#define _ST_UNIFORMS_H

#pragma mrshader include starry/shader/defs.glsl

uniform mat4 u_view;
uniform mat4 u_projection;
uniform uvec2 u_atlas_size;

#pragma mrshader define U_VIEW "u_view"
#pragma mrshader define U_PROJECTION "u_projection"
#pragma mrshader define U_ATLAS_SIZE "u_atlas_size"

#pragma mrshader define SSBO_ATLAS 0
layout(binding = 0, std430) readonly buffer atlas {
	// storing the whole 16k rects is faster than implementing hashmaps on the gpu
	Rect u_atlas_textures[];
};

#pragma mrshader define SSBO_VERTICES 1
layout(binding = 1, std430) readonly buffer vertices {
	PackedTerrainVertex u_vertices[];
};

#pragma mrshader define SSBO_CHUNK_POSITIONS 2
layout(binding = 2, std430) readonly buffer chunk_positions {
	uvec3 u_chunk_positions[];
};

#endif // _ST_UNIFORMS_H
