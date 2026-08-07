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

TextWrap :: enum {
	OFF,
	WORD,
}

DrawTextDesc :: struct {
	text:         string,
	pos:          [2]f32,
	size:         f32,
	color:        [4]f32,
	font:         hm.Handle32,
	line_spacing: f32,
	wrap:         TextWrap,
	bounds:       [2]f32,
}

GlyphInfo :: struct {
	glyph:   hb.codepoint_t,
	cluster: u32, // original byte/rune offset
	advance: [2]f32,
	offset:  [2]f32,
	size:    [2]f32,
	bearing: [2]f32,
}

GlyphLine :: struct {
	glyphs: []GlyphInfo,
}

shape_text :: proc(desc: DrawTextDesc, allocator := context.allocator) -> []GlyphInfo
{
	font_data := font_data(desc.font)

	int_size := i32(math.ceil(desc.size))
	scale := desc.size / f32(int_size)

	ft.set_pixel_sizes(font_data.face, 0, u32(int_size))

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
	info_ptr := cast([^]hb.glyph_info_t)hb.buffer_get_glyph_infos(buf, &count)
	info := info_ptr[:count]

	pos_ptr := cast([^]hb.glyph_position_t)hb.buffer_get_glyph_positions(buf, &count)
	pos := pos_ptr[:count]

	glyphs := make([]GlyphInfo, count, allocator)

	for i in 0 ..< count {
		gid := info[i].codepoint

		glyph := GlyphInfo {
			glyph   = info[i].codepoint,
			cluster = info[i].cluster,
			advance = {
				f32(pos[i].x_advance) / 64.0 * scale,
				f32(pos[i].y_advance) / 64.0 * scale,
			},
			offset  = {
				f32(pos[i].x_offset) / 64.0 * scale,
				f32(pos[i].y_offset) / 64.0 * scale,
			},
		}

		font_char := make_or_get_glyph_texture_from_font(desc.font, int_size, gid)
		glyph.bearing = cast([2]f32)font_char.bearing
		glyph.size = (cast([2]f32)font_char.size) * scale

		glyphs[i] = glyph
	}

	return glyphs
}

basic_text_layout :: proc(
	desc: DrawTextDesc,
	glyphs: []GlyphInfo,
	allocator := context.allocator,
) -> [dynamic]GlyphLine
{
	lines := make([dynamic]GlyphLine, allocator)

	line_start_idx := 0
	for glyph, i in glyphs {
		if desc.text[glyph.cluster] == '\n' {
			append(&lines, GlyphLine{glyphs = glyphs[line_start_idx:i]})
			line_start_idx = i + 1
		}
	}
	append(&lines, GlyphLine{glyphs = glyphs[line_start_idx:len(glyphs)]})

	return lines
}

text_layout :: proc(
	desc: DrawTextDesc,
	glyphs: []GlyphInfo,
	allocator := context.allocator,
) -> [dynamic]GlyphLine
{
	switch desc.wrap {
	case .OFF:
		return basic_text_layout(desc, glyphs, allocator)
	case .WORD:
		unimplemented()
	}
	unreachable()
}

TextUniform :: struct #align (16) #max_field_align(16) {
	color:      [4]f32,
	resolution: [2]f32,
	pos:        [2]f32,
	char_size:  [2]f32,
}

draw_glyph_lines :: proc(desc: DrawTextDesc, lines: [dynamic]GlyphLine)
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

	x, y := desc.pos.x, desc.pos.y
	for line in lines {
		for glyph in line.glyphs {
			font_char := make_or_get_glyph_texture_from_font(
				desc.font,
				int_size,
				glyph.glyph,
			)

			xpos := x + f32(glyph.bearing.x) * scale + glyph.offset.x
			ypos := y + (f32(tall_char_size) - glyph.bearing.y) * scale

			// missing texture == size is 0 == rendering whitespace
			if font_char.texture != {} {
				gpu.bind_texture(dev, font_char.texture, slot = 0)

				uniforms := TextUniform {
					color      = desc.color,
					resolution = frame_sizef(),
					pos        = {xpos, ypos},
					char_size  = glyph.size,
				}
				gpu.update_buffer(
					dev,
					global.gfx2d.text_uniforms,
					mem.ptr_to_bytes(&uniforms),
				)
				gpu.draw(dev, vertex_count = 6)
			}

			x += glyph.advance.x
		}

		x = desc.pos.x
		y += f32(tall_char_size) * desc.line_spacing
	}
}

// note: defaults are handled when binding to lua
// lua: `gfx.draw_text`
draw_text :: proc(desc: DrawTextDesc)
{
	// why
	if len(desc.text) == 0 {
		return
	}

	glyphs := shape_text(desc, context.temp_allocator)
	lines := text_layout(desc, glyphs, context.temp_allocator)
	draw_glyph_lines(desc, lines)
}
