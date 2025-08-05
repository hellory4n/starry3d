/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/format.h
 * File formats used by starry
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

#ifndef _ST_FORMAT_H
#define _ST_FORMAT_H

#include <trippin/common.h>
#include <trippin/math.h>
#include <trippin/memory.h>

namespace tr {

// Standard palette used for .stvox models
enum class VoxPalette : uint8
{
	TRANSPARENT,
	BLACK_5,
	BLACK_4,
	BLACK_3,
	BLACK_2,
	BLACK_1,
	WHITE_5,
	WHITE_4,
	WHITE_3,
	WHITE_2,
	WHITE_1,
	STRAWBERRY_5,
	STRAWBERRY_4,
	STRAWBERRY_3,
	STRAWBERRY_2,
	STRAWBERRY_1,
	ORANGE_5,
	ORANGE_4,
	ORANGE_3,
	ORANGE_2,
	ORANGE_1,
	BANANA_5,
	BANANA_4,
	BANANA_3,
	BANANA_2,
	BANANA_1,
	LIME_5,
	LIME_4,
	LIME_3,
	LIME_2,
	LIME_1,
	MINT_5,
	MINT_4,
	MINT_3,
	MINT_2,
	MINT_1,
	BLUEBERRY_5,
	BLUEBERRY_4,
	BLUEBERRY_3,
	BLUEBERRY_2,
	BLUEBERRY_1,
	GRAPE_5,
	GRAPE_4,
	GRAPE_3,
	GRAPE_2,
	GRAPE_1,
	BUBBLEGUM_5,
	BUBBLEGUM_4,
	BUBBLEGUM_3,
	BUBBLEGUM_2,
	BUBBLEGUM_1,
	LATTE_5,
	LATTE_4,
	LATTE_3,
	LATTE_2,
	LATTE_1,
	COCOA_5,
	COCOA_4,
	COCOA_3,
	COCOA_2,
	COCOA_1,
};

// Represents a color palette for voxel models. It could just use regular colors but this is faster
// :). This is pretty much just a fancy wrapper for an array, + a static method for loading
struct Palette
{
	// that's how many colors fit in a byte
	static constexpr usize MAX_COLORS = 255;

	tr::Array<tr::Color> colors;

public:
	Palette();
	// "Single-argument constructors must be marked explicit to avoid unintentional implicit
	// conversions"
	// this is on purpose you twatwaffle
	// NOLINTBEGIN(google-explicit-constructor)
	Palette(tr::Array<tr::Color> c) : colors(c) {}
	// NOLINTEND(google-explicit-constructor)

	// unnecessary don't care
	tr::Color& operator[](usize idx) const
	{
		return this->colors[idx];
	}
};

} // namespace tr

#endif