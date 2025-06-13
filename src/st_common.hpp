/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * st_common.hpp
 * Utilities, engine initialization/deinitialization, and the
 * engine's global state
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

enum class InputState {
	NOT_PRESSED,
	JUST_PRESSED,
	HELD,
	JUST_RELEASED,
};

struct Starry3D {
	tr::Ref<tr::Arena> arena;

	// window
	GLFWwindow* window;
	tr::Vec2<int32> window_size;

	// timing
	float64 prev_time;
	float64 current_time;
	float64 delta_time;

	// input
	tr::Array<InputState> key_state;
	tr::Array<bool> key_prev_down;
	tr::Array<InputState> mouse_state;
	tr::Array<bool> mouse_prev_down;

	// path crap
	tr::String app_name = "Starry3D";
	tr::String app_dir = "";
	tr::String user_dir = "";

	Starry3D() {};
};

// This is where the engine's internal state goes. You probably shouldn't use this directly.
extern Starry3D engine;

// Initializes the crap library. `app_name` is your game's name, which is used for `user://` prefixes.
// `asset_dir` is just your assets directory, relative to the executable.
void init(tr::String app_name, tr::String asset_dir);

// Deinitializes the crap library.
void free();

// Turns Starry3D paths into real paths. `app://` refers to the game's assets folder, and `user://` refers
// to the directory where the OS lets you store your own crap.
tr::String path(tr::Ref<tr::Arena> arena, tr::String from);

}

#endif
