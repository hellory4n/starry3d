/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/light.glsl
 * Lighting.
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

#ifndef _ST_LIGHT_H
#define _ST_LIGHT_H

// shitty tmp constants
const vec3 SUN_DIR = vec3(0.5, 1.0, -0.75);
const vec4 SUN_COLOR = vec4(1, 1, 1, 1);
const vec4 AMBIENT = vec4(0.5, 0.55, 0.5, 1);

vec4 light(vec4 src, vec3 normal)
{
	vec3 sundir = normalize(SUN_DIR);
	float diff = max(dot(normal, sundir), 0.0);
	return src * ((AMBIENT * SUN_COLOR) + diff * (1.0 - AMBIENT * SUN_COLOR));
}

#endif // _ST_LIGHT_H
