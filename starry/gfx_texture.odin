package starry

import hm "core:container/handle_map"
import "core:fmt"
import "core:image"
@(require) import "core:image/jpeg"
@(require) import "core:image/png"
import "gpu"

// TODO texture caching
// TODO expose Image (cpu-side) to lua

TextureData :: struct {
	handle: hm.Handle32,
	img:    ^image.Image,
	tex:    gpu.Texture,
	path:   string,
}

load_texture_from_memory :: proc(data: []byte, label := "[buffer]") -> (h: hm.Handle32, ok: bool)
{
	img, err := image.load_from_bytes(data)
	if err != nil {
		fmt.printfln("couldn't load %s: %s", label, err)
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
	case 1:
		format = .GRAYSCALE_U8
	case 2:
		format = .GRAYSCALE_ALPHA_U8
	case 3:
		format = .RGB_U8
	case 4:
		format = .RGBA_U8
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

	h = hm.add(&global.textures, TextureData{img = img, tex = gpu_texture, path = label})
	return h, true
}

// lua: `gfx.load_texture`
load_texture :: proc(path: string) -> (h: hm.Handle32, ok: bool)
{
	buffer, err := read_from_app_dir(path, context.allocator)
	if err != nil {
		fmt.printfln("couldn't load %s: %s", path, err)
		return {}, false
	}
	defer delete(buffer)

	h, ok = load_texture_from_memory(buffer, path)
	if ok {
		fmt.printfln("loaded %s (%v)", path, h)
	}
	return
}

// lua: `gfx.Texture:__gc`
unload_texture :: proc(h: hm.Handle32)
{
	texture, ok := hm.get(&global.textures, h)
	assert(ok)

	gpu.free_texture(texture.tex)
	// TODO we are keeping the image data on the CPU for this long,
	// just so that we can access the width and height
	image.destroy(texture.img)
	hm.remove(&global.textures, h)
	fmt.printfln("unloaded %s (%v)", texture.path, h)
}

texture_data :: proc(h: hm.Handle32) -> TextureData
{
	texture, ok := hm.get(&global.textures, h)
	assert(ok)
	return texture^
}

texture_is_valid :: proc(h: hm.Handle32) -> bool
{
	return hm.is_valid(&global.textures, h)
}

texture_size :: proc(h: hm.Handle32) -> [2]f32
{
	texture := texture_data(h)
	return {f32(texture.img.width), f32(texture.img.height)}
}
