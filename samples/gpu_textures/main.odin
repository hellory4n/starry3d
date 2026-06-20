package gpu_textures

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import stgfx "../../starrygfx"
import st "../../starrylib"
import "core:mem"

app: struct {
	pipeline:       gpu.Pipeline,
	vertex_buffer:  gpu.Buffer,
	index_buffer:   gpu.Buffer,
	texture:        stapp.Asset_Handle,
	sampler:        gpu.Sampler,
}

Vertex :: struct {
	pos: [2]f32,
	uv:  [2]f32,
}

@(rodata)
VERTICES := [?]Vertex {
	Vertex{pos = {0.5, 0.5}, uv = {1.0, 0.0}},
	Vertex{pos = {0.5, -0.5}, uv = {1.0, 1.0}},
	Vertex{pos = {-0.5, -0.5}, uv = {0.0, 1.0}},
	Vertex{pos = {-0.5, 0.5}, uv = {0.0, 0.0}},
}

@(rodata)
INDICES := [?]u32{0, 1, 3, 1, 2, 3}

new_app :: proc()
{
	stgfx.init_asset_loaders()
	dev := stapp.get_gpu()

	vert := gpu.new_shader(dev, #load("shader.vert"), .VERTEX)
	defer gpu.free_shader(vert)

	frag := gpu.new_shader(dev, #load("shader.frag"), .FRAGMENT)
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

	app.sampler = gpu.new_sampler(dev, wrap = .TILE, filter = .NEAREST_NEIGHBOR)
	// parses texture and uploads it to the gpu, through `gpu.new_texture`
	// see starrygfx/texture.odin if you don't want to use the asset system
	app.texture = stapp.load(stgfx.ASSET_TEXTURE, "fish.png")
}

free_app :: proc()
{
	gpu.free_sampler(app.sampler)
	gpu.free_buffer(app.index_buffer)
	gpu.free_buffer(app.vertex_buffer)
	gpu.free_pipeline(app.pipeline)

	stgfx.free_asset_loaders()
}

render_app :: proc(dt: f32, dev: gpu.Device)
{
	gpu.begin_render_pass(dev, gpu.default_framebuffer(dev), clear_color = [4]f32{0, 0, 0, 1})

	gpu.bind_pipeline(dev, app.pipeline)
	gpu.bind_vertex_buffer(dev, app.vertex_buffer)
	gpu.bind_index_buffer(dev, app.index_buffer)
	gpu.bind_texture(dev, stgfx.texture_gpu_handle(app.texture), slot = 0)
	gpu.bind_sampler(dev, app.sampler, slot = 0)

	gpu.draw_indexed(dev, index_count = 6)
	gpu.end_render_pass(dev)
}

main :: proc()
{
	ctx := st.init_better_context()
	defer st.free_better_context(&ctx)
	context = ctx.ctx

	stapp.run(
		app_name = "gpu textures",
		app_version = {0, 1, 0},
		asset_dir = "samples/gpu_textures",
		init_proc = new_app,
		free_proc = free_app,
		render_proc = render_app,
	)
}
