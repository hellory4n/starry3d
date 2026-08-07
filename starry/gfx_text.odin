package starry

import ft "../thirdparty/freetype"
import hb "../thirdparty/harfbuzz"
import "core:c"
import hm "core:container/handle_map"
import "core:math"
import "core:mem"
import "gpu"

AlignHorizontal :: enum {
	LEFT,
	CENTER,
	RIGHT,
}

AlignVertical :: enum {
	TOP,
	MIDDLE,
	BOTTOM,
	BASELINE,
}

DrawTextDesc :: struct {
	text:         string,
	pos:          [2]f32,
	size:         f32,
	color:        [4]f32,
	font:         hm.Handle32,
	line_spacing: f32,
}

TextUniform :: struct #align (16) #max_field_align(16) {
	color:      [4]f32,
	resolution: [2]f32,
	pos:        [2]f32,
	char_size:  [2]f32,
}
// note: defaults are handled when binding to lua
// lua: `gfx.draw_text`
draw_text :: proc(desc: DrawTextDesc)
{
	dev := gpu_device()
	gpu.bind_pipeline(dev, global.gfx2d.text_pipeline)
	gpu.bind_uniform_buffer(dev, global.gfx2d.text_uniforms, slot = 0)
	gpu.bind_sampler(dev, global.samplers[.BILINEAR], slot = 0)

	int_size := i32(math.ceil(desc.size))
	scale := desc.size / f32(int_size)

	font_data := font_data(desc.font)
	t_glyph: hb.codepoint_t
	ok := hb.font_get_glyph(font_data.hb_font, 'T', 0, &t_glyph)
	ensure(bool(ok), "how is there no T in your font?????")
	tall_char_size :=
		make_or_get_glyph_texture_from_font(desc.font, int_size, t_glyph).bearing.y

	// shaping time
	// TODO this is allocating every frame. you can't set custom allocators. worrying
	buf := hb.buffer_create()
	defer hb.buffer_destroy(buf)

	hb.buffer_add_utf8(
		buf,
		raw_data(desc.text),
		c.int(len(desc.text)),
		0,
		c.int(len(desc.text)),
	)
	hb.buffer_guess_segment_properties(buf)
	hb.shape(font_data.hb_font, buf, nil, 0)

	// TODO are these always the same length? if not then fuck me
	count: c.uint
	infos_ptr := cast([^]hb.glyph_info_t)hb.buffer_get_glyph_infos(buf, &count)
	infos := infos_ptr[:count]

	pos_ptr := cast([^]hb.glyph_position_t)hb.buffer_get_glyph_positions(buf, &count)
	pos := pos_ptr[:count]

	x, y := desc.pos.x, desc.pos.y
	for i in 0 ..< count {
		gid := infos[i].codepoint

		// TODO handle more whitespace characters
		if desc.text[infos[i].cluster] == '\n' {
			x = desc.pos.x
			y += f32(tall_char_size) * desc.line_spacing
			continue
		}

		font_char := make_or_get_glyph_texture_from_font(desc.font, int_size, gid)

		// harfbuzz positions are in 26.6 fixed-point
		x_offset := f32(pos[i].x_offset) / 64.0 * scale
		y_offset := f32(pos[i].y_offset) / 64.0 * scale
		x_advance := f32(pos[i].x_advance) / 64.0 * scale
		y_advance := f32(pos[i].y_advance) / 64.0 * scale

		xpos := x + f32(font_char.bearing.x) * scale + x_offset
		ypos := y + f32(tall_char_size - font_char.bearing.y) * scale + y_offset
		w := f32(font_char.size.x) * scale
		h := f32(font_char.size.y) * scale

		// missing texture == size is 0 == rendering whitespace
		if font_char.texture != {} {
			gpu.bind_texture(dev, font_char.texture, slot = 0)

			uniforms := TextUniform {
				color      = desc.color,
				resolution = frame_sizef(),
				pos        = {xpos, ypos},
				char_size  = {w, h},
			}
			gpu.update_buffer(
				dev,
				global.gfx2d.text_uniforms,
				mem.ptr_to_bytes(&uniforms),
			)
			gpu.draw(dev, vertex_count = 6)
		}

		x += x_advance
		y += y_advance
	}
}
