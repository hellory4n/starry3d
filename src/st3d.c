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

static TrArena st3d_arena;

static GLFWwindow* st3d_window;
static TrVec2i st3d_winsize;

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
	tr_panic("gl error %i: %s", error_code, description);
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

	// initialize window
	if (!glfwInit()) {
		tr_panic("couldn't initialize glfw");
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	#ifdef DEBUG
	glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, true);
	#endif

	// i use a tiling window manager and it's fucking with everything
	#ifdef DEBUG
	glfwWindowHint(GLFW_RESIZABLE, false);
	#else
	glfwWindowHint(GLFW_RESIZABLE, true);
	#endif

	st3d_window = glfwCreateWindow(width, height, app, NULL, NULL);
	tr_assert(st3d_window != NULL, "couldn't create window");
	glfwMakeContextCurrent(st3d_window);
	glfwSwapInterval(1);

	// callbacks
	glfwSetFramebufferSizeCallback(st3d_window, on_framebuffer_resize);
	glfwSetErrorCallback(on_error);

	tr_liblog("created window");

	// sbsubsytestesmysmys
	st3di_init_render();

	tr_liblog("initialized starry3d");
}

void st3d_free(void)
{
	glfwDestroyWindow(st3d_window);
	glfwTerminate();
	tr_liblog("destroyed window");

	// sbsubsytestesmysmys
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
	glfwPollEvents();
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
	tr_log("%s", (char*)st3d_full_exe_dir.buffer);

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
