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
	st::draw_triangle();

	ImGui::ShowDemoWindow();
}

void Sandbox::free()
{
	st::free_triangle();
	tr::log("freed sandbox :)");
}
