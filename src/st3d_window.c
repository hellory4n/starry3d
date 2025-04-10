// used by windows.h, included by rgfw
#define OEMRESOURCE
// let me use readlink() :(
#define _GNU_SOURCE

// i love oepngl
#define RGL_LOAD_IMPLEMENTATION
#include <rglLoad.h>

// i'm a pedantic fuck and i can't make rgfw use TR_LOG_LIB_INFO
//#define RGFW_DEBUG
// i love C
#define RGFW_IMPLEMENTATION
// i guess i can only include rgfw from one file or else everything crashes and dies??
#include <RGFW.h>

// normal includes
#include <stdio.h>
#include <string.h>
#include <libtrippin.h>
#include "st3d_core.h"
#include "st3d_window.h"

// :(
// windows.h is used too but it's included by rgfw and i guess everything is fucked
#ifdef ST3D_WINDOWS
	#include <windows.h>
#else
	#include <unistd.h>
	#include <libgen.h>
#endif

void st3di_window_new(St3dCtx* ctx, int32_t width, int32_t height, const char* title)
{
	RGFW_setGLHint(RGFW_glMinor, 3);
	RGFW_setGLHint(RGFW_glMajor, 3);
	RGFW_setGLHint(RGFW_glProfile, RGFW_glCore);

	// i have a tiling window manager :D
	// dont want this to fuck everything while i'm just testing
	#ifdef DEBUG
	ctx->window = RGFW_createWindow(title, RGFW_RECT(0, 0, width, height), RGFW_windowNoResize);
	#else
	ctx->window = RGFW_createWindow(title, RGFW_RECT(0, 0, width, height), 0);
	#endif
	tr_assert(ctx->window != NULL, "couldn't initialize window");

	#ifdef ST3D_WINDOWS
	tr_log(TR_LOG_LIB_INFO, "created window (backend: Windows through RGFW)");
	#else
	tr_log(TR_LOG_LIB_INFO, "created window (backend: X11 through RGFW)");
	#endif

	RGFW_window_makeCurrent(ctx->window);
	tr_assert(!RGL_loadGL3((RGLloadfunc)RGFW_getProcAddress), "couldn't initialize OpenGL");
	tr_log(TR_LOG_LIB_INFO, "initialized OpenGL context");

	tr_log(TR_LOG_LIB_INFO, "GL_VENDOR %s", glGetString(GL_VENDOR));
	tr_log(TR_LOG_LIB_INFO, "GL_RENDERER %s", glGetString(GL_RENDERER));
	tr_log(TR_LOG_LIB_INFO, "GL_VERSION %s", glGetString(GL_VERSION));
	tr_log(TR_LOG_LIB_INFO, "GL_SHADING_LANGUAGE_VERSION %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
}

void st3di_window_free(St3dCtx* ctx)
{
	RGFW_window_close(ctx->window);
	tr_log(TR_LOG_LIB_INFO, "closed window");
}

void st3d_poll_events(St3dCtx* ctx)
{
	RGFW_event* event = NULL;
	// why??
	// i cant be bothered to make it less ugly
	while ((event = RGFW_window_checkEvent(ctx->window)) != NULL) {
		switch (event->type) {
		case RGFW_quit:
			ctx->window_closing = true;
			break;

		case RGFW_keyPressed:
			ctx->held_keys[event->button] = true;
			tr_log(TR_LOG_ERROR, "SIGMA!!");
			break;
		case RGFW_keyReleased:
			ctx->held_keys[event->button] = false;
			//tr_log(TR_LOG_ERROR, "SIGMA!!");
			break;

		case RGFW_mouseButtonPressed:
			ctx->held_mouse[event->button] = true;
			break;
		case RGFW_mouseButtonReleased:
			ctx->held_mouse[event->button] = false;
			break;

		case RGFW_windowResized:
			glViewport(0, 0, ((RGFW_window*)ctx->window)->r.w, ((RGFW_window*)ctx->window)->r.h);
			break;
		}
	}

	// we also calculate delta time here fuck you
	double now = st3d_time(ctx);
	ctx->delta_time = now - ctx->prev_time;
	ctx->prev_time = now;
}

void st3d_swap_buffers(St3dCtx* ctx)
{
	RGFW_window_swapBuffers(ctx->window);
}

bool st3d_is_closing(St3dCtx* ctx)
{
	return ctx->window_closing;
}

void st3d_close(St3dCtx* ctx)
{
	ctx->window_closing = true;
}

double st3d_time(St3dCtx* ctx)
{
	// it's really just for consistency
	(void)ctx;
	return RGFW_getTime();
}

double st3d_delta_time(St3dCtx* ctx)
{
	// delta time is calculated in st3d_poll_events
	return ctx->delta_time;
}

const char* st3d_app_dir(St3dCtx* ctx)
{
	const size_t bufsize = 260;

	// no need to get it twice
	if (ctx->full_app_dir.buffer != NULL) {
		return ctx->full_app_dir.buffer;
	}
	ctx->full_app_dir = tr_slice_new(ctx->arena, bufsize, sizeof(char));

	// :(
	#ifdef ST3D_WINDOWS
	DWORD len = GetModuleFileNameA(NULL, ctx->full_app_dir.buffer, bufsize);
    if (len == 0 || len == bufsize) {
		tr_log(TR_LOG_WARNING, "couldn't get app directory; using relative paths");
	}

    // remove the executable filename
    for (int i = len - 1; i >= 0; i--) {
		char* c = (char*)tr_slice_at(ctx->full_app_dir, len);
        if (*c == '\\' || *c == '/') {
            *c = '\0';
            break;
        }
    }
	#else
	ssize_t len = readlink("/proc/self/exe", ctx->full_app_dir.buffer, bufsize - 1);

	if (len != -1) {
		*(char*)tr_slice_at(ctx->full_app_dir, len) = '\0';
		// scary!
		ctx->full_app_dir.buffer = dirname(ctx->full_app_dir.buffer);
	}
	else {
		tr_log(TR_LOG_WARNING, "couldn't get app directory; using relative paths");
		*(char*)tr_slice_at(ctx->full_app_dir, 0) = '.';
	}
	#endif

	return ctx->full_app_dir.buffer;
}

const char* st3d_user_dir(St3dCtx* ctx)
{
	const size_t bufsize = 260;

	// no need to get it twice
	if (ctx->full_user_dir.buffer != NULL) {
		return ctx->full_user_dir.buffer;
	}
	ctx->full_user_dir = tr_slice_new(ctx->arena, bufsize, sizeof(char));

	#ifdef ST3D_WINDOWS
	char* sigma = getenv("APPDATA");
	snprintf(ctx->full_user_dir.buffer, bufsize, "%s/%s", sigma, ctx->user_dir);
	#else
	char* sigma = getenv("HOME");
	snprintf(ctx->full_user_dir.buffer, bufsize, "%s/.local/share/%s", sigma, ctx->user_dir);
	#endif

	return ctx->full_user_dir.buffer;
}

void st3d_path(St3dCtx* ctx, const char* s, char* buf, size_t n)
{
	if (strncmp(s, "app:", 4) == 0) {
		// remove the prefix
		const char* trimmed = s + 4;
		snprintf(buf, n, "%s/%s/%s", st3d_app_dir(ctx), ctx->app_dir, trimmed);
	}
	else if (strncmp(s, "usr:", 4) == 0) {
		// remove the prefix
		const char* trimmed = s + 4;
		snprintf(buf, n, "%s/%s", st3d_user_dir(ctx), trimmed);
	}
	else {
		tr_panic("you fucking legumes did you read the documentation for st3d_path");
	}
}

bool st3d_is_key_just_pressed(St3dCtx* ctx, St3dKey key)
{
	return RGFW_isPressed(ctx->window, key);
}

bool st3d_is_key_held(St3dCtx* ctx, St3dKey key)
{
	return ctx->held_keys[key];
}

bool st3d_is_key_just_released(St3dCtx* ctx, St3dKey key)
{
	return RGFW_isReleased(ctx->window, key);
}

bool st3d_is_key_not_pressed(St3dCtx* ctx, St3dKey key)
{
	return !ctx->held_keys[key];
}

bool st3d_is_mouse_button_just_pressed(St3dCtx* ctx, St3dMouseButton btn)
{
	return RGFW_isMousePressed(ctx->window, btn);
}

bool st3d_is_mouse_button_held(St3dCtx* ctx, St3dMouseButton btn)
{
	return ctx->held_mouse[btn];
}

bool st3d_is_mouse_button_just_released(St3dCtx* ctx, St3dMouseButton btn)
{
	return RGFW_isMouseReleased(ctx->window, btn);
}

bool st3d_is_mouse_button_not_pressed(St3dCtx* ctx, St3dMouseButton btn)
{
	return !ctx->held_mouse[btn];
}

TrVec2f st3d_mouse_position(St3dCtx* ctx)
{
	RGFW_point sogma = RGFW_window_getMousePoint(ctx->window);
	return (TrVec2f){sogma.x, sogma.y};
}

St3dMouseScroll st3d_mouse_scroll(St3dCtx* ctx)
{
	// TODO maybe its not isMouseHeld and my life is a lie
	if (RGFW_isMouseHeld(ctx->window, RGFW_mouseScrollUp)) {
		return ST3D_MOUSE_SCROLL_UP;
	}
	else if (RGFW_isMouseHeld(ctx->window, RGFW_mouseScrollDown)) {
		return ST3D_MOUSE_SCROLL_DOWN;
	}
	else {
		return ST3D_MOUSE_SCROLL_NONE;
	}
}
