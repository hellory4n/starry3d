package starry

import ft "../thirdparty/freetype"
import hm "core:container/handle_map"
import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:mem"
import "gpu"

// TODO this is a horrible renderer:
// - there is no batching anywhere
// - fonts create a new texture per character, per (integer) size
// - text isn't batched or instanced
// - text layout should be cached (it's not exactly trivial)

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

		ok: bool
		global.default_font, ok = load_font_from_memory(
			#load("assets/NotoSans-Medium.ttf"),
			label = "NotoSans-Medium.ttf (preloaded)",
			preloaded = true,
		)
		assert(ok)
	}
}

free_2d_renderer :: proc()
{
	if is_headless() {
		return
	}

	unload_font(global.default_font)
	ft.done_free_type(global.ft)

	for sampler in global.samplers {
		gpu.free_sampler(sampler)
	}

	gpu.free_pipeline(global.gfx2d.text_pipeline)
	gpu.free_buffer(global.gfx2d.text_uniforms)
	gpu.free_pipeline(global.gfx2d.rect_pipeline)
	gpu.free_buffer(global.gfx2d.rect_uniforms)
}

RenderPassDesc :: struct {
	clear_color: Maybe(vec4),
}

// lua: `gfx.begin_render_pass`
begin_render_pass :: proc(desc: RenderPassDesc)
{
	dev := gpu_device()

	switch clear_color in desc.clear_color {
	case vec4:
		gpu.begin_render_pass(
			dev,
			gpu.default_framebuffer(dev),
			color_load_op = .CLEAR,
			clear_color = clear_color,
		)

	case:
		gpu.begin_render_pass(dev, gpu.default_framebuffer(dev), color_load_op = .LOAD)
	}
}

// lua: `gfx.end_render_pass`
end_render_pass :: proc()
{
	dev := gpu_device()
	gpu.end_render_pass(dev)
}

// lua: `gfx.set_scissor`
set_scissor :: proc(pos: Maybe(vec2), size: Maybe(vec2))
{
	dev := gpu_device()

	ipos, isize: Maybe(ivec2)
	if size != nil {
		isize = cast(ivec2)linalg.round(size.?)
	}
	if pos != nil {
		ipos = cast(ivec2)linalg.round(pos.?)
		ipos = ivec2{ipos.?.x, frame_sizei().y - ipos.?.y - (isize.? or_else ivec2{}).y}
	}

	gpu.set_scissor(dev, ipos, isize)
}

RectUniform :: struct #align (16) #max_field_align(16) {
	color:        vec4,
	resolution:   vec2,
	pos:          vec2,
	size:         vec2,
	origin:       vec2,
	texture_size: vec2,
	crop_pos:     vec2,
	crop_size:    vec2,
	rot:          f32,
	has_texture:  b32,
}

// for both gfx.draw_rectangle and gfx.draw_rectangle_outline
DrawRectangleDesc :: struct {
	pos:          vec2,
	size:         vec2,
	origin:       vec2,
	rot:          f32,
	texture:      hm.Handle32,
	color:        vec4,
	filter:       gpu.Texture_Filter,
	texture_pos:  vec2,
	texture_size: vec2,
	border_width: f32,
}

// note: defaults are handled when binding to lua
// lua: `gfx.draw_rectangle`
draw_rectangle :: proc(desc: DrawRectangleDesc)
{
	dev := gpu_device()
	gpu.bind_pipeline(dev, global.gfx2d.rect_pipeline)

	texdata: TextureData
	if texture_is_valid(desc.texture) {
		texdata = texture_data(desc.texture)^
		gpu.bind_texture(dev, texdata.tex, slot = 0)
		gpu.bind_sampler(dev, global.samplers[desc.filter], slot = 0)
	}

	uniforms := RectUniform {
		color        = desc.color,
		resolution   = frame_sizef(),
		pos          = desc.pos,
		size         = desc.size,
		origin       = desc.origin,
		texture_size = texture_size(desc.texture) if texture_is_valid(desc.texture) else {},
		crop_pos     = desc.texture_pos,
		crop_size    = desc.texture_size,
		rot          = desc.rot,
		has_texture  = b32(texture_is_valid(desc.texture)),
	}
	gpu.update_buffer(dev, global.gfx2d.rect_uniforms, mem.ptr_to_bytes(&uniforms))
	gpu.bind_uniform_buffer(dev, global.gfx2d.rect_uniforms, slot = 0)

	gpu.draw(dev, vertex_count = 6)
}

// note: defaults are handled when binding to lua
// lua: `gfx.draw_rectangle`
draw_rectangle_outline :: proc(desc: DrawRectangleDesc)
{
	// TODO this sucks
	border_width := math.abs(desc.border_width)
	// don't divide by 0
	if border_width == 0 {
		return
	}

	size := desc.size
	pos := desc.pos
	origin := desc.origin

	// left and right bars are shorter to not overdraw
	h_short := size.y - border_width * 2
	outer_top_left := vec2{pos.x - size.x * origin.x, pos.y - size.y * origin.y}

	// top
	draw_rectangle(
		{
			pos    = pos, // shared pivot
			size   = {size.x, border_width},
			origin = {origin.x, (size.y * origin.y) / border_width},
			rot    = desc.rot,
			color  = desc.color,
		},
	)

	// bottom
	draw_rectangle(
		{
			pos = pos,
			size = {size.x, border_width},
			origin = {
				origin.x,
				(pos.y - (outer_top_left.y + size.y - border_width)) /
				border_width,
			},
			rot = desc.rot,
			color = desc.color,
		},
	)

	// left
	draw_rectangle(
		{
			pos = pos,
			size = {border_width, h_short},
			origin = {
				(size.x * origin.x) / border_width,
				(pos.y - (outer_top_left.y + border_width)) / h_short,
			},
			rot = desc.rot,
			color = desc.color,
		},
	)

	// right (short)
	draw_rectangle(
		{
			pos = pos,
			size = {border_width, h_short},
			origin = {
				(pos.x - (outer_top_left.x + size.x - border_width)) /
				border_width,
				(pos.y - (outer_top_left.y + border_width)) / h_short,
			},
			rot = desc.rot,
			color = desc.color,
		},
	)
}
