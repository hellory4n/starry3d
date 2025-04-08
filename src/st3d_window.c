// normal includes
#include <libtrippin.h>
#include "st3d_core.h"
#include "st3d_window.h"

// i love oepngl
#define RGL_LOAD_IMPLEMENTATION
#include <rglLoad.h>

// i'm a pedantic fuck and i can't make rgfw use TR_LOG_LIB_INFO
//#define RGFW_DEBUG
// st3d_window.h includes st3d_core.h, which includes RGFW.h
// i love C
#define RGFW_IMPLEMENTATION
// i guess i can only include rgfw from one function or else everything crashes and dies??
#include <RGFW.h>

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
	tr_log(TR_LOG_LIB_INFO, "created window");

	RGFW_window_makeCurrent(ctx->window);
	tr_assert(!RGL_loadGL3((RGLloadfunc)RGFW_getProcAddress), "couldn't initialize OpenGL");
	tr_log(TR_LOG_LIB_INFO, "initialized OpenGL context");

	tr_log(TR_LOG_LIB_INFO, "GL_VENDOR: %s", glGetString(GL_VENDOR));
	tr_log(TR_LOG_LIB_INFO, "GL_RENDERER: %s", glGetString(GL_RENDERER));
	tr_log(TR_LOG_LIB_INFO, "GL_VERSION: %s", glGetString(GL_VERSION));
	tr_log(TR_LOG_LIB_INFO, "GL_SHADING_LANGUAGE_VERSION %s", glGetString(GL_SHADING_LANGUAGE_VERSION));
}

void st3di_window_free(St3dCtx* ctx)
{
	RGFW_window_close(ctx->window);
	tr_log(TR_LOG_LIB_INFO, "closed window");
}
