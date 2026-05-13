package debug_text

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

update_app :: proc(dt: f32)
{
	strt.debugtext("It is akin to gratitude.\n")
	strt.debugtext("I am quite fond of the death penalty.\n")
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	gpu.begin_render_pass(dev, swap, [4]f32{0, 0, 0, 1})
	gpu.bind_pipeline(dev, app.pipeline)

	gpu.draw(dev, vertex_count = 3)
	gpu.end_render_pass(dev)
}

main :: proc()
{
	strt.run(
		app_name = "debug text",
		app_version = {0, 1, 0},
		asset_dir = "examples/debug_text",
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
		debug_text_enabled = true,
	)
}
