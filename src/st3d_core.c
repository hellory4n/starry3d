#include <stdio.h>
#include <stdbool.h>
#define RGFW_DEBUG
#define RGFW_IMPLEMENTATION
#include <RGFW.h>
#include "st3d_core.h"

void st3d_show_triangle(void)
{
	RGFW_window* win = RGFW_createWindow("a window", RGFW_RECT(0, 0, 800, 600), RGFW_windowCenter | RGFW_windowNoResize);

	while (RGFW_window_shouldClose(win) == RGFW_FALSE) {
		while (RGFW_window_checkEvent(win)) {  // or RGFW_window_checkEvents(); if you only want callbacks
			// you can either check the current event yourself
			if (win->event.type == RGFW_quit) break;

			if (win->event.type == RGFW_mouseButtonPressed && win->event.button == RGFW_mouseLeft) {
				printf("You clicked at x: %d, y: %d\n", win->event.point.x, win->event.point.y);
			}

			// or use the existing functions
			if (RGFW_isMousePressed(win, RGFW_mouseRight)) {
				printf("The right mouse button was clicked at x: %d, y: %d\n", win->event.point.x, win->event.point.y);
			}
		}

		glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);

		// You can use modern OpenGL techniques, but this method is more straightforward for drawing just one triangle.
		glBegin(GL_TRIANGLES);
		glColor3f(1, 0, 0); glVertex2f(-0.6, -0.75);
		glColor3f(0, 1, 0); glVertex2f(0.6, -0.75);
		glColor3f(0, 0, 1); glVertex2f(0, 0.75);
		glEnd();

		RGFW_window_swapBuffers(win);
	}

	RGFW_window_close(win);
}
