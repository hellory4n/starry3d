package sandbox

import strt "../starryrt"
import gpu "../starryrt/gpu"
import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:mem"

app: struct {
	pipeline:      gpu.Pipeline,
	vertex_buffer: gpu.Buffer,
	index_buffer:  gpu.Buffer,
	texture:       strt.Texture,
	sampler:       gpu.Sampler,
}

Vertex :: struct {
	pos: [2]f32,
	uv:  [2]f32,
}

@(rodata)
VERTICES := [?]Vertex {
	Vertex{pos = {0.0, 0.5}, uv = {0.5, 0.0}},
	Vertex{pos = {0.5, -0.5}, uv = {1.0, 1.0}},
	Vertex{pos = {-0.5, -0.5}, uv = {0.0, 1.0}},
}

@(rodata)
INDICES := [?]u32{0, 1, 2}

Uniforms :: struct {
	model:   matrix[4, 4]f32 `gpu:"u_model"`,
	view:    matrix[4, 4]f32 `gpu:"u_view"`,
	proj:    matrix[4, 4]f32 `gpu:"u_proj"`,
	texture: i32 `gpu:"u_texture"`,
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
		vertex_size = size_of(Vertex),
		vertex_layout = []gpu.Vertex_Attribute {
			gpu.Vertex_Attribute {
				name = "pos",
				type = .VEC2_FLOAT32,
				offset = offset_of(Vertex, pos),
			},
			gpu.Vertex_Attribute {
				name = "uv",
				type = .VEC2_FLOAT32,
				offset = offset_of(Vertex, uv),
			},
		},
	)

	vert_bytes := mem.slice_to_bytes(VERTICES[:])
	app.vertex_buffer = gpu.new_buffer(dev, .VERTEX, .READ_ONLY, len(vert_bytes), vert_bytes)

	idx_bytes := mem.slice_to_bytes(INDICES[:])
	app.index_buffer = gpu.new_buffer(dev, .INDEX, .READ_ONLY, len(idx_bytes), idx_bytes)

	app.sampler = gpu.new_sampler(dev, .TILE, .BILINEAR_FILTER)
	app.texture = strt.fetch_texture("sandbox/assets/hurley.png")
}

free_app :: proc()
{
	gpu.free_sampler(app.sampler)
	gpu.free_buffer(app.index_buffer)
	gpu.free_buffer(app.vertex_buffer)
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

	gpu.bind_vertex_buffer(dev, app.vertex_buffer)
	gpu.bind_index_buffer(dev, app.index_buffer)
	gpu.bind_texture(dev, strt.texture_gpu_handle(app.texture), slot = 0)
	gpu.bind_sampler(dev, app.sampler, slot = 0)

	gpu.set_uniforms(
		dev,
		Uniforms {
			model = glm.identity(matrix[4, 4]f32),
			view = glm.identity(matrix[4, 4]f32),
			proj = glm.identity(matrix[4, 4]f32),
			texture = 0,
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
