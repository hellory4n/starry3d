#ifndef ST3D_RENDER_H
#define ST3D_RENDER_H
#include <libtrippin.h>
#include "st3d_core.h"

// mesh
typedef struct {
	// opegngl
	uint32_t vbo;
} St3dModel;

// shade deez
typedef struct {
	uint32_t obj;
} St3dShader;

#define ST3D_DEFAULT_VERTEX_SHADER \
	"#version 330 core\n" \
	"layout (location = 0) in vec3 pos;" \
	"" \
	"void main()" \
	"{" \
	"	gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);" \
	"}"

#define ST3D_DEFAULT_FRAGMENT_SHADER \
	"#version 330 core\n" \
	"out vec4 FragColor;" \
	"" \
	"void main()" \
	"{" \
	"	FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);" \
	"}"

void st3di_gl_new(St3dCtx* ctx);

void st3di_gl_free(St3dCtx* ctx);

// Generates a new triangle model. This is just so I can test OpenGL lmao
St3dModel st3d_mesh_gen_triangle(St3dCtx* ctx, TrVec3f vert1, TrVec3f vert2, TrVec3f vert3);

// Compiles a shader from source code (not paths).
St3dShader st3d_shader_new(const char* vert_src, const char* frag_src);

// Uses the shader :D
void st3d_shader_use(St3dShader shader);

#endif // ST3D_RENDER_H
