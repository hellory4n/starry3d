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
	// FIXME this definitely doesn't work on big endian who gives a shit
	TerrainVertex v;
	v.position.x = bitfieldExtract(data.x, 0, 4);
	v.position.y = bitfieldExtract(data.x, 4, 4);
	v.position.z = bitfieldExtract(data.x, 8, 4);
	v.normal = bitfieldExtract(data.x, 12, 3);
	v.using_texture = bool(bitfieldExtract(data.x, 15, 1);
	v.billboard = bool(bitfieldExtract(data.x, 16, 1));
	v.shaded = bool(bitfieldExtract(data.x, 17, 1));

	if (v.using_texture) {
		v.texture_id = bitfieldExtract(data.y, 0, 16);
	}
	else {
		v.color.r = bitfieldExtract(data.y, 0, 8);
		v.color.g = bitfieldExtract(data.y, 8, 8);
		v.color.b = bitfieldExtract(data.y, 16, 8);
		v.color.a = bitfieldExtract(data.y, 24, 8);
	}

	v.chunk_pos_idx = bitfieldExtract(data.z, 0, 16);
	return v;
}

#endif // _ST_VERTEX_H
