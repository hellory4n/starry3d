#include <st_render.hpp>

#include "hello_triangle.hpp"
#include "shader/basic.glsl.hpp"

namespace sandbox {
	tr::Ref<st::Mesh> mesh;
	tr::Ref<st::ShaderProgram> shader;
}

void sandbox::init_triangle()
{
	// shader crap
	tr::Ref<st::VertexShader> vert_shader = new st::VertexShader(st::BASIC_SHADER_VERTEX);
	tr::Ref<st::FragmentShader> frag_shader = new st::FragmentShader(st::BASIC_SHADER_FRAGMENT);

	sandbox::shader = new st::ShaderProgram();
	sandbox::shader->attach(vert_shader.get());
	sandbox::shader->attach(frag_shader.get());
	sandbox::shader->link();
	sandbox::shader->use();

	// mesh crap
	st::VertexAttribute format_arr[] = {
		{"position", st::VertexAttributeType::VEC3_FLOAT32, offsetof(sandbox::Vertex, position)},
		{"color",    st::VertexAttributeType::VEC4_FLOAT32, offsetof(sandbox::Vertex, color)},
	};
	tr::Array<st::VertexAttribute> format(format_arr, sizeof(format_arr) / sizeof(st::VertexAttribute));

	Vertex vertices_arr[] = {
		{{0.5, -0.5, 0.0}, tr::Color::rgb(0xff0000).to_vec4()},
		{{-0.5, 0.5, 0.0}, tr::Color::rgb(0x00ff00).to_vec4()},
		{{ 0.5, 0.5, 0.0}, tr::Color::rgb(0x0000ff).to_vec4()},
	};
	tr::Array<Vertex> vertices(vertices_arr, sizeof(vertices_arr) / sizeof(Vertex));

	st::Triangle indices_arr[] = {
		{0, 1, 2},
	};
	tr::Array<st::Triangle> indices(indices_arr, sizeof(indices_arr) / sizeof(st::Triangle));

	sandbox::mesh = new st::Mesh(format, vertices, indices, false);
	mesh->retain();
	shader->retain();
}

void sandbox::render_triangle()
{
	sandbox::mesh->draw(tr::Matrix4x4::identity(), tr::Matrix4x4::identity(),
		tr::Matrix4x4::identity());
}
