/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * st_format.hpp
 * Implements file formats used by starry3d
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

#ifndef _ST_FORMAT_H
#define _ST_FORMAT_H

#include <trippin/common.hpp>
#include <trippin/memory.hpp>
#include <trippin/string.hpp>
#include <trippin/math.hpp>

#include "render.hpp"

namespace st {

// Standard palette used for .stvox models
enum class VoxPalette : uint8
{
	TRANSPARENT,
	BLACK_5,       BLACK_4,       BLACK_3,       BLACK_2,       BLACK_1,
	WHITE_5,       WHITE_4,       WHITE_3,       WHITE_2,       WHITE_1,
	STRAWBERRY_5,  STRAWBERRY_4,  STRAWBERRY_3,  STRAWBERRY_2,  STRAWBERRY_1,
	ORANGE_5,      ORANGE_4,      ORANGE_3,      ORANGE_2,      ORANGE_1,
	BANANA_5,      BANANA_4,      BANANA_3,      BANANA_2,      BANANA_1,
	LIME_5,        LIME_4,        LIME_3,        LIME_2,        LIME_1,
	MINT_5,        MINT_4,        MINT_3,        MINT_2,        MINT_1,
	BLUEBERRY_5,   BLUEBERRY_4,   BLUEBERRY_3,   BLUEBERRY_2,   BLUEBERRY_1,
	GRAPE_5,       GRAPE_4,       GRAPE_3,       GRAPE_2,       GRAPE_1,
	BUBBLEGUM_5,   BUBBLEGUM_4,   BUBBLEGUM_3,   BUBBLEGUM_2,   BUBBLEGUM_1,
	LATTE_5,       LATTE_4,       LATTE_3,       LATTE_2,       LATTE_1,
	COCOA_5,       COCOA_4,       COCOA_3,       COCOA_2,       COCOA_1,
};

// Small header thing used to figure out what kind of data it's looking at.
enum class StvoxTag : uint8
{
	// Just so it doesn't think a bunch of 0s is valid
	INVALID,
	// File header, points to a `st::StvoxHeader`
	HEADER,
	// The dimensions of the model, points to a `st::VoxDimensions`
	DIMENSIONS,
	// A cube, points to a `st::Cube`
	CUBE,
	// A cube with a single texture, points to a `st::TextureCube`
	TEXTURE_CUBE,
	// A cube with multiple textures, points to a `st::MultiTextureCube`
	MULTI_TEXTURE_CUBE,
	// A plane with a texture, points to a `st::TexturePlane`
	TEXTURE_PLANE,
	// Similar to a `StvoxTag::TEXTURE_PLANE`, but it's always looking at the camera. Points to a
	// `st::Billboard`
	BILLBOARD,
};

// Magic number in .stvox files
constexpr char STVOX_MAGIC_NUMBER[8] = {'s','t','a','r','v','o','x','!'};

// .stvox file header
struct StvoxHeader
{
	static constexpr StvoxTag TAG = StvoxTag::HEADER;

	// Magic number, should be "starvox!" (no null terminator)
	char magic[8];
	// The file format version, should be 400 for v0.4.0 (when the format was last updated). 400-499 is reserved
	// for adding new tags, and should be safe to load even from previous versions. If the format gets updated,
	// this should match the engine version, e.g. 800 for v0.8.0, 1,100 for v1.1.0, and 12,000 for v1.20.0
	uint32 version;

	// Returns true if the header is valid.
	bool is_valid()
	{
		// magic number
		if (this->magic[0] != STVOX_MAGIC_NUMBER[0]) return false;
		if (this->magic[1] != STVOX_MAGIC_NUMBER[1]) return false;
		if (this->magic[2] != STVOX_MAGIC_NUMBER[2]) return false;
		if (this->magic[3] != STVOX_MAGIC_NUMBER[3]) return false;
		if (this->magic[4] != STVOX_MAGIC_NUMBER[4]) return false;
		if (this->magic[5] != STVOX_MAGIC_NUMBER[5]) return false;
		if (this->magic[6] != STVOX_MAGIC_NUMBER[6]) return false;
		if (this->magic[7] != STVOX_MAGIC_NUMBER[7]) return false;

		// 400-499 are safe to load
		if (this->version < 400 || this->version > 499) return false;

		return true;
	}
};

// .stvox model dimensions
struct VoxDimensions
{
	static constexpr StvoxTag TAG = StvoxTag::DIMENSIONS;

	// The dimensions of the model duh
	tr::Vec3<uint8> dimensions;
};

// .stvox colored cube
struct Cube
{
	static constexpr StvoxTag TAG = StvoxTag::CUBE;

	tr::Vec3<uint8> from;
	tr::Vec3<uint8> to;
	VoxPalette color;
	// If true, the cube reacts to the environment's lighting. Else, it's just a solid color
	bool illuminated;
};

// Index pointing to a texture in a texture atlas. 2 numbers for modding and crap lmao. It's also useful for
// if the texture atlas' format has to be changed to fit more textures.
struct TextureAtlasId
{
	uint16 package;
	uint16 texture;
};

// .stvox cube with a single texture
struct TextureCube
{
	static constexpr StvoxTag TAG = StvoxTag::TEXTURE_CUBE;

	tr::Vec3<uint8> from;
	tr::Vec3<uint8> to;
	TextureAtlasId texture;
};

// .stvox cube with multiple texture
struct MultiTextureCube
{
	static constexpr StvoxTag TAG = StvoxTag::MULTI_TEXTURE_CUBE;

	tr::Vec3<uint8> from;
	tr::Vec3<uint8> to;
	TextureAtlasId left;
	TextureAtlasId right;
	TextureAtlasId top;
	TextureAtlasId bottom;
	TextureAtlasId front;
	TextureAtlasId back;
};

// .stvox textured plane
struct TexturePlane
{
	static constexpr StvoxTag TAG = StvoxTag::TEXTURE_PLANE;

	tr::Vec3<uint8> from;
	tr::Vec3<uint8> to;
	TextureAtlasId texture;
};

// .stvox textured plane that always looks at the camera
struct Billboard
{
	static constexpr StvoxTag TAG = StvoxTag::BILLBOARD;

	tr::Vec3<uint8> from;
	tr::Vec3<uint8> to;
	TextureAtlasId texture;
};

// It's just used for arrays in `VoxModel`
struct VoxItem
{
	union {
		Cube cube;
		TextureCube texture_cube;
		MultiTextureCube multi_texture_cube;
		TexturePlane texture_plane;
		Billboard billboard;
	};
	StvoxTag tag;
};

// Voxel model, usually from a .stvox file
struct VoxModel
{
	tr::Vec3<uint8> dimensions;
	tr::Array<VoxItem> items;

	VoxModel() : dimensions(0, 0, 0), items() {}

	// Loads a .stvox model and returns it, or null if it fails.
	static tr::Maybe<VoxModel> load(tr::String path);

	// Tries to save the model into a .stvox model. Returns true if it succeeds, returns false otherwise.
	bool save(tr::String path);
};

// As the name implies, it controls the global appearance of voxel models. This should be swappable and still
// work with everything, because why not.
struct VoxAppearance
{
	Texture atlas;
	// TODO tr::HashMap<K, V> or whatever the fuck
	tr::Array<tr::Pair<TextureAtlasId, tr::Vec2<uint32>>> atlas_ids;
	tr::Array<tr::Color> palette;

	// Loads the file lmao.
	static tr::Maybe<VoxAppearance> load(tr::String path);

	// Tries to save the file into a file. Returns true if it succeeded, returns false otherwise.
	bool save(tr::String path);
};

// Sets the current `VoxAppearance`
void set_vox_appearance(VoxAppearance appearance);

// Gets the current `VoxAppearance`
VoxAppearance vox_appearance();

}

#endif
