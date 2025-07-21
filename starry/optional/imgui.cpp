/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/optional/imgui.cpp
 * Integrates Starry3D with Dear ImGui
 *
 * Copyright (c) 2025 hellory4n <hellory4n@gmail.com>
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 */

#include <trippin/common.hpp>
#include <trippin/log.hpp>
#include <trippin/iofs.hpp>

#include "starry/configs/sokol.hpp" // IWYU pragma: keep
#include <sokol/sokol_app.h>
#include <sokol/sokol_gfx.h>
#include <sokol/sokol_log.h>
#include <sokol/sokol_glue.h>
// TODO use imconfig.h?
#include <imgui.h>
#define SOKOL_IMGUI_IMPL
#include <sokol/util/sokol_imgui.h>

#include "starry/optional/imgui.hpp"

namespace st {
	// it's a hassle
	// implemented in common.cpp
	void __sokol_log(const char* tag, uint32 level, uint32 item_id, const char* msg_or_null,
		uint32 line_nr, const char* filename_or_null, void* user_data
	);
}

void st::imgui::init()
{
	simgui_desc_t imgui_desc = {};
	imgui_desc.logger.func = st::__sokol_log;
	// TODO should this be configurable?
	imgui_desc.ini_filename = tr::path(tr::scratchpad(), "user://imgui.ini");
	simgui_setup(imgui_desc);

	ImGuiIO& io = ImGui::GetIO();
	io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
	io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
	io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;

	tr::info("initialized imgui v%s", IMGUI_VERSION);
}

void st::imgui::free()
{
	simgui_shutdown();
	tr::info("deinitialized imgui");
}

void st::imgui::update()
{
	int width = sapp_width();
	int height = sapp_height();

	simgui_frame_desc_t frame_desc = {};
	frame_desc.width = width;
	frame_desc.height = height;
	frame_desc.delta_time = sapp_frame_duration();
	frame_desc.dpi_scale = sapp_dpi_scale();
	simgui_new_frame(frame_desc);
}

void st::imgui::render()
{
	simgui_render();
}

void st::imgui::on_event(const void* event)
{
	simgui_handle_event(reinterpret_cast<const sapp_event*>(event));
}
