/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * imgui.hpp
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

#ifdef ST_IMGUI
#ifndef _ST_IMGUI_H
#define _ST_IMGUI_H

#include <imgui.h>

namespace st {

namespace imgui {
	void init();
	void free();
	void update();
	void render();
	void on_event(const void* event);
}

}

#endif

#else
	// just so you know why imgui doesn't work
	#error Using starry/imgui.hpp requires ST_IMGUI to be defined in the project
#endif
