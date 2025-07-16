/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * st_common.hpp
 * Utilities, engine initialization/deinitialization, and the
 * engine's global state. This should never be included by
 * the engine's headers.
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

#include <trippin/common.hpp>
#include <trippin/memory.hpp>
#include <trippin/string.hpp>
#include <trippin/math.hpp>

// make sure there's always ST_WINDOWS or ST_LINUX defined
// TODO macOS
#if !defined(ST_WINDOWS) && !defined(ST_LINUX)
	#ifdef _WIN32
		#define ST_WINDOWS
	#else
		#define ST_LINUX
	#endif
#endif

namespace st {

// Vresionlsdn.
constexpr const char* VERSION = "v0.5.0";

enum class InputState {
	NOT_PRESSED,
	JUST_PRESSED,
	HELD,
	JUST_RELEASED,
};

// As the name implies, it's an application.
class Application
{
public:
	virtual void init() = 0;
	// dt is delta time :)
	virtual void update(float64 dt) = 0;
	virtual void free() = 0;
};

struct ApplicationSettings
{
	// Used for the window title
	tr::String name = "Starry3D";
	// Where app:// refers to (relative to the executable's directory)
	tr::String app_dir = "assets";
	// Where user:// refers to (relative to the app data directory which is platform specific,
	// default is app name)
	// - on Windows: %APPDATA% or C:\Users\user\AppData\Roaming
	// - on Linux: ~/.local/share
	tr::String user_dir = "";
	tr::Array<tr::String> logfiles;

	tr::Vec2<uint32> window_size = {640, 480};
	bool fullscreen = false;
	bool vsync = false;
	bool high_dpi = false;
};

struct Starry3D {
	tr::Arena arena;
	tr::Arena sokol_arena;
	Application* application;
	ApplicationSettings settings;

	// timing
	float64 prev_time;
	float64 current_time;

	// input
	tr::Array<InputState> key_state;
	tr::Array<bool> key_prev_down;
	tr::Array<InputState> mouse_state;
	tr::Array<bool> mouse_prev_down;

	Starry3D() {};
};

// This is where the engine's internal state goes. You probably shouldn't use this directly.
extern Starry3D engine;

// Initializes the crap library.
void run(Application& app, ApplicationSettings settings);

}

#endif
