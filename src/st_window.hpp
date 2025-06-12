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

#ifndef _ST_WINDOW_H
#define _ST_WINDOW_H

#include <libtrippin.hpp>

namespace st {

// The key to success.
enum class Key {
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
	RIGHT = 262,
	LEFT = 263,
	DOWN = 264,
	UP = 265,
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
	LEFT_CONTROL = 341,
	LEFT_ALT = 342,
	LEFT_SUPER = 343,
	RIGHT_SHIFT = 344,
	RIGHT_CONTROL = 345,
	RIGHT_ALT = 346,
	RIGHT_SUPER = 347,
	MENU = 348,
	LAST = MENU,
};

enum class MouseButton {
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

struct WindowOptions {
	tr::String title = "Starry3D";
	tr::Vec2<int32> size = {640, 480};
	bool resizable = false;
	bool vsync = false;

	// shut up
	WindowOptions() {}
};

// As the name implies, it opens a window.
void open_window(WindowOptions options);

// Frees the window.
void free_window();

// Politely asks the window to close.
void close_window();

// If true, the window is closing and dying.
bool is_window_closing();

// Literally just `glfwPollEvents()`
void poll_events();

// As the name implies, it returns the window size.
tr::Vec2<int32> window_size();

bool is_key_just_pressed(Key key);
bool is_key_just_released(Key key);
bool is_key_held(Key key);
bool is_key_not_pressed(Key key);

bool is_mouse_just_pressed(MouseButton btn);
bool is_mouse_just_released(MouseButton btn);
bool is_mouse_held(MouseButton btn);
bool is_mouse_not_pressed(MouseButton btn);

// Gets the mouse position, (0, 0) is the top left
tr::Vec2<float64> mouse_position();

// Returns the current mouse scroll. (0, 0) is no scroll, positive values are towards the bottom/right,
// and negative values are towards the top/left
// tr::Vec2<float32> mouse_scroll();

// If false, the mouse gets disabled, which enables raw mouse input.
void set_mouse_enabled(bool val);

// Gets the time since the window started, in seconds
float64 time();

// Gets the time between frames, in seconds
float64 delta_time();

// Gets the amount of frames per second.
float64 fps();

}

#endif
