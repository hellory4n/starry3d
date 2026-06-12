package gpu_bufferless

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import st "../../starrylib"

app: struct {
	framebuffer:     gpu.Framebuffer,
	sampler:         gpu.Sampler,
	tri_pipeline:    gpu.Pipeline,
	postfx_pipeline: gpu.Pipeline,
}

new_app :: proc()
{
	dev := stapp.get_gpu()

	app.framebuffer = gpu.new_framebuffer(
		dev,
		stapp.framebuffer_sizei(),
		color_attachments = {gpu.Attachment{format = .RGBA_F32}},
	)
	// recreate framebuffer on resize
	stapp.on_resize(proc(userdata: rawptr, window: ^stapp.Window)
	{
		app.framebuffer = gpu.new_framebuffer(
			stapp.get_gpu(),
			stapp.framebuffer_sizei(),
			color_attachments = {gpu.Attachment{format = .RGBA_F32}},
		)
	})

	tri_vert := gpu.new_shader(dev, #load("tri.vert"), .VERTEX)
	tri_frag := gpu.new_shader(dev, #load("tri.frag"), .FRAGMENT)
	defer gpu.free_shader(tri_vert)
	defer gpu.free_shader(tri_frag)

	app.tri_pipeline = gpu.new_pipeline(
		dev,
		shaders = gpu.Render_Shaders{vertex = tri_vert, fragment = tri_frag},
	)

	postfx_vert := gpu.new_shader(dev, #load("postfx.vert"), .VERTEX)
	postfx_frag := gpu.new_shader(dev, #load("postfx.frag"), .FRAGMENT)
	defer gpu.free_shader(postfx_vert)
	defer gpu.free_shader(postfx_frag)

	app.postfx_pipeline = gpu.new_pipeline(
		dev,
		shaders = gpu.Render_Shaders{vertex = postfx_vert, fragment = postfx_frag},
	)

	app.sampler = gpu.new_sampler(dev, wrap = .CLAMP_TO_BORDER, filter = .NEAREST_NEIGHBOR)
}

free_app :: proc()
{
	gpu.free_pipeline(app.postfx_pipeline)
	gpu.free_pipeline(app.tri_pipeline)
	gpu.free_framebuffer(app.framebuffer)
}

render_app :: proc(dt: f32, dev: gpu.Device)
{
	// first pass - render triangle
	gpu.begin_render_pass(dev, app.framebuffer, clear_color = [4]f32{0, 0, 0, 1})
	gpu.bind_pipeline(dev, app.tri_pipeline)

	gpu.draw(dev, vertex_count = 3)
	gpu.end_render_pass(dev)

	// second pass - postprocessing
	// the framebuffer is sampled as a texture, and then rendered as a fullscreen quad
	gpu.begin_render_pass(dev, gpu.default_framebuffer(dev), clear_color = [4]f32{1, 0, 1, 1})
	gpu.bind_pipeline(dev, app.postfx_pipeline)

	color_fb := gpu.framebuffer_color_attachment(app.framebuffer, idx = 0)
	gpu.bind_texture(dev, color_fb, slot = 0)
	gpu.bind_sampler(dev, app.sampler, slot = 0)

	Uniforms :: struct {
		texture: i32 `gpu:"u_framebuffer"`,
	}
	gpu.set_uniforms(dev, Uniforms{texture = 0})

	gpu.draw(dev, vertex_count = 6)
	gpu.end_render_pass(dev)
}

main :: proc()
{
	ctx := st.init_better_context()
	defer st.free_better_context(&ctx)
	context = ctx.ctx

	stapp.run(
		app_name = "gpu framebuffers",
		app_version = {0, 1, 0},
		asset_dir = "samples/gpu_framebuffers",
		init_proc = new_app,
		free_proc = free_app,
		render_proc = render_app,
	)
}
