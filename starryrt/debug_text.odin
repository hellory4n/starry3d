package starryrt

import "core:mem"
import "core:strings"
import "gpu"

@(private)
Debug_Text_Vertex :: struct {
	pos:  [2]f32,
	uv:   [2]f32,
	char: i32,
}

@(private)
init_debug_text_renderer :: proc()
{
	engine.debugrender.mesh = make([dynamic]Debug_Text_Vertex)
	dev := get_gpu()

	vert := gpu.new_shader(dev, #load("shader/debugtext.vert"), .VERTEX)
	defer gpu.free_shader(vert)

	frag := gpu.new_shader(dev, #load("shader/debugtext.frag"), .FRAGMENT)
	defer gpu.free_shader(frag)

	engine.debugrender.pipeline = gpu.new_pipeline(
		dev,
		shaders = gpu.Render_Shaders{vertex = vert, fragment = frag},
		vertex_size = size_of(Debug_Text_Vertex),
		vertex_layout = []gpu.Vertex_Attribute {
			gpu.Vertex_Attribute {
				name = "pos",
				type = .VEC2_FLOAT32,
				offset = offset_of(Debug_Text_Vertex, pos),
			},
			gpu.Vertex_Attribute {
				name = "uv",
				type = .VEC2_FLOAT32,
				offset = offset_of(Debug_Text_Vertex, uv),
			},
			gpu.Vertex_Attribute {
				name = "char",
				type = .INT32,
				offset = offset_of(Debug_Text_Vertex, char),
			},
		},
	)

	VERTEX_BUFFER_SIZE :: 512 * 1024 // based on nothing
	engine.debugrender.vertex_buffer = gpu.new_buffer(
		dev,
		.VERTEX,
		.STREAMED,
		VERTEX_BUFFER_SIZE,
	)

	engine.debugrender.sampler = gpu.new_sampler(dev, .CLAMP_TO_EDGE, .NEAREST_NEIGHBOR)
	engine.debugrender.texture = load_texture_from_memory(#load("assets/debugtext.png"))
}

@(private)
free_debug_text_renderer :: proc()
{
	gpu.free_sampler(engine.debugrender.sampler)
	gpu.free_buffer(engine.debugrender.vertex_buffer)
	gpu.free_pipeline(engine.debugrender.pipeline)
	delete(engine.debugrender.mesh)
}

@(private)
render_debug_text :: proc()
{
	dev := get_gpu()
	swap := get_swapchain()

	gpu.update_buffer(
		dev,
		engine.debugrender.vertex_buffer,
		data = mem.slice_to_bytes(engine.debugrender.mesh[:]),
	)
	vertex_count := len(engine.debugrender.mesh)
	clear(&engine.debugrender.mesh)
	engine.debugrender.cursor = {0, 0}

	gpu.begin_render_pass(dev, swap)

	gpu.bind_pipeline(dev, engine.debugrender.pipeline)
	gpu.bind_vertex_buffer(dev, engine.debugrender.vertex_buffer)
	gpu.bind_texture(dev, texture_gpu_handle(engine.debugrender.texture), slot = 0)
	gpu.bind_sampler(dev, engine.debugrender.sampler, slot = 0)

	Uniforms :: struct {
		texture: i32 `gpu:"u_atlas_texture"`,
	}
	gpu.set_uniforms(dev, Uniforms{texture = 0})

	gpu.draw(dev, u32(vertex_count))
	gpu.end_render_pass(dev)
}

@(private)
DEBUG_TEXT_CHAR_SIZE :: [2]i32{8, 16}

// Shows text on the screen for debugging purposes. Requires `debug_text` to be enabled
// in `strt.run`.
debugtext :: proc(str: string)
{
	char_size := DEBUG_TEXT_CHAR_SIZE * 2
	if is_high_dpi() {
		char_size = cast([2]i32)(scale_factor() * cast([2]f32)char_size)
	}

	allowed_chars, ok := strings.ascii_set_make(
		" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n\r\t",
	)
	assert(ok, "what the fuck?")

	for char in str {
		char := char

		// fuck unicode
		// since this isn't C we can use \0 as the placeholder character
		if char < 0 do char = '\x00'
		if char > 255 do char = '\x00'
		if !strings.ascii_set_contains(allowed_chars, byte(char)) do char = '\x00'

		// whitespace fuckery
		if char == '\r' do continue
		if char == '\n' {
			engine.debugrender.cursor.x = 0
			engine.debugrender.cursor.y += char_size.y
			continue
		}
		if char == ' ' {
			engine.debugrender.cursor.x += char_size.x
			continue
		}
		// not pulling an andrew kelley
		if char == '\t' {
			engine.debugrender.cursor.x += char_size.x * 4
			continue
		}

		// fuck index buffers
		append(
			&engine.debugrender.mesh,
			Debug_Text_Vertex {
				pos = [2]f32{-1, -1} + cast([2]f32)(engine.debugrender.cursor +
					({1, 1} * char_size)) /
				framebuffer_sizef(),
				uv = {1, 0},
				char = i32(char),
			},
		)
		append(
			&engine.debugrender.mesh,
			Debug_Text_Vertex {
				pos = [2]f32{-1, -1} + cast([2]f32)(engine.debugrender.cursor +
					({1, 0} * char_size)) /
				framebuffer_sizef(),
				uv = {1, 1},
				char = i32(char),
			},
		)
		append(
			&engine.debugrender.mesh,
			Debug_Text_Vertex {
				pos = [2]f32{-1, -1} + cast([2]f32)(engine.debugrender.cursor +
					({0, 1} * char_size)) /
				framebuffer_sizef(),
				uv = {0, 0},
				char = i32(char),
			},
		)
		append(
			&engine.debugrender.mesh,
			Debug_Text_Vertex {
				pos = [2]f32{-1, -1} + cast([2]f32)(engine.debugrender.cursor +
					({1, 0} * char_size)) /
				framebuffer_sizef(),
				uv = {1, 1},
				char = i32(char),
			},
		)
		append(
			&engine.debugrender.mesh,
			Debug_Text_Vertex {
				pos = [2]f32{-1, -1} + cast([2]f32)(engine.debugrender.cursor +
					({0, 0} * char_size)) /
				framebuffer_sizef(),
				uv = {0, 1},
				char = i32(char),
			},
		)
		append(
			&engine.debugrender.mesh,
			Debug_Text_Vertex {
				pos = [2]f32{-1, -1} + cast([2]f32)(engine.debugrender.cursor +
					({0, 1} * char_size)) /
				framebuffer_sizef(),
				uv = {0, 0},
				char = i32(char),
			},
		)

		// fuck word wrap
		engine.debugrender.cursor.x += char_size.x
	}
}
