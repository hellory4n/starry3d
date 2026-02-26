package starryrt

import stlib "../starrylib"
import "base:runtime"
import "core:c"
import "core:log"
import "core:strings"
import stbi "vendor:stb/image"
import "vendor:wgpu"
import "vendor:wgpu/glfwglue"

@(private)
Debug_Text_Vertex :: struct {
	position: [2]f32,
	uv:       [2]f32,
	char:     i32,
}

// has to be global otherwise callback stuff could get fucky
@(private)
render: struct {
	ctx:                          runtime.Context, // used in callbacks
	debug_text_mesh:              [dynamic]Debug_Text_Vertex,
	debug_text_cursor:            [2]i32,
	debug_text_font_data:         [^]u8,
	// madness
	instance:                     wgpu.Instance,
	surface:                      wgpu.Surface,
	adapter:                      wgpu.Adapter,
	device:                       wgpu.Device,
	queue:                        wgpu.Queue,
	voxel_shader:                 wgpu.ShaderModule,
	debug_text_shader:            wgpu.ShaderModule,
	voxel_pipeline_layout:        wgpu.PipelineLayout,
	voxel_pipeline:               wgpu.RenderPipeline,
	debug_text_pipeline_layout:   wgpu.PipelineLayout,
	debug_text_pipeline:          wgpu.RenderPipeline,
	debug_text_vertex_buffer:     wgpu.Buffer,
	debug_text_texture:           wgpu.Texture,
	debug_text_texture_view:      wgpu.TextureView,
	debug_text_sampler:           wgpu.Sampler,
	debug_text_bind_group_layout: wgpu.BindGroupLayout,
	debug_text_bind_group:        wgpu.BindGroup,
}

@(private)
init_render_subsystem :: proc(window: ^Window, app_name: string, app_version: [3]u32)
{
	render.ctx = context
	render.debug_text_mesh = make([dynamic]Debug_Text_Vertex)

	// usual webgpu fuckery
	render.instance = wgpu.CreateInstance(nil)
	if render.instance == nil {
		log.panicf("webgpu isn't supported by this device")
	}
	render.surface = glfwglue.GetSurface(render.instance, window.glfw)
	log.infof("created webgpu instance")

	wgpu.InstanceRequestAdapter(
		render.instance,
		&{
			powerPreference = .HighPerformance,
			featureLevel = .Core,
			compatibleSurface = render.surface,
		},
		{callback = on_adapter},
	)

	on_adapter :: proc "c" (
		status: wgpu.RequestAdapterStatus,
		adapter: wgpu.Adapter,
		message: string,
		userdata1: rawptr,
		userdata2: rawptr,
	)
	{
		context = render.ctx
		if status != .Success || adapter == nil {
			log.panicf("request adapter failure: [%v] %s", status, message)
		}
		render.adapter = adapter

		info, status := wgpu.AdapterGetInfo(render.adapter)
		if status == .Success {
			log.infof("using device '%s' (%d)", info.device, info.deviceID)
			log.infof("- vendor:  %s (%d)", info.vendor, info.vendorID)
			log.infof("- type:    %s", info.adapterType)
			log.infof("- backend: %s", info.backendType)
		}

		wgpu.AdapterRequestDevice(adapter, nil, {callback = on_device})
	}

	on_device :: proc "c" (
		status: wgpu.RequestDeviceStatus,
		device: wgpu.Device,
		message: string,
		userdata1: rawptr,
		userdata2: rawptr,
	)
	{
		context = render.ctx
		if status != .Success || device == nil {
			log.panicf("request device failure: [%v] %s", status, message)
		}
		render.device = device
		log.infof("created device context")
	}

	// why the FUCK does calling the DRIVER which is on the CPU need to be ASYNC
	// FIXME this is *technically* non-blocking. it WILL break.
	wgpu.InstanceProcessEvents(render.instance)

	reconfigure_surface(size = framebuffer_sizeu(window))
	render.queue = wgpu.DeviceGetQueue(render.device)

	render.voxel_shader = wgpu.DeviceCreateShaderModule(
		render.device,
		&{
			nextInChain = &wgpu.ShaderSourceWGSL {
				sType = .ShaderSourceWGSL,
				code = #load("shader/voxel.wgsl", string),
			},
		},
	)
	log.infof("compiled voxel shader")

	render.debug_text_shader = wgpu.DeviceCreateShaderModule(
		render.device,
		&{
			nextInChain = &wgpu.ShaderSourceWGSL {
				sType = .ShaderSourceWGSL,
				code = #load("shader/debug_text.wgsl", string),
			},
		},
	)
	log.infof("compiled debug text shader")

	render.debug_text_vertex_buffer = wgpu.DeviceCreateBuffer(
		render.device,
		&{
			usage = {.Vertex, .CopyDst},
			size  = 4 * 1024 * 1024, // absurd worst case guess based on nothing
		},
	)

	render.voxel_pipeline_layout = wgpu.DeviceCreatePipelineLayout(render.device, &{})
	render.voxel_pipeline = wgpu.DeviceCreateRenderPipeline(
		render.device,
		&{
			label = "voxel",
			layout = render.voxel_pipeline_layout,
			vertex = {module = render.voxel_shader, entryPoint = "main_vert"},
			fragment = &{
				module = render.voxel_shader,
				entryPoint = "main_frag",
				targetCount = 1,
				targets = &wgpu.ColorTargetState {
					format = .BGRA8Unorm,
					blend = &{
						alpha = {
							srcFactor = .SrcAlpha,
							dstFactor = .OneMinusSrcAlpha,
							operation = .Add,
						},
						color = {
							srcFactor = .SrcAlpha,
							dstFactor = .OneMinusSrcAlpha,
							operation = .Add,
						},
					},
					writeMask = wgpu.ColorWriteMaskFlags_All,
				},
			},
			primitive = {topology = .TriangleList, cullMode = .None},
			multisample = {count = 1, mask = 0xFFFFFFFF},
		},
	)
	log.infof("compiled voxel pipeline")

	font_texture_data_png := #load("assets/debugtext.png")
	font_atlas_x, font_atlas_y, font_atlas_channels: c.int
	render.debug_text_font_data = stbi.load_from_memory(
		raw_data(font_texture_data_png),
		c.int(len(font_texture_data_png)),
		&font_atlas_x,
		&font_atlas_y,
		&font_atlas_channels,
		4,
	)
	log.infof("loaded debug text sprite font")

	atlas_texture_size := wgpu.Extent3D {
		width              = u32(font_atlas_x),
		height             = u32(font_atlas_y),
		depthOrArrayLayers = 1,
	}
	view_formats := []wgpu.TextureFormat{}
	render.debug_text_texture = wgpu.DeviceCreateTexture(
		render.device,
		&{
			usage = {.TextureBinding, .CopyDst},
			dimension = ._2D,
			format = .RGBA8UnormSrgb,
			mipLevelCount = 1,
			sampleCount = 1,
			viewFormats = raw_data(view_formats),
			size = atlas_texture_size,
		},
	)

	wgpu.QueueWriteTexture(
		render.queue,
		&{texture = render.debug_text_texture, aspect = .All},
		render.debug_text_font_data,
		uint(font_atlas_x * font_atlas_y * font_atlas_channels * size_of(u8)),
		&{
			offset = 0,
			bytesPerRow = u32(4 * font_atlas_x),
			rowsPerImage = u32(font_atlas_y),
		},
		&atlas_texture_size,
	)

	render.debug_text_texture_view = wgpu.TextureCreateView(render.debug_text_texture)
	render.debug_text_sampler = wgpu.DeviceCreateSampler(
		render.device,
		&{
			addressModeU = .ClampToEdge,
			addressModeV = .ClampToEdge,
			addressModeW = .ClampToEdge,
			magFilter = .Nearest,
			minFilter = .Nearest,
			mipmapFilter = .Nearest,
			maxAnisotropy = 1,
		},
	)

	debug_text_bind_group_layout_entries := []wgpu.BindGroupLayoutEntry {
		{
			binding = 0,
			visibility = {.Fragment},
			texture = {
				multisampled = false,
				viewDimension = ._2D,
				sampleType = .Float,
			},
		},
		{binding = 1, visibility = {.Fragment}, sampler = {type = .Filtering}},
	}
	render.debug_text_bind_group_layout = wgpu.DeviceCreateBindGroupLayout(
		render.device,
		&{
			entryCount = len(debug_text_bind_group_layout_entries),
			entries = raw_data(debug_text_bind_group_layout_entries),
		},
	)
	debug_text_bind_group_entries := []wgpu.BindGroupEntry {
		{binding = 0, textureView = render.debug_text_texture_view},
		{binding = 1, sampler = render.debug_text_sampler},
	}
	render.debug_text_bind_group = wgpu.DeviceCreateBindGroup(
		render.device,
		&{
			layout = render.debug_text_bind_group_layout,
			entryCount = len(debug_text_bind_group_entries),
			entries = raw_data(debug_text_bind_group_entries),
		},
	)

	render.debug_text_pipeline_layout = wgpu.DeviceCreatePipelineLayout(
		render.device,
		&{
			bindGroupLayoutCount = 1,
			bindGroupLayouts = &render.debug_text_bind_group_layout,
		},
	)

	debug_text_attributes := []wgpu.VertexAttribute {
		{
			format = .Float32x2,
			offset = u64(offset_of(Debug_Text_Vertex, position)),
			shaderLocation = 0,
		},
		{
			format = .Float32x2,
			offset = u64(offset_of(Debug_Text_Vertex, uv)),
			shaderLocation = 1,
		},
		{
			format = .Sint32,
			offset = u64(offset_of(Debug_Text_Vertex, char)),
			shaderLocation = 2,
		},
	}
	debug_text_buffer_layouts := []wgpu.VertexBufferLayout {
		{
			stepMode = .Vertex,
			arrayStride = size_of(Debug_Text_Vertex),
			attributeCount = len(debug_text_attributes),
			attributes = raw_data(debug_text_attributes),
		},
	}
	// hehe

	render.debug_text_pipeline = wgpu.DeviceCreateRenderPipeline(
		render.device,
		&{
			label = "debug text",
			layout = render.debug_text_pipeline_layout,
			vertex = {
				module = render.debug_text_shader,
				entryPoint = "main_vert",
				bufferCount = len(debug_text_buffer_layouts),
				buffers = raw_data(debug_text_buffer_layouts),
			},
			fragment = &{
				module = render.debug_text_shader,
				entryPoint = "main_frag",
				targetCount = 1,
				targets = &wgpu.ColorTargetState {
					format = .BGRA8Unorm,
					blend = &{
						alpha = {
							srcFactor = .SrcAlpha,
							dstFactor = .OneMinusSrcAlpha,
							operation = .Add,
						},
						color = {
							srcFactor = .SrcAlpha,
							dstFactor = .OneMinusSrcAlpha,
							operation = .Add,
						},
					},
					writeMask = wgpu.ColorWriteMaskFlags_All,
				},
			},
			primitive = {topology = .TriangleList, cullMode = .None},
			multisample = {count = 1, mask = 0xFFFFFFFF},
		},
	)
	log.infof("compiled debug text pipeline")

	return
}

@(private = "file")
reconfigure_surface :: proc(size: [2]u32)
{
	surface_config := wgpu.SurfaceConfiguration {
		device      = render.device,
		usage       = {.RenderAttachment},
		format      = .BGRA8Unorm,
		width       = size.x,
		height      = size.y,
		presentMode = .Mailbox,
		alphaMode   = .Opaque,
	}
	wgpu.SurfaceConfigure(render.surface, &surface_config)
}

@(private)
free_render_subsytem :: proc()
{
	wgpu.RenderPipelineRelease(render.debug_text_pipeline)
	wgpu.PipelineLayoutRelease(render.debug_text_pipeline_layout)
	wgpu.ShaderModuleRelease(render.debug_text_shader)
	wgpu.BindGroupRelease(render.debug_text_bind_group)
	wgpu.BindGroupLayoutRelease(render.debug_text_bind_group_layout)
	wgpu.SamplerRelease(render.debug_text_sampler)
	wgpu.TextureViewRelease(render.debug_text_texture_view)
	wgpu.TextureRelease(render.debug_text_texture)
	wgpu.BufferRelease(render.debug_text_vertex_buffer)

	wgpu.RenderPipelineRelease(render.voxel_pipeline)
	wgpu.PipelineLayoutRelease(render.voxel_pipeline_layout)
	wgpu.ShaderModuleRelease(render.voxel_shader)

	wgpu.QueueRelease(render.queue)
	wgpu.DeviceRelease(render.device)
	wgpu.AdapterRelease(render.adapter)
	wgpu.SurfaceRelease(render.surface)
	wgpu.InstanceRelease(render.instance)

	delete(render.debug_text_mesh)
	stbi.image_free(render.debug_text_font_data)
	log.infof("freed renderer")
}

@(private)
render_loop :: proc()
{
	// swapchain fuckery
	surface_texture := wgpu.SurfaceGetCurrentTexture(render.surface)
	#partial switch surface_texture.status {
	case .Timeout, .Outdated, .Lost:
		if surface_texture.texture != nil {
			wgpu.TextureRelease(surface_texture.texture)
		}
		wgpu.SurfaceUnconfigure(render.surface)
		reconfigure_surface(framebuffer_sizeu(main_window()))
		return // skip this frame

	case .OutOfMemory, .DeviceLost, .Error:
		log.panicf("get_current_texture status=%v", surface_texture.status)
	}

	// apparently that's not enough for it to resize properly
	if main_window().pending_resize {
		if surface_texture.texture != nil {
			wgpu.TextureRelease(surface_texture.texture)
		}
		wgpu.SurfaceUnconfigure(render.surface)
		reconfigure_surface(framebuffer_sizeu(main_window()))

		main_window().pending_resize = false
		return // skip this frame
	}

	frame := wgpu.TextureCreateView(surface_texture.texture, nil)
	defer wgpu.TextureViewRelease(frame)

	cmd := wgpu.DeviceCreateCommandEncoder(render.device, nil)
	defer wgpu.CommandEncoderRelease(cmd)

	render_voxels(cmd, frame)
	render_debug_text(cmd, frame)

	// Job Done!
	cmd_buffer := wgpu.CommandEncoderFinish(cmd, nil)
	defer wgpu.CommandBufferRelease(cmd_buffer)

	wgpu.QueueSubmit(render.queue, {cmd_buffer})
	wgpu.SurfacePresent(render.surface)
}

@(private = "file")
render_voxels :: proc(cmd: wgpu.CommandEncoder, frame: wgpu.TextureView)
{
	render_pass := wgpu.CommandEncoderBeginRenderPass(
		cmd,
		&{
			label = "voxel",
			colorAttachmentCount = 1,
			colorAttachments = &wgpu.RenderPassColorAttachment {
				view = frame,
				loadOp = .Clear,
				storeOp = .Store,
				depthSlice = wgpu.DEPTH_SLICE_UNDEFINED,
				clearValue = {0, 0, 0, 0},
			},
		},
	)

	wgpu.RenderPassEncoderSetPipeline(render_pass, render.voxel_pipeline)
	wgpu.RenderPassEncoderDraw(
		render_pass,
		vertexCount = 3,
		instanceCount = 1,
		firstVertex = 0,
		firstInstance = 0,
	)

	wgpu.RenderPassEncoderEnd(render_pass)
	wgpu.RenderPassEncoderRelease(render_pass)
}

@(private = "file")
render_debug_text :: proc(cmd: wgpu.CommandEncoder, frame: wgpu.TextureView)
{
	if len(render.debug_text_mesh) == 0 {
		return
	}

	wgpu.QueueWriteBuffer(
		render.queue,
		render.debug_text_vertex_buffer,
		bufferOffset = 0,
		data = raw_data(render.debug_text_mesh),
		size = len(render.debug_text_mesh) * size_of(Debug_Text_Vertex),
	)

	wgpu.QueueWriteBuffer(
		render.queue,
		render.debug_text_vertex_buffer,
		bufferOffset = 0,
		data = raw_data(render.debug_text_mesh),
		size = len(render.debug_text_mesh) * size_of(Debug_Text_Vertex),
	)
	clear(&render.debug_text_mesh)
	render.debug_text_cursor = {0, 0}

	render_pass := wgpu.CommandEncoderBeginRenderPass(
		cmd,
		&{
			label = "debug text",
			colorAttachmentCount = 1,
			colorAttachments = &wgpu.RenderPassColorAttachment {
				view = frame,
				loadOp = .Load,
				storeOp = .Store,
				depthSlice = wgpu.DEPTH_SLICE_UNDEFINED,
			},
		},
	)

	wgpu.RenderPassEncoderSetBindGroup(render_pass, 0, render.debug_text_bind_group)
	wgpu.RenderPassEncoderSetVertexBuffer(
		render_pass,
		slot = 0,
		buffer = render.debug_text_vertex_buffer,
		offset = 0,
		size = wgpu.BufferGetSize(render.debug_text_vertex_buffer),
	)
	wgpu.RenderPassEncoderSetPipeline(render_pass, render.debug_text_pipeline)

	wgpu.RenderPassEncoderDraw(
		render_pass,
		vertexCount = u32(len(render.debug_text_mesh)),
		instanceCount = 1,
		firstVertex = 0,
		firstInstance = 0,
	)

	wgpu.RenderPassEncoderEnd(render_pass)
	wgpu.RenderPassEncoderRelease(render_pass)
}

DEBUG_TEXT_CHAR_SIZE :: [2]i32{8, 16}

// adds text to be printed to the built-in debug text renderer. only ASCII text supported.
debug_text_print :: proc(text: string)
{
	char_size := DEBUG_TEXT_CHAR_SIZE
	if is_high_dpi(main_window()) {
		char_size = stlib.vector_cast(
			2,
			i32,
			stlib.vector_cast(2, f32, char_size) * scale_factor(main_window()),
		)
	}

	allowed_chars, ok := strings.ascii_set_make(
		" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\n\r\t",
	)
	ensure(ok, message = "what the fuck?")

	for rune in text {
		rune := rune

		// fuck unicode
		// since this isn't C we can use \0 as the placeholder character
		if rune < 0 do rune = '\x00'
		if rune > 255 do rune = '\x00'
		if !strings.ascii_set_contains(allowed_chars, byte(rune)) do rune = '\x00'

		// whitespace fuckery
		if rune == '\r' do continue
		if rune == '\n' {
			render.debug_text_cursor.x = 0
			render.debug_text_cursor.y += char_size.y
			continue
		}
		if rune == ' ' {
			render.debug_text_cursor.x += char_size.x
			continue
		}
		// not pulling an andrew kelley
		if rune == '\t' {
			render.debug_text_cursor.x += char_size.x * 4
		}

		// fuck index buffers
		append(
			&render.debug_text_mesh,
			Debug_Text_Vertex {
				position = stlib.vector_cast(
					2,
					f32,
					render.debug_text_cursor + ({1, 1} * char_size),
				) /
				framebuffer_sizef(main_window()),
				uv = {1, 1},
				char = i32(rune),
			},
		)
		append(
			&render.debug_text_mesh,
			Debug_Text_Vertex {
				position = stlib.vector_cast(
					2,
					f32,
					render.debug_text_cursor + ({1, 0} * char_size),
				) /
				framebuffer_sizef(main_window()),
				uv = {1, 0},
				char = i32(rune),
			},
		)
		append(
			&render.debug_text_mesh,
			Debug_Text_Vertex {
				position = stlib.vector_cast(
					2,
					f32,
					render.debug_text_cursor + ({0, 1} * char_size),
				) /
				framebuffer_sizef(main_window()),
				uv = {0, 1},
				char = i32(rune),
			},
		)
		append(
			&render.debug_text_mesh,
			Debug_Text_Vertex {
				position = stlib.vector_cast(
					2,
					f32,
					render.debug_text_cursor + ({1, 0} * char_size),
				) /
				framebuffer_sizef(main_window()),
				uv = {1, 0},
				char = i32(rune),
			},
		)
		append(
			&render.debug_text_mesh,
			Debug_Text_Vertex {
				position = stlib.vector_cast(
					2,
					f32,
					render.debug_text_cursor + ({0, 0} * char_size),
				) /
				framebuffer_sizef(main_window()),
				uv = {0, 0},
				char = i32(rune),
			},
		)
		append(
			&render.debug_text_mesh,
			Debug_Text_Vertex {
				position = stlib.vector_cast(
					2,
					f32,
					render.debug_text_cursor + ({0, 1} * char_size),
				) /
				framebuffer_sizef(main_window()),
				uv = {0, 1},
				char = i32(rune),
			},
		)

		// fuck word wrap
		render.debug_text_cursor.x += char_size.x
	}
}
