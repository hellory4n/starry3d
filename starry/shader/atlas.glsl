/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/atlas.glsl
 * Handles texture atlas stuff I guess.
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

#ifndef _ST_ATLAS_H
#define _ST_ATLAS_H

#pragma mrshader include starry/shader/defs.glsl
#pragma mrshader include starry/shader/uniforms.glsl

vec2 get_texcoords(TerrainVertex v, int vertex_id)
{
	vec2 texcoords = vec2(0, 0);
	Rect texture_rect = u_atlas_textures[v.texture_id];

	switch (vertex_id % 4) {
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

#endif // _ST_ATLAS_H
