package starry

import hm "core:container/handle_map"
import "core:image"
@(require) import "core:image/jpeg"
@(require) import "core:image/png"
import "core:log"
import "gpu"

Texture_Data :: struct {
	handle: hm.Handle32,
	img:    ^image.Image,
	tex:    gpu.Texture,
}

_texture_load :: proc(data: []byte, path: string) -> (h: hm.Handle32, ok: bool)
{
	img, err := image.load_from_bytes(data)
	if err != nil {
		log.errorf("couldn't load %q: %s", path, err)
		return h, false
	}
	defer if !ok {
		image.destroy(img)
	}

	if img.depth != 8 {
		unimplemented("bit depths other than 8")
	}

	format: gpu.Texture_Format
	switch img.channels {
	case 3:
		format = .RGB_U8
	case 4:
		format = .RGBA_U8
	case:
		unimplemented("TODO grayscale image support")
	}

	gpu_texture := gpu.new_texture(
		dev = gpu_device(),
		size = {i32(img.width), i32(img.height)},
		input_format = format,
		gpu_format = .RGBA_U8,
		data = img.pixels.buf[:],
	)
	defer if !ok {
		gpu.free_texture(gpu_texture)
	}

	h = hm.add(&global.textures, Texture_Data{img = img, tex = gpu_texture})
	return h, true
}

_texture_unload :: proc(h: hm.Handle32)
{
	texture, ok := hm.get(&global.textures, h)
	assert(ok)

	gpu.free_texture(texture.tex)
	image.destroy(texture.img)
	hm.remove(&global.textures, h)
}

_texture_unload_all :: proc()
{
	iter := hm.iterator_make(&global.textures)
	for _, h in hm.iterate(&iter) {
		_texture_unload(h)
	}
	hm.dynamic_destroy(&global.textures)
}

// Returns the texture size in pixels.
texture_size :: proc(h: AssetRef) -> [2]i32
{
	texture, ok := hm.get(&global.textures, h.handle)
	assert(ok)
	assert(h.type == strid("texture"))
	return {i32(texture.img.width), i32(texture.img.height)}
}

Texture_Channels :: enum {
	GRAYSCALE       = 0,
	GRAYSCALE_ALPHA = 1,
	RGB             = 2,
	RGB_ALPHA       = 3,
}

// Returns the channels of a texture.
texture_channels :: proc(h: AssetRef) -> Texture_Channels
{
	texture, ok := hm.get(&global.textures, h.handle)
	assert(ok)
	assert(h.type == strid("texture"))
	return Texture_Channels(texture.img.channels)
}

// Returns the bit depth of the texture, which is most likely 8 or 16.
texture_bit_depth :: proc(h: AssetRef) -> int
{
	texture, ok := hm.get(&global.textures, h.handle)
	assert(ok)
	assert(h.type == strid("texture"))
	return texture.img.depth
}

// Returns the data for the texture.
texture_data :: proc(h: AssetRef) -> []byte
{
	texture, ok := hm.get(&global.textures, h.handle)
	assert(ok)
	assert(h.type == strid("texture"))
	return texture.img.pixels.buf[:]
}

// Returns the GPU handle for the texture.
texture_gpu_handle :: proc(h: AssetRef) -> gpu.Texture
{
	texture, ok := hm.get(&global.textures, h.handle)
	assert(ok)
	assert(h.type == strid("texture"))
	return texture.tex
}
