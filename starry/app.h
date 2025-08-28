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

// The key to success. Note the values are identical to RGFW
enum class Key : uint8
{
	UNKNOWN = 0,
	ESCAPE = '\033',
	BACKTICK = '`',
	NUM_0 = '0',
	NUM_1 = '1',
	NUM_2 = '2',
	NUM_3 = '3',
	NUM_4 = '4',
	NUM_5 = '5',
	NUM_6 = '6',
	NUM_7 = '7',
	NUM_8 = '8',
	NUM_9 = '9',
	MINUS = '-',
	EQUALS = '=',
	BACKSPACE = '\b',
	TAB = '\t',
	SPACE = ' ',
	A = 'a',
	B = 'b',
	C = 'c',
	D = 'd',
	E = 'e',
	F = 'f',
	G = 'g',
	H = 'h',
	I = 'i',
	J = 'j',
	K = 'k',
	L = 'l',
	M = 'm',
	N = 'n',
	O = 'o',
	P = 'p',
	Q = 'q',
	R = 'r',
	S = 's',
	T = 't',
	U = 'u',
	V = 'v',
	W = 'w',
	X = 'x',
	Y = 'y',
	Z = 'z',
	PERIOD = '.',
	COMMA = ',',
	SLASH = '/',
	LEFT_BRACKET = '[',
	RIGHT_BRACKET = ']',
	SEMICOLON = ';',
	APOSTROPHE = '\'',
	BACKSLASH = '\\',
	RETURN = '\n',
	ENTER = RETURN,
	DELETE = '\177',
	F1,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,
	F13,
	F14,
	F15,
	F16,
	F17,
	F18,
	F19,
	F20,
	F21,
	F22,
	F23,
	F24,
	F25,
	CAPS_LOCK,
	LEFT_SHIFT,
	LEFT_CTRL,
	LEFT_ALT,
	LEFT_SUPER,
	RIGHT_SHIFT,
	RIGHT_CTRL,
	RIGHT_ALT,
	RIGHT_SUPER,
	ARROW_UP,
	ARROW_DOWN,
	ARROW_LEFT,
	ARROW_RIGHT,
	INSERT,
	MENU,
	END,
	HOME,
	PAGE_UP,
	PAGE_DOWN,
	NUM_LOCK,
	KP_SLASH,
	KP_MULTIPLY,
	KP_PLUS,
	KP_MINUS,
	KP_EQUAL,
	KP_1,
	KP_2,
	KP_3,
	KP_4,
	KP_5,
	KP_6,
	KP_7,
	KP_8,
	KP_9,
	KP_0,
	KP_PERIOD,
	KP_RETURN,
	SCROLL_LOCK,
	PRINT_SCREEN,
	PAUSE,
	INTERNATIONAL_1,
	INTERNATIONAL_2,
	LAST = INTERNATIONAL_2
};

// Mouse btutton :)
enum class MouseButton
{
	LEFT,
	MIDDLE,
	RIGHT,
	SCROLL_UP,
	SCROLL_DOWN,
	MISC_1,
	MISC_2,
	MISC_3,
	MISC_4,
	MISC_5,
	FINAL, // not sure what this is, it's just stolen from rgfw
};

// As the name implies, it's an application.
class Application
{
public:
	virtual tr::Result<void> init() = 0;
	// dt is delta time :)
	virtual tr::Result<void> update(float64 dt) = 0;
	virtual tr::Result<void> free() = 0;
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
	tr::Array<tr::String> logfiles = {};

	tr::Vec2<uint32> window_size = {640, 480};
	bool resizable = true;
	bool fullscreen = false;
	bool vsync = false;
	bool high_dpi = false;
};

// Initializes the crap library.
void run(Application& app, ApplicationSettings settings);

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
tr::Vec2<int32> mouse_position();

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
