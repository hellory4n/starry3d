package gpu_storage_buffers

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import st "../../starrylib"
import "core:math/linalg"
import "core:mem"

app: struct {
	pipeline:       gpu.Pipeline,
	storage_buffer: gpu.Buffer,
}

// remember to follow std430 alignment rules
Triangle :: struct #align (16) #max_field_align(16) {
	transform: matrix[4, 4]f32,
	color:     [4]f32,
}

// here we put the info about each triangle we want to draw
// the storage buffer will then be filled with this array
TRIANGLES := [?]Triangle {
	Triangle {
		transform = linalg.matrix4_rotate(2, [3]f32{1, 0, 0}) *
		linalg.matrix4_translate([3]f32{-0.5, 0, 0}),
		color = [4]f32{1, 0, 0, 1},
	},
	Triangle {
		transform = linalg.matrix4_rotate(2, [3]f32{0, 1, 0}),
		color = [4]f32{0, 1, 0, 1},
	},
	Triangle {
		transform = linalg.matrix4_rotate(2, [3]f32{0, 0, 1}) *
		linalg.matrix4_translate([3]f32{0.5, 0, 0}),
		color = [4]f32{0, 0, 1, 1},
	},
}

new_app :: proc()
{
	dev := stapp.get_gpu()

	vert := gpu.new_shader(dev, #load("tri.vert"), .VERTEX)
	defer gpu.free_shader(vert)

	frag := gpu.new_shader(dev, #load("tri.frag"), .FRAGMENT)
	defer gpu.free_shader(frag)

	app.pipeline = gpu.new_pipeline(
		dev,
		shaders = gpu.Render_Shaders{vertex = vert, fragment = frag},
	)

	tris_bytes := mem.slice_to_bytes(TRIANGLES[:])
	app.storage_buffer = gpu.new_buffer(dev, .STORAGE, .READ_ONLY, len(tris_bytes), tris_bytes)
}

free_app :: proc()
{
	gpu.free_buffer(app.storage_buffer)
	gpu.free_pipeline(app.pipeline)
}

render_app :: proc(dt: f32, dev: gpu.Device)
{
	gpu.begin_render_pass(dev, gpu.default_framebuffer(dev), clear_color = [4]f32{0, 0, 0, 1})
	gpu.bind_pipeline(dev, app.pipeline)
	gpu.bind_storage_buffer(dev, app.storage_buffer, slot = 0)

	gpu.draw(dev, vertex_count = 3, instance_count = 3)
	gpu.end_render_pass(dev)
}

main :: proc()
{
	ctx := st.init_better_context()
	defer st.free_better_context(&ctx)
	context = ctx.ctx

	stapp.run(
		app_name = "gpu storage buffers",
		app_version = {0, 1, 0},
		asset_dir = "samples/gpu_storage_buffers",
		init_proc = new_app,
		free_proc = free_app,
		render_proc = render_app,
	)
}
