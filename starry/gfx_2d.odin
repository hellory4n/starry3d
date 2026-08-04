package starry

import ft "../thirdparty/freetype"
import hm "core:container/handle_map"
import "core:fmt"
import "gpu"

// TODO this is a horrible renderer:
// - there is no batching anywhere
// - fonts create a new texture per character, per font size
// - text isn't batched or instanced
// - the command system is useless (at least in this version)

init_2d_renderer :: proc()
{
	if is_headless() {
		return
	}

	dev := gpu_device()
	init_shared(dev)
	init_rect_pipeline(dev)
	init_text_pipeline(dev)

	init_shared :: #force_inline proc(dev: gpu.Device)
	{
		global.gfx2d.commands = make([dynamic]DrawCommand2D)

		for &sampler, filter in global.samplers {
			// wrap doesn't really matter
			// TODO what if wrap does matter...
			sampler = gpu.new_sampler(dev, wrap = .CLAMP_TO_BORDER, filter = filter)
		}
	}

	init_rect_pipeline :: #force_inline proc(dev: gpu.Device)
	{
		global.gfx2d.rect_uniforms = gpu.new_buffer(
			dev,
			{.UNIFORM},
			{.TRANSFER_DST},
			size_of(RectUniform),
			label = "gfx2d rect uniforms",
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
	}

	init_text_pipeline :: #force_inline proc(dev: gpu.Device)
	{
		if err := ft.init_free_type(&global.ft); err != .Ok {
			fmt.printfln("couldn't initialize FreeType: %s", err)
		}

		// TODO default fallback font?

		global.gfx2d.text_uniforms = gpu.new_buffer(
			dev,
			{.UNIFORM},
			{.TRANSFER_DST},
			size_of(TextUniform),
			label = "gfx2d text uniforms",
		)

		text_vert := gpu.new_shader(
			dev,
			#load("shader/text.vert"),
			.VERTEX,
			label = "gfx2d text (vert)",
		)
		defer gpu.free_shader(text_vert)

		text_frag := gpu.new_shader(
			dev,
			#load("shader/text.frag"),
			.FRAGMENT,
			label = "gfx2d text (frag)",
		)
		defer gpu.free_shader(text_frag)

		global.gfx2d.text_pipeline = gpu.new_pipeline(
			dev,
			gpu.Render_Pipeline_Settings {
				vertex_shader = text_vert,
				fragment_shader = text_frag,
			},
			bindings = {
				{type = .UNIFORM_BUFFER, slot = 0},
				{type = .TEXTURE, slot = 0},
				{type = .SAMPLER, slot = 0},
			},
		)
	}
}

free_2d_renderer :: proc()
{
	if is_headless() {
		return
	}

	ft.done_free_type(global.ft)

	for sampler in global.samplers {
		gpu.free_sampler(sampler)
	}

	gpu.free_pipeline(global.gfx2d.text_pipeline)
	gpu.free_buffer(global.gfx2d.text_uniforms)
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

AlignHorizontal :: enum {
	LEFT,
	CENTER,
	RIGHT,
}

AlignVertical :: enum {
	TOP,
	MIDDLE,
	BOTTOM,
	BASELINE,
}

DrawTextDesc :: struct {
	text:         string,
	pos:          [2]f32,
	size:         f32,
	color:        [4]f32,
	font:         hm.Handle32,
	line_spacing: f32,
}

// note: defaults are handled when binding to lua
// lua: `gfx.draw_text`
draw_text :: proc(desc: DrawTextDesc)
{
	append(&global.gfx2d.commands, desc)
}
