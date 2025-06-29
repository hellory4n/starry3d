#include <st_render.hpp>
#include <st_window.hpp>

#include "hello_triangle.hpp"
#include "shader/basic.glsl.hpp"

namespace sandbox {
	tr::Ref<st::Mesh> mesh;
	tr::Ref<st::ShaderProgram> shader;
	tr::Ref<st::Texture> texture;

	tr::Vec3<float64> position;
	tr::Vec3<float64> rotation;
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
		{"uv",       st::VertexAttributeType::VEC2_FLOAT32, offsetof(sandbox::Vertex, uv)}
	};
	tr::Array<st::VertexAttribute> format(format_arr, sizeof(format_arr) / sizeof(st::VertexAttribute));

	Vertex vertices_arr[] = {
		{{-0.5, -0.5, 0.0}, tr::Color::rgb(0xff0000), {-1, -1}},
		{{ 0.5, -0.5, 0.0}, tr::Color::rgb(0x00ff00), {1, -1}},
		{{ 0.0,  0.5, 0.0}, tr::Color::rgb(0x0000ff), {0.5, 1}},
	};
	tr::Array<Vertex> vertices(vertices_arr, sizeof(vertices_arr) / sizeof(Vertex));

	st::Triangle indices_arr[] = {
		{0, 1, 2},
	};
	tr::Array<st::Triangle> indices(indices_arr, sizeof(indices_arr) / sizeof(st::Triangle));

	sandbox::mesh = new st::Mesh(format, vertices, indices, false);

	sandbox::texture = new st::Texture("app://enough_fckery.jpg");
	sandbox::mesh->set_texture(sandbox::texture);
}

void sandbox::render_triangle()
{
	float64 dt = st::delta_time();

	if (st::is_key_held(st::Key::LEFT))  sandbox::position.x -= 1 * dt;
	if (st::is_key_held(st::Key::RIGHT)) sandbox::position.x += 1 * dt;
	if (st::is_key_held(st::Key::UP))    sandbox::position.z += 1 * dt;
	if (st::is_key_held(st::Key::DOWN))  sandbox::position.z -= 1 * dt;

	sandbox::mesh->draw(sandbox::position, sandbox::rotation);
}
