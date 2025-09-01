/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/optional/imgui.h
 * Support for Dear ImGui so that developers can finally ImGui all over the
 * place. The american dream.
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

#include <cstdint>
#ifndef ST_IMGUI
	#error "ImGui requires defining ST_IMGUI for the whole project"
#endif

#include <trippin/common.h>
#include <trippin/math.h>

// this is from imconfig.h but we can still define it here idfk man
#define IM_VEC2_CLASS_EXTRA                     \
	constexpr ImVec2(tr::Vec2<float32> f)   \
		: x(f.x)                        \
		, y(f.y)                        \
	{                                       \
	}                                       \
	operator tr::Vec2<float32>() const      \
	{                                       \
		return tr::Vec2<float32>(x, y); \
	}

#define IM_VEC4_CLASS_EXTRA                           \
	constexpr ImVec4(tr::Vec4<float32> f)         \
		: x(f.x)                              \
		, y(f.y)                              \
		, z(f.z)                              \
		, w(f.w)                              \
	{                                             \
	}                                             \
	operator tr::Vec4<float32>() const            \
	{                                             \
		return tr::Vec4<float32>(x, y, z, w); \
	}

#include <imgui.h>

namespace st {

namespace imgui {
	void init();
	void free();
	void new_frame();
	void render();

	// some helpers and shit
	constexpr ImVec4 rgba(uint32 hex)
	{
		tr::Color coloring_it = tr::Color::rgba(hex);
		tr::Vec4<float32> color_but_float = coloring_it;
		return {color_but_float.x, color_but_float.y, color_but_float.z, color_but_float.w};
	}

	constexpr ImVec4 rgb(uint32 hex)
	{
		tr::Color coloring_it = tr::Color::rgb(hex);
		tr::Vec4<float32> color_but_float = coloring_it;
		return {color_but_float.x, color_but_float.y, color_but_float.z, color_but_float.w};
	}

} // namespace imgui

} // namespace st

#endif
