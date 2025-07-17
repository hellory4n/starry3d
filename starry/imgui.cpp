/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * imgui.cpp
 * Integrates Starry3D with Dear ImGui
 *
 * Copyright (C) 2025 by hellory4n <hellory4n@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this
 * software for any purpose with or without fee is hereby
 * granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <trippin/common.hpp>
#include <trippin/log.hpp>
#include <trippin/iofs.hpp>

#define SOKOL_GLCORE
#define SOKOL_ASSERT(X) TR_ASSERT(X)
#define SOKOL_UNREACHABLE() tr::panic("unreachable code from sokol")
#define SOKOL_NO_ENTRY
#include <sokol/sokol_app.h>
#include <sokol/sokol_gfx.h>
#include <sokol/sokol_log.h>
#include <sokol/sokol_glue.h>
#include <imgui.h>
#define SOKOL_IMGUI_IMPL
#include <sokol/util/sokol_imgui.h>

#include "imgui.hpp"

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
