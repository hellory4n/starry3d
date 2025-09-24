/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/app.h
 * Manages the app's window and input, as well as `st::run` which is quite
 * important innit mate.
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

#ifndef _ST_COMMON_H
#define _ST_COMMON_H

#include <type_traits>

#include <trippin/collection.h>
#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/string.h>

// sokol supports them, but we don't
// these all use clang so #warning should work
// TODO support them? it's that shrimple
#ifdef __APPLE__
	#warning "macOS is not officially supported"
#endif
#ifdef __ANDROID__
	#warning "Android is not supported"
#endif
#ifdef __EMSCRIPTEN__
	#warning "macOS is not supported"
#endif

namespace st {

// Vresionlsdn.
constexpr const char* VERSION = "v0.6.0";
// Vresionlsdn. Format is XYYZZ
constexpr uint32 VERSION_NUM = 6'00; // can't do 0'06'00 bcuz it would become an octal number
constexpr uint32 VERSION_MAJOR = 0;
constexpr uint32 VERSION_MINOR = 6;
constexpr uint32 VERSION_PATCH = 0;

struct InputState
{
	enum class State : uint8
	{
		NOT_PRESSED,
		JUST_PRESSED,
		HELD,
		JUST_RELEASED,
	} state = State::NOT_PRESSED;
	bool pressed = false;
};

// The key to success. Note the values are identical to GLFW
enum class Key
{
	UNKNOWN = 0,
	SPACE = 32,
	APOSTROPHE = 39,
	COMMA = 44,
	MINUS = 45,
	PERIOD = 46,
	SLASH = 47,
	NUM_0 = 48,
	NUM_1 = 49,
	NUM_2 = 50,
	NUM_3 = 51,
	NUM_4 = 52,
	NUM_5 = 53,
	NUM_6 = 54,
	NUM_7 = 55,
	NUM_8 = 56,
	NUM_9 = 57,
	SEMICOLON = 59,
	EQUAL = 61,
	A = 65,
	B = 66,
	C = 67,
	D = 68,
	E = 69,
	F = 70,
	G = 71,
	H = 72,
	I = 73,
	J = 74,
	K = 75,
	L = 76,
	M = 77,
	N = 78,
	O = 79,
	P = 80,
	Q = 81,
	R = 82,
	S = 83,
	T = 84,
	U = 85,
	V = 86,
	W = 87,
	X = 88,
	Y = 89,
	Z = 90,
	LEFT_BRACKET = 91,
	BACKSLASH = 92,
	RIGHT_BRACKET = 93,
	GRAVE_ACCENT = 96,
	INTERNATIONAL_1 = 161,
	INTERNATIONAL_2 = 162,
	ESCAPE = 256,
	ENTER = 257,
	TAB = 258,
	BACKSPACE = 259,
	INSERT = 260,
	DELETE = 261,
	ARROW_RIGHT = 262,
	ARROW_LEFT = 263,
	ARROW_DOWN = 264,
	ARROW_UP = 265,
	PAGE_UP = 266,
	PAGE_DOWN = 267,
	HOME = 268,
	END = 269,
	CAPS_LOCK = 280,
	SCROLL_LOCK = 281,
	NUM_LOCK = 282,
	PRINT_SCREEN = 283,
	PAUSE = 284,
	F1 = 290,
	F2 = 291,
	F3 = 292,
	F4 = 293,
	F5 = 294,
	F6 = 295,
	F7 = 296,
	F8 = 297,
	F9 = 298,
	F10 = 299,
	F11 = 300,
	F12 = 301,
	F13 = 302,
	F14 = 303,
	F15 = 304,
	F16 = 305,
	F17 = 306,
	F18 = 307,
	F19 = 308,
	F20 = 309,
	F21 = 310,
	F22 = 311,
	F23 = 312,
	F24 = 313,
	F25 = 314,
	KP_0 = 320,
	KP_1 = 321,
	KP_2 = 322,
	KP_3 = 323,
	KP_4 = 324,
	KP_5 = 325,
	KP_6 = 326,
	KP_7 = 327,
	KP_8 = 328,
	KP_9 = 329,
	KP_DECIMAL = 330,
	KP_DIVIDE = 331,
	KP_MULTIPLY = 332,
	KP_SUBTRACT = 333,
	KP_ADD = 334,
	KP_ENTER = 335,
	KP_EQUAL = 336,
	LEFT_SHIFT = 340,
	LEFT_CTRL = 341,
	LEFT_ALT = 342,
	LEFT_SUPER = 343,
	RIGHT_SHIFT = 344,
	RIGHT_CTRL = 345,
	RIGHT_ALT = 346,
	RIGHT_SUPER = 347,
	MENU = 348,
	LAST = MENU,
};

// Mouse btutton :)
enum class MouseButton
{
	BTN_1 = 0,
	BTN_2 = 1,
	BTN_3 = 2,
	BTN_4 = 3,
	BTN_5 = 4,
	BTN_6 = 5,
	BTN_7 = 6,
	BTN_8 = 7,
	LAST = BTN_8,
	LEFT = BTN_1,
	RIGHT = BTN_2,
	MIDDLE = BTN_3,
};

// As the name implies, it's an application.
class Application
{
public:
	// pls use free() i just put this here to silence the warning
	virtual ~Application() = default;

	// dt is delta time. You could just use update for everything but I think it's nicer to have
	// separate functions
	virtual void update(float64 dt)
	{
		(void)dt;
	}
	virtual void draw() {}
	virtual void gui() {}
	virtual void free() {}
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
	tr::Array<const tr::String> log_files = {};

	tr::Vec2<uint32> window_size = {640, 480};
	bool resizable = true;
	bool fullscreen = false;
	bool vsync = false;
	bool high_dpi = false;
};

// the funny lambda stuff is so the app is initialized *after* the engine, without the whole
// thing needing to be a template
// cursed i know
void _run(std::function<Application*(tr::Arena& arena)> make_app, ApplicationSettings settings);

// Initializes the crap library.
template<typename App>
requires std::is_base_of_v<Application, App>
void run(ApplicationSettings settings)
{
	st::_run([](tr::Arena& arena) { return arena.make_ptr<App>(); }, settings);
}

// If true, the window should close. Duh.
bool window_should_close();

// Kindly requests the window to be closed. If you want to force quit just use
// `tr::quit`/`tr::panic`
void close_window();

// Returns the window size. May not be 100% accurate because of high DPI crap (you can enable high
// DPi from `st::ApplicationSettings`)
tr::Vec2<uint32> window_size();

// TODO signal-based input handling?

bool is_key_just_pressed(Key key);
bool is_key_just_released(Key key);
bool is_key_held(Key key);
bool is_key_not_pressed(Key key);

bool is_mouse_just_pressed(MouseButton btn);
bool is_mouse_just_released(MouseButton btn);
bool is_mouse_held(MouseButton btn);
bool is_mouse_not_pressed(MouseButton btn);

// Returns the mouse position in pixels (0, 0 is the top left)
tr::Vec2<float64> mouse_position();

// Like `st::mouse_position` but only how much it moved since the last frame
tr::Vec2<float64> delta_mouse_position();

// TODO mouse_scroll()

// If false, the mouse gets disabled, which enables raw mouse input.
void set_mouse_enabled(bool val);

// Gets the time since the window started, in seconds
float64 time_sec();

// Gets the time between frames, in seconds
float64 delta_time_sec();

// Gets the amount of frames per second.
float64 fps();

}

#endif
