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
#include "starry/render.h"
#include "world.h"

struct Vertex
{
	tr::Vec3<float32> position;
	tr::Vec2<float32> texcoords;
};

tr::Result<void> sbox::Sandbox::init()
{
	st::Camera& cam = st::Camera::current();
	cam.position = {0, 0, 1};
	cam.fov = 90;
	cam.projection = st::CameraProjection::PERSPECTIVE;
	st::set_mouse_enabled(_ui_enabled);

	auto vert_shader = st::VertexShader(ST_BASIC_SHADER_VERTEX);
	auto frag_shader = st::FragmentShader(ST_BASIC_SHADER_FRAGMENT);
	TR_DEFER(vert_shader.free());
	TR_DEFER(frag_shader.free());

	program = st::ShaderProgram();
	program.attach(vert_shader);
	program.attach(frag_shader);
	program.link();
	program.use();
	program.set_uniform("u_model", tr::Matrix4x4::identity());
	program.set_uniform("u_view", tr::Matrix4x4::identity());
	program.set_uniform("u_projection", tr::Matrix4x4::identity());

	tr::Array<st::VertexAttribute> attrs = {
		{"position",  st::VertexAttributeType::VEC3_FLOAT32, offsetof(Vertex, position) },
		{"texcoords", st::VertexAttributeType::VEC2_FLOAT32, offsetof(Vertex, texcoords)},
	};

	tr::Array<Vertex> vertices = {
		{{-0.5, -0.5, 0.0}, {0.5, 0.0}},
		{{0.5, -0.5, 0.0},  {1, 1}    },
		{{0.0, 0.5, 0.0},   {0, 1}    },
	};

	tr::Array<st::Triangle> triangles = {
		{2, 1, 0},
	};

	mesh = st::Mesh(attrs, vertices, triangles, true);

	st::Texture texture = st::Texture::load("app://enough_fckery.jpg").unwrap();
	texture.use();

	sbox::setup_world();

	tr::log("initialized sandbox :)");
	return {};
}

tr::Result<void> sbox::Sandbox::update(float64 dt)
{
	// hlep
	if (st::is_key_just_pressed(st::Key::ESCAPE)) {
		_ui_enabled = !_ui_enabled;
		st::set_mouse_enabled(_ui_enabled);
	}
	if (st::is_key_just_pressed(st::Key::F1)) {
		st::set_wireframe_mode(true);
	}

	player_controller(dt);

	return {};
}

tr::Result<void> sbox::Sandbox::draw()
{
	st::clear_screen(tr::Color::rgb(0x009ccf));
	program.set_uniform("u_view", st::Camera::current().view_matrix());
	program.set_uniform("u_projection", st::Camera::current().projection_matrix());
	mesh.draw();
	return {};
}

tr::Result<void> sbox::Sandbox::gui()
{
	sbox::debug_mode();
	return {};
}

tr::Result<void> sbox::Sandbox::free()
{
	program.free();
	mesh.free();
	arena.free();

	tr::log("freed sandbox :)");
	return {};
}

void sbox::Sandbox::player_controller(float64 dt) const
{
	if (_ui_enabled) {
		return;
	}

	st::Camera& cam = st::Camera::current();
	tr::Vec2<float64> mouse = st::delta_mouse_position();
	cam.rotation.y += float32(mouse.x * MOUSE_SENSITIVITY);
	cam.rotation.x += float32(mouse.y * MOUSE_SENSITIVITY);
	// don't break your neck
	cam.rotation.x = tr::clamp(cam.rotation.x, -89.0f, 89.0f);

	tr::Vec3<float32> move = {};
	if (st::is_key_held(st::Key::W)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y)) * 1, 0,
			 cosf(tr::deg2rad(cam.rotation.y)) * -1};
	}
	if (st::is_key_held(st::Key::S)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y)) * -1, 0,
			 cosf(tr::deg2rad(cam.rotation.y)) * 1};
	}
	if (st::is_key_held(st::Key::A)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y - 90)) * 1, 0,
			 cosf(tr::deg2rad(cam.rotation.y - 90)) * -1};
	}
	if (st::is_key_held(st::Key::D)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y - 90)) * -1, 0,
			 cosf(tr::deg2rad(cam.rotation.y - 90)) * 1};
	}
	if (st::is_key_held(st::Key::SPACE)) {
		move.y += 1;
	}
	if (st::is_key_held(st::Key::LEFT_SHIFT)) {
		move.y -= 1;
	}

	if (move.length() > 0.0f) {
		cam.position += move.normalize() * PLAYER_SPEED * float32(dt);
	}
}
