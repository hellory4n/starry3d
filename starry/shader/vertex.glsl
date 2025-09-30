/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/vertex.glsl
 * For unpacking the aptly named `st::PackedModelVertex`
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

#ifndef _ST_VERTEX_H
#define _ST_VERTEX_H

#pragma mrshader include starry/shader/defs.glsl

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

#endif // _ST_VERTEX_H
