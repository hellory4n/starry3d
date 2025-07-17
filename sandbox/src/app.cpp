#include <starry/render.hpp>
#include <starry/imgui.hpp>
#include "app.hpp"

void Sandbox::init()
{
	st::init_triangle();
	tr::log("initialized sandbox :)");
}

void Sandbox::update(float64)
{
	ImGui::ShowDemoWindow();

	st::draw_triangle();

	if (st::is_key_just_pressed(st::Key::H)) tr::log("just pressed");
	if (st::is_key_held(st::Key::H)) tr::log("held");
	if (st::is_key_just_released(st::Key::H)) tr::log("just released");
}

void Sandbox::free()
{
	st::free_triangle();
	tr::log("freed sandbox :)");
}
