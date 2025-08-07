#include "app.h"

#include <cstdio>

#include <starry/optional/imgui.h>
#include <starry/render.h>

tr::Result<void, const tr::Error&> Sandbox::init()
{
	tr::log("initialized sandbox :)");
	return {};
}

tr::Result<void, const tr::Error&> Sandbox::update(float64)
{
	ImGui::ShowDemoWindow();

	if (st::is_key_just_pressed(st::Key::H)) tr::log("just pressed");
	if (st::is_key_held(st::Key::H)) tr::log("held");
	if (st::is_key_just_released(st::Key::H)) tr::log("just released");

	return {};
}

tr::Result<void, const tr::Error&> Sandbox::free()
{
	tr::log("freed sandbox :)");

	return {};
}
