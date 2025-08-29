#include "app.h"

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
	cam.fov = 90;
	cam.projection = st::CameraProjection::PERSPECTIVE;

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

	if (st::is_key_just_pressed(st::Key::SPACE)) {
		tr::warn("just pressed!");
	}
	if (st::is_key_just_released(st::Key::SPACE)) {
		tr::warn("just released!");
	}
	if (st::is_key_held(st::Key::SPACE)) {
		tr::warn("holding!");
	}

	// hlep
	// if (st::is_key_just_pressed(st::Key::ESCAPE)) {
	// 	_ui_enabled = !_ui_enabled;
	// 	st::set_mouse_enabled(_ui_enabled);
	// }

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
	if (_ui_enabled) {
		return;
	}

	// TODO we have a whole math library for this shit
	// so like, use it?
	// (this is stolen from the C starry3d)

	st::Camera& cam = st::Camera::current();
	tr::Vec2<float64> delta_mouse_pos = st::delta_mouse_position();

	cam.rotation.y += float32(delta_mouse_pos.x * MOUSE_SENSITIVITY);
	cam.rotation.x += float32(delta_mouse_pos.y * MOUSE_SENSITIVITY);
	// don't break your neck
	cam.rotation.x = tr::clamp(cam.rotation.x, -89.0f, 89.0f);

	tr::Vec3<float32> in = {};
	if (st::is_key_held(st::Key::W)) {
		in.z += 1;
	}
	if (st::is_key_held(st::Key::S)) {
		in.z -= 1;
	}
	if (st::is_key_held(st::Key::A)) {
		in.x -= 1;
	}
	if (st::is_key_held(st::Key::D)) {
		in.x += 1;
	}
	// TODO is this ass?
	if (st::is_key_held(st::Key::SPACE)) {
		in.y += 1;
	}
	if (st::is_key_held(st::Key::LEFT_SHIFT)) {
		in.y -= 1;
	}

	float32 yaw = tr::deg2rad(cam.rotation.y);
	tr::Vec3<float32> forward = {sinf(yaw), 0, -cosf(yaw)};
	tr::Vec3<float32> right = {cosf(yaw), 0, sinf(yaw)};

	float32 len_xz = sqrtf(in.x * in.x + in.z * in.z);
	if (len_xz > 0.0001f) {
		in.x /= len_xz;
		in.z /= len_xz;
	}

	tr::Vec3<float32> move = {
		right.x * in.x + forward.x * in.z, in.y, right.z * in.x + forward.z * in.z
	};
	// TODO did i fuck it?
	cam.position += -(move * PLAYER_SPEED * float32(dt));
	cam.rotation.z = 0; // just in case
}
