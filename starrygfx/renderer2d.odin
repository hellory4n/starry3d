package starrygfx

import stapp "../starryapp"
import "../starryapp/gpu"
import st "../starrylib"
import hm "core:container/handle_map"
import "core:mem"

// TODO command buffers exist for a reason
@(private)
Command_2D_Type :: enum {
	NIL,
	RECTANGLE,
	TEXTURE,
}

@(private)
Command_2D :: union #no_nil {
	Rect_Command_2D,
	Texture_Command_2D,
}

// idk man
@(private)
command_2d_type :: proc(cmd: Command_2D) -> Command_2D_Type
{
	switch _ in cmd {
	case Rect_Command_2D:
		return .RECTANGLE
	case Texture_Command_2D:
		return .TEXTURE
	}
	unreachable()
}

@(private)
Base_Command_2D :: struct {
	type: Command_2D_Type,
	pos:  [2]f32,
}

@(private)
Rect_Command_2D :: struct {
	pos:   [2]f32,
	size:  [2]f32,
	color: [4]f32,
}

@(private)
Texture_Command_2D :: struct {
	pos:      [2]f32,
	size:     [2]f32,
	modulate: [4]f32,
	texture:  gpu.Texture,
	filter:   gpu.Texture_Filter,
}

@(private)
Uniform_2D :: struct #align (16) #max_field_align(16) {
	color:      [4]f32,
	resolution: [2]f32,
	pos:        [2]f32,
	size:       [2]f32,
}

@(private)
init_2d :: proc()
{
	global.gfx2d.commands = make([dynamic]Command_2D)

	dev := stapp.get_gpu()

	global.gfx2d.uniform_buffer = gpu.new_buffer(
		dev,
		{.UNIFORM},
		{.TRANSFER_DST},
		size_of(Uniform_2D),
		label = "gfx2d uniforms",
	)

	rect_vert := gpu.new_shader(
		dev,
		#load("shader/2d_rect.vert"),
		.VERTEX,
		label = "gfx2d rect (vert)",
	)
	defer gpu.free_shader(rect_vert)

	rect_frag := gpu.new_shader(
		dev,
		#load("shader/2d_rect.frag"),
		.FRAGMENT,
		label = "gfx2d rect (frag)",
	)
	defer gpu.free_shader(rect_frag)

	global.gfx2d.pipelines[.RECTANGLE] = gpu.new_pipeline(
		dev,
		gpu.Render_Pipeline_Settings {
			vertex_shader = rect_vert,
			fragment_shader = rect_frag,
		},
		bindings = {gpu.Binding{type = .UNIFORM_BUFFER, slot = 0}},
	)

	texture_vert := gpu.new_shader(
		dev,
		#load("shader/2d_texture.vert"),
		.VERTEX,
		label = "gfx2d texture (vert)",
	)
	defer gpu.free_shader(texture_vert)

	texture_frag := gpu.new_shader(
		dev,
		#load("shader/2d_texture.frag"),
		.FRAGMENT,
		label = "gfx2d texture (frag)",
	)
	defer gpu.free_shader(texture_frag)

	global.gfx2d.pipelines[.TEXTURE] = gpu.new_pipeline(
		dev,
		gpu.Render_Pipeline_Settings {
			vertex_shader = texture_vert,
			fragment_shader = texture_frag,
		},
		bindings = {
			gpu.Binding{type = .UNIFORM_BUFFER, slot = 0},
			gpu.Binding{type = .SAMPLER, slot = 0},
			gpu.Binding{type = .TEXTURE, slot = 0},
		},
	)

	for &sampler, filter in global.gfx2d.samplers {
		// wrap doesn't really matter
		sampler = gpu.new_sampler(dev, wrap = .CLAMP_TO_BORDER, filter = filter)
	}
}

@(private)
free_2d :: proc()
{
	for sampler in global.gfx2d.samplers {
		gpu.free_sampler(sampler)
	}

	for pipeline in global.gfx2d.pipelines {
		// .NIL is a command type, and it is, well, nil
		// so we can't free .NIL
		if pipeline.idx != {} {
			gpu.free_pipeline(pipeline)
		}
	}

	gpu.free_buffer(global.gfx2d.uniform_buffer)
	delete(global.gfx2d.commands)
}

clear_screen :: proc(dev: gpu.Device, color := [4]f32{0, 0, 0, 1})
{
	gpu.begin_render_pass(
		dev,
		gpu.default_framebuffer(dev),
		color_load_op = .CLEAR,
		clear_color = color,
	)
	gpu.end_render_pass(dev)
}

render_2d :: proc(dev: gpu.Device)
{
	defer clear(&global.gfx2d.commands)

	// if the user wants to clear, they would have called `clear_screen`
	gpu.begin_render_pass(dev, gpu.default_framebuffer(dev), color_load_op = .DONT_CARE)
	defer gpu.end_render_pass(dev)

	last_cmd_type := Command_2D_Type.NIL

	for cmd in global.gfx2d.commands {
		cmd_type := command_2d_type(cmd)
		if cmd_type != last_cmd_type {
			last_cmd_type = cmd_type
			gpu.bind_pipeline(dev, global.gfx2d.pipelines[cmd_type])
			gpu.bind_uniform_buffer(dev, global.gfx2d.uniform_buffer, slot = 0)
		}

		switch c in cmd {
		case Rect_Command_2D:
			uniforms := Uniform_2D {
				color      = c.color,
				resolution = stapp.framebuffer_sizef(),
				pos        = c.pos,
				size       = c.size,
			}
			gpu.update_buffer(
				dev,
				global.gfx2d.uniform_buffer,
				mem.ptr_to_bytes(&uniforms),
			)

			gpu.draw(dev, vertex_count = 6)

		case Texture_Command_2D:
			uniforms := Uniform_2D {
				color      = c.modulate,
				resolution = stapp.framebuffer_sizef(),
				pos        = c.pos,
				size       = c.size,
			}
			gpu.update_buffer(
				dev,
				global.gfx2d.uniform_buffer,
				mem.ptr_to_bytes(&uniforms),
			)

			gpu.bind_sampler(dev, global.gfx2d.samplers[c.filter], slot = 0)
			gpu.bind_texture(dev, c.texture, slot = 0)

			gpu.draw(dev, vertex_count = 6)
		}
	}
}

draw_colored_rect :: proc(pos, size: [2]f32, color: [4]f32)
{
	append(&global.gfx2d.commands, Rect_Command_2D{pos = pos, size = size, color = color})
}

draw_texture_rect :: proc(
	pos, size: [2]f32,
	texture: stapp.Asset_Ref,
	modulate := [4]f32{1, 1, 1, 1},
	filter := gpu.Texture_Filter.BILINEAR,
)
{
	tex_data, ok := hm.get(&global.textures, texture.handle)
	assert(ok)
	assert(texture.type == st.strid("texture"))

	append(
		&global.gfx2d.commands,
		Texture_Command_2D {
			pos = pos,
			size = size,
			texture = tex_data.tex,
			modulate = modulate,
		},
	)
}
