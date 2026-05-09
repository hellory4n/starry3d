package starryrt

import hm "core:container/handle_map"
import "core:image"
import "core:log"

Texture :: distinct hm.Handle32

Texture_Data :: struct {
	handle: Texture,
	img:    ^image.Image,
}

// Forces a texture to be reloaded, ignoring if it's already in texture cache
reload_texture :: proc(path: string) -> (texture: Texture, ok: bool) #optional_ok
{
	context.allocator = engine.ctx.allocator

	img, err := image.load(path)
	if err != nil {
		log.errorf("couldn't load %q: %s", path, err)
		return texture, false
	}

	texture, ok = hm.add(&engine.textures, Texture_Data{img = img})
	if !ok do return

	engine.texture_cache[path] = texture
	return
}

// Unloads a texture from memory.
unload_texture :: proc(texture: Texture)
{
	context.allocator = engine.ctx.allocator

	t, ok := hm.get(&engine.textures, texture)
	assert(ok)

	image.destroy(t.img)
	hm.remove(&engine.textures, texture)
}

// Fetches a texture from the cache, and loads if it's not in there yet. This means that it'll
// only be loaded once throughout the entire app's lifecycle.
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
