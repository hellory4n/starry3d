#include "debug_mode.h"

#include <trippin/common.h>
#include <trippin/math.h>
#include <trippin/memory.h>
#include <trippin/string.h>

#include <imgui.h>
#include <imgui_internal.h> // why
#include <starry/app.h>
#include <starry/optional/imgui.h>
#include <starry/world.h>

#include "starry/internal.h"
#include "starry/render.h"

static void _dock_space()
{
	ImGuiWindowFlags window_flags = ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_NoTitleBar |
					ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize |
					ImGuiWindowFlags_NoMove |
					ImGuiWindowFlags_NoBringToFrontOnFocus |
					ImGuiWindowFlags_NoNavFocus | ImGuiWindowFlags_NoBackground;

	ImGuiViewport* viewport = ImGui::GetMainViewport();
	ImGui::SetNextWindowPos(viewport->Pos);
	ImGui::SetNextWindowSize(viewport->Size);
	ImGui::SetNextWindowViewport(viewport->ID);

	ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0.0f, 0.0f));
	ImGui::Begin("Sandbox", nullptr, window_flags);
	TR_DEFER(ImGui::End());
	ImGui::PopStyleVar();

	ImGuiID dockspace_id = ImGui::GetID("dockspacema");
	ImGui::DockSpace(dockspace_id, ImVec2(0.0f, 0.0f));

	// default dock stuff
	// TODO wtf is this
	static bool is_first_time = true;
	if (is_first_time) {
		ImGui::DockBuilderRemoveNode(dockspace_id);
		ImGui::DockBuilderAddNode(dockspace_id, ImGuiDockNodeFlags_DockSpace);
		ImGui::DockBuilderSetNodeSize(dockspace_id, ImGui::GetMainViewport()->Size);

		ImGuiID dock_main_id = dockspace_id;
		ImGuiID dock_id_left = ImGui::DockBuilderSplitNode(
			dock_main_id, ImGuiDir_Left, 0.26f, nullptr, nullptr
		);
		ImGuiID dock_id_left_top;
		ImGuiID dock_id_left_bottom = ImGui::DockBuilderSplitNode(
			dock_id_left, ImGuiDir_Down, 0.35f, nullptr, &dock_id_left_top
		);
		ImGuiID dock_id_left_bottom_top;
		ImGuiID dock_id_left_bottom_bottom = ImGui::DockBuilderSplitNode(
			dock_id_left_bottom, ImGuiDir_Down, 0.5f, nullptr, &dock_id_left_bottom_top
		);

		ImGui::DockBuilderDockWindow("debug", dock_id_left_top);
		ImGui::DockBuilderDockWindow("about", dock_id_left_bottom_top);
		ImGui::DockBuilderDockWindow("help", dock_id_left_bottom_bottom);

		ImGui::DockBuilderFinish(dockspace_id);

		is_first_time = false;
	}
}

static void _tutorial()
{
	ImGui::Begin("help");
	TR_DEFER(ImGui::End());

	ImGui::BulletText("WASD to move");
	ImGui::BulletText("Look around with your mouse");
	ImGui::BulletText("Space/left shift to fly");
	ImGui::BulletText("Esc to toggle mouse");
}

static void _about()
{
	ImGui::Begin("about");
	TR_DEFER(ImGui::End());

	ImGui::Text("Starry %s", st::VERSION);
	ImGui::BulletText("using libtrippin %s", tr::VERSION);
	ImGui::BulletText("using ImGui %s", IMGUI_VERSION);

	st::Platform platform = st::platform();
	tr::String platform_str = "";
	switch (platform) {
	case st::Platform::LINUX:
		platform_str = "Linux";
		break;
	case st::Platform::MACOSX:
		platform_str = "Mac OS X";
		break;
	case st::Platform::WINDOWS:
		platform_str = "Windows";
		break;
	default:
		platform_str = "unknown unix-like";
		break;
	}

#ifdef TR_ONLY_CLANG
	tr::String cc = "clang";
#elif defined(TR_ONLY_GCC)
	tr::String cc = "gcc";
#elif defined(TR_ONLY_MSVC)
	tr::String cc = "msvc";
#else
	tr::String cc = "unknown compiler";
#endif

	ImGui::BulletText(
		"built for %s %s using %s", *platform_str, tr::is_debug() ? "(debug)" : "(release)",
		*cc
	);
}

static void _debug_mode()
{
	ImGui::Begin("debug");
	TR_DEFER(ImGui::End());

	// this is the same logic the renderer uses for checking when it should be updated
	if (st::_st->prev_chunk != st::current_chunk() || st::_st->chunk_updates_in_your_area) {
		ImGui::TextColored(st::imgui::rgb(0xc6262e), "updating terrain mesh!");
	}

	ImGui::Text("FPS: %.1f", st::fps());

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
	ImGui::BulletText(
		"Current chunk: %i, %i, %i", st::current_chunk().x, st::current_chunk().y,
		st::current_chunk().z
	);

	float64 camera_yaw = fmodf(fmodf(cam.rotation.y, 360) + 360, 360);
	tr::String facing;
	if (camera_yaw < 22.5 || camera_yaw >= 337.5) {
		facing = "north";
	}
	else if (camera_yaw < 67.5) {
		facing = "north east";
	}
	else if (camera_yaw < 112.5) {
		facing = "east";
	}
	else if (camera_yaw < 157.5) {
		facing = "south east";
	}
	else if (camera_yaw < 202.5) {
		facing = "south";
	}
	else if (camera_yaw < 247.5) {
		facing = "south west";
	}
	else if (camera_yaw < 292.5) {
		facing = "west";
	}
	else {
		facing = "north west";
	}
	ImGui::BulletText("Facing %s", *facing);

	// i love hacking my own engine
	ImGui::Text("Memory usage:");
	ImGui::BulletText("tr::scratchpad: %zu KiB", tr::bytes_to_kb(tr::scratchpad().allocated()));
	ImGui::BulletText("_st->arena: %zu KiB", tr::bytes_to_kb(st::_st->arena.allocated()));
	ImGui::BulletText(
		"_st->asset_arena: %zu KiB", tr::bytes_to_kb(st::_st->asset_arena.allocated())
	);
	ImGui::BulletText(
		"_st->render_arena: %zu KiB", tr::bytes_to_kb(st::_st->render_arena.allocated())
	);
	ImGui::BulletText(
		"_st->world_arena: %zu KiB", tr::bytes_to_kb(st::_st->world_arena.allocated())
	);

	ImGui::Text("Rendering:");
	ImGui::BulletText("Terrain quads: %i", st::_st->instances);
	ImGui::BulletText("Triangles: %i", st::_st->instances * 2);

	static int prev_render_distance = 12;
	static int render_distance = 12;
	// the real limit is 40 but i don't have enough memory for that
	if (ImGui::SliderInt("Render distance", &render_distance, 4, 20)) {
		if (render_distance != prev_render_distance) {
			st::set_render_distance(static_cast<uint32>(render_distance));
		}
		prev_render_distance = render_distance;
	}

	// man
	ImGui::Text("Environment");
	st::Environment& env = st::environment();
	static float32 sun_color[4] = {1, 1, 1, 1};
	if (ImGui::ColorEdit4("Sun color", sun_color)) {
		env.sun_color =
			tr::Vec4<float32>{sun_color[0], sun_color[1], sun_color[2], sun_color[3]};
	}
	static float32 ambient_color[4] = {0, 0, 0, 1};
	if (ImGui::ColorEdit4("Ambient color", ambient_color)) {
		env.ambient_color = tr::Vec4<float32>{
			ambient_color[0], ambient_color[1], ambient_color[2], ambient_color[3]
		};
	}
	static float32 sky_color[4] = {0, 0, 0, 1};
	if (ImGui::ColorEdit4("Sky color", ambient_color)) {
		env.sky_color =
			tr::Vec4<float32>{sky_color[0], sky_color[1], sky_color[2], sky_color[3]};
	}
	static float32 sundir[3] = {};
	if (ImGui::DragFloat3("Sun direction", sundir, 0.01f, -1, 1)) {
		env.sun_direction = {sundir[0], sundir[1], sundir[2]};
	}
}

void sbox::debug_mode()
{
	_dock_space();
	_debug_mode();
	_about();
	_tutorial();
}

void sbox::imgui_theme()
{
	// mostly stolen btw
	// TODO your own fucking theme dumbass
	ImVec4* colors = ImGui::GetStyle().Colors;
	colors[ImGuiCol_Text] = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
	colors[ImGuiCol_TextDisabled] = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
	colors[ImGuiCol_WindowBg] = ImVec4(0.05f, 0.05f, 0.07f, 0.9f);
	colors[ImGuiCol_TitleBg] = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	colors[ImGuiCol_TitleBgActive] = ImVec4(0.447f, 0.223f, 0.886f, 1.00f);
	colors[ImGuiCol_TitleBgCollapsed] = ImVec4(0.00f, 0.00f, 0.00f, 1.00f);
	colors[ImGuiCol_MenuBarBg] = ImVec4(0.14f, 0.14f, 0.14f, 1.00f);
	colors[ImGuiCol_ScrollbarBg] = ImVec4(0.05f, 0.05f, 0.05f, 0.54f);
	colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.34f, 0.34f, 0.34f, 0.54f);
	colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.40f, 0.40f, 0.40f, 0.54f);
	colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.56f, 0.56f, 0.56f, 0.54f);
	colors[ImGuiCol_CheckMark] = ImVec4(0.33f, 0.67f, 0.86f, 1.00f);
	colors[ImGuiCol_SliderGrab] = ImVec4(0.34f, 0.34f, 0.34f, 0.54f);
	colors[ImGuiCol_SliderGrabActive] = ImVec4(0.56f, 0.56f, 0.56f, 0.54f);
	colors[ImGuiCol_Button] = ImVec4(0.05f, 0.05f, 0.05f, 0.54f);
	colors[ImGuiCol_ButtonHovered] = ImVec4(0.19f, 0.19f, 0.19f, 0.54f);
	colors[ImGuiCol_ButtonActive] = ImVec4(0.20f, 0.22f, 0.23f, 1.00f);
	colors[ImGuiCol_Header] = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
	colors[ImGuiCol_HeaderHovered] = ImVec4(0.00f, 0.00f, 0.00f, 0.36f);
	colors[ImGuiCol_HeaderActive] = ImVec4(0.20f, 0.22f, 0.23f, 0.33f);
	colors[ImGuiCol_Separator] = ImVec4(0.28f, 0.28f, 0.28f, 0.29f);
	colors[ImGuiCol_SeparatorHovered] = ImVec4(0.44f, 0.44f, 0.44f, 0.29f);
	colors[ImGuiCol_SeparatorActive] = ImVec4(0.40f, 0.44f, 0.47f, 1.00f);
	colors[ImGuiCol_ResizeGrip] = ImVec4(0.28f, 0.28f, 0.28f, 0.29f);
	colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.44f, 0.44f, 0.44f, 0.29f);
	colors[ImGuiCol_ResizeGripActive] = ImVec4(0.40f, 0.44f, 0.47f, 1.00f);
	colors[ImGuiCol_Tab] = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
	colors[ImGuiCol_TabHovered] = ImVec4(0.14f, 0.14f, 0.14f, 1.00f);
	colors[ImGuiCol_TabActive] = ImVec4(0.20f, 0.20f, 0.20f, 0.36f);
	colors[ImGuiCol_TabUnfocused] = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
	colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.14f, 0.14f, 0.14f, 1.00f);
	colors[ImGuiCol_DockingPreview] = ImVec4(0.33f, 0.67f, 0.86f, 1.00f);
	colors[ImGuiCol_DockingEmptyBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	colors[ImGuiCol_PlotLines] = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
	colors[ImGuiCol_PlotLinesHovered] = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
	colors[ImGuiCol_PlotHistogram] = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
	colors[ImGuiCol_PlotHistogramHovered] = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
	colors[ImGuiCol_TableHeaderBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
	colors[ImGuiCol_TableBorderStrong] = ImVec4(0.00f, 0.00f, 0.00f, 0.52f);
	colors[ImGuiCol_TableBorderLight] = ImVec4(0.28f, 0.28f, 0.28f, 0.29f);
	colors[ImGuiCol_TableRowBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
	colors[ImGuiCol_TableRowBgAlt] = ImVec4(1.00f, 1.00f, 1.00f, 0.06f);
	colors[ImGuiCol_TextSelectedBg] = ImVec4(0.20f, 0.22f, 0.23f, 1.00f);
	colors[ImGuiCol_DragDropTarget] = ImVec4(0.33f, 0.67f, 0.86f, 1.00f);
	colors[ImGuiCol_NavHighlight] = ImVec4(1.00f, 0.00f, 0.00f, 1.00f);
	colors[ImGuiCol_NavWindowingHighlight] = ImVec4(1.00f, 0.00f, 0.00f, 0.70f);
	colors[ImGuiCol_NavWindowingDimBg] = ImVec4(1.00f, 0.00f, 0.00f, 0.20f);
	colors[ImGuiCol_ModalWindowDimBg] = ImVec4(1.00f, 0.00f, 0.00f, 0.35f);

	ImGuiStyle& style = ImGui::GetStyle();
	style.WindowPadding = ImVec2(8.00f, 8.00f);
	style.FramePadding = ImVec2(5.00f, 2.00f);
	style.CellPadding = ImVec2(6.00f, 6.00f);
	style.ItemSpacing = ImVec2(6.00f, 6.00f);
	style.ItemInnerSpacing = ImVec2(6.00f, 6.00f);
	style.TouchExtraPadding = ImVec2(0.00f, 0.00f);
	style.IndentSpacing = 25;
	style.ScrollbarSize = 15;
	style.GrabMinSize = 10;
	style.WindowBorderSize = 1;
	style.ChildBorderSize = 1;
	style.PopupBorderSize = 1;
	style.FrameBorderSize = 1;
	style.TabBorderSize = 1;
	style.WindowRounding = 2;
	style.ChildRounding = 2;
	style.FrameRounding = 1;
	style.PopupRounding = 2;
	style.ScrollbarRounding = 9;
	style.GrabRounding = 3;
	style.LogSliderDeadzone = 4;
	style.TabRounding = 4;
}
