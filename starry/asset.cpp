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

#include "starry/asset.h"

#include <trippin/common.h>
#include <trippin/iofs.h>
#include <trippin/log.h>
#include <trippin/memory.h>

#include <sokol/sokol_gfx.h>

// jesus
TR_GCC_IGNORE_WARNING(-Wold-style-cast)
TR_GCC_IGNORE_WARNING(-Wsign-conversion)
TR_GCC_IGNORE_WARNING(-Wcast-qual)
TR_GCC_IGNORE_WARNING(-Wimplicit-fallthrough)
TR_GCC_IGNORE_WARNING(-Wimplicit-int-conversion)
#define STB_IMAGE_IMPLEMENTATION
#include <stb/stb_image.h>
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()
TR_GCC_RESTORE()

#include "starry/internal.h"
#include "starry/render.h"

void st::_init::asset()
{
	// TODO use this
}

void st::_free::asset()
{
	// TODO use this
}

st::Texture::Texture()
{
	// uint32 texture;
	// glGenTextures(1, &texture);
	// glBindTexture(GL_TEXTURE_2D, texture);
}

tr::Result<st::Texture> st::Texture::load(tr::String path)
{
	// // no need to load things twice
	// if (engine.textures.contains(path)) {
	// 	return engine.textures[path];
	// }

	// // first load file
	// // TODO sokol_fetch is a thing dumbass
	// TR_TRY_ASSIGN(
	// 	tr::File& file, tr::File::open(
	// 				engine.asset_arena, tr::path(tr::scratchpad(), path),
	// 				tr::FileMode::READ_BINARY
	// 			)
	// );
	// TR_DEFER(file.close());
	// TR_TRY_ASSIGN(tr::Array<uint8> data, file.read_all_bytes(engine.asset_arena));

	// // then parse the data
	// constexpr int CHANNELS = 4; // rgba
	// int width, height, channels;
	// uint8* pixels = stbi_load_from_memory(
	// 	*data, static_cast<int>(data.len()), &width, &height, &channels, CHANNELS
	// );
	// if (pixels == nullptr) {
	// 	return tr::scratchpad().make<tr::StringError>("couldn't parse image file");
	// }
	// TR_DEFER(stbi_image_free(pixels));

	// // the constructor setups some placeholder texture faffery
	// Texture texture = {};
	// texture._width = width;
	// texture._height = height;
	// texture._path = path;

	// // then finally give it to sokol
	// sg_image_desc desc = {};
	// desc.width = width;
	// desc.height = height;
	// desc.pixel_format = SG_PIXELFORMAT_RGBA8;
	// desc.data.subimage[0][0].ptr = pixels;
	// desc.data.subimage[0][0].size = static_cast<usize>(width * height * CHANNELS);
	// sg_init_image(sg_image{texture._image_id}, desc);

	// if (sg_query_image_state(sg_image{texture._image_id}) != SG_RESOURCESTATE_VALID) {
	// 	return tr::scratchpad().make<RenderError>(
	// 		RenderErrorType::RESOURCE_CREATION_FAILED
	// 	);
	// }

	// engine.textures[path] = texture;
	// tr::info(
	// 	"loaded texture from %s (id %i, sampler id %i)", *path, texture._image_id,
	// 	texture._sampler_id
	// );
	// return engine.textures[path];
	return Texture();
}

void st::Texture::free()
{
	// if (sg_query_image_state(sg_image{_image_id}) == SG_RESOURCESTATE_VALID) {
	// 	sg_destroy_image(sg_image{_image_id});
	// }
	// if (sg_query_sampler_state(sg_sampler{_sampler_id}) == SG_RESOURCESTATE_VALID) {
	// 	sg_destroy_sampler(sg_sampler{_sampler_id});
	// }
	// _image_id = SG_INVALID_ID;
	// _sampler_id = SG_INVALID_ID;
	// tr::info("freed texture from %s", *_path);
}

tr::Vec2<uint32> st::Texture::size() const
{
	return {_width, _height};
}

void st::Texture::bind(int32 slot) const
{
	// TR_ASSERT_MSG(
	// 	slot < SG_MAX_IMAGE_BINDSLOTS,
	// 	"can't bind texture to slot %i; only %i texture bind slots available", slot,
	// 	SG_MAX_IMAGE_BINDSLOTS
	// );
	// TR_ASSERT(_image_id != SG_INVALID_ID);
	// engine.bindings.images[slot] = sg_image{_image_id};
	// engine.bindings.samplers[slot] = sg_sampler{_sampler_id};
}

void st::Texture::_free_all_textures()
{
	for (auto [_, texture] : engine.textures) {
		texture.free();
	}
}

tr::String st::Texture::path() const
{
	return _path;
}
