/*
 * Starry3D: C voxel game engine
 * More information at https://github.com/hellory4n/starry3d
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

#ifndef _ST_CORE_H
#define _ST_CORE_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// The key to success.
typedef enum {
	ST_KEY_NULL = 0,
	ST_KEY_SPACE = 32,
	ST_KEY_APOSTROPHE = 39,
	ST_KEY_COMMA = 44,
	ST_KEY_MINUS = 45,
	ST_KEY_PERIOD = 46,
	ST_KEY_SLASH = 47,
	ST_KEY_0 = 48,
	ST_KEY_1 = 49,
	ST_KEY_2 = 50,
	ST_KEY_3 = 51,
	ST_KEY_4 = 52,
	ST_KEY_5 = 53,
	ST_KEY_6 = 54,
	ST_KEY_7 = 55,
	ST_KEY_8 = 56,
	ST_KEY_9 = 57,
	ST_KEY_SEMICOLON = 59,
	ST_KEY_EQUAL = 61,
	ST_KEY_A = 65,
	ST_KEY_B = 66,
	ST_KEY_C = 67,
	ST_KEY_D = 68,
	ST_KEY_E = 69,
	ST_KEY_F = 70,
	ST_KEY_G = 71,
	ST_KEY_H = 72,
	ST_KEY_I = 73,
	ST_KEY_J = 74,
	ST_KEY_K = 75,
	ST_KEY_L = 76,
	ST_KEY_M = 77,
	ST_KEY_N = 78,
	ST_KEY_O = 79,
	ST_KEY_P = 80,
	ST_KEY_Q = 81,
	ST_KEY_R = 82,
	ST_KEY_S = 83,
	ST_KEY_T = 84,
	ST_KEY_U = 85,
	ST_KEY_V = 86,
	ST_KEY_W = 87,
	ST_KEY_X = 88,
	ST_KEY_Y = 89,
	ST_KEY_Z = 90,
	ST_KEY_LEFT_BRACKET = 91,
	ST_KEY_BACKSLASH = 92,
	ST_KEY_RIGHT_BRACKET = 93,
	ST_KEY_GRAVE_ACCENT = 96,
	ST_KEY_INTERNATIONAL_1 = 161,
	ST_KEY_INTERNATIONAL_2 = 162,
	ST_KEY_ESCAPE = 256,
	ST_KEY_ENTER = 257,
	ST_KEY_TAB = 258,
	ST_KEY_BACKSPACE = 259,
	ST_KEY_INSERT = 260,
	ST_KEY_DELETE = 261,
	ST_KEY_RIGHT = 262,
	ST_KEY_LEFT = 263,
	ST_KEY_DOWN = 264,
	ST_KEY_UP = 265,
	ST_KEY_PAGE_UP = 266,
	ST_KEY_PAGE_DOWN = 267,
	ST_KEY_HOME = 268,
	ST_KEY_END = 269,
	ST_KEY_CAPS_LOCK = 280,
	ST_KEY_SCROLL_LOCK = 281,
	ST_KEY_NUM_LOCK = 282,
	ST_KEY_PRINT_SCREEN = 283,
	ST_KEY_PAUSE = 284,
	ST_KEY_F1 = 290,
	ST_KEY_F2 = 291,
	ST_KEY_F3 = 292,
	ST_KEY_F4 = 293,
	ST_KEY_F5 = 294,
	ST_KEY_F6 = 295,
	ST_KEY_F7 = 296,
	ST_KEY_F8 = 297,
	ST_KEY_F9 = 298,
	ST_KEY_F10 = 299,
	ST_KEY_F11 = 300,
	ST_KEY_F12 = 301,
	ST_KEY_F13 = 302,
	ST_KEY_F14 = 303,
	ST_KEY_F15 = 304,
	ST_KEY_F16 = 305,
	ST_KEY_F17 = 306,
	ST_KEY_F18 = 307,
	ST_KEY_F19 = 308,
	ST_KEY_F20 = 309,
	ST_KEY_F21 = 310,
	ST_KEY_F22 = 311,
	ST_KEY_F23 = 312,
	ST_KEY_F24 = 313,
	ST_KEY_F25 = 314,
	ST_KEY_KP_0 = 320,
	ST_KEY_KP_1 = 321,
	ST_KEY_KP_2 = 322,
	ST_KEY_KP_3 = 323,
	ST_KEY_KP_4 = 324,
	ST_KEY_KP_5 = 325,
	ST_KEY_KP_6 = 326,
	ST_KEY_KP_7 = 327,
	ST_KEY_KP_8 = 328,
	ST_KEY_KP_9 = 329,
	ST_KEY_KP_DECIMAL = 330,
	ST_KEY_KP_DIVIDE = 331,
	ST_KEY_KP_MULTIPLY = 332,
	ST_KEY_KP_SUBTRACT = 333,
	ST_KEY_KP_ADD = 334,
	ST_KEY_KP_ENTER = 335,
	ST_KEY_KP_EQUAL = 336,
	ST_KEY_LEFT_SHIFT = 340,
	ST_KEY_LEFT_CONTROL = 341,
	ST_KEY_LEFT_ALT = 342,
	ST_KEY_LEFT_SUPER = 343,
	ST_KEY_RIGHT_SHIFT = 344,
	ST_KEY_RIGHT_CONTROL = 345,
	ST_KEY_RIGHT_ALT = 346,
	ST_KEY_RIGHT_SUPER = 347,
	ST_KEY_MENU = 348,
	ST_KEY_LAST = ST_KEY_MENU,
} StKey;

typedef enum {
	ST_MOUSE_BUTTON_1 = 0,
	ST_MOUSE_BUTTON_2 = 1,
	ST_MOUSE_BUTTON_3 = 2,
	ST_MOUSE_BUTTON_4 = 3,
	ST_MOUSE_BUTTON_5 = 4,
	ST_MOUSE_BUTTON_6 = 5,
	ST_MOUSE_BUTTON_7 = 6,
	ST_MOUSE_BUTTON_8 = 7,
	ST_MOUSE_BUTTON_LAST = ST_MOUSE_BUTTON_8,
	ST_MOUSE_BUTTON_LEFT = ST_MOUSE_BUTTON_1,
	ST_MOUSE_BUTTON_RIGHT = ST_MOUSE_BUTTON_2,
	ST_MOUSE_BUTTON_MIDDLE = ST_MOUSE_BUTTON_3,
} StMouseButton;

// Initializes the engine and all of its subsystems
void st_open_window(TrArena* arena, const char* title, uint32_t width, uint32_t height);

// It closes the window :)
void st_close_window(void);

// If true, the window is closing and dying.
bool st_is_closing(void);

// It's just `glfwPollEvents()`
void st_poll_events(void);

// Returns the internal window handle. This is just a `GLFWwindow*` because we only use GLFW.
void* st_get_window_handle(void);

// Returns the window size.
TrVec2i st_window_size(void);

bool st_is_key_just_pressed(StKey key);
bool st_is_key_just_released(StKey key);
bool st_is_key_held(StKey key);
bool st_is_key_not_pressed(StKey key);

bool st_is_mouse_just_pressed(StMouseButton btn);
bool st_is_mouse_just_released(StMouseButton btn);
bool st_is_mouse_held(StMouseButton btn);
bool st_is_mouse_not_pressed(StMouseButton btn);

// Returns the mouse position lmao. (0, 0) is the top left
TrVec2f st_mouse_position(void);

// Returns the current mouse scroll. (0, 0) is no scroll, positive values are towards the bottom/right,
// and negative values are towards the top/left
TrVec2f st_mouse_scroll(void);

// If false, the mouse gets disabled, which enables raw mouse input, which is useful for FPS controllers
// and stuff.
void st_set_mouse_enabled(bool val);

// Gets the time since the window started, in seconds
double st_time(void);

// Gets the time between frames, in seconds
double st_delta_time(void);

// Gets the frames per second (FPS) that the program is running on
double st_fps(void);

// If true, enables VSync. Otherwise, disables it.
void st_set_vsync(bool enabled);

// make sure there's always ST_WINDOWS or ST_LINUX defined
#if !defined(ST_WINDOWS) && !defined(ST_LINUX)
	#ifdef _WIN32
		#define ST_WINDOWS
	#else
		#define ST_LINUX
	#endif
#endif

#ifdef __cplusplus
}
#endif

#endif
