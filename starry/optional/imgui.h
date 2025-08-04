/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/optional/imgui.h
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

#ifndef _ST_IMGUI_H
#define _ST_IMGUI_H

#ifdef ST_IMGUI
	#include <imgui.h>
#else
	// just so you know why imgui doesn't work
	#error Using starry/optional/imgui.h requires ST_IMGUI to be defined in the project
#endif

namespace st {

namespace imgui {

void init();
void free();
void update();
void render();
void on_event(const void* event);

} // namespace imgui

} // namespace st

#endif
