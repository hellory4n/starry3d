package sandbox

import strt "../starryrt"
import gpu "../starryrt/gpu"
import "core:fmt"
import glm "core:math/linalg/glsl"

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
	if strt.window_is_mouse_button_just_pressed(strt.main_window(), .LEFT) {
		fmt.println("Fuh")
	}
}

render_app :: proc()
{
	dev := strt.get_gpu()
	swap := strt.get_swapchain()

	gpu.begin_render_pass(dev, swap, [4]f32{0, 0, 0, 1})

	gpu.bind_pipeline(dev, app.pipeline)
	Uniforms :: struct {
		model: matrix[4, 4]f32 `gpu:"u_model"`,
		view:  matrix[4, 4]f32 `gpu:"u_view"`,
		proj:  matrix[4, 4]f32 `gpu:"u_proj"`,
	}
	gpu.set_uniforms(
		dev,
		Uniforms {
			model = glm.identity(matrix[4, 4]f32),
			view = glm.identity(matrix[4, 4]f32),
			proj = glm.identity(matrix[4, 4]f32),
		},
	)

	gpu.draw(dev, vertex_count = 3)

	gpu.end_render_pass(dev)
}

main :: proc()
{
	strt.run(
		app_name = "sandbox",
		app_version = {0, 1, 0},
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
	)
}
