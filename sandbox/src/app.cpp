#include "app.h"

#include <trippin/common.h>
#include <trippin/log.h>
#include <trippin/math.h>
#include <trippin/memory.h>

#include <starry/app.h>
#include <starry/gpu.h>
#include <starry/shader/basic.glsl.h>
#include <starry/world.h>

#include "debug_mode.h"
#include "world.h"

struct Vertex
{
	tr::Vec3<float32> position;
	tr::Vec4<float32> color;
};

tr::Result<void> sbox::Sandbox::init()
{
	st::Camera& cam = st::Camera::current();
	cam.position = {0, 0, 1};
	cam.rotation = {0, 180, 0};
	cam.fov = 90;
	cam.projection = st::CameraProjection::PERSPECTIVE;
	st::set_mouse_enabled(_ui_enabled);

	auto vert_shader = st::VertexShader(ST_BASIC_SHADER_VERTEX);
	auto frag_shader = st::FragmentShader(ST_BASIC_SHADER_FRAGMENT);
	TR_DEFER(vert_shader.free());
	TR_DEFER(frag_shader.free());

	program = st::ShaderProgram();
	program.unwrap().attach(vert_shader);
	program.unwrap().attach(frag_shader);
	program.unwrap().link();
	program.unwrap().use();
	program.unwrap().set_uniform("u_model", tr::Matrix4x4::identity());
	program.unwrap().set_uniform("u_view", tr::Matrix4x4::identity());
	program.unwrap().set_uniform("u_projection", tr::Matrix4x4::identity());

	tr::Array<st::VertexAttribute> attrs = {
		{"position", st::VertexAttributeType::VEC3_FLOAT32, offsetof(Vertex, position)},
		{"color",    st::VertexAttributeType::VEC4_FLOAT32, offsetof(Vertex, color)   },
	};

	tr::Array<Vertex> vertices = {
		{{-0.5, -0.5, 0.0}, tr::Color::rgb(0xff0000)},
		{{0.5, -0.5, 0.0},  tr::Color::rgb(0x00ff00)},
		{{0.0, 0.5, 0.0},   tr::Color::rgb(0x0000ff)},
	};

	tr::Array<st::Triangle> triangles = {
		{0, 1, 2},
	};

	mesh = st::Mesh(attrs, vertices, triangles, true);

	sbox::setup_world();

	tr::log("initialized sandbox :)");
	return {};
}

tr::Result<void> sbox::Sandbox::update(float64 dt)
{
	sbox::debug_mode();

	// hlep
	if (st::is_key_just_pressed(st::Key::ESCAPE)) {
		_ui_enabled = !_ui_enabled;
		st::set_mouse_enabled(_ui_enabled);
	}

	player_controller(dt);

	st::clear_screen(tr::Color::rgb(0x009ccf));
	program.unwrap().set_uniform("u_view", st::Camera::current().view_matrix());
	program.unwrap().set_uniform("u_projection", st::Camera::current().projection_matrix());
	mesh.unwrap().draw();
	return {};
}

tr::Result<void> sbox::Sandbox::free()
{
	program.unwrap().free();
	mesh.unwrap().free();

	tr::log("freed sandbox :)");
	return {};
}

void sbox::Sandbox::player_controller(float64 dt) const
{
	// TODO this doesn't work too! :D
	if (_ui_enabled) {
		return;
	}

	st::Camera& cam = st::Camera::current();
	tr::Vec2<float64> mouse = st::delta_mouse_position();
	cam.rotation.y += float32(mouse.x * MOUSE_SENSITIVITY);
	cam.rotation.x += float32(mouse.y * MOUSE_SENSITIVITY);
	// don't break your neck
	cam.rotation.x = tr::clamp(cam.rotation.x, -89.0f, 89.0f);
	tr::log("cam rotiation: %f, %f, %f", cam.rotation.x, cam.rotation.y, cam.rotation.z);
}
