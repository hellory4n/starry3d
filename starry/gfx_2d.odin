package starry

import "gpu"

// TODO update everything to use command buffers with the new starrygpu version TREE(3)

// lua: `gfx.clear`
clear_screen :: proc(color: [4]f32)
{
	dev := gpu_device()
	gpu.begin_render_pass(
		dev,
		gpu.default_framebuffer(dev),
		color_load_op = .CLEAR,
		clear_color = color,
	)
}

end_drawing_2d :: proc()
{
	dev := gpu_device()
	gpu.end_render_pass(dev)
}
