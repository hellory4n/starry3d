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

#include "asset.h"

#include <trippin/iofs.h>

#include "trippin/common.h"
#include "trippin/log.h"
#include "trippin/memory.h"

#define STB_IMAGE_IMPLEMENTATION
#include <sokol/sokol_gfx.h>
// jesus
TR_GCC_IGNORE_WARNING(-Wold-style-cast)
TR_GCC_IGNORE_WARNING(-Wsign-conversion)
TR_GCC_IGNORE_WARNING(-Wcast-qual)
TR_GCC_IGNORE_WARNING(-Wimplicit-fallthrough)
TR_GCC_IGNORE_WARNING(-Wimplicit-int-conversion)
#include <stb/stb_image.h>
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()

#include "starry/common.h"
#include "starry/render.h"

tr::Result<const st::Texture&, const tr::Error&> st::Texture::load(tr::String path)
{
	// no need to load things twice
	if (st::engine.texture_cache.contains(path)) {
		return st::engine.texture_cache[path];
	}

	// first load file
	// TODO sokol_fetch is a thing dumbass
	TR_TRY_ASSIGN(
		tr::File& file,
		tr::File::open(st::engine.asset_arena, path, tr::FileMode::READ_BINARY)
	);
	TR_TRY_ASSIGN(tr::Array<uint8> data, file.read_all_bytes(st::engine.asset_arena));
	file.close();

	// then parse the data
	constexpr int CHANNELS = 4; // rgba
	int width, height, channels;
	uint8* pixels = stbi_load_from_memory(
		*data, static_cast<int>(data.len()), &width, &height, &channels, CHANNELS
	);
	if (pixels == nullptr) {
		return tr::scratchpad().make<tr::StringError>("couldn't parse image file");
	}

	// then finally give it to sokol
	sg_image_desc desc = {};
	desc.width = width;
	desc.height = height;
	desc.pixel_format = SG_PIXELFORMAT_RGBA8;
	desc.data.subimage[0][0].ptr = pixels;
	desc.data.subimage[0][0].size = static_cast<usize>(width * height * CHANNELS);

	sg_image image = sg_make_image(desc);
	if (sg_query_image_state(image) != SG_RESOURCESTATE_VALID) {
		return tr::scratchpad().make<RenderError>(
			RenderErrorType::RESOURCE_CREATION_FAILED
		);
	}

	// TODO libtrippin v2.5 has TR_DEFER now
	stbi_image_free(pixels);

	st::Texture texture = {};
	texture._width = static_cast<uint32>(width);
	texture._height = static_cast<uint32>(height);
	texture._sg_image_id = 0;

	st::engine.texture_cache[path] = texture;
	return st::engine.texture_cache[path];
}

void st::Texture::free()
{
	if (sg_query_image_state(sg_image{_sg_image_id}) == SG_RESOURCESTATE_VALID) {
		sg_destroy_image(sg_image{_sg_image_id});
	}
	_sg_image_id = SG_INVALID_ID;
}

uint32 st::Texture::handle() const
{
	return _sg_image_id;
}

tr::Vec2<uint32> st::Texture::size() const
{
	return {_width, _height};
}

void st::Texture::bind(int32 slot) const
{
	TR_ASSERT_MSG(
		slot < SG_MAX_IMAGE_BINDSLOTS,
		"can't bind texture to slot %i; only %i texture bind slots available", slot,
		SG_MAX_IMAGE_BINDSLOTS
	);
	st::renderer.bindings.images[slot] = sg_image{_sg_image_id};
}
