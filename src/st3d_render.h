#ifndef ST_ST3D_RENDER_H
#define ST_ST3D_RENDER_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

#define ST3D_DEFAULT_VERTEX_SHADER                     \
	"#version 330 core\n"                              \
	"layout (location = 0) in vec3 pos;"               \
	""                                                 \
	"void main()"                                      \
	"{"                                                \
	"	gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);" \
	"}\n\0"

#define ST3D_DEFAULT_FRAGMENT_SHADER               \
	"#version 330 core\n"                          \
	"out vec4 FragColor;"                          \
	""                                             \
	"void main()"                                  \
	"{"                                            \
	"	FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);" \
	"}\n\0"

// INTERNAL
void st3di_init_render(void);
// INTERNAL
void st3di_free_render(void);

// Begins drawing and clears the screen
void st3d_begin_drawing(TrColor clear_color);

// Does some fuckery that ends drawing.
void st3d_end_drawing(void);

// If true, everything is rendered in wireframe mode, which shows a bunch of lines instead of the
// actual 3D objects.
void st3d_set_wireframe(bool wireframe);

// Shade deez nuts.
typedef struct {
	uint32_t program;
} St3dShader;

// Compiles a shader. The arguments are for the source code of the shaders.
St3dShader st3d_shader_new(const char* vert, const char* frag);

// Frees the shader.
void st3d_shader_free(St3dShader shader);

// Starts using a shader. To go back to the default one, use `st3d_shader_stop_using`
void st3d_shader_use(St3dShader shader);

// Goes back to the default shader.
void st3d_shader_stop_using(void);

// M<esh
typedef struct {
	uint32_t vao;
	uint32_t vbo;
	uint32_t ebo;
	// How many indices the mesh has
	int32_t index_count;
} St3dMesh;

// Uploads a mesh to the GPU. `readonly` is intended for meshes that change. You should usually
// leave it false.
St3dMesh st3d_mesh_new(TrSlice_float vertices, TrSlice_uint32 indices, bool readonly);

// It frees the mesh.
void st3d_mesh_free(St3dMesh mesh);

// Draws a mesh.
void st3d_mesh_draw(St3dMesh mesh);

#ifdef __cplusplus
}
#endif

#endif // ST_ST3D_RENDER_H
