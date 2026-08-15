package starry

import ft "../thirdparty/freetype"
import hb "../thirdparty/harfbuzz"
import "core:c"
import hm "core:container/handle_map"
import "core:math"
import "core:mem"
import "core:unicode"
import "core:unicode/utf8"
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
	CHARACTER,
	WORD,
}

HorizontalAlign :: enum {
	LEFT,
	CENTER,
	RIGHT,
}

VerticalAlign :: enum {
	TOP,
	CENTER,
	BOTTOM,
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
	halign:       HorizontalAlign,
	valign:       VerticalAlign,
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
	glyphs:  []GlyphInfo,
	width:   f32,
	ascent:  f32,
	descent: f32,
}

TextLayout :: struct {
	lines:  [dynamic]GlyphLine,
	height: f32,
	ascent: f32,
}

shape_text :: proc(desc: DrawTextDesc, allocator := context.allocator) -> []GlyphInfo
{
	font_data := font_data(desc.font)

	int_size := i32(math.ceil(desc.size))
	scale := desc.size / f32(int_size)

	hb.font_set_scale(font_data.hb_font, int_size * 64, int_size * 64)
	hb.font_set_ppem(font_data.hb_font, u32(int_size), u32(int_size))

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

font_vertical_metrics :: proc(desc: DrawTextDesc) -> (ascent, line_height: f32)
{
	font := font_data(desc.font)
	int_size := i32(math.ceil(desc.size))
	scale := desc.size / f32(int_size)

	ft.set_pixel_sizes(font.face, 0, u32(int_size))
	ascent = f32(font.face.size.metrics.ascender) / 64.0 * scale
	descent := f32(-font.face.size.metrics.descender) / 64.0 * scale
	line_height = ascent + descent
	return
}

glyph_line_vertical_metrics :: proc(glyphs: []GlyphInfo, size: f32) -> (ascent, descent: f32)
{
	int_size := i32(math.ceil(size))
	scale := size / f32(int_size)

	for g in glyphs {
		top := g.bearing.y * scale - g.offset.y
		bottom := (g.size.y - g.bearing.y * scale) + g.offset.y
		ascent = max(ascent, top)
		descent = max(descent, bottom)
	}
	return
}

line_spacing_px :: proc(desc: DrawTextDesc) -> f32
{
	em := desc.size
	return em * max(desc.line_spacing - 1, 0)
}

finish_line :: proc(layout: ^TextLayout, desc: DrawTextDesc, glyphs: []GlyphInfo, pen_x: f32)
{
	line_glyphs := glyphs
	ascent, descent := glyph_line_vertical_metrics(line_glyphs, desc.size)

	if ascent == 0 && descent == 0 {
		font_ascent, font_line_height := font_vertical_metrics(desc)
		ascent = font_ascent
		descent = font_line_height - font_ascent
	}

	append(
		&layout.lines,
		GlyphLine{glyphs = line_glyphs, width = pen_x, ascent = ascent, descent = descent},
	)
}

basic_text_layout :: proc(
	desc: DrawTextDesc,
	glyphs: []GlyphInfo,
	allocator := context.allocator,
) -> (
	layout: TextLayout,
)
{
	layout.lines = make([dynamic]GlyphLine, allocator)

	line_start_idx := 0
	pen_x: f32 = 0

	for glyph, i in glyphs {
		pen_x += glyph.advance.x

		if desc.text[glyph.cluster] == '\n' {
			finish_line(&layout, desc, glyphs[line_start_idx:i], pen_x)
			line_start_idx = i + 1
			pen_x = 0
		}
	}

	// last line
	if line_start_idx < len(glyphs) {
		finish_line(&layout, desc, glyphs[line_start_idx:], pen_x)
	}

	return layout
}

char_wrap_text_layout :: proc(
	desc: DrawTextDesc,
	glyphs: []GlyphInfo,
	allocator := context.allocator,
) -> (
	layout: TextLayout,
)
{
	layout.lines = make([dynamic]GlyphLine, allocator)

	line_start_idx := 0
	pen_x: f32 = 0

	for glyph, i in glyphs {
		visual_right_edge := pen_x + glyph.offset.x + glyph.bearing.x + glyph.size.x

		if desc.text[glyph.cluster] == '\n' {
			finish_line(&layout, desc, glyphs[line_start_idx:i], pen_x)
			line_start_idx = i + 1
			pen_x = 0
			continue
		}

		if pen_x > 0 && visual_right_edge > desc.bounds.x {
			finish_line(&layout, desc, glyphs[line_start_idx:i], pen_x)
			line_start_idx = i
			pen_x = 0
		}

		pen_x += glyph.advance.x
	}

	// last line
	if line_start_idx < len(glyphs) {
		finish_line(&layout, desc, glyphs[line_start_idx:], pen_x)
	}

	return layout
}

word_wrap_text_layout :: proc(
	desc: DrawTextDesc,
	glyphs: []GlyphInfo,
	allocator := context.allocator,
) -> (
	layout: TextLayout,
)
{
	// TODO kinda messy but i don't wanna touch it
	layout.lines = make([dynamic]GlyphLine, allocator)

	line_start_idx := 0
	pen_x: f32 = 0

	i := 0
	for i < len(glyphs) {
		glyph := glyphs[i]

		if desc.text[glyph.cluster] == '\n' {
			finish_line(&layout, desc, glyphs[line_start_idx:i], pen_x)
			line_start_idx = i + 1
			pen_x = 0
			i += 1
			continue
		}

		// find word length
		// words are sequences of non-whitespace glyphs
		word_start := i
		word_end := i
		word_advance: f32 = 0
		word_visual_right: f32 = 0

		for word_end < len(glyphs) {
			g := glyphs[word_end]
			r := utf8.rune_at(desc.text, int(g.cluster))

			if unicode.is_white_space(r) {
				break
			}

			candidate := word_advance + g.offset.x + g.bearing.x + g.size.x
			word_visual_right = max(word_visual_right, candidate)
			word_advance += g.advance.x
			word_end += 1
		}

		// leading whitespace that belongs with this word (or trailing on previous)
		// we treat spaces as breakable, so we measure them separately
		space_end := word_end
		space_advance: f32 = 0
		for space_end < len(glyphs) {
			g := glyphs[space_end]
			r := utf8.rune_at(desc.text, int(g.cluster))
			if !unicode.is_white_space(r) || r == '\n' {
				break
			}
			space_advance += g.advance.x
			space_end += 1
		}

		// does the whole word fit on the current line?
		word_fits := true
		if pen_x > 0 {
			visual_if_placed := pen_x + word_visual_right
			if visual_if_placed > desc.bounds.x {
				word_fits = false
			}
		}

		if !word_fits {
			finish_line(&layout, desc, glyphs[line_start_idx:word_start], pen_x)
			line_start_idx = word_start
			pen_x = 0
		}

		if word_advance > desc.bounds.x && pen_x == 0 {
			// fallback to character wrapping on very long words
			for j in word_start ..< word_end {
				g := glyphs[j]
				visual_right := pen_x + g.offset.x + g.bearing.x + g.size.x

				if pen_x > 0 && visual_right > desc.bounds.x {
					finish_line(&layout, desc, glyphs[line_start_idx:j], pen_x)
					line_start_idx = j
					pen_x = 0
				}
				pen_x += g.advance.x
			}
		} else {
			pen_x += word_advance
		}

		pen_x += space_advance

		i = space_end
	}

	// last line
	if line_start_idx < len(glyphs) {
		finish_line(&layout, desc, glyphs[line_start_idx:], pen_x)
	}

	return layout
}

text_layout :: proc(
	desc: DrawTextDesc,
	glyphs: []GlyphInfo,
	allocator := context.allocator,
) -> (
	layout: TextLayout,
)
{
	switch desc.wrap {
	case .OFF:
		layout = basic_text_layout(desc, glyphs, allocator)
	case .CHARACTER:
		layout = char_wrap_text_layout(desc, glyphs, allocator)
	case .WORD:
		layout = word_wrap_text_layout(desc, glyphs, allocator)
	}

	ascent, line_height := font_vertical_metrics(desc)
	spacing := line_spacing_px(desc)
	for _, i in layout.lines {
		layout.height += ascent
		if i + 1 < len(layout.lines) {
			layout.height += spacing
		}
	}
	
	return layout
}

TextUniform :: struct #align (16) #max_field_align(16) {
	color:      [4]f32,
	resolution: [2]f32,
	pos:        [2]f32,
	char_size:  [2]f32,
}

draw_text_layout :: proc(desc: DrawTextDesc, layout: TextLayout)
{
	dev := gpu_device()
	gpu.bind_pipeline(dev, global.gfx2d.text_pipeline)
	gpu.bind_uniform_buffer(dev, global.gfx2d.text_uniforms, slot = 0)

	int_size := i32(math.ceil(desc.size))
	is_fractional_size := !approx_eql(f32(int_size), desc.size)
	scale := desc.size / f32(int_size)

	if desc.size < 16 || (desc.size < 64 && !is_fractional_size) {
		gpu.bind_sampler(dev, global.samplers[.NEAREST_NEIGHBOR], slot = 0)
	} else {
		gpu.bind_sampler(dev, global.samplers[.BILINEAR], slot = 0)
	}

	spacing := line_spacing_px(desc)
	font_ascent, _ := font_vertical_metrics(desc)
	x := desc.pos.x
	y: f32
	switch desc.valign {
	case .TOP:
		y = desc.pos.y
	case .CENTER:
		y = desc.pos.y + (desc.bounds.y - layout.height) / 2
	case .BOTTOM:
		y = desc.pos.y + (desc.bounds.y - layout.height)
	}

	for line, i in layout.lines {
		draw_text_line(
			desc,
			line,
			i,
			len(layout.lines),
			int_size,
			scale,
			spacing,
			font_ascent,
			is_fractional_size,
			&y,
		)
	}
}

draw_text_line :: proc(
	desc: DrawTextDesc,
	line: GlyphLine,
	i: int,
	line_len: int,
	int_size: i32,
	scale: f32,
	spacing: f32,
	font_ascent: f32,
	is_fractional_size: bool,
	y: ^f32,
)
{
	dev := gpu_device()
	baseline := y^ + font_ascent

	x: f32
	switch desc.halign {
	case .LEFT:
		x = desc.pos.x
	case .CENTER:
		x = desc.pos.x + ((desc.bounds.x - line.width) / 2)
	case .RIGHT:
		x = desc.pos.x + (desc.bounds.x - line.width)
	}

	for glyph in line.glyphs {
		font_char := make_or_get_glyph_texture_from_font(desc.font, int_size, glyph.glyph)

		xpos := x + f32(glyph.bearing.x) * scale + glyph.offset.x
		ypos := baseline - glyph.bearing.y * scale + glyph.offset.y

		if desc.size < 16 || (desc.size < 64 && !is_fractional_size) {
			xpos = math.round(xpos)
			ypos = math.round(ypos)
		}

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

	y^ += font_ascent
	if i + 1 < line_len {
		y^ += spacing
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
	layout := text_layout(desc, glyphs, context.temp_allocator)
	draw_text_layout(desc, layout)
}

// lua: `gfx.measure_text`
measure_text :: proc(desc: DrawTextDesc) -> [2]f32
{
	glyphs := shape_text(desc, context.temp_allocator)
	layout := text_layout(desc, glyphs, context.temp_allocator)

	max_width: f32 = 0
	for line in layout.lines {
		if line.width > max_width {
			max_width = line.width
		}
	}

	return {max_width, layout.height}
}
