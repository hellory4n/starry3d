package starryrt

import "base:runtime"
import "core:log"
import "vendor:wgpu"
import "vendor:wgpu/glfwglue"

// has to be static otherwise callback stuff could get fucky
@(private = "file")
render: struct {
	ctx:      runtime.Context, // used in callbacks
	instance: wgpu.Instance,
	surface:  wgpu.Surface,
	adapter:  wgpu.Adapter,
	device:   wgpu.Device,
	queue:    wgpu.Queue,
}

@(private)
init_render_subsystem :: proc(window: ^Window, app_name: string, app_version: [3]u32)
{
	render.ctx = context

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
	wgpu.QueueRelease(render.queue)
	wgpu.DeviceRelease(render.device)
	wgpu.AdapterRelease(render.adapter)
	wgpu.SurfaceRelease(render.surface)
	wgpu.InstanceRelease(render.instance)
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
	if delta_framebuffer_sizei(main_window()) != framebuffer_sizei(main_window()) {
		if surface_texture.texture != nil {
			wgpu.TextureRelease(surface_texture.texture)
		}
		wgpu.SurfaceUnconfigure(render.surface)
		reconfigure_surface(framebuffer_sizeu(main_window()))
		return // skip this frame
	}

	frame := wgpu.TextureCreateView(surface_texture.texture, nil)
	defer wgpu.TextureViewRelease(frame)

	// interesting crap starts here
	cmd := wgpu.DeviceCreateCommandEncoder(render.device, nil)
	defer wgpu.CommandEncoderRelease(cmd)

	render_pass := wgpu.CommandEncoderBeginRenderPass(
		cmd,
		&{
			colorAttachmentCount = 1,
			colorAttachments = &wgpu.RenderPassColorAttachment {
				view = frame,
				loadOp = .Clear,
				storeOp = .Store,
				depthSlice = wgpu.DEPTH_SLICE_UNDEFINED,
				clearValue = {1, 0, 0, 1},
			},
		},
	)

	wgpu.RenderPassEncoderEnd(render_pass)
	wgpu.RenderPassEncoderRelease(render_pass)

	// Job Done!
	cmd_buffer := wgpu.CommandEncoderFinish(cmd, nil)
	defer wgpu.CommandBufferRelease(cmd_buffer)

	wgpu.QueueSubmit(render.queue, {cmd_buffer})
	wgpu.SurfacePresent(render.surface)
}
