/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/asset.h
 * Manages loading assets
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

#ifndef _ST_ASSET_H
#define _ST_ASSET_H

#include <trippin/common.h>
#include <trippin/error.h>
#include <trippin/math.h>

namespace st {

// Image on the GPU
class Texture
{
	// an sg_image is just an uint32 for the id
	// so no need to include sokol here
	uint32 _sg_image_id = 0;
	uint32 _width = 0;
	uint32 _height = 0;

public:
	// Loads an texture and puts it into a cache thing. If it was already loaded, then it
	// returns the existing texture.
	static tr::Result<const Texture&, const tr::Error&> load(tr::String path);

	// Returns the internal texture handle.
	uint32 handle() const;

	// Returns the texture's size in pixels
	tr::Vec2<uint32> size() const;
};

} // namespace st

#endif
