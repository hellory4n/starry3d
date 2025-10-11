/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/defs.glsl
 * Just a bunch of structs and enums and constants
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

#ifndef _ST_DEFS_H
#define _ST_DEFS_H

struct TerrainVertex {
	uvec3 position;
	uint normal;
	bool shaded;
	bool using_texture;
	bool billboard;
	uint texture_id;
	uvec4 color;
	uint chunk_pos_idx;
};

#define NORMAL_FRONT 0u
#define NORMAL_BACK 1u
#define NORMAL_LEFT 2u
#define NORMAL_RIGHT 3u
#define NORMAL_TOP 4u
#define NORMAL_BOTTOM 5u

#define QUAD_CORNER_TOP_LEFT 0u
#define QUAD_CORNER_TOP_RIGHT 1u
#define QUAD_CORNER_BOTTOM_LEFT 2u
#define QUAD_CORNER_BOTTOM_RIGHT 3u

#define CHUNK_SIZE 16

struct Rect {
	uint x;
	uint y;
	uint width;
	uint height;
};

struct PackedTerrainVertex {
	uint x;
	uint y;
	uint z;
};

#endif // _ST_DEFS_H
