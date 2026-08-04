package starry

import ft "../thirdparty/freetype"
import "core:c"
import hm "core:container/handle_map"
import "core:fmt"
import "gpu"

FontData :: struct {
	handle:    hm.Handle32,
	buffer:    []byte,
	path:      string,
	face:      ft.Face,
	textures:  map[rune]FontCharacter,
	preloaded: bool,
}

FontCharacter :: struct {
	texture: gpu.Texture,
	size:    [2]i32,
	bearing: [2]i32,
	advance: [2]i32,
}

// should be enough for now
// TODO expose this?
RENDERED_FONT_SIZE :: 64

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

	ft.set_pixel_sizes(face, 0, 96)

	textures := make(map[rune]FontCharacter, global.ctx.allocator)

	return hm.add(
			&global.fonts,
			FontData {
				path = label,
				face = face,
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

	for _, t in font.textures {
		gpu.free_texture(t.texture)
	}
	delete(font.textures)

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
make_or_get_char_texture_from_font :: proc(h: hm.Handle32, r: rune) -> FontCharacter
{
	font := font_data(h)
	font_char, ok := font.textures[r]
	if ok {
		return font_char
	}

	if err := ft.load_char(font.face, c.ulong(r), {.Render}); err != .Ok {
		fmt.printfln("couldn't load glyph for font loaded from %q: %s", font.path, err)
	}

	font_char = FontCharacter {
		size    = {i32(font.face.glyph.bitmap.width), i32(font.face.glyph.bitmap.rows)},
		bearing = {i32(font.face.glyph.bitmap_left), i32(font.face.glyph.bitmap_top)},
		advance = {i32(font.face.glyph.advance.x), i32(font.face.glyph.advance.y)},
	}

	if font_char.size != {0, 0} {
		font_char.texture = gpu.new_texture(
			gpu_device(),
			font_char.size,
			gpu_format = .GRAYSCALE_U8,
			input_format = .GRAYSCALE_U8,
			data = font.face.glyph.bitmap.buffer[:font.face.glyph.bitmap.width *
			font.face.glyph.bitmap.rows],
		)
	}

	font.textures[r] = font_char
	return font_char
}
