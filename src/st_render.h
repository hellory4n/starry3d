/*
 * Starry3D: C voxel game engine
 * More information at https://github.com/hellory4n/starry3d
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

#ifndef _ST_RENDER_H
#define _ST_RENDER_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

#define ST_2D_LEFT 0
#define ST_2D_RIGHT 1280
#define ST_2D_TOP 0
#define ST_2D_BOTTOM 720

// Initializes the renderer duh.
void st_render_init(void);

// Frees the renderer duh.
void st_render_free(void);

// Begins drawing and clears the screen
void st_begin_drawing(void);

// Does some fuckery that ends drawing.
void st_end_drawing(void);

// If true, everything is rendered in wireframe mode, which shows a bunch of lines instead of the
// actual 3D objects.
void st_set_wireframe(bool wireframe);

// Image on the GPU and stuff.
typedef struct {
	uint32_t id;
	uint32_t width;
	uint32_t height;
} StTexture;

// Loads a texture from a path
StTexture st_texture_new(const char* path);

// Frees the texture
void st_texture_free(StTexture texture);

// Camera.
typedef struct {
	TrVec3f position;
	// In euler degrees
	TrVec3f rotation;
	// On perspective, this is the FOV in degrees. On orthographic, this is the width, which does something.
	float view;
	// How near can you see before it gets clipped out
	float near;
	// How far can you see before it gets clipped out
	float far;
	// If true, the camera is perspective. Else, it's orthographic.
	bool perspective;
} StCamera;

// Returns the current camera
StCamera st_camera(void);

// Sets the current camera
void st_set_camera(StCamera cam);

// Sets global lighting settings.
typedef struct {
	// This is actually just the clear color because I'm lazy.
	TrColor sky_color;
	// Even if it's dark there's still some light somewhere. That is not life advice.
	TrColor ambient_color;

	// this is how you get clangd to accept my documentation comments??
	struct {
		TrColor color;
		// As the name implies, it's the direction of the sun. Should be normalized (-1 to 1)
		TrVec3f direction;
	}
	// As the sun hits, she'll be waiting, with her cool things, and her heaven, hey hey lover,
	// you still burn me, you're a song yeah, hey hey.
	sun;
} StEnvironment;

// Returns the current environment
StEnvironment st_environment(void);

// Sets the current environment
void st_set_environment(StEnvironment env);

// M<esh
typedef struct {
	uint32_t vao;
	uint32_t vbo;
	uint32_t ebo;
	// How many indices the mesh has
	int32_t index_count;
	// The texture of the mesh, if any
	StTexture texture;

	struct {
		TrColor color;
	} material;
} StMesh;

// Uploads a mesh to the GPU. `readonly` is intended for meshes that change. You should usually
// leave it false. The format for vertices is XYZXYZUV, for the position (3 floats), normals
// (3 floats), and texcoords (2 floats), where each letter is a float.
StMesh st_mesh_new(TrSlice_float* vertices, TrSlice_uint32* indices, bool readonly);

// It frees the mesh.
void st_mesh_free(StMesh mesh);

// Draws a mesh with a transform thingy. There's 3 matrices because the final translation
// faffery is handled in the shader.
void st_mesh_draw_transform(StMesh mesh, float* model, float* view, float* proj);

// Draws a mesh in the 3D world using whatever camera you set. Rotation is in euler degrees.
void st_mesh_draw_3d(StMesh mesh, TrVec3f pos, TrVec3f rot);

// As the name implies, it converts screen positions to world positions.
TrVec3f st_screen_to_world_pos(TrVec2f pos);

// Shade deez nuts.
typedef struct {
	uint32_t program;
} StShader;

// Compiles a shader. The arguments are for the source code of the shaders.
StShader st_shader_new(const char* vert, const char* frag);

// Frees the shader.
void st_shader_free(StShader shader);

// Starts using a shader. To go back to the default one, use `st_shader_stop_using`
void st_shader_use(StShader shader);

// Goes back to the default shader.
void st_shader_stop_using(void);

// Sets the uniform to a bool value
void st_shader_set_bool(StShader shader, const char* name, bool val);

// Sets the uniform to an int32 value
void st_shader_set_int32(StShader shader, const char* name, int32_t val);

// Sets the uniform to a float value
void st_shader_set_float(StShader shader, const char* name, float val);

// Sets the uniform to a vec2f value. Note that this converts doubles to floats because that's how
// OpenGL works.
void st_shader_set_vec2f(StShader shader, const char* name, TrVec2f val);

// Sets the uniform to a vec2i value. Note that this converts int64s to int32 because that's how
// OpenGL works.
void st_shader_set_vec2i(StShader shader, const char* name, TrVec2i val);

// Sets the uniform to a vec3f value. Note that this converts doubles to floats because that's how
// OpenGL works.
void st_shader_set_vec3f(StShader shader, const char* name, TrVec3f val);

// Sets the uniform to a vec3i value. Note that this converts int64s to int32 because that's how
// OpenGL works.
void st_shader_set_vec3i(StShader shader, const char* name, TrVec3i val);

// Sets the uniform to a vec4f value. Note that this converts doubles to floats because that's how
// OpenGL works.
void st_shader_set_vec4f(StShader shader, const char* name, TrVec4f val);

// Sets the uniform to a vec4i value. Note that this converts int64s to int32 because that's how
// OpenGL works.
void st_shader_set_vec4i(StShader shader, const char* name, TrVec4i val);

// Sets the uniform to a 4x4 matrix value. Takes in a float array because I don't know anymore.
void st_shader_set_mat4f(StShader shader, const char* name, float* val);

typedef enum {
	// No culling
	ST_CULL_FACE_NONE,
	ST_CULL_FACE_BACK,
	ST_CULL_FACE_FRONT,
	// Both front and back faces
	ST_CULL_FACE_FRONT_BACK,
} StCullFace;

// Sets the culling face and enables/disables culling. (`ST_CULL_FACE_NONE` disables culling)
void st_cull_face(StCullFace face);

typedef enum {
	ST_FRONT_FACE_CLOCKWISE,
	ST_FRONT_FACE_COUNTER_CLOCKWISE,
} StFrontFace;

// Sets the front face for culling.
void st_front_face(StFrontFace mode);

#ifdef __cplusplus
}
#endif

#endif // _ST_RENDER_H
