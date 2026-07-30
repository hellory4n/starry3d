package starry

import "core:fmt"
import "core:mem"
import "gpu"
import fons "vendor:fontstash"

DrawCommand2D :: union {
	DrawRectangleDesc,
	DrawTextDesc,
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

TextUniform :: struct #align (16) #max_field_align(16) {
	color:      [4]f32,
	resolution: [2]f32,
	xy0:        [2]f32,
	xy1:        [2]f32,
	uv0:        [2]f32,
	uv1:        [2]f32,
}

run_2d_draw_command :: proc(cmd: DrawCommand2D)
{
	dev := gpu_device()

	switch desc in cmd {
	case DrawRectangleDesc:
		gpu.bind_pipeline(dev, global.gfx2d.rect_pipeline)

		texdata: TextureData
		if texture_is_valid(desc.texture) {
			texdata = texture_data(desc.texture)
			gpu.bind_texture(dev, texdata.tex, slot = 0)
			gpu.bind_sampler(dev, global.gfx2d.samplers[desc.filter], slot = 0)
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

	case DrawTextDesc:
		gpu.bind_pipeline(dev, global.gfx2d.text_pipeline)
		gpu.bind_texture(dev, global.gfx2d.text_atlas, slot = 0)
		gpu.bind_sampler(dev, global.gfx2d.samplers[.NEAREST_NEIGHBOR], slot = 0)
		gpu.bind_uniform_buffer(dev, global.gfx2d.text_uniforms, slot = 0)

		fctx := &global.gfx2d.fonsctx
		fons.SetFont(fctx, font_data(desc.font).font_id)
		fons.SetSize(fctx, desc.size)
		fons.SetAlignHorizontal(fctx, desc.halign)
		fons.SetAlignVertical(fctx, desc.valign)
		fons.SetSpacing(fctx, desc.size * 1.2)

		// TODO make this instanced or batched i'm begging you

		for iter := fons.TextIterInit(fctx, desc.pos.x, desc.pos.y, desc.text); true; {
			quad: fons.Quad
			if !fons.TextIterNext(fctx, &iter, &quad) {
				break
			}

			uniforms := TextUniform {
				color      = desc.color,
				resolution = frame_sizef(),
				xy0        = {quad.x0, quad.y0},
				xy1        = {quad.x1, quad.y1},
				uv0        = {quad.s0, quad.t0},
				uv1        = {quad.s1, quad.t1},
			}
			gpu.update_buffer(
				dev,
				global.gfx2d.text_uniforms,
				mem.ptr_to_bytes(&uniforms),
			)

			gpu.draw(dev, vertex_count = 6)
		}
	}
}
