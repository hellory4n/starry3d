#include <glad/gl.h>
#include <GLFW/glfw3.h>
#include <libtrippin.h>
#include "st3d.h"
#include "st3d_render.h"

static GLFWwindow* tr_window;
static TrVec2i tr_winsize;

static void on_framebuffer_resize(GLFWwindow* window, int width, int height)
{
	(void)window;
	glViewport(0, 0, width, height);
	tr_winsize = (TrVec2i){width, height};
}

static void on_error(int error_code, const char* description)
{
	// tr_panic puts a breakpoint and that's cool
	tr_panic("gl error %i: %s", error_code, description);
}

void st3d_init(const char* app, const char* assets, uint32_t width, uint32_t height)
{
	// gonna use that later
	(void)assets;

	tr_init("log.txt");

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

	tr_window = glfwCreateWindow(width, height, app, NULL, NULL);
	tr_assert(tr_window != NULL, "couldn't create window");
	glfwMakeContextCurrent(tr_window);

	// callbacks
	glfwSetFramebufferSizeCallback(tr_window, on_framebuffer_resize);
	glfwSetErrorCallback(on_error);

	tr_liblog("created window");

	// sbsubsytestesmysmys
	st3di_init_render();

	tr_liblog("initialized starry3d");
}

void st3d_free(void)
{
	glfwDestroyWindow(tr_window);
	glfwTerminate();
	tr_liblog("destroyed window");

	// sbsubsytestesmysmys
	st3di_free_render();

	tr_liblog("deinitialized starry3d");
	tr_free();
}

void* st3d_get_window_handle(void)
{
	return tr_window;
}

void st3d_poll_events(void)
{
	glfwPollEvents();
}

void st3d_close(void)
{
	glfwSetWindowShouldClose(tr_window, true);
}

bool st3d_is_closing(void)
{
	return glfwWindowShouldClose(tr_window);
}

TrVec2i st3d_window_size(void)
{
	return tr_winsize;
}
