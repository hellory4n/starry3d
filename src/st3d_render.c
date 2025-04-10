#include <GL/gl.h>
#include <GL/glext.h>
#include <rglLoad.h>
#include <libtrippin.h>
#include "st3d_render.h"

// does error checking :D
static void glcheck(void)
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

// sorry
// use like `GLCHECK glSomeFunction();`
// TODO im definitely using this more than necessary
#define GLCHECK glcheck();

void st3di_gl_new(St3dCtx* ctx)
{
	(void)ctx;
}

void st3di_gl_free(St3dCtx* ctx)
{
	(void)ctx;
}

St3dModel st3d_mesh_gen_triangle(St3dCtx* ctx, TrVec3f vert1, TrVec3f vert2, TrVec3f vert3)
{
	St3dModel mate = {0};
	TrSlice verts = tr_slice_new(ctx->arena, 3 * 3, sizeof(float));
	// help.
	*(float*)tr_slice_at(verts, 0) = (float)vert1.x;
	*(float*)tr_slice_at(verts, 1) = (float)vert1.y;
	*(float*)tr_slice_at(verts, 2) = (float)vert1.z;
	*(float*)tr_slice_at(verts, 3) = (float)vert2.x;
	*(float*)tr_slice_at(verts, 4) = (float)vert2.y;
	*(float*)tr_slice_at(verts, 5) = (float)vert2.z;
	*(float*)tr_slice_at(verts, 6) = (float)vert3.x;
	*(float*)tr_slice_at(verts, 7) = (float)vert3.y;
	*(float*)tr_slice_at(verts, 8) = (float)vert3.z;

	GLCHECK glGenBuffers(1, &mate.vbo);
	GLCHECK glBindBuffer(GL_ARRAY_BUFFER, mate.vbo);
	GLCHECK glBufferData(GL_ARRAY_BUFFER, verts.length * sizeof(float), verts.buffer, GL_STATIC_DRAW);
	GLCHECK;

	return mate;
}

St3dShader st3d_shader_new(const char* vert_src, const char* frag_src)
{
	St3dShader shader = {0};

	uint32_t vert_shader;
	GLCHECK vert_shader = glCreateShader(GL_VERTEX_SHADER);
	GLCHECK glShaderSource(vert_shader, 1, &vert_src, NULL);
	GLCHECK glCompileShader(vert_shader);

	// check if it compiled
	int32_t success;
	glGetShaderiv(vert_shader, GL_COMPILE_STATUS, &success);
	if (!success) {
		char info_logma[512];
		glGetShaderInfoLog(vert_shader, 512, NULL, info_logma);
		tr_log(TR_LOG_ERROR, "OpenGL: vertex shader compilation error: %s", info_logma);
		// so there's a breakpoint :D
		#ifdef DEBUG
		tr_panic("oh look. shader's busted.");
		#endif
	}

	uint32_t frag_shader;
	GLCHECK frag_shader = glCreateShader(GL_FRAGMENT_SHADER);
	GLCHECK glShaderSource(frag_shader, 1, &frag_src, NULL);
	GLCHECK glCompileShader(frag_shader);

	// check if it compiled
	glGetShaderiv(frag_shader, GL_COMPILE_STATUS, &success);
	if (!success) {
		char info_logma[512];
		glGetShaderInfoLog(frag_shader, 512, NULL, info_logma);
		tr_log(TR_LOG_ERROR, "OpenGL: fragment shader compilation error: %s", info_logma);
		// so there's a breakpoint :D
		#ifdef DEBUG
		tr_panic("oh look. shader's busted.");
		#endif
	}

	GLCHECK shader.obj = glCreateProgram();
	GLCHECK glAttachShader(shader.obj, vert_shader);
	GLCHECK glAttachShader(shader.obj, frag_shader);
	GLCHECK glLinkProgram(shader.obj);

	// check if it linked
	glGetProgramiv(shader.obj, GL_LINK_STATUS, &success);
	if (!success) {
		char info_logma[512];
		glGetProgramInfoLog(shader.obj, 512, NULL, info_logma);
	}

	// they're already linked, now we can just get rid of it
	GLCHECK glDeleteShader(vert_shader);
	GLCHECK glDeleteShader(frag_shader);

	tr_log(TR_LOG_LIB_INFO, "compiled shader (id %u)", shader.obj);
	return shader;
}

void st3d_shader_start_use(St3dShader shader)
{
	glUseProgram(shader.obj);
}
