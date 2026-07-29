package starry

import hm "core:container/handle_map"
import "gpu"

// TODO update everything to use command buffers with the new starrygpu version TREE(3)

init_2d_renderer :: proc()
{
	global.gfx2d.commands = make([dynamic]DrawCommand2D)
	dev := gpu_device()

	global.gfx2d.rect_uniforms = gpu.new_buffer(
		dev,
		{.UNIFORM},
		{.TRANSFER_DST},
		size_of(RectUniform),
		label = "gfx2d uniforms",
	)

	rect_vert := gpu.new_shader(
		dev,
		#load("shader/rect.vert"),
		.VERTEX,
		label = "gfx2d rect (vert)",
	)
	defer gpu.free_shader(rect_vert)

	rect_frag := gpu.new_shader(
		dev,
		#load("shader/rect.frag"),
		.FRAGMENT,
		label = "gfx2d rect (frag)",
	)
	defer gpu.free_shader(rect_frag)

	global.gfx2d.rect_pipeline = gpu.new_pipeline(
		dev,
		gpu.Render_Pipeline_Settings {
			vertex_shader = rect_vert,
			fragment_shader = rect_frag,
		},
		bindings = {
			{type = .UNIFORM_BUFFER, slot = 0},
			{type = .TEXTURE, slot = 0},
			{type = .SAMPLER, slot = 0},
		},
	)

	for &sampler, filter in global.gfx2d.samplers {
		// wrap doesn't really matter
		// TODO what if wrap does matter...
		sampler = gpu.new_sampler(dev, wrap = .CLAMP_TO_BORDER, filter = filter)
	}
}

free_2d_renderer :: proc()
{
	for sampler in global.gfx2d.samplers {
		gpu.free_sampler(sampler)
	}

	gpu.free_pipeline(global.gfx2d.rect_pipeline)
	gpu.free_buffer(global.gfx2d.rect_uniforms)
	delete(global.gfx2d.commands)
}

// lua: `gfx.clear`
clear_screen :: proc(color: [4]f32)
{
	dev := gpu_device()
	gpu.begin_render_pass(
		dev,
		gpu.default_framebuffer(dev),
		color_load_op = .CLEAR,
		clear_color = color,
	)

	clear(&global.gfx2d.commands)
}

end_drawing_2d :: proc()
{
	dev := gpu_device()

	// TODO prepare font atlas here
	for cmd in global.gfx2d.commands {
		run_2d_draw_command(cmd)
	}

	gpu.end_render_pass(dev)
}

DrawRectangleDesc :: struct {
	pos:          [2]f32,
	size:         [2]f32,
	origin:       [2]f32,
	rot:          f32,
	texture:      hm.Handle32,
	color:        [4]f32,
	filter:       gpu.Texture_Filter,
	texture_pos:  [2]f32,
	texture_size: [2]f32,
}

// note: defaults are handled when binding to lua
// lua: `gfx.draw_rectangle`
draw_rectangle :: proc(desc: DrawRectangleDesc)
{
	append(&global.gfx2d.commands, desc)
}

DrawTextDesc :: struct {
	text:   string,
	pos:    [2]f32,
	size:   f32,
	color:  [4]f32,
	font:   hm.Handle32,
	halign: enum {
		LEFT,
		CENTER,
		RIGHT,
	},
	valign: enum {
		TOP,
		MIDDLE,
		BOTTOM,
		BASELINE,
	},
}

// note: defaults are handled when binding to lua
// lua: `gfx.draw_text`
draw_text :: proc(desc: DrawTextDesc)
{
	append(&global.gfx2d.commands, desc)
}
