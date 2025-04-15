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
	// disabled bcuz it gets unflipped in the transformations apparently
	// stbi_set_flip_vertically_on_load(true);

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
	tr_liblog("freed mesh (vao %u)", mesh.vao);
}

void st3d_mesh_draw_transform(St3dMesh mesh, float* transform)
{
	// help.
	st3d_shader_set_mat4f(st3d_default_shader, "u_mvp", transform);

	// 0 means no texture
	// because i didn't want to use a pointer just to have null
	if (mesh.texture.id != 0) {
		glBindTexture(GL_TEXTURE_2D, mesh.texture.id);
	}
	else {
		// i love the state machine !!
		glBindTexture(GL_TEXTURE_2D, 0);
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

void st3d_mesh_draw_2d(St3dMesh mesh, TrVec2f pos)
{
	mat4x4 model;
	mat4x4_identity(model);
	mat4x4_translate(model, pos.x, pos.y, 0);

	mat4x4 proj;
	mat4x4_ortho(proj, ST3D_2D_LEFT, ST3D_2D_RIGHT, ST3D_2D_BOTTOM, ST3D_2D_TOP, 1.0f, -1.0f);

	mat4x4 mvp;
	mat4x4_identity(mvp);
	mat4x4_mul(mvp, proj, model);

	st3d_mesh_draw_transform(mesh, (float*)mvp);
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
