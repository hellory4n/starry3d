/*
 * starry3d v0.4.0
 *
 * C++ voxel engine
 * https://github.com/hellory4n/starry3d
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

#include "st_window.hpp"

#include "st_common.hpp"

#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>
#include <GLFW/glfw3.h>

void st::open_window(st::WindowOptions options)
{
	if (!glfwInit()) {
		tr::panic("couldn't initialize glfw");
	}

	glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
	glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
	glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
	glfwWindowHint(GLFW_RESIZABLE, options.resizable);
	#ifdef DEBUG
	glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, true);
	#endif

	st::engine.window = glfwCreateWindow(options.size.x, options.size.y,
		options.title.buffer(), nullptr, nullptr
	);
	tr::assert(st::engine.window != nullptr, "couldn't create window");
	glfwMakeContextCurrent(st::engine.window);

	// some callbacks
	glfwSetFramebufferSizeCallback(st::engine.window, [](GLFWwindow* _, int w, int h) -> void {
		glViewport(0, 0, w, h);
		st::engine.window_size = {w, h};
	});

	glfwSetErrorCallback([](int error_code, const char* description) -> void {
		#ifdef DEBUG
		tr::panic("GL error %i: %s", error_code, description);
		#else
		tr::error("GL error %i: %s", error_code, description);
		#endif
	});

	// a bit more annoyment in the logs
	int32 platform = glfwGetPlatform();
	tr::String platform_str = "unknown platform";
	switch (platform) {
		case GLFW_PLATFORM_WIN32:   platform_str = "Win32";   break;
		case GLFW_PLATFORM_X11:     platform_str = "X11";     break;
		case GLFW_PLATFORM_WAYLAND: platform_str = "Wayland"; break;
		case GLFW_PLATFORM_COCOA:   platform_str = "Cocoa";   break;
	}
	tr::info("created window for %s", platform_str.buffer());

	if (!glfwRawMouseMotionSupported()) {
		tr::warn("warning: raw mouse motion is not supported");
	}

	gladLoadGL(glfwGetProcAddress);

	// apparently windows is shit so we have to do this immediately
	glViewport(0, 0, options.size.x, options.size.y);
	st::engine.window_size = options.size;

	tr::info("initialized OpenGL");
	tr::info("- GL vendor:       %s", glGetString(GL_VENDOR));
	tr::info("- GL renderer:     %s", glGetString(GL_RENDERER));
	tr::info("- GL version:      %s", glGetString(GL_VERSION));
	tr::info("- GLSL version:    %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
}

void st::free_window()
{
	glfwDestroyWindow(st::engine.window);
	glfwTerminate();
	tr::info("destroyed window");
}

void st::close_window() { glfwSetWindowShouldClose(st::engine.window, true); }
bool st::is_window_closing() { return glfwWindowShouldClose(st::engine.window); }
void st::poll_events() { glfwPollEvents(); }
tr::Vec2<int32> window_size() { return st::engine.window_size; }
