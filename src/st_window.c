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

#include <stdio.h>
#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <libtrippin.h>
#include "st_window.h"
#include "st_common.h"

typedef enum {
	ST_INPUT_STATE_NOT_PRESSED,
	ST_INPUT_STATE_JUST_PRESSED,
	ST_INPUT_STATE_HELD,
	ST_INPUT_STATE_JUST_RELEASED,
} StInputState;

static GLFWwindow* st_window;
static TrVec2i st_winsize;

static double st_prev_time;
static double st_cur_time;
static double st_delta_tim;

// type is StInputState
static TrSlice_int32 st_key_state;
// type is bool
static TrSlice_bool st_key_prev_down;
static TrSlice_bool st_key_state;
// type is StInputState
static TrSlice_int32 st_mouse_state;
// type is bool
static TrSlice_bool st_mouse_prev_down;
static TrVec2f st_cur_mouse_scroll;

static void on_framebuffer_resize(GLFWwindow* window, int width, int height)
{
	(void)window;
	glViewport(0, 0, width, height);
	st_winsize = (TrVec2i){width, height};
}

static void on_error(int error_code, const char* description)
{
	// tr_panic puts a breakpoint and that's cool
	#ifdef DEBUG
	tr_panic("gl error %i: %s", error_code, description);
	#else
	tr_warn("gl error: %i: %s", error_code, description);
	#endif
}

// not static because nuklear wants this callback too so if nuklear is setup, we override this callback
// and then give the scroll state back to nuklear lmao
void __st_on_scroll(GLFWwindow* window, double x, double y)
{
	(void)window;
	st_cur_mouse_scroll = (TrVec2f){x, y};
}

void st_open_window(TrArena* arena, const char* title, uint32_t width, uint32_t height)
{
	st_key_state = tr_slice_new(arena, ST_KEY_LAST + 1, sizeof(int32_t));
	st_key_prev_down = tr_slice_new(arena, ST_KEY_LAST + 1, sizeof(bool));
	st_mouse_state = tr_slice_new(arena, ST_MOUSE_BUTTON_LAST + 1, sizeof(int32_t));
	st_mouse_prev_down = tr_slice_new(arena, ST_MOUSE_BUTTON_LAST + 1, sizeof(bool));

	// initialize window
	if (!glfwInit()) {
		tr_panic("couldn't initialize glfw");
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_RESIZABLE, true);
	#ifdef DEBUG
	glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, true);
	#endif
	// so it works with renderdoc
	#if defined(DEBUG) && defined(ST_LINUX)
	glfwWindowHint(GLFW_PLATFORM, GLFW_PLATFORM_X11);
	#endif

	st_window = glfwCreateWindow(width, height, title, NULL, NULL);
	tr_assert(st_window != NULL, "couldn't create window");
	glfwMakeContextCurrent(st_window);

	// callbacks
	glfwSetFramebufferSizeCallback(st_window, on_framebuffer_resize);
	glfwSetErrorCallback(on_error);
	glfwSetScrollCallback(st_window, __st_on_scroll);

	tr_liblog("created window");

	if (!glfwRawMouseMotionSupported()) {
		tr_warn("raw mouse motion isn't supported");
	}

	gladLoadGL(glfwGetProcAddress);

	// apparently windows is shit so i have to do this immediately
	on_framebuffer_resize(st_window, width, height);

	tr_liblog("initialized starry3d");
}

void st_close_window(void)
{
	glfwDestroyWindow(st_window);
	glfwTerminate();
	tr_liblog("destroyed window");
}

void* st_get_window_handle(void)
{
	return st_window;
}

void st_poll_events(void)
{
	// sir.
	st_cur_mouse_scroll = (TrVec2f){0, 0};

	glfwPollEvents();

	// we have more fancy states :)

	// valid keys start at space
	// it gets mad if you try to check for anything before that
	for (int32_t key = ST_KEY_SPACE; key <= ST_KEY_LAST; key++) {
		bool is_down = glfwGetKey(st_window, key) == GLFW_PRESS;

		// help
		bool* was_down = TR_AT(st_key_prev_down, bool, key);
		if (!(*was_down) && is_down) {
			*TR_AT(st_key_state, int32_t, key) = ST_INPUT_STATE_JUST_PRESSED;
		}
		else if ((*was_down) && is_down) {
			*TR_AT(st_key_state, int32_t, key) = ST_INPUT_STATE_HELD;
		}
		else if ((*was_down) && !is_down) {
			*TR_AT(st_key_state, int32_t, key) = ST_INPUT_STATE_JUST_RELEASED;
		}
		else {
			*TR_AT(st_key_state, int32_t, key) = ST_INPUT_STATE_NOT_PRESSED;
		}

		*was_down = is_down;
	}

	// christ
	for (int32_t btn = ST_MOUSE_BUTTON_1; btn <= ST_MOUSE_BUTTON_LAST; btn++) {
		bool is_down = glfwGetMouseButton(st_window, btn) == GLFW_PRESS;

		bool* was_down = TR_AT(st_mouse_prev_down, bool, btn);
		if (!(*was_down) && is_down) {
			*TR_AT(st_mouse_state, int32_t, btn) = ST_INPUT_STATE_JUST_PRESSED;
		}
		else if ((*was_down) && is_down) {
			*TR_AT(st_mouse_state, int32_t, btn) = ST_INPUT_STATE_HELD;
		}
		else if ((*was_down) && !is_down) {
			*TR_AT(st_mouse_state, int32_t, btn) = ST_INPUT_STATE_JUST_RELEASED;
		}
		else {
			*TR_AT(st_mouse_state, int32_t, btn) = ST_INPUT_STATE_NOT_PRESSED;
		}

		*was_down = is_down;
	}

	// YOU UNDERSTAND MECHANICAL HANDS ARE THE RULER OF EVERYTHING
	// ah
	// RULER OF EVERYTHING
	// ah
	// IM THE RULER OF EVERYTHING
	// in the end...
	st_update_all_timers();
	st_cur_time = st_time();
	st_delta_tim = st_cur_time - st_prev_time;
	st_prev_time = st_cur_time;
}

void st_close(void)
{
	glfwSetWindowShouldClose(st_window, true);
}

bool st_is_closing(void)
{
	return glfwWindowShouldClose(st_window);
}

TrVec2i st_window_size(void)
{
	return st_winsize;
}

bool st_is_key_just_pressed(StKey key)
{
	return *TR_AT(st_key_state, int32_t, key) == ST_INPUT_STATE_JUST_PRESSED;
}

bool st_is_key_just_released(StKey key)
{
	return *TR_AT(st_key_state, int32_t, key) == ST_INPUT_STATE_JUST_RELEASED;
}

bool st_is_key_held(StKey key)
{
	return *TR_AT(st_key_state, int32_t, key) == ST_INPUT_STATE_JUST_PRESSED ||
	       *TR_AT(st_key_state, int32_t, key) == ST_INPUT_STATE_JUST_RELEASED ||
		   *TR_AT(st_key_state, int32_t, key) == ST_INPUT_STATE_HELD;
}

bool st_is_key_not_pressed(StKey key)
{
	return *TR_AT(st_key_state, int32_t, key) == ST_INPUT_STATE_NOT_PRESSED;
}

bool st_is_mouse_just_pressed(StMouseButton btn)
{
	return *TR_AT(st_mouse_state, int32_t, btn) == ST_INPUT_STATE_JUST_PRESSED;
}

bool st_is_mouse_just_released(StMouseButton btn)
{
	return *TR_AT(st_mouse_state, int32_t, btn) == ST_INPUT_STATE_JUST_RELEASED;
}

bool st_is_mouse_held(StMouseButton btn)
{
	return *TR_AT(st_mouse_state, int32_t, btn) == ST_INPUT_STATE_JUST_PRESSED ||
	       *TR_AT(st_mouse_state, int32_t, btn) == ST_INPUT_STATE_JUST_RELEASED ||
		   *TR_AT(st_mouse_state, int32_t, btn) == ST_INPUT_STATE_HELD;
}

bool st_is_mouse_not_pressed(StMouseButton btn)
{
	return *TR_AT(st_mouse_state, int32_t, btn) == ST_INPUT_STATE_NOT_PRESSED;
}

TrVec2f st_mouse_position(void)
{
	double x, y;
	glfwGetCursorPos(st_window, &x, &y);
	return (TrVec2f){x, y};
}

TrVec2f st_mouse_scroll(void)
{
	return st_cur_mouse_scroll;
}

void st_set_mouse_enabled(bool val)
{
	glfwSetInputMode(st_window, GLFW_CURSOR, val ? GLFW_CURSOR_NORMAL : GLFW_CURSOR_DISABLED);
}

double st_time(void)
{
	return glfwGetTime();
}

double st_delta_time(void)
{
	return st_delta_tim;
}

double st_fps(void)
{
	return 1.0 / st_delta_tim;
}

void st_set_vsync(bool enabled)
{
	if (enabled) {
		glfwSwapInterval(1);
	}
	else {
		glfwSwapInterval(0);
	}
}
