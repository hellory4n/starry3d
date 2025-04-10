#ifndef ST3D_WINDOW_H
#define ST3D_WINDOW_H
#include <libtrippin.h>
#include "st3d_core.h"

#ifdef __cplusplus
extern "C" {
#endif

// its hte key to suceess. Stolen directly from RGFW so the values are the same
typedef enum {
	ST3D_KEY_NULL = 0,
	ST3D_KEY_ESCAPE = '\033',
	ST3D_KEY_BACKTICK = '`',
	ST3D_KEY_0 = '0',
	ST3D_KEY_1 = '1',
	ST3D_KEY_2 = '2',
	ST3D_KEY_3 = '3',
	ST3D_KEY_4 = '4',
	ST3D_KEY_5 = '5',
	ST3D_KEY_6 = '6',
	ST3D_KEY_7 = '7',
	ST3D_KEY_8 = '8',
	ST3D_KEY_9 = '9',

	ST3D_KEY_MINUS = '-',
	ST3D_KEY_EQUALS = '=',
	ST3D_KEY_BACKSPACE = '\b',
	ST3D_KEY_TAB = '\t',
	ST3D_KEY_SPACE = ' ',

	ST3D_KEY_A = 'a',
	ST3D_KEY_B = 'b',
	ST3D_KEY_C = 'c',
	ST3D_KEY_D = 'd',
	ST3D_KEY_E = 'e',
	ST3D_KEY_F = 'f',
	ST3D_KEY_G = 'g',
	ST3D_KEY_H = 'h',
	ST3D_KEY_I = 'i',
	ST3D_KEY_J = 'j',
	ST3D_KEY_K = 'k',
	ST3D_KEY_L = 'l',
	ST3D_KEY_M = 'm',
	ST3D_KEY_N = 'n',
	ST3D_KEY_O = 'o',
	ST3D_KEY_P = 'p',
	ST3D_KEY_Q = 'q',
	ST3D_KEY_R = 'r',
	ST3D_KEY_S = 's',
	ST3D_KEY_T = 't',
	ST3D_KEY_U = 'u',
	ST3D_KEY_V = 'v',
	ST3D_KEY_W = 'w',
	ST3D_KEY_X = 'x',
	ST3D_KEY_Y = 'y',
	ST3D_KEY_Z = 'z',

	ST3D_KEY_PERIOD = '.',
	ST3D_KEY_COMMA = ',',
	ST3D_KEY_SLASH = '/',
	ST3D_KEY_LBRACKET = '{',
	ST3D_KEY_RBRACKET = '}',
	ST3D_KEY_SEMICOLON = ';',
	ST3D_KEY_APOSTROPHE = '\'',
	ST3D_KEY_BACKSLASH = '\\',
	ST3D_KEY_ENTER = '\n',

	ST3D_KEY_DELETE = '\177',

	ST3D_KEY_F1,
	ST3D_KEY_F2,
	ST3D_KEY_F3,
	ST3D_KEY_F4,
	ST3D_KEY_F5,
	ST3D_KEY_F6,
	ST3D_KEY_F7,
	ST3D_KEY_F8,
	ST3D_KEY_F9,
	ST3D_KEY_F10,
	ST3D_KEY_F11,
	ST3D_KEY_F12,

	ST3D_KEY_CAPS_LOCK,
	ST3D_KEY_LSHIFT,
	ST3D_KEY_LCONTROL,
	ST3D_KEY_LALT,
	ST3D_KEY_LSUPER,
	ST3D_KEY_RSHIFT,
	ST3D_KEY_RCONTROL,
	ST3D_KEY_RALT,
	ST3D_KEY_RSUPER,
	ST3D_KEY_UP,
	ST3D_KEY_DOWN,
	ST3D_KEY_LEFT,
	ST3D_KEY_RIGHT,

	ST3D_KEY_INSERT,
	ST3D_KEY_END,
	ST3D_KEY_HOME,
	ST3D_KEY_PAGE_UP,
	ST3D_KEY_PAGE_DOWN,

	ST3D_KEY_NUM_LOCK,
	ST3D_KEY_KP_SLASH,
	ST3D_KEY_MULTIPLY,
	ST3D_KEY_KP_MINUS,
	ST3D_KEY_KP_1,
	ST3D_KEY_KP_2,
	ST3D_KEY_KP_3,
	ST3D_KEY_KP_4,
	ST3D_KEY_KP_5,
	ST3D_KEY_KP_6,
	ST3D_KEY_KP_7,
	ST3D_KEY_KP_8,
	ST3D_KEY_KP_9,
	ST3D_KEY_KP_0,
	ST3D_KEY_KP_PERIOD,
	ST3D_KEY_KP_RETURN,
	ST3D_KEY_SCROLL_LOCK,
	ST3D_KEY_KEY_LAST = 256,
} St3dKey;

// mosue
typedef enum {
	ST3D_MOUSE_BUTTON_LEFT,
	ST3D_MOUSE_BUTTON_MIDDLE,
	ST3D_MOUSE_BUTTON_RIGHT,
} St3dMouseButton;

typedef enum {
	ST3D_MOUSE_SCROLL_DOWN = -1,
	ST3D_MOUSE_SCROLL_NONE = 0,
	ST3D_MOUSE_SCROLL_UP = 1,
} St3dMouseScroll;

// Meant to be called from st3d_init
void st3di_window_new(St3dCtx* ctx, int32_t width, int32_t height, const char* title);

// Meant to be called from st3d_free
void st3di_window_free(St3dCtx* ctx);

// You know how GLFW has `glfwPollEvents`? This is the same thing
void st3d_poll_events(St3dCtx* ctx);

// yea
void st3d_swap_buffers(St3dCtx* ctx);

// As the name implies, it returns true if it's closing
bool st3d_is_closing(St3dCtx* ctx);

// It closes the window :D
void st3d_close(St3dCtx* ctx);

// Gets the time in seconds since the window was created
double st3d_time(St3dCtx* ctx);

// Gets the time in seconds since the last frame
double st3d_delta_time(St3dCtx* ctx);

// Gets the directory of the executable
const char* st3d_app_dir(St3dCtx* ctx);

// Gets the directory where you're supposed to save things
const char* st3d_user_dir(St3dCtx* ctx);

// Shorthand for getting paths. Start with `app:` to get from the directory of the executable, and `usr:`
// to get from the directory where you save things. For example, `app:assets/bob.png`, and `usr:espionage.txt`.
// Writes the actual path to buf, which should be at least 260 characters because Windows.
void st3d_path(St3dCtx* ctx, const char* s, TrSlice buf, size_t n);

bool st3d_is_key_just_pressed(St3dCtx* ctx, St3dKey key);

bool st3d_is_key_held(St3dCtx* ctx, St3dKey key);

bool st3d_is_key_just_released(St3dCtx* ctx, St3dKey key);

bool st3d_is_key_not_pressed(St3dCtx* ctx, St3dKey key);

bool st3d_is_mouse_button_just_pressed(St3dCtx* ctx, St3dMouseButton btn);

bool st3d_is_mouse_button_held(St3dCtx* ctx, St3dMouseButton btn);

bool st3d_is_mouse_button_just_released(St3dCtx* ctx, St3dMouseButton btn);

bool st3d_is_mouse_button_not_pressed(St3dCtx* ctx, St3dMouseButton btn);

TrVec2f st3d_mouse_position(St3dCtx* ctx);

// scroll
St3dMouseScroll st3d_mouse_scroll(St3dCtx* ctx);

#ifdef __cplusplus
}
#endif

#endif // ST3D_WINDOW_H
