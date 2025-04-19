#ifndef _ST3D_CORE_H
#define _ST3D_CORE_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// Starry3D version :D
#define ST3D_VERSION "v0.1.1"

// Default size for buffers storing paths. It's 260 because that's the limit on Windows.
#define ST3D_PATH_SIZE 260

// The key to success.
typedef enum {
	ST3D_KEY_NULL = 0,
	ST3D_KEY_SPACE = 32,
	ST3D_KEY_APOSTROPHE = 39,
	ST3D_KEY_COMMA = 44,
	ST3D_KEY_MINUS = 45,
	ST3D_KEY_PERIOD = 46,
	ST3D_KEY_SLASH = 47,
	ST3D_KEY_0 = 48,
	ST3D_KEY_1 = 49,
	ST3D_KEY_2 = 50,
	ST3D_KEY_3 = 51,
	ST3D_KEY_4 = 52,
	ST3D_KEY_5 = 53,
	ST3D_KEY_6 = 54,
	ST3D_KEY_7 = 55,
	ST3D_KEY_8 = 56,
	ST3D_KEY_9 = 57,
	ST3D_KEY_SEMICOLON = 59,
	ST3D_KEY_EQUAL = 61,
	ST3D_KEY_A = 65,
	ST3D_KEY_B = 66,
	ST3D_KEY_C = 67,
	ST3D_KEY_D = 68,
	ST3D_KEY_E = 69,
	ST3D_KEY_F = 70,
	ST3D_KEY_G = 71,
	ST3D_KEY_H = 72,
	ST3D_KEY_I = 73,
	ST3D_KEY_J = 74,
	ST3D_KEY_K = 75,
	ST3D_KEY_L = 76,
	ST3D_KEY_M = 77,
	ST3D_KEY_N = 78,
	ST3D_KEY_O = 79,
	ST3D_KEY_P = 80,
	ST3D_KEY_Q = 81,
	ST3D_KEY_R = 82,
	ST3D_KEY_S = 83,
	ST3D_KEY_T = 84,
	ST3D_KEY_U = 85,
	ST3D_KEY_V = 86,
	ST3D_KEY_W = 87,
	ST3D_KEY_X = 88,
	ST3D_KEY_Y = 89,
	ST3D_KEY_Z = 90,
	ST3D_KEY_LEFT_BRACKET = 91,
	ST3D_KEY_BACKSLASH = 92,
	ST3D_KEY_RIGHT_BRACKET = 93,
	ST3D_KEY_GRAVE_ACCENT = 96,
	ST3D_KEY_INTERNATIONAL_1 = 161,
	ST3D_KEY_INTERNATIONAL_2 = 162,
	ST3D_KEY_ESCAPE = 256,
	ST3D_KEY_ENTER = 257,
	ST3D_KEY_TAB = 258,
	ST3D_KEY_BACKSPACE = 259,
	ST3D_KEY_INSERT = 260,
	ST3D_KEY_DELETE = 261,
	ST3D_KEY_RIGHT = 262,
	ST3D_KEY_LEFT = 263,
	ST3D_KEY_DOWN = 264,
	ST3D_KEY_UP = 265,
	ST3D_KEY_PAGE_UP = 266,
	ST3D_KEY_PAGE_DOWN = 267,
	ST3D_KEY_HOME = 268,
	ST3D_KEY_END = 269,
	ST3D_KEY_CAPS_LOCK = 280,
	ST3D_KEY_SCROLL_LOCK = 281,
	ST3D_KEY_NUM_LOCK = 282,
	ST3D_KEY_PRINT_SCREEN = 283,
	ST3D_KEY_PAUSE = 284,
	ST3D_KEY_F1 = 290,
	ST3D_KEY_F2 = 291,
	ST3D_KEY_F3 = 292,
	ST3D_KEY_F4 = 293,
	ST3D_KEY_F5 = 294,
	ST3D_KEY_F6 = 295,
	ST3D_KEY_F7 = 296,
	ST3D_KEY_F8 = 297,
	ST3D_KEY_F9 = 298,
	ST3D_KEY_F10 = 299,
	ST3D_KEY_F11 = 300,
	ST3D_KEY_F12 = 301,
	ST3D_KEY_F13 = 302,
	ST3D_KEY_F14 = 303,
	ST3D_KEY_F15 = 304,
	ST3D_KEY_F16 = 305,
	ST3D_KEY_F17 = 306,
	ST3D_KEY_F18 = 307,
	ST3D_KEY_F19 = 308,
	ST3D_KEY_F20 = 309,
	ST3D_KEY_F21 = 310,
	ST3D_KEY_F22 = 311,
	ST3D_KEY_F23 = 312,
	ST3D_KEY_F24 = 313,
	ST3D_KEY_F25 = 314,
	ST3D_KEY_KP_0 = 320,
	ST3D_KEY_KP_1 = 321,
	ST3D_KEY_KP_2 = 322,
	ST3D_KEY_KP_3 = 323,
	ST3D_KEY_KP_4 = 324,
	ST3D_KEY_KP_5 = 325,
	ST3D_KEY_KP_6 = 326,
	ST3D_KEY_KP_7 = 327,
	ST3D_KEY_KP_8 = 328,
	ST3D_KEY_KP_9 = 329,
	ST3D_KEY_KP_DECIMAL = 330,
	ST3D_KEY_KP_DIVIDE = 331,
	ST3D_KEY_KP_MULTIPLY = 332,
	ST3D_KEY_KP_SUBTRACT = 333,
	ST3D_KEY_KP_ADD = 334,
	ST3D_KEY_KP_ENTER = 335,
	ST3D_KEY_KP_EQUAL = 336,
	ST3D_KEY_LEFT_SHIFT = 340,
	ST3D_KEY_LEFT_CONTROL = 341,
	ST3D_KEY_LEFT_ALT = 342,
	ST3D_KEY_LEFT_SUPER = 343,
	ST3D_KEY_RIGHT_SHIFT = 344,
	ST3D_KEY_RIGHT_CONTROL = 345,
	ST3D_KEY_RIGHT_ALT = 346,
	ST3D_KEY_RIGHT_SUPER = 347,
	ST3D_KEY_MENU = 348,
	ST3D_KEY_LAST = ST3D_KEY_MENU,
} St3dKey;

typedef enum {
	ST3D_MOUSE_BUTTON_1 = 0,
	ST3D_MOUSE_BUTTON_2 = 1,
	ST3D_MOUSE_BUTTON_3 = 2,
	ST3D_MOUSE_BUTTON_4 = 3,
	ST3D_MOUSE_BUTTON_5 = 4,
	ST3D_MOUSE_BUTTON_6 = 5,
	ST3D_MOUSE_BUTTON_7 = 6,
	ST3D_MOUSE_BUTTON_8 = 7,
	ST3D_MOUSE_BUTTON_LAST = ST3D_MOUSE_BUTTON_8,
	ST3D_MOUSE_BUTTON_LEFT = ST3D_MOUSE_BUTTON_1,
	ST3D_MOUSE_BUTTON_RIGHT = ST3D_MOUSE_BUTTON_2,
	ST3D_MOUSE_BUTTON_MIDDLE = ST3D_MOUSE_BUTTON_3,
} St3dMouseButton;

// Initializes the engine and all of its subsystems
void st3d_init(const char* app, const char* assets, uint32_t width, uint32_t height);

// Frees the engine and all of its subsystems
void st3d_free(void);

// If true, the window is closing and dying.
bool st3d_is_closing(void);

// It closes the window :)
void st3d_close(void);

// It's just `glfwPollEvents()`
void st3d_poll_events(void);

// Returns the internal window handle. This is just a `GLFWwindow*` because we only use GLFW.
void* st3d_get_window_handle(void);

// Returns the window size.
TrVec2i st3d_window_size(void);

bool st3d_is_key_just_pressed(St3dKey key);
bool st3d_is_key_just_released(St3dKey key);
bool st3d_is_key_held(St3dKey key);
bool st3d_is_key_not_pressed(St3dKey key);

// Gets the directory of the executable, and outputs it into out
void st3d_app_dir(TrString* out);

// Gets the directory where you're supposed to save things, and outputs it into out
void st3d_user_dir(TrString* out);

// Shorthand for getting paths. Start with `app:` to get from the assets directory, and `usr:`
// to get from the directory where you save things. For example, `app:images/bob.png`, and `usr:espionage.txt`.
// Writes the actual path to out, which should be at least 260 characters because Windows.
void st3d_path(const char* s, TrString* out);

#ifdef __cplusplus
}
#endif

#endif
