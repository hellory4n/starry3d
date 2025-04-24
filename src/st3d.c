// yes this is intentional
// don't want to make users have to compile a lot of random crap
#include <whereami.c>

#include <stdio.h>
#include <math.h>
#include <libgen.h>

#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <libtrippin.h>
#include "st3d.h"
#include "st3d_render.h"
#include "st3d_voxel.h"

typedef enum {
	ST3D_INPUT_STATE_NOT_PRESSED,
	ST3D_INPUT_STATE_JUST_PRESSED,
	ST3D_INPUT_STATE_HELD,
	ST3D_INPUT_STATE_JUST_RELEASED,
} St3dInputState;

static TrArena st3d_arena;

static GLFWwindow* st3d_window;
static TrVec2i st3d_winsize;

static double st3d_prev_time;
static double st3d_cur_time;
static double st3d_delta_tim;

// type is St3dInputState
static TrSlice_int32 st3d_key_state;
// type is bool
static TrSlice_bool st3d_key_prev_down;
static TrSlice_bool st3d_key_state;
// type is St3dInputState
static TrSlice_int32 st3d_mouse_state;
// type is bool
static TrSlice_bool st3d_mouse_prev_down;
static TrVec2f st3d_cur_mouse_scroll;

static TrString st3d_app;
static TrString st3d_assets;
static TrString st3d_full_exe_dir;
static TrString st3d_full_user_dir;
static bool st3d_exe_dir_fetched;
static bool st3d_user_dir_fetched;

static void on_framebuffer_resize(GLFWwindow* window, int width, int height)
{
	(void)window;
	glViewport(0, 0, width, height);
	st3d_winsize = (TrVec2i){width, height};
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
void __st3d_on_scroll(GLFWwindow* window, double x, double y)
{
	(void)window;
	st3d_cur_mouse_scroll = (TrVec2f){x, y};
}

void st3d_init(const char* app, const char* assets, uint32_t width, uint32_t height)
{
	tr_init("log.txt");
	st3d_arena = tr_arena_new(TR_MB(1));

	st3d_full_exe_dir = tr_slice_new(&st3d_arena, ST3D_PATH_SIZE, sizeof(char));
	st3d_full_user_dir = tr_slice_new(&st3d_arena, ST3D_PATH_SIZE, sizeof(char));
	st3d_app = tr_slice_new(&st3d_arena, ST3D_PATH_SIZE, sizeof(char));
	st3d_assets = tr_slice_new(&st3d_arena, ST3D_PATH_SIZE, sizeof(char));
	strncpy(st3d_app.buffer, app, ST3D_PATH_SIZE);
	strncpy(st3d_assets.buffer, assets, ST3D_PATH_SIZE);

	st3d_key_state = tr_slice_new(&st3d_arena, ST3D_KEY_LAST + 1, sizeof(int32_t));
	st3d_key_prev_down = tr_slice_new(&st3d_arena, ST3D_KEY_LAST + 1, sizeof(bool));
	st3d_mouse_state = tr_slice_new(&st3d_arena, ST3D_MOUSE_BUTTON_LAST + 1, sizeof(int32_t));
	st3d_mouse_prev_down = tr_slice_new(&st3d_arena, ST3D_MOUSE_BUTTON_LAST + 1, sizeof(bool));

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

	st3d_window = glfwCreateWindow(width, height, app, NULL, NULL);
	tr_assert(st3d_window != NULL, "couldn't create window");
	glfwMakeContextCurrent(st3d_window);
	glfwSwapInterval(1);

	// callbacks
	glfwSetFramebufferSizeCallback(st3d_window, on_framebuffer_resize);
	glfwSetErrorCallback(on_error);
	glfwSetScrollCallback(st3d_window, __st3d_on_scroll);

	tr_liblog("created window");

	if (!glfwRawMouseMotionSupported()) {
		tr_warn("raw mouse motion isn't supported");
	}

	// sbsubsytestesmysmys
	st3di_init_render();
	st3di_vox_init();

	// apparently windows is shit so i have to do this immediately
	on_framebuffer_resize(st3d_window, width, height);

	tr_liblog("initialized starry3d");
}

void st3d_free(void)
{
	glfwDestroyWindow(st3d_window);
	glfwTerminate();
	tr_liblog("destroyed window");

	// sbsubsytestesmysmys
	st3di_vox_free();
	st3di_free_render();

	tr_liblog("deinitialized starry3d");
	tr_arena_free(&st3d_arena);
	tr_free();
}

void* st3d_get_window_handle(void)
{
	return st3d_window;
}

void st3d_poll_events(void)
{
	// sir.
	st3d_cur_mouse_scroll = (TrVec2f){0, 0};

	glfwPollEvents();

	// we have more fancy states :)

	// valid keys start at space
	// it gets mad if you try to check for anything before that
	for (int32_t key = ST3D_KEY_SPACE; key <= ST3D_KEY_LAST; key++) {
		bool is_down = glfwGetKey(st3d_window, key) == GLFW_PRESS;

		// help
		bool* was_down = TR_AT(st3d_key_prev_down, bool, key);
		if (!(*was_down) && is_down) {
			*TR_AT(st3d_key_state, int32_t, key) = ST3D_INPUT_STATE_JUST_PRESSED;
		}
		else if ((*was_down) && is_down) {
			*TR_AT(st3d_key_state, int32_t, key) = ST3D_INPUT_STATE_HELD;
		}
		else if ((*was_down) && !is_down) {
			*TR_AT(st3d_key_state, int32_t, key) = ST3D_INPUT_STATE_JUST_RELEASED;
		}
		else {
			*TR_AT(st3d_key_state, int32_t, key) = ST3D_INPUT_STATE_NOT_PRESSED;
		}

		*was_down = is_down;
	}

	// christ
	for (int32_t btn = ST3D_MOUSE_BUTTON_1; btn <= ST3D_MOUSE_BUTTON_LAST; btn++) {
		bool is_down = glfwGetMouseButton(st3d_window, btn) == GLFW_PRESS;

		bool* was_down = TR_AT(st3d_mouse_prev_down, bool, btn);
		if (!(*was_down) && is_down) {
			*TR_AT(st3d_mouse_state, int32_t, btn) = ST3D_INPUT_STATE_JUST_PRESSED;
		}
		else if ((*was_down) && is_down) {
			*TR_AT(st3d_mouse_state, int32_t, btn) = ST3D_INPUT_STATE_HELD;
		}
		else if ((*was_down) && !is_down) {
			*TR_AT(st3d_mouse_state, int32_t, btn) = ST3D_INPUT_STATE_JUST_RELEASED;
		}
		else {
			*TR_AT(st3d_mouse_state, int32_t, btn) = ST3D_INPUT_STATE_NOT_PRESSED;
		}

		*was_down = is_down;
	}

	// YOU UNDERSTAND MECHANICAL HANDS ARE THE RULER OF EVERYTHING
	// ah
	// RULER OF EVERYTHING
	// ah
	// IM THE RULER OF EVERYTHING
	// in the end...
	st3d_cur_time = st3d_time();
	st3d_delta_tim = st3d_cur_time - st3d_prev_time;
	st3d_prev_time = st3d_cur_time;
}

void st3d_close(void)
{
	glfwSetWindowShouldClose(st3d_window, true);
}

bool st3d_is_closing(void)
{
	return glfwWindowShouldClose(st3d_window);
}

TrVec2i st3d_window_size(void)
{
	return st3d_winsize;
}

bool st3d_is_key_just_pressed(St3dKey key)
{
	return *TR_AT(st3d_key_state, int32_t, key) == ST3D_INPUT_STATE_JUST_PRESSED;
}

bool st3d_is_key_just_released(St3dKey key)
{
	return *TR_AT(st3d_key_state, int32_t, key) == ST3D_INPUT_STATE_JUST_RELEASED;
}

bool st3d_is_key_held(St3dKey key)
{
	return *TR_AT(st3d_key_state, int32_t, key) == ST3D_INPUT_STATE_JUST_PRESSED ||
	       *TR_AT(st3d_key_state, int32_t, key) == ST3D_INPUT_STATE_JUST_RELEASED ||
		   *TR_AT(st3d_key_state, int32_t, key) == ST3D_INPUT_STATE_HELD;
}

bool st3d_is_key_not_pressed(St3dKey key)
{
	return *TR_AT(st3d_key_state, int32_t, key) == ST3D_INPUT_STATE_NOT_PRESSED;
}

bool st3d_is_mouse_just_pressed(St3dMouseButton btn)
{
	return *TR_AT(st3d_mouse_state, int32_t, btn) == ST3D_INPUT_STATE_JUST_PRESSED;
}

bool st3d_is_mouse_just_released(St3dMouseButton btn)
{
	return *TR_AT(st3d_mouse_state, int32_t, btn) == ST3D_INPUT_STATE_JUST_RELEASED;
}

bool st3d_is_mouse_held(St3dMouseButton btn)
{
	return *TR_AT(st3d_mouse_state, int32_t, btn) == ST3D_INPUT_STATE_JUST_PRESSED ||
	       *TR_AT(st3d_mouse_state, int32_t, btn) == ST3D_INPUT_STATE_JUST_RELEASED ||
		   *TR_AT(st3d_mouse_state, int32_t, btn) == ST3D_INPUT_STATE_HELD;
}

bool st3d_is_mouse_not_pressed(St3dMouseButton btn)
{
	return *TR_AT(st3d_mouse_state, int32_t, btn) == ST3D_INPUT_STATE_NOT_PRESSED;
}

TrVec2f st3d_mouse_position(void)
{
	double x, y;
	glfwGetCursorPos(st3d_window, &x, &y);
	return (TrVec2f){x, y};
}

TrVec2f st3d_mouse_scroll(void)
{
	return st3d_cur_mouse_scroll;
}

void st3d_set_mouse_enabled(bool val)
{
	glfwSetInputMode(st3d_window, GLFW_CURSOR, val ? GLFW_CURSOR_NORMAL : GLFW_CURSOR_DISABLED);
}

double st3d_time(void)
{
	return glfwGetTime();
}

double st3d_delta_time(void)
{
	return st3d_delta_tim;
}

double st3d_fps(void)
{
	return 1.0 / st3d_delta_tim;
}

void st3d_app_dir(TrString* out)
{
	// no need to get it twice
	if (st3d_exe_dir_fetched) {
		memcpy(out->buffer, st3d_full_exe_dir.buffer, (size_t)fmin(out->length, st3d_full_exe_dir.length));
		return;
	}

	// actually get the path :)
	// yes this is how you're supposed to use whereami
	int dirname_len;
	wai_getExecutablePath(st3d_full_exe_dir.buffer, st3d_full_exe_dir.length, &dirname_len);
	*TR_AT(st3d_full_exe_dir, char, dirname_len) = '\0';
	tr_liblog("executable directory: %s", (char*)st3d_full_exe_dir.buffer);

	memcpy(out->buffer, st3d_full_exe_dir.buffer, (size_t)fmin(out->length, st3d_full_exe_dir.length));
	st3d_exe_dir_fetched = true;
}

void st3d_user_dir(TrString* out)
{
	// no need to get it twice
	if (st3d_user_dir_fetched) {
		memcpy(out->buffer, st3d_full_user_dir.buffer, (size_t)fmin(out->length, st3d_full_user_dir.length));
		return;
	}

	// actually get the path :)
	// TODO will probably segfault if you have a really weird setup or smth
	#ifdef ST3D_WINDOWS
	char* sigma = getenv("APPDATA");
	snprintf(st3d_full_user_dir.buffer, st3d_full_user_dir.length, "%s/%s", sigma, (char*)st3d_app.buffer);
	#else
	char* sigma = getenv("HOME");
	snprintf(st3d_full_user_dir.buffer, st3d_full_user_dir.length, "%s/.local/share/%s", sigma,
		(char*)st3d_app.buffer);
	#endif
	tr_liblog("user directory: %s", (char*)st3d_full_user_dir.buffer);

	memcpy(out->buffer, st3d_full_user_dir.buffer, (size_t)fmin(out->length, st3d_full_user_dir.length));
	st3d_user_dir_fetched = true;
}

void st3d_path(const char* s, TrString* out)
{
	if (out->length < ST3D_PATH_SIZE) {
		tr_warn("buffer may not be large enough to store path");
	}

	if (strncmp(s, "app:", 4) == 0) {
		// remove the prefix
		const char* trimmed = s + 4;
		TrString stigma = tr_slice_new(&st3d_arena, ST3D_PATH_SIZE, sizeof(char));
		st3d_app_dir(&stigma);
		snprintf(out->buffer, out->length, "%s/%s/%s", (char*)stigma.buffer, (char*)st3d_assets.buffer, trimmed);
	}
	else if (strncmp(s, "usr:", 4) == 0) {
		// remove the prefix
		const char* trimmed = s + 4;
		TrString stigma = tr_slice_new(&st3d_arena, ST3D_PATH_SIZE, sizeof(char));
		st3d_user_dir(&stigma);
		snprintf(out->buffer, out->length, "%s/%s", (char*)stigma.buffer, trimmed);
	}
	else {
		tr_panic("you fucking legumes did you read the documentation for st3d_path");
	}
}
