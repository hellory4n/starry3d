/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/configs/sokol.hpp
 * Some configuration for sokol :)
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

#ifndef _ST_CONFIGS_SOKOL_H
#define _ST_CONFIGS_SOKOL_H

// backends
#if defined(_WIN32)
	#define SOKOL_D3D11
#elif defined(__APPLE__)
	#define SOKOL_METAL
#else
	#define SOKOL_GLCORE
#endif

#define SOKOL_ASSERT(X) TR_ASSERT(X)
#define SOKOL_UNREACHABLE tr::panic("unreachable code from sokol")
#define SOKOL_NO_ENTRY

#endif
