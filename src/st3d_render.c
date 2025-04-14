#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>
#include <GLFW/glfw3.h>
#define STB_IMAGE_IMPLEMENTATION
#include <stb_image.h>
#include <linmath.h>
#include <libtrippin.h>
#include "st3d.h"
#include "st3d_render.h"

static St3dShader st3d_default_shader;
static bool st3d_wireframe;

static TrVec3f st3d_cam_pos;
static TrRotation st3d_cam_rot;
static float st3d_cam_fov;
// x is near, y is far
static TrVec2f st3d_cam_nearfar;

void st3di_init_render(void)
{
	gladLoadGL(glfwGetProcAddress);

	// opengl? i hardly know el
	tr_liblog("- GL vendor: %s", glGetString(GL_VENDOR));
	tr_liblog("- GL renderer: %s", glGetString(GL_RENDERER));
	tr_liblog("- GL version: %s", glGetString(GL_VERSION));
	tr_liblog("- GLSL version: %s", glGetString(GL_SHADING_LANGUAGE_VERSION));

	const char* vertsrc = ST3D_DEFAULT_VERTEX_SHADER;
	const char* fragsrc = ST3D_DEFAULT_FRAGMENT_SHADER;
	st3d_default_shader = st3d_shader_new(vertsrc, fragsrc);

	// we're not australian
	// get it get it get it get it
	stbi_set_flip_vertically_on_load(true);

	// transparency
	// TODO being able to set the blending modes would be cool
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void st3di_free_render(void)
{
	st3d_shader_free(st3d_default_shader);
}

void st3d_begin_drawing(TrColor clear_color)
{
	glClearColor(clear_color.r / 255.0f, clear_color.g / 255.0f,
		clear_color.b / 255.0f, clear_color.a / 255.0f);
	glClear(GL_COLOR_BUFFER_BIT);

	st3d_shader_use(st3d_default_shader);
}

void st3d_end_drawing(void)
{
	glfwSwapBuffers(st3d_get_window_handle());
}

void st3d_set_camera_position(TrVec3f pos)
{
	st3d_cam_pos = pos;
}

void st3d_set_camera_rotation(TrRotation rot)
{
	st3d_cam_rot = rot;
}

void st3d_set_camera_fov(float fov)
{
	st3d_cam_fov = fov;
}

void st3d_set_camera_near_far(float near, float far)
{
	st3d_cam_nearfar = (TrVec2f){near, far};
}

St3dMesh st3d_mesh_new(TrSlice_float* vertices, TrSlice_uint32* indices, bool readonly)
{
	St3dMesh mesh = {0};
	mesh.index_count = indices->length;

	glGenVertexArrays(1, &mesh.vao);
	glBindVertexArray(mesh.vao);

	// vbo
	glGenBuffers(1, &mesh.vbo);
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo);

	glBufferData(GL_ARRAY_BUFFER, vertices->length * sizeof(float),
		vertices->buffer, readonly ? GL_STATIC_DRAW : GL_DYNAMIC_DRAW);

	// position attribute
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 9 * sizeof(float), (void*)0);
	glEnableVertexAttribArray(0);
	// color attribute
	glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, 9 * sizeof(float), (void*)(3 * sizeof(float)));
	glEnableVertexAttribArray(1);
	// texcoords attribute
	glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 9 * sizeof(float), (void*)(7 * sizeof(float)));
	glEnableVertexAttribArray(2);

	// ebo
	glGenBuffers(1, &mesh.ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo);
	if (readonly) {
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices->length * sizeof(uint32_t), indices->buffer, GL_STATIC_DRAW);
	}
	else {
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices->length * sizeof(uint32_t), indices->buffer, GL_DYNAMIC_DRAW);
	}

	// unbind vao
	glBindVertexArray(0);

	tr_liblog("uploaded mesh (vao %u, vbo %u, ebo %u)", mesh.vao, mesh.vbo, mesh.ebo);
	return mesh;
}

void st3d_mesh_free(St3dMesh mesh)
{
	glDeleteVertexArrays(1, &mesh.vao);
	glDeleteBuffers(1, &mesh.vbo);
	glDeleteBuffers(1, &mesh.ebo);
	tr_liblog("freed mesh (vao %u)", mesh.vao);
}

void st3d_mesh_draw(St3dMesh mesh, TrVec3f pos, TrRotation rot)
{
	// world space
	mat4x4 translation;
	mat4x4_identity(translation);
	mat4x4_translate(translation, pos.x, pos.y, pos.z);

	// rotation
	mat4x4 rx, ry, rz, rotation;
	mat4x4_identity(rx);
	mat4x4_identity(ry);
	mat4x4_identity(rz);

	mat4x4_rotate_X(rx, rx, rot.x);
	mat4x4_rotate_Y(ry, ry, rot.y);
	mat4x4_rotate_Z(rz, rz, rot.z);

	mat4x4 tmp1;
	mat4x4_mul(tmp1, ry, rx);
	mat4x4_mul(rotation, rz, tmp1);

	// combine translation and rotation
	mat4x4 model;
	mat4x4_mul(translation, translation, rotation);

	// camera
	mat4x4 view;
	mat4x4_identity(view);
	// TODO maybe i have to negate that?
	mat4x4_translate(view, st3d_cam_pos.x, st3d_cam_pos.y, st3d_cam_pos.z);

	mat4x4 view_rx, view_ry, view_rz, view_rot;
	mat4x4_identity(view_rx);
	mat4x4_identity(view_ry);
	mat4x4_identity(view_rz);

	mat4x4_rotate_X(view_rx, view_rx, tr_deg2rad(st3d_cam_rot.x));
	mat4x4_rotate_Y(view_ry, view_ry, tr_deg2rad(st3d_cam_rot.y));
	mat4x4_rotate_Z(view_rz, view_rz, tr_deg2rad(st3d_cam_rot.z));

	mat4x4 tmp2;
	mat4x4_mul(tmp2, view_ry, view_rx);
	mat4x4_mul(view_rot, view_rz, tmp2);

	// project deez
	TrVec2i winsize = st3d_window_size();
	mat4x4 projection;
	mat4x4_perspective(projection, st3d_cam_fov, (float)winsize.x / winsize.y, st3d_cam_nearfar.x,
		st3d_cam_nearfar.y);

	// actually render
	st3d_shader_set_mat4x4f(st3d_default_shader, "model", (float*)model);
	st3d_shader_set_mat4x4f(st3d_default_shader, "view", (float*)view);
	st3d_shader_set_mat4x4f(st3d_default_shader, "projection", (float*)projection);

	// 0 means no texture
	// because i didn't want to use a pointer just to have null
	if (mesh.texture.id != 0) {
		// doing this glActiveTexture crap is required on some drivers i think
		glActiveTexture(GL_TEXTURE0);
		glBindTexture(GL_TEXTURE_2D, mesh.texture.id);
	}

	glBindVertexArray(mesh.vao);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo);
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo);
	if (st3d_wireframe) {
		glDrawElements(GL_LINE_LOOP, mesh.index_count, GL_UNSIGNED_INT, 0);
	}
	else {
		glDrawElements(GL_TRIANGLES, mesh.index_count, GL_UNSIGNED_INT, 0);
	}
	// unbind vao
	glBindVertexArray(0);
}

static void check_shader(uint32_t obj)
{
	int32_t success;
	glGetShaderiv(obj, GL_COMPILE_STATUS, &success);
	if (!success) {
		char infolog[512];
		glGetShaderInfoLog(obj, 512, NULL, infolog);
		tr_panic("shader compilation error: %s", infolog);
	}
}

St3dShader st3d_shader_new(const char* vert, const char* frag)
{
	St3dShader shader = {0};

	uint32_t vert_shader = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vert_shader, 1, &vert, NULL);
	glCompileShader(vert_shader);
	check_shader(vert_shader);

	uint32_t frag_shader = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(frag_shader, 1, &frag, NULL);
	glCompileShader(frag_shader);
	check_shader(frag_shader);

	shader.program = glCreateProgram();
	glAttachShader(shader.program, vert_shader);
	glAttachShader(shader.program, frag_shader);
	glLinkProgram(shader.program);

	// check for linking
	int32_t success;
	glGetProgramiv(shader.program, GL_LINK_STATUS, &success);
	if (!success) {
		char infolog[512];
		glGetProgramInfoLog(shader.program, 512, NULL, infolog);
		tr_panic("shader linking error: %s", infolog);
	}

	// we don't need them anymore
	// we already linked
	glDeleteShader(vert_shader);
	glDeleteShader(frag_shader);

	tr_liblog("compiled and linked shader (id %u)", shader.program);
	return shader;
}

void st3d_shader_free(St3dShader shader)
{
	glDeleteProgram(shader.program);
	tr_liblog("deleted shader (id %u)", shader.program);
}

void st3d_shader_use(St3dShader shader)
{
	glUseProgram(shader.program);
}

void st3d_shader_set_bool(St3dShader shader, const char* name, bool val)
{
	glUniform1i(glGetUniformLocation(shader.program, name), (int32_t)val);
}

void st3d_shader_set_int32(St3dShader shader, const char* name, int32_t val)
{
	glUniform1i(glGetUniformLocation(shader.program, name), val);
}

void st3d_shader_set_float(St3dShader shader, const char* name, float val)
{
	glUniform1f(glGetUniformLocation(shader.program, name), val);
}

void st3d_shader_set_vec2f(St3dShader shader, const char* name, TrVec2f val)
{
	glUniform2f(glGetUniformLocation(shader.program, name), val.x, val.y);
}

void st3d_shader_set_vec2i(St3dShader shader, const char* name, TrVec2i val)
{
	glUniform2i(glGetUniformLocation(shader.program, name), val.x, val.y);
}

void st3d_shader_set_vec3f(St3dShader shader, const char* name, TrVec3f val)
{
	glUniform3f(glGetUniformLocation(shader.program, name), val.x, val.y, val.z);
}

void st3d_shader_set_vec3i(St3dShader shader, const char* name, TrVec3i val)
{
	glUniform3f(glGetUniformLocation(shader.program, name), val.x, val.y, val.z);
}

void st3d_shader_set_vec4f(St3dShader shader, const char* name, TrVec4f val)
{
	glUniform4f(glGetUniformLocation(shader.program, name), val.x, val.y, val.z, val.w);
}

void st3d_shader_set_vec4i(St3dShader shader, const char* name, TrVec4i val)
{
	glUniform4i(glGetUniformLocation(shader.program, name), val.x, val.y, val.z, val.w);
}

void st3d_shader_set_mat4x4f(St3dShader shader, const char* name, float* val)
{
	glUniformMatrix4fv(glGetUniformLocation(shader.program, name), 1, false, val);
}

void st3d_set_wireframe(bool wireframe)
{
	// i would use glPolygonMode but it just doesn't work??
	// it's actually used in st3d_mesh_draw
	st3d_wireframe = wireframe;
}

St3dTexture st3d_texture_new(const char* path)
{
	// TODO no need to load textures multiple times, put it in a cache
	int32_t width, height, channels;
	uint8_t* data = stbi_load(path, &width, &height, &channels, 0);
	if (data == NULL) {
		tr_panic("couldn't load image");
	}

	// TODO there's no way this is correct but i can't be bothered to check
	GLenum format;
	switch (channels) {
		case 1: format = GL_R;    break;
		case 2: format = GL_RG;   break;
		case 3: format = GL_RGB;  break;
		case 4: format = GL_RGBA; break;
	}

	// help
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	St3dTexture texture = {
		.width = width,
		.height = height,
	};
	glGenBuffers(1, &texture.id);
	glBindTexture(GL_TEXTURE_2D, texture.id);
	glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
	glGenerateMipmap(GL_TEXTURE_2D);

	stbi_image_free(data);
	tr_liblog("loaded texture from %s (id %u)", path, texture.id);
	return texture;
}

void st3d_texture_free(St3dTexture texture)
{
	glDeleteTextures(1, &texture.id);
	tr_liblog("freed texture (id %u)", texture.id);
}
