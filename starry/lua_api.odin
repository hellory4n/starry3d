package starry

import "base:runtime"
import "gpu"

// TODO this sucks, delete this eventually

@(export)
st_app_gpu :: proc "c" () -> i32
{
	context = global.ctx
	return transmute(i32)gpu_device()
}

@(export)
stgpu_begin_render_pass :: proc "c" (
	dev: i32,
	framebuffer: i32,
	color_load_op: i32,
	color_store_op: i32,
	depth_load_op: i32,
	depth_store_op: i32,
	clear_color_r: f32,
	clear_color_g: f32,
	clear_color_b: f32,
	clear_color_a: f32,
	clear_depth: f32,
)
{
	context = global.ctx
	gpu.begin_render_pass(
		transmute(gpu.Device)dev,
		transmute(gpu.Framebuffer)framebuffer,
		gpu.Load_Op(color_load_op),
		gpu.Store_Op(color_store_op),
		gpu.Load_Op(depth_load_op),
		gpu.Store_Op(depth_store_op),
		{clear_color_r, clear_color_g, clear_color_b, clear_color_a},
		clear_depth,
	)
}

@(export)
stgpu_end_render_pass :: proc "c" (dev: i32)
{
	context = global.ctx
	gpu.end_render_pass(transmute(gpu.Device)dev)
}

@(export)
stgpu_default_framebuffer :: proc "c" (dev: i32) -> i32
{
	context = global.ctx
	return transmute(i32)gpu.default_framebuffer(transmute(gpu.Device)dev)
}
