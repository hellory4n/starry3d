package starry

import "core:math"
import hm "core:container/handle_map"
import "gpu"
import "core:mem"

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

// note: defaults are handled when binding to lua
// lua: `gfx.draw_text`
draw_text :: proc(desc: DrawTextDesc)
{
	TextUniform :: struct #align (16) #max_field_align(16) {
		color:      [4]f32,
		resolution: [2]f32,
		pos:        [2]f32,
		char_size:  [2]f32,
	}

	dev := gpu_device()
	gpu.bind_pipeline(dev, global.gfx2d.text_pipeline)
	gpu.bind_uniform_buffer(dev, global.gfx2d.text_uniforms, slot = 0)
	gpu.bind_sampler(dev, global.samplers[.BILINEAR], slot = 0)

	int_size := i32(math.ceil(desc.size))
	tall_char_size := make_or_get_char_texture_from_font(desc.font, 'T', int_size).bearing.y

	x, y := desc.pos.x, desc.pos.y
	for r in desc.text {
		// TODO handle more whitespace characters
		if r == '\n' {
			x = desc.pos.x
			y += f32(tall_char_size) * desc.line_spacing
			continue
		}

		font_char := make_or_get_char_texture_from_font(desc.font, r, int_size)

		// for fractional sizes
		scale := desc.size / f32(int_size)
		xpos := x + f32(font_char.bearing.x) * scale
		ypos := y + f32(tall_char_size - font_char.bearing.y) * scale
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

		// advance is 1/64 pixels, so bitshift to convert it back to pixels
		x += f32(font_char.advance.x >> 6) * scale
		// y += f32(font_char.advance.x >> 6) * scale;
	}
}
