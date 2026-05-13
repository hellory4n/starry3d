package starryrt

import "core:bytes"
import hm "core:container/handle_map"
import "core:image"
import "core:image/jpeg"
import "core:image/png"
import "core:log"
import "gpu"

Texture :: distinct hm.Handle32

Texture_Data :: struct {
	handle: Texture,
	img:    ^image.Image,
	tex:    gpu.Texture,
}

// Forces a texture to be reloaded, ignoring if it's already in texture cache
reload_texture :: proc(path: string) -> (texture: Texture, ok: bool) #optional_ok
{
	context.allocator = engine.ctx.allocator

	file: []byte
	file, ok = load_asset_bytes(path)
	if !ok {
		return
	}
	defer delete(file)

	img, err := image.load_from_bytes(file)
	if err != nil {
		log.errorf("couldn't load %q: %s", path, err)
		return texture, false
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
		dev = get_gpu(),
		size = {i32(img.width), i32(img.height)},
		input_format = format,
		gpu_format = .RGBA_U8,
		data = img.pixels.buf[:],
	)
	defer if !ok {
		gpu.free_texture(gpu_texture)
	}

	texture, ok = hm.add(&engine.textures, Texture_Data{img = img, tex = gpu_texture})
	if !ok do return

	engine.texture_cache[path] = texture
	return
}

// Loads a texture from memory. The data should be valid PNG/JPEG data.
load_texture_from_memory :: proc(data: []byte) -> (texture: Texture, ok: bool) #optional_ok
{
	context.allocator = engine.ctx.allocator

	img, err := image.load_from_bytes(data)
	if err != nil {
		log.errorf("couldn't load texture: %s", err)
		return texture, false
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
		dev = get_gpu(),
		size = {i32(img.width), i32(img.height)},
		input_format = format,
		gpu_format = .RGBA_U8,
		data = img.pixels.buf[:],
	)
	defer if !ok {
		gpu.free_texture(gpu_texture)
	}

	texture, ok = hm.add(&engine.textures, Texture_Data{img = img, tex = gpu_texture})
	if !ok do return

	return
}

// Unloads a texture from memory.
unload_texture :: proc(texture: Texture)
{
	context.allocator = engine.ctx.allocator

	t, ok := hm.get(&engine.textures, texture)
	assert(ok)

	gpu.free_texture(t.tex)
	// NOTE: the CPU-side image data could be deleted in reload_texture but it's not so
	// that you can always fetch it who gives a shit
	image.destroy(t.img)
	hm.remove(&engine.textures, texture)
}

// Fetches a texture from the cache, and loads it if it's not in there yet. This means that it'll
// only be loaded once throughout the entire app's lifecycle. The engine will handle freeing the
// texture automatically.
fetch_texture :: proc(path: string) -> (texture: Texture, ok: bool) #optional_ok
{
	texture, ok = engine.texture_cache[path]
	if !ok {
		return reload_texture(path)
	}

	if !hm.is_valid(engine.textures, texture) {
		return reload_texture(path)
	}

	return texture, true
}

// Returns the texture size in pixels.
texture_size :: proc(texture: Texture) -> [2]i32
{
	t, ok := hm.get(&engine.textures, texture)
	assert(ok)

	return {i32(t.img.width), i32(t.img.height)}
}

Texture_Channels :: enum {
	GRAYSCALE       = 0,
	GRAYSCALE_ALPHA = 1,
	RGB             = 2,
	RGB_ALPHA       = 3,
}

// Returns the channels of a texture.
texture_channels :: proc(texture: Texture) -> Texture_Channels
{
	t, ok := hm.get(&engine.textures, texture)
	assert(ok)

	return Texture_Channels(t.img.channels)
}

// Returns the bit depth of the texture, most likely 8 or 16.
texture_bit_depth :: proc(texture: Texture) -> int
{
	t, ok := hm.get(&engine.textures, texture)
	assert(ok)

	return t.img.depth
}

// Returns the data for the texture.
texture_data :: proc(texture: Texture) -> []byte
{
	t, ok := hm.get(&engine.textures, texture)
	assert(ok)

	return t.img.pixels.buf[:]
}

// Returns the GPU handle for the texture.
texture_gpu_handle :: proc(texture: Texture) -> gpu.Texture
{
	t, ok := hm.get(&engine.textures, texture)
	assert(ok)

	return t.tex
}
