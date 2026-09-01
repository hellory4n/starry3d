package starry

import "core:c"
import hm "core:container/handle_map"
import "core:fmt"
import "gpu"
import stbi "vendor:stb/image"

// TODO texture caching
// TODO expose Image (cpu-side) to lua

TextureData :: struct {
	handle: hm.Handle32,
	path:   string,
	size:   ivec2,
	tex:    gpu.Texture,
}

load_texture_from_memory :: proc(data: []byte, label := "[buffer]") -> (h: hm.Handle32, ok: bool)
{
	x, y, channels_in_file: c.int
	img_data := stbi.load_from_memory(
		raw_data(data),
		c.int(len(data)),
		&x,
		&y,
		&channels_in_file,
		desired_channels = 4,
	)
	defer stbi.image_free(img_data)

	gpu_texture := gpu.new_texture(
		dev = gpu_device(),
		size = {x, y},
		input_format = .RGBA_U8,
		gpu_format = .RGBA_F32,
		data = img_data[:x * y * channels_in_file],
	)
	defer if !ok {
		gpu.free_texture(gpu_texture)
	}

	h = hm.add(&global.textures, TextureData{size = {x, y}, tex = gpu_texture, path = label})
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
	hm.remove(&global.textures, h)
	fmt.printfln("unloaded %s (%v)", texture.path, h)
}

texture_data :: proc(h: hm.Handle32) -> ^TextureData
{
	texture, ok := hm.get(&global.textures, h)
	assert(ok)
	return texture
}

texture_is_valid :: proc(h: hm.Handle32) -> bool
{
	return hm.is_valid(&global.textures, h)
}

texture_size :: proc(h: hm.Handle32) -> vec2
{
	texture := texture_data(h)
	// TODO i forgot why this returns floats
	return cast(vec2)texture.size
}
