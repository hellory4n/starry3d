package gpu_bufferless

import strt "../../starryrt"
import gpu "../../starryrt/gpu"

app: struct {
	pipeline: gpu.Pipeline,
}

new_app :: proc()
{
	dev := strt.get_gpu()

	vert := gpu.new_shader(dev, #load("tri.vert"), .VERTEX)
	defer gpu.free_shader(vert)

	frag := gpu.new_shader(dev, #load("tri.frag"), .FRAGMENT)
	defer gpu.free_shader(frag)

	app.pipeline = gpu.new_pipeline(
		dev,
		shaders = gpu.Render_Shaders{vertex = vert, fragment = frag},
	)
}

free_app :: proc()
{
	gpu.free_pipeline(app.pipeline)
}

render_app :: proc()
{
	dev := strt.get_gpu()
	swap := strt.get_swapchain()

	gpu.begin_render_pass(dev, swap, [4]f32{0, 0, 0, 1})
	gpu.bind_pipeline(dev, app.pipeline)

	gpu.draw(dev, vertex_count = 3)
	gpu.end_render_pass(dev)
}

main :: proc()
{
	strt.run(
		app_name = "gpu bufferless",
		app_version = {0, 1, 0},
		asset_dir = "examples/gpu_bufferless",
		init_proc = new_app,
		free_proc = free_app,
		render_proc = render_app,
	)
}
