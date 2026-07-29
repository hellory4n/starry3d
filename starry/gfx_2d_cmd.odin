package starry

import "core:mem"
import "gpu"

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
			texture_size = {f32(texdata.img.width), f32(texdata.img.height)} if texdata.img != nil else {},
			crop_pos     = desc.texture_pos,
			crop_size    = desc.texture_size,
			rot          = desc.rot,
			has_texture  = texdata.img != nil,
		}
		gpu.update_buffer(dev, global.gfx2d.rect_uniforms, mem.ptr_to_bytes(&uniforms))
		gpu.bind_uniform_buffer(dev, global.gfx2d.rect_uniforms, slot = 0)

		gpu.draw(dev, vertex_count = 6)

	case DrawTextDesc:
		unimplemented("big massive batched renderer")
	}
}
