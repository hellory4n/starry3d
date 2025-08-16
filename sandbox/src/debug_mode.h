#pragma once
#include <starry/app.h>
#include <starry/optional/imgui.h>
#include <starry/world.h>

static inline void debug_mode()
{
	ImGui::Begin("Debug mode");

	ImGui::Text("Controls:");
	ImGui::BulletText("WASD to move");
	ImGui::BulletText("Look around with your mouse");
	ImGui::BulletText("Space/left shift to fly");
	ImGui::BulletText("Esc to toggle mouse");

	ImGui::Text("FPS: %f", st::fps());

	st::Camera& cam = st::Camera::current();
	ImGui::Text(
		"Camera: (%s)",
		cam.projection == st::CameraProjection::PERSPECTIVE ? "perspective" : "orthographic"
	);
	ImGui::BulletText("Position: %f, %f, %f", cam.position.x, cam.position.y, cam.position.z);
	ImGui::BulletText("Rotation: %f, %f, %f", cam.rotation.x, cam.rotation.y, cam.rotation.z);
	ImGui::BulletText(
		"%s: %f", cam.projection == st::CameraProjection::PERSPECTIVE ? "FOV" : "Zoom",
		cam.fov // it's a union, the value is the same but with different names
	);

	ImGui::End();
}
