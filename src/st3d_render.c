#include <GLFW/glfw3.h>
#include <GL/gl.h>
#include "st3d.h"
#include "st3d_render.h"

void st3d_begin_drawing(TrColor clear_color)
{
	glClearColor(clear_color.r / 255.0f, clear_color.g / 255.0f,
		clear_color.b / 255.0f, clear_color.a / 255.0f);
	glClear(GL_COLOR_BUFFER_BIT);
}

void st3d_end_drawing(void)
{
	glfwSwapBuffers(st3d_get_window_handle());
}
