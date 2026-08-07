package starry

import ft "../thirdparty/freetype"
import hb "../thirdparty/harfbuzz"
import "core:c"
import hm "core:container/handle_map"
import "core:fmt"
import "gpu"

FontData :: struct {
	handle:    hm.Handle32,
	buffer:    []byte,
	path:      string,
	face:      ft.Face,
	hb_font:   ^hb.font_t,
	// i32 is pixel size (rounded up if the source is a float)
	textures:  map[i32]map[hb.codepoint_t]FontGlyph,
	preloaded: bool,
}

FontGlyph :: struct {
	texture: gpu.Texture,
	size:    [2]i32,
	bearing: [2]i32,
}

// shared between freetype and harfbuzz
FT_LOAD_FLAGS :: ft.Load_Flags{.Render, .Force_Autohint}

load_font_from_memory :: proc(
	data: []byte,
	label := "[buffer]",
	preloaded := false,
) -> (
	h: hm.Handle32,
	ok: bool,
)
{
	face: ft.Face
	if err := ft.new_memory_face(global.ft, raw_data(data), c.long(len(data)), 0, &face);
	   err != .Ok {
		fmt.printfln("couldn't load %s: %s", label, err)
	}

	// this is wrong but harfbuzz might complain
	ft.set_pixel_sizes(face, 0, 16)
	hb_font := hb.ft_font_create(face, nil)
	textures := make(map[i32]map[hb.codepoint_t]FontGlyph, global.ctx.allocator)

	hb.ft_font_set_load_flags(hb_font, FT_LOAD_FLAGS)

	return hm.add(
			&global.fonts,
			FontData {
				path = label,
				face = face,
				hb_font = hb_font,
				textures = textures,
				buffer = data,
				preloaded = preloaded,
			},
		),
		true
}

// lua: `gfx.load_font`
load_font :: proc(path: string) -> (h: hm.Handle32, ok: bool)
{
	buffer, err := read_from_app_dir(path, context.allocator)
	if err != nil {
		fmt.printfln("couldn't load %s: %s", path, err)
		return {}, false
	}

	h, ok = load_font_from_memory(buffer, path)
	if ok {
		fmt.printfln("loaded %s (%v)", path, h)
	}
	return
}

// lua: `gfx.Font:__gc`
unload_font :: proc(h: hm.Handle32)
{
	font, ok := hm.get(&global.fonts, h)
	assert(ok)

	for _, texture_map in font.textures {
		for _, font_char in texture_map {
			gpu.free_texture(font_char.texture)
		}
		delete(texture_map)
	}
	delete(font.textures)

	hb.font_destroy(font.hb_font)

	ft.done_face(font.face)
	if !font.preloaded {
		delete(font.buffer)
	}

	fmt.printfln("unloaded %s (%v)", font.path, h)
	hm.remove(&global.fonts, h)
}

font_data :: proc(h: hm.Handle32) -> ^FontData
{
	font, ok := hm.get(&global.fonts, h)
	assert(ok)
	return font
}

// you'll never guess what this does
make_or_get_glyph_texture_from_font :: proc(
	h: hm.Handle32,
	size: i32,
	glyph_idx: hb.codepoint_t,
) -> (
	font_glyph: FontGlyph,
)
{
	font := font_data(h)
	texture_map, ok := &font.textures[size]
	if !ok {
		font.textures[size] = make(map[hb.codepoint_t]FontGlyph)
		texture_map = &font.textures[size]
	}

	font_glyph, ok = texture_map[glyph_idx]
	if ok {
		return font_glyph
	}

	ft.set_pixel_sizes(font.face, 0, u32(size))
	if err := ft.load_glyph(font.face, u32(glyph_idx), {.Render}); err != .Ok {
		fmt.printfln(
			"couldn't load glyph idx %d for font %q: %s",
			glyph_idx,
			font.path,
			err,
		)
	}

	font_glyph = FontGlyph {
		size    = {i32(font.face.glyph.bitmap.width), i32(font.face.glyph.bitmap.rows)},
		bearing = {i32(font.face.glyph.bitmap_left), i32(font.face.glyph.bitmap_top)},
	}

	if font_glyph.size != {0, 0} {
		font_glyph.texture = gpu.new_texture(
			gpu_device(),
			font_glyph.size,
			gpu_format = .GRAYSCALE_U8,
			input_format = .GRAYSCALE_U8,
			data = font.face.glyph.bitmap.buffer[:font.face.glyph.bitmap.width *
			font.face.glyph.bitmap.rows],
		)
	}

	texture_map[glyph_idx] = font_glyph
	return font_glyph
}
