#define GLAD_GL_IMPLEMENTATION
#include <glad/gl.h>
#include <GLFW/glfw3.h>
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
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), NULL);
	glEnableVertexAttribArray(0);
	// color attribute
	glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3 * sizeof(float)));
	glEnableVertexAttribArray(1);

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

void st3d_mesh_draw(St3dMesh mesh)
{
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

void st3d_set_wireframe(bool wireframe)
{
	// i would use glPolygonMode but it just doesn't work??
	// it's actually used in st3d_mesh_draw
	st3d_wireframe = wireframe;
}
