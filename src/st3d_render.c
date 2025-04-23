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
static St3dCamera st3d_cam;
static St3dEnvironment st3d_env;

void st3di_init_render(void)
{
	gladLoadGL(glfwGetProcAddress);

	// opengl? i hardly know el
	tr_liblog("- GL vendor: %s", glGetString(GL_VENDOR));
	tr_liblog("- GL renderer: %s", glGetString(GL_RENDERER));
	tr_liblog("- GL version: %s", glGetString(GL_VERSION));
	tr_liblog("- GLSL version: %s", glGetString(GL_SHADING_LANGUAGE_VERSION));

	const char* verticesrc = ST3D_DEFAULT_VERTEX_SHADER;
	const char* fragsrc = ST3D_DEFAULT_FRAGMENT_SHADER;
	st3d_default_shader = st3d_shader_new(verticesrc, fragsrc);

	// we're not australian
	// get it get it get it get it
	stbi_set_flip_vertically_on_load(true);
}

void st3di_free_render(void)
{
	st3d_shader_free(st3d_default_shader);
}

void st3d_begin_drawing(void)
{
	glClearColor(st3d_env.sky_color.r / 255.0f, st3d_env.sky_color.g / 255.0f,
		st3d_env.sky_color.b / 255.0f, st3d_env.sky_color.a / 255.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	st3d_shader_use(st3d_default_shader);

	// we set these here because nuklear changes the state and then resets everything
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, 0);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LESS);
	glEnable(GL_CULL_FACE);
	glCullFace(GL_FRONT);
}

void st3d_end_drawing(void)
{
	glfwSwapBuffers(st3d_get_window_handle());
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
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)0);
	glEnableVertexAttribArray(0);
	// normals attribute
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(3 * sizeof(float)));
	glEnableVertexAttribArray(1);
	// texcoords attribute
	glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(5 * sizeof(float)));
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
	tr_liblog("freed mesh (vao %u)", mesh.vao);
}

void st3d_mesh_draw_transform(St3dMesh mesh, float* model, float* view, float* proj)
{
	// help.
	st3d_shader_set_mat4f(st3d_default_shader, "u_model", model);
	st3d_shader_set_mat4f(st3d_default_shader, "u_view", view);
	st3d_shader_set_mat4f(st3d_default_shader, "u_proj", proj);
	st3d_shader_set_bool(st3d_default_shader, "u_has_texture", mesh.texture.id != 0);
	st3d_shader_set_vec3f(st3d_default_shader, "u_sun_color",
		(TrVec3f){st3d_env.sun.color.r / 255.0f, st3d_env.sun.color.g / 255.0f,
		st3d_env.sun.color.b / 255.0f});
	st3d_shader_set_vec3f(st3d_default_shader, "u_ambient",
		(TrVec3f){st3d_env.ambient_color.r / 255.0f, st3d_env.ambient_color.g / 255.0f,
		st3d_env.ambient_color.b / 255.0f});
	st3d_shader_set_vec4f(st3d_default_shader, "u_obj_color",
		(TrVec4f){mesh.material.color.r / 255.0f, mesh.material.color.g / 255.0f,
		mesh.material.color.b / 255.0f, mesh.material.color.a / 255.0f});
	st3d_shader_set_vec3f(st3d_default_shader, "u_sun_dir", st3d_env.sun.direction);

	// 0 means no texture
	// because i didn't want to use a pointer just to have null
	if (mesh.texture.id != 0) {
		glBindTexture(GL_TEXTURE_2D, mesh.texture.id);
	}
	else {
		glBindTexture(GL_TEXTURE_2D, 0);
	}

	glBindVertexArray(mesh.vao);
	if (st3d_wireframe) {
		glDrawElements(GL_LINE_LOOP, mesh.index_count, GL_UNSIGNED_INT, 0);
	}
	else {
		glDrawElements(GL_TRIANGLES, mesh.index_count, GL_UNSIGNED_INT, 0);
	}
	// unbind vao
	glBindVertexArray(0);
}

void st3d_mesh_draw_3d(St3dMesh mesh, TrVec3f pos, TrVec3f rot)
{
	mat4x4 model, view, proj;

	// perspective
	if (st3d_cam.perspective) {
		mat4x4_identity(model);
		mat4x4_translate(model, pos.x, pos.y, pos.z);

		mat4x4_rotate_X(model, model, tr_deg2rad(rot.x));
		mat4x4_rotate_Y(model, model, tr_deg2rad(rot.y));
		mat4x4_rotate_Z(model, model, tr_deg2rad(rot.z));

		mat4x4 view_pos, view_rot;
		mat4x4_identity(view_pos);
		mat4x4_identity(view_rot);
		mat4x4_translate(view_pos, -st3d_cam.position.x, -st3d_cam.position.y, -st3d_cam.position.z);

		mat4x4_rotate_X(view_rot, view_rot, tr_deg2rad(st3d_cam.rotation.x));
		mat4x4_rotate_Y(view_rot, view_rot, tr_deg2rad(st3d_cam.rotation.y));
		mat4x4_rotate_Z(view_rot, view_rot, tr_deg2rad(st3d_cam.rotation.z));

		mat4x4_mul(view, view_rot, view_pos);

		TrVec2i winsize = st3d_window_size();
		mat4x4_perspective(proj, tr_deg2rad(st3d_cam.view), (double)winsize.x / winsize.y,
			st3d_cam.near, st3d_cam.far);
	}
	// orthographic
	else {
		mat4x4_identity(model);
		// ???????
		mat4x4_translate_in_place(model, pos.x, -pos.y, pos.z);

		mat4x4_rotate_X(model, model, tr_deg2rad(rot.x));
		mat4x4_rotate_Y(model, model, tr_deg2rad(rot.y));
		mat4x4_rotate_Z(model, model, tr_deg2rad(rot.z));

		mat4x4 view_pos, view_rot;
		mat4x4_identity(view_pos);
		mat4x4_identity(view_rot);
		mat4x4_translate(view_pos, -st3d_cam.position.x, st3d_cam.position.y, -st3d_cam.position.z);

		mat4x4_rotate_X(view_rot, view_rot, tr_deg2rad(st3d_cam.rotation.x));
		mat4x4_rotate_Y(view_rot, view_rot, tr_deg2rad(st3d_cam.rotation.y));
		mat4x4_rotate_Z(view_rot, view_rot, tr_deg2rad(st3d_cam.rotation.z));

		mat4x4_mul(view, view_pos, view_rot);

		TrVec2i winsize = st3d_window_size();
		double ortho_height = st3d_cam.view * ((double)winsize.y / winsize.x);

		double left = -st3d_cam.view / 2.0;
		double right = st3d_cam.view / 2.0;
		double bottom = -ortho_height / 2.0;
		double top = ortho_height / 2.0;

		mat4x4_ortho(proj, left, right, top, bottom, st3d_cam.near, st3d_cam.far);
	}

	st3d_mesh_draw_transform(mesh, (float*)model, (float*)view, (float*)proj);
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

void st3d_shader_set_mat4f(St3dShader shader, const char* name, float* val)
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
	// path.
	TrArena tmp = tr_arena_new(ST3D_PATH_SIZE);
	TrString sitrnmvhz = tr_slice_new(&tmp, ST3D_PATH_SIZE, sizeof(char));
	st3d_path(path, &sitrnmvhz);

	// TODO no need to load textures multiple times, put it in a cache
	int32_t width, height, channels;
	uint8_t* data = stbi_load(sitrnmvhz.buffer, &width, &height, &channels, 0);
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
	glGenTextures(1, &texture.id);
	glBindTexture(GL_TEXTURE_2D, texture.id);
	glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
	glGenerateMipmap(GL_TEXTURE_2D);

	stbi_image_free(data);
	tr_arena_free(&tmp);
	tr_liblog("loaded texture from %s (id %u)", path, texture.id);
	return texture;
}

void st3d_texture_free(St3dTexture texture)
{
	glDeleteTextures(1, &texture.id);
	tr_liblog("freed texture (id %u)", texture.id);
}

St3dCamera st3d_camera(void)
{
	return st3d_cam;
}

void st3d_set_camera(St3dCamera cam)
{
	st3d_cam = cam;
}

St3dEnvironment st3d_environment(void)
{
	return st3d_env;
}

void st3d_set_environment(St3dEnvironment env)
{
	st3d_env = env;
}
