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

TerrainVertex unpack_vertex(PackedTerrainVertex data)
{
	TerrainVertex v;

	v.position.x = (data.x >> 0) & 0x1Fu;
	v.position.y = (data.x >> 5) & 0x1Fu;
	v.position.z = (data.x >> 10) & 0x1Fu;
	v.normal = (data.x >> 15) & 0x7u;
	v.using_texture = ((data.x >> 18) & 1u) != 0u;
	v.billboard = ((data.x >> 19) & 1u) != 0u;
	v.shaded = ((data.x >> 20) & 1u) != 0u;

	if (v.using_texture) {
		v.texture_id = data.y & 0xFFFFu;
		v.color = uvec4(255, 255, 255, 255);
	}
	else {
		v.color = uvec4(
			(data.y >> 0) & 0xFFu,
			(data.y >> 8) & 0xFFu,
			(data.y >> 16) & 0xFFu,
			(data.y >> 24) & 0xFFu
		);
		v.texture_id = 0;
	}

	return v;
}

#endif // _ST_VERTEX_H
