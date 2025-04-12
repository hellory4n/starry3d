#include <GL/gl.h>
#include <GLFW/glfw3.h>
#include <libtrippin.h>
#include "st3d.h"

static GLFWwindow* tr_window;

static void on_framebuffer_resize(GLFWwindow* window, int width, int height)
{
	(void)window;
	glViewport(0, 0, width, height);
}

static void on_error(int error_code, const char* description)
{
	tr_error("gl error %i: %s", error_code, description);
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
	glfwWindowHint(GLFW_RESIZABLE, true);

	tr_window = glfwCreateWindow(width, height, app, NULL, NULL);
	tr_assert(tr_window != NULL, "couldn't create window");
	glfwMakeContextCurrent(tr_window);

	// callbacks
	glfwSetFramebufferSizeCallback(tr_window, on_framebuffer_resize);
	glfwSetErrorCallback(on_error);

	tr_liblog("created window");
	tr_liblog("initialized starry3d");
}

void st3d_free(void)
{
	glfwDestroyWindow(tr_window);
	tr_liblog("destroyed window");

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
