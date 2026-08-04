package starry

import "core:mem"
import "gpu"

DrawCommand2D :: union {
	DrawRectangleDesc,
	DrawTextDesc,
}

run_2d_draw_command :: proc(cmd: DrawCommand2D)
{
	dev := gpu_device()

	switch desc in cmd {
	case DrawRectangleDesc:
		run_draw_rect_cmd(dev, desc)

	case DrawTextDesc:
		run_draw_text_cmd(dev, desc)
	}
}

RectUniform :: struct #align (16) #max_field_align(16) {
	color:        [4]f32,
	resolution:   [2]f32,
	pos:          [2]f32,
	size:         [2]f32,
	origin:       [2]f32,
	texture_size: [2]f32,
	crop_pos:     [2]f32,
	crop_size:    [2]f32,
	rot:          f32,
	has_texture:  b32,
}

run_draw_rect_cmd :: proc(dev: gpu.Device, desc: DrawRectangleDesc)
{
	gpu.bind_pipeline(dev, global.gfx2d.rect_pipeline)

	texdata: TextureData
	if texture_is_valid(desc.texture) {
		texdata = texture_data(desc.texture)^
		gpu.bind_texture(dev, texdata.tex, slot = 0)
		gpu.bind_sampler(dev, global.samplers[desc.filter], slot = 0)
	}

	uniforms := RectUniform {
		color        = desc.color,
		resolution   = frame_sizef(),
		pos          = desc.pos,
		size         = desc.size,
		origin       = desc.origin,
		texture_size = texture_size(desc.texture) if texture_is_valid(desc.texture) else {},
		crop_pos     = desc.texture_pos,
		crop_size    = desc.texture_size,
		rot          = desc.rot,
		has_texture  = b32(texture_is_valid(desc.texture)),
	}
	gpu.update_buffer(dev, global.gfx2d.rect_uniforms, mem.ptr_to_bytes(&uniforms))
	gpu.bind_uniform_buffer(dev, global.gfx2d.rect_uniforms, slot = 0)

	gpu.draw(dev, vertex_count = 6)
}

TextUniform :: struct #align (16) #max_field_align(16) {
	color:      [4]f32,
	resolution: [2]f32,
	pos:        [2]f32,
	char_size:  [2]f32,
}

run_draw_text_cmd :: proc(dev: gpu.Device, desc: DrawTextDesc)
{
	gpu.bind_pipeline(dev, global.gfx2d.text_pipeline)
	gpu.bind_uniform_buffer(dev, global.gfx2d.text_uniforms, slot = 0)
	gpu.bind_sampler(dev, global.samplers[.BILINEAR], slot = 0)

	tall_char_size := make_or_get_char_texture_from_font(desc.font, 'T').bearing.y

	x, y := desc.pos.x, desc.pos.y
	for r in desc.text {
		// TODO handle more whitespace characters
		if r == '\n' {
			x = desc.pos.x
			y += desc.size * desc.line_spacing
			continue
		}

		font_char := make_or_get_char_texture_from_font(desc.font, r)

		scale := desc.size / RENDERED_FONT_SIZE
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
