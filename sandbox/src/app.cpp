#include "app.h"

// #include <starry/asset.h>
// #include <starry/optional/imgui.h>
// #include <starry/render.h>

#include "debug_mode.h"
#include "starry/app.h"
#include "world.h"

tr::Result<void> sbox::Sandbox::init()
{
	// st::Camera& cam = st::Camera::current();
	// cam.position = {0, 0, -5};
	// cam.fov = 90;
	// cam.projection = st::CameraProjection::PERSPECTIVE;

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
	}
	st::set_mouse_enabled(_ui_enabled);

	player_controller(dt);
	return {};
}

tr::Result<void> sbox::Sandbox::free()
{
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

	// st::Camera& cam = st::Camera::current();
	// tr::Vec2<float32> delta_mouse_pos = st::relative_mouse_position();

	// cam.rotation.y += delta_mouse_pos.x * MOUSE_SENSITIVITY;
	// cam.rotation.x += delta_mouse_pos.y * MOUSE_SENSITIVITY;
	// // don't break your neck
	// cam.rotation.x = tr::clamp(cam.rotation.x, -89.0f, 89.0f);

	// tr::Vec3<float32> in = {};
	// if (st::is_key_held(st::Key::W)) {
	// 	in.z += 1;
	// }
	// if (st::is_key_held(st::Key::S)) {
	// 	in.z -= 1;
	// }
	// if (st::is_key_held(st::Key::A)) {
	// 	in.x -= 1;
	// }
	// if (st::is_key_held(st::Key::D)) {
	// 	in.x += 1;
	// }
	// // TODO is this ass?
	// if (st::is_key_held(st::Key::SPACE)) {
	// 	in.y += 1;
	// }
	// if (st::is_key_held(st::Key::LEFT_SHIFT)) {
	// 	in.y -= 1;
	// }

	// float32 yaw = tr::deg2rad(cam.rotation.y);
	// tr::Vec3<float32> forward = {sinf(yaw), 0, -cosf(yaw)};
	// tr::Vec3<float32> right = {cosf(yaw), 0, sinf(yaw)};

	// float32 len_xz = sqrtf(in.x * in.x + in.z * in.z);
	// if (len_xz > 0.0001f) {
	// 	in.x /= len_xz;
	// 	in.z /= len_xz;
	// }

	// tr::Vec3<float32> move = {
	// 	right.x * in.x + forward.x * in.z, in.y, right.z * in.x + forward.z * in.z
	// };
	// // TODO did i fuck it?
	// cam.position += -(move * PLAYER_SPEED * static_cast<float32>(dt));
	// cam.rotation.z = 0; // just in case
}
