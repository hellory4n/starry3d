/*
 * starry3d v0.4.0
 *
 * C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * Copyright (C) 2025 by hellory4n <hellory4n@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this
 * software for any purpose with or without fee is hereby
 * granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#ifndef _ST_COMMON_H
#define _ST_COMMON_H

#include <libtrippin.hpp>

// make sure there's always ST_WINDOWS or ST_LINUX defined
// TODO macOS
#if !defined(ST_WINDOWS) && !defined(ST_LINUX)
	#ifdef _WIN32
		#define ST_WINDOWS
	#else
		#define ST_LINUX
	#endif
#endif

// didn't want to include glfw here
struct GLFWwindow;

namespace st {

// Vresionlsdn.
constexpr const char* VERSION = "v0.4.0";

struct Starry3D {
	GLFWwindow* window;
	tr::Vec2<int32> window_size;
};

// This is where the engine's internal state goes. You probably shouldn't use this directly.
extern Starry3D engine;

// Initializes the crap library.
void init();

// Deinitializes the crap library.
void free();

}

#endif
