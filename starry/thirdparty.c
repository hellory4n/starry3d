/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/thirdparty.cpp
 * This is where we define the implementations for single-header libraries
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

// stb
#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>

// glfw + glad
// idk how much of this is necessary, i just stole it from
// https://github.com/SasLuca/glfw-single-header/blob/master/example/test.c

#if defined(_MSC_VER)
	// Make MS math.h define M_PI
	#define _USE_MATH_DEFINES
#endif

#ifdef __APPLE__
	#define _GLFW_COCOA
#elif _WIN32
	#define _GLFW_WIN32
#else
	#define _GLFW_X11
	#define _GLFW_WAYLAND
#endif

#define LSH_GLFW_IMPLEMENTATION
#define GLFW_INCLUDE_NONE
#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>
#include <glfw-single-header/glfw.h>
