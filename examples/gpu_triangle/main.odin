package gpu_triangle

import strt "../../starryrt"
import gpu "../../starryrt/gpu"
import "core:mem"

app: struct {
	pipeline:      gpu.Pipeline,
	vertex_buffer: gpu.Buffer,
	index_buffer:  gpu.Buffer,
}

Vertex :: struct {
	pos:   [2]f32,
	color: [3]f32,
}

@(rodata)
VERTICES := [?]Vertex {
	Vertex{pos = {0.0, 0.5}, color = {1.0, 0.0, 0.0}},
	Vertex{pos = {0.5, -0.5}, color = {0.0, 1.0, 0.0}},
	Vertex{pos = {-0.5, -0.5}, color = {0.0, 0.0, 1.0}},
}

@(rodata)
INDICES := [?]u32{0, 1, 2}

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
		vertex_size = size_of(Vertex),
		vertex_layout = []gpu.Vertex_Attribute {
			gpu.Vertex_Attribute {
				name = "pos",
				type = .VEC2_FLOAT32,
				offset = offset_of(Vertex, pos),
			},
			gpu.Vertex_Attribute {
				name = "color",
				type = .VEC3_FLOAT32,
				offset = offset_of(Vertex, color),
			},
		},
	)

	vert_bytes := mem.slice_to_bytes(VERTICES[:])
	app.vertex_buffer = gpu.new_buffer(dev, .VERTEX, .READ_ONLY, len(vert_bytes), vert_bytes)

	idx_bytes := mem.slice_to_bytes(INDICES[:])
	app.index_buffer = gpu.new_buffer(dev, .INDEX, .READ_ONLY, len(idx_bytes), idx_bytes)
}

free_app :: proc()
{
	gpu.free_buffer(app.index_buffer)
	gpu.free_buffer(app.vertex_buffer)
	gpu.free_pipeline(app.pipeline)
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	gpu.begin_render_pass(dev, swap, [4]f32{0, 0, 0, 1})

	gpu.bind_pipeline(dev, app.pipeline)
	gpu.bind_vertex_buffer(dev, app.vertex_buffer)
	gpu.bind_index_buffer(dev, app.index_buffer)

	gpu.draw_indexed(dev, index_count = 3)
	gpu.end_render_pass(dev)
}

main :: proc()
{
	strt.run(
		app_name = "gpu triangle",
		app_version = {0, 1, 0},
		asset_dir = "examples/gpu_triangle",
		init_proc = new_app,
		free_proc = free_app,
		render_proc = render_app,
	)
}
