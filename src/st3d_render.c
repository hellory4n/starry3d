#include <GL/gl.h>
#include <GL/glext.h>
#include <libtrippin.h>
#include "st3d_render.h"

// does error checking :D
static void glerror(void)
{
	GLenum err = glGetError();
	if (err == 0) {
		return;
	}

	// tr_panic sets a breakpoint so that's cool
	// but we don't want to panic on release
	#ifndef DEBUG
	switch (err) {
	case GL_INVALID_ENUM:
		tr_log(TR_LOG_WARNING, "OpenGL error: invalid enum");
		break;
	case GL_INVALID_VALUE:
		tr_log(TR_LOG_WARNING, "OpenGL error: invalid value");
		break;
	case GL_INVALID_OPERATION:
		tr_log(TR_LOG_WARNING, "OpenGL error: invalid operation");
		break;
	case GL_STACK_OVERFLOW:
		tr_log(TR_LOG_WARNING, "OpenGL error: stack overflow");
		break;
	case GL_STACK_UNDERFLOW:
		tr_log(TR_LOG_WARNING, "OpenGL error: stack underflow");
		break;
	case GL_OUT_OF_MEMORY:
		tr_log(TR_LOG_WARNING, "OpenGL error: out of memory");
		break;
	case GL_INVALID_FRAMEBUFFER_OPERATION:
		tr_log(TR_LOG_WARNING, "OpenGL error: invalid framebuffer operation");
		break;
	}
	#else
	switch (err) {
	case GL_INVALID_ENUM:
		tr_panic("OpenGL error: invalid enum");
		break;
	case GL_INVALID_VALUE:
		tr_panic("OpenGL error: invalid value");
		break;
	case GL_INVALID_OPERATION:
		tr_panic("OpenGL error: invalid operation");
		break;
	case GL_STACK_OVERFLOW:
		tr_panic("OpenGL error: stack overflow");
		break;
	case GL_STACK_UNDERFLOW:
		tr_panic("OpenGL error: stack underflow");
		break;
	case GL_OUT_OF_MEMORY:
		tr_panic("OpenGL error: out of memory");
		break;
	case GL_INVALID_FRAMEBUFFER_OPERATION:
		tr_panic("OpenGL error: invalid framebuffer operation");
		break;
	}
	#endif
}

void st3di_gl_new(St3dCtx* ctx)
{
}

void st3di_gl_free(St3dCtx* ctx);
