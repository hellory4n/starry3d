/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/thirdparty.c
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

// you can't include a c++ header in c duh
// so we have to redefine TR_GCC_IGNORE_WARNING
#ifdef __GNUC__
	#define TR_GCC_PRAGMA(X) _Pragma(#X)

	/* so you don't have to check between GCC and clang, it'll just shut up */
	#ifdef TR_ONLY_CLANG
		#define TR_GCC_IGNORE_WARNING(Warning) \
			TR_GCC_PRAGMA(GCC diagnostic push)                  \
			TR_GCC_PRAGMA(GCC diagnostic ignored "-Wunknown-warning-option")                  \
			TR_GCC_PRAGMA(GCC diagnostic push)                  \
			TR_GCC_PRAGMA(GCC diagnostic ignored #Warning)
	#else
		#define TR_GCC_IGNORE_WARNING(Warning) \
			TR_GCC_PRAGMA(GCC diagnostic push)                  \
			TR_GCC_PRAGMA(GCC diagnostic ignored "-Wpragmas")                  \
			TR_GCC_PRAGMA(GCC diagnostic push)                  \
			TR_GCC_PRAGMA(GCC diagnostic ignored #Warning)
	#endif

	#define TR_GCC_RESTORE() TR_GCC_PRAGMA(GCC diagnostic pop)
#else
	#define TR_GCC_IGNORE_WARNING(Warning)
	#define TR_GCC_RESTORE()
#endif

#ifdef __APPLE__
	#define _GLFW_COCOA
#elif _WIN32
	#define _GLFW_WIN32
#else
	// TODO it'd be nice to support wayland but you have to fuck with wayland-scanner and
	// generating header files or some shit
	// i get the wayland haters now
	#define _GLFW_X11
#endif

// evil hacking muahahahaha kill me
// (glfw is getting a bunch of errors and shit)
#define GL_CONTEXT_RELEASE_BEHAVIOR 0x82FB
#define GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH 0x82FC
#if defined(_GLFW_X11) || defined(_GLFW_WAYLAND)
	#define _GNU_SOURCE
	#include <fcntl.h> // IWYU pragma: keep
	#include <poll.h> // IWYU pragma: keep
	#include <time.h> // IWYU pragma: keep
	#include <unistd.h> // IWYU pragma: keep
#endif

#ifdef _MSC_VER
	#define _USE_MATH_DEFINES
#endif

TR_GCC_IGNORE_WARNING(-Wtypedef-redefinition)
TR_GCC_IGNORE_WARNING(-Wunused-parameter)
TR_GCC_IGNORE_WARNING(-Wmissing-field-initializers)
TR_GCC_IGNORE_WARNING(-Wsign-compare)
TR_GCC_IGNORE_WARNING(-Wpedantic)
#define LSH_GLFW_IMPLEMENTATION
#define _GLFW_IMPLEMENTATION
#define GLFW_INCLUDE_NONE
#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>
#include <glfw-single-header/glfw.h>

// stb
#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>
