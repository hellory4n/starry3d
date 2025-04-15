#ifndef _ST3D_RENDER_H
#define _ST3D_RENDER_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

#define ST3D_DEFAULT_VERTEX_SHADER             \
	"#version 330 core\n"                      \
	"layout (location = 0) in vec3 pos;"       \
	"layout (location = 1) in vec4 color;"     \
	"layout (location = 2) in vec2 texcoord;"  \
	""                                         \
	"out vec4 out_color;"                      \
	"out vec2 TexCoord;"                       \
	""                                         \
	"uniform mat4 u_mvp;"                      \
	""                                         \
	"void main()"                              \
	"{"                                        \
	"	gl_Position = u_mvp * vec4(pos, 1.0);" \
	"	out_color = color;"                    \
	"	TexCoord = texcoord;"                  \
	"}"

#define ST3D_DEFAULT_FRAGMENT_SHADER                           \
	"#version 330 core\n"                                      \
	"in vec4 out_color;"                                       \
	"in vec2 TexCoord;"                                        \
	""                                                         \
	"out vec4 FragColor;"                                      \
	""                                                         \
	"uniform sampler2D u_texture;"                             \
	""                                                         \
	"void main()"                                              \
	"{"                                                        \
	"	FragColor = texture(u_texture, TexCoord) * out_color;" \
	"}"

#define ST3D_2D_LEFT 0
#define ST3D_2D_RIGHT 1280
#define ST3D_2D_TOP 0
#define ST3D_2D_BOTTOM 720

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

// Sets the uniform to a bool value
void st3d_shader_set_bool(St3dShader shader, const char* name, bool val);

// Sets the uniform to an int32 value
void st3d_shader_set_int32(St3dShader shader, const char* name, int32_t val);

// Sets the uniform to a float value
void st3d_shader_set_float(St3dShader shader, const char* name, float val);

// Sets the uniform to a vec2f value. Note that this converts doubles to floats because that's how
// OpenGL works.
void st3d_shader_set_vec2f(St3dShader shader, const char* name, TrVec2f val);

// Sets the uniform to a vec2i value. Note that this converts int64s to int32 because that's how
// OpenGL works.
void st3d_shader_set_vec2i(St3dShader shader, const char* name, TrVec2i val);

// Sets the uniform to a vec3f value. Note that this converts doubles to floats because that's how
// OpenGL works.
void st3d_shader_set_vec3f(St3dShader shader, const char* name, TrVec3f val);

// Sets the uniform to a vec3i value. Note that this converts int64s to int32 because that's how
// OpenGL works.
void st3d_shader_set_vec3i(St3dShader shader, const char* name, TrVec3i val);

// Sets the uniform to a vec4f value. Note that this converts doubles to floats because that's how
// OpenGL works.
void st3d_shader_set_vec4f(St3dShader shader, const char* name, TrVec4f val);

// Sets the uniform to a vec4i value. Note that this converts int64s to int32 because that's how
// OpenGL works.
void st3d_shader_set_vec4i(St3dShader shader, const char* name, TrVec4i val);

// Sets the uniform to a 4x4 matrix value. Takes in a float array because I don't know anymore.
void st3d_shader_set_mat4f(St3dShader shader, const char* name, float* val);

// Image on the GPU and stuff.
typedef struct {
	uint32_t id;
	uint32_t width;
	uint32_t height;
} St3dTexture;

// Loads a texture from a path
St3dTexture st3d_texture_new(const char* path);

// Frees the texture
void st3d_texture_free(St3dTexture texture);

// Camera.
typedef struct {
	TrVec3f position;
	// In euler degrees
	TrVec3f rotation;
	// In degrees
	float fov;
	// How near can you see before it gets clipped out
	float near;
	// How far can you see before it gets clipped out
	float far;
} St3dCamera;

// Returns the current camera
St3dCamera st3d_camera(void);

// Sets the current camera
void st3d_set_camera(St3dCamera cam);

// M<esh
typedef struct {
	uint32_t vao;
	uint32_t vbo;
	uint32_t ebo;
	// How many indices the mesh has
	int32_t index_count;
	// The texture of the mesh, if any
	St3dTexture texture;
} St3dMesh;

// Uploads a mesh to the GPU. `readonly` is intended for meshes that change. You should usually
// leave it false.
St3dMesh st3d_mesh_new(TrSlice_float* vertices, TrSlice_uint32* indices, bool readonly);

// It frees the mesh.
void st3d_mesh_free(St3dMesh mesh);

// Draws a mesh with a transform thingy.
void st3d_mesh_draw_transform(St3dMesh mesh, float* transform);

// Draws a mesh in 2D using an orthographic projection.
void st3d_mesh_draw_2d(St3dMesh mesh, TrVec2f pos);

// Draws a mesh in the 3D world using an orthographic projection. Rotation is in euler degrees.
void st3d_mesh_draw_3d(St3dMesh mesh, TrVec3f pos, TrVec3f rot);

#ifdef __cplusplus
}
#endif

#endif // _ST3D_RENDER_H
