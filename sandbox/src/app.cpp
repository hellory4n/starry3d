#include "app.h"

#include <trippin/common.h>
#include <trippin/log.h>
#include <trippin/math.h>
#include <trippin/memory.h>

#include <starry/app.h>
#include <starry/render.h>

#include "debug_mode.h"
#include "starry/world.h"
#include "world.h"

sbox::Sandbox::Sandbox()
{
	st::Camera& cam = st::Camera::current();
	cam.position = {0, 0, 1};
	cam.fov = 90;
	cam.projection = st::CameraProjection::PERSPECTIVE;
	st::set_mouse_enabled(_ui_enabled);

	sbox::setup_world();
	sbox::imgui_theme();

	for (int32 x = 0; x < 200; x++) {
		for (int32 z = 0; z < 200; z++) {
			st::place_static_block({x, 0, z}, Model::GRASS);
		}
	}

	tr::log("initialized sandbox :)");
}

void sbox::Sandbox::update(float64 dt)
{
	// hlep
	if (st::is_key_just_pressed(st::Key::ESCAPE)) {
		_ui_enabled = !_ui_enabled;
		st::set_mouse_enabled(_ui_enabled);
	}
	static bool wireframe_mode = false;
	if (st::is_key_just_pressed(st::Key::F1)) {
		wireframe_mode = !wireframe_mode;
		st::set_wireframe_mode(wireframe_mode);
	}

	_player_controller(dt);
}

void sbox::Sandbox::draw() {}

void sbox::Sandbox::gui()
{
	sbox::debug_mode();
}

void sbox::Sandbox::free()
{
	tr::log("freed sandbox :)");
}

void sbox::Sandbox::_player_controller(float64 dt) const
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
