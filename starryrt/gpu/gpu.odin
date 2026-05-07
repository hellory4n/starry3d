/*
# Starrygpu

The non-vexing postmodern graphics API.

Starrygpu is also known as Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr. Jr. OBE (🇪🇸 Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OIB) (Joel Pablo for short)

Joel Pablo name is also QuejaPalronicador

QuejaPalronicadorf name is also Qurjs fhycmjjjjjjjjjjjjjjjjjç

Qurjs fhycmjjjjjjjjjjjjjjjjjç foyr6th name is QuejaGontificador

Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr. Jr. OBE (🇪🇸 Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OIB) or QuejaPalronicador or Qurjs fhycmjjjjjjjjjjjjjjjjjç can produce mind boggling effects.
*/
package stgpu

import "base:runtime"
import hm "core:container/handle_map"
import "core:log"
import gl "vendor:OpenGL"

// TODO separate the OpenGL implementation into its own file
// i really can't be bothered to do that rn

// TODO custom validation layers

Device :: distinct hm.Handle32

@(private)
Gl_Device :: struct {
	handle: Device,
}

Swapchain :: distinct hm.Handle32

@(private)
Gl_Swapchain :: struct {
	handle:            Swapchain,
	window:            rawptr,
	swap_buffers_proc: proc(window: rawptr),
}

Pipeline :: distinct hm.Handle32

@(private)
Gl_Pipeline :: struct {
	handle: Pipeline,
}

Shader :: distinct hm.Handle32

@(private)
Gl_Shader :: struct {
	handle: Shader,
}

Buffer :: distinct hm.Handle32

@(private)
Gl_Buffer :: struct {
	handle: Buffer,
}

Texture :: distinct hm.Handle32

@(private)
Gl_Texture :: struct {
	handle: Texture,
}

Sampler :: distinct hm.Handle32

@(private)
Gl_Sampler :: struct {
	handle: Sampler,
}

@(private)
global: struct {
	devices:    hm.Static_Handle_Map(1024, Gl_Device, Device),
	swapchains: hm.Static_Handle_Map(1024, Gl_Swapchain, Swapchain),
	pipelines:  hm.Static_Handle_Map(1024, Gl_Pipeline, Pipeline),
	shaders:    hm.Static_Handle_Map(1024, Gl_Shader, Shader),
	buffers:    hm.Static_Handle_Map(1024, Gl_Buffer, Buffer),
	textures:   hm.Static_Handle_Map(1024, Gl_Texture, Texture),
	samplers:   hm.Static_Handle_Map(1024, Gl_Sampler, Sampler),
}

Resource_View :: struct {
	resource: union {
		Buffer,
		Texture,
	},
	offset:   u32,
	size:     u32,
}

Gl_Init_Glue :: struct {
	get_proc_address_proc: gl.Set_Proc_Address_Type,
}

Init_Glue :: union {
	Gl_Init_Glue,
}

// Initializes the GPU context so that you can GPU all over the place.
//
// Multiple contexts in OpenGL is technically possible, though likely broken and horrid,
// so don't do that.
new_device :: proc(glue: Init_Glue, debug: bool = ODIN_DEBUG) -> (dev: Device, ok: bool)
{
	gl_glue := glue.(Gl_Init_Glue)
	gl.load_up_to(4, 3, gl_glue.get_proc_address_proc)

	when ODIN_DEBUG {
		gl.Enable(gl.DEBUG_OUTPUT)
		gl.Enable(gl.DEBUG_OUTPUT_SYNCHRONOUS)
		gl.DebugMessageCallback(
			proc "c" (
				source: u32,
				type: u32,
				id: u32,
				severity: u32,
				length: i32,
				message: cstring,
				userparam: rawptr,
			)
			{
				context = runtime.default_context()
				switch severity {
				case gl.DEBUG_SEVERITY_HIGH:
					log.panicf("OpenGL 0x%X: %s", id, message)
				case gl.DEBUG_SEVERITY_MEDIUM:
				case gl.DEBUG_SEVERITY_LOW:
					log.warnf("OpenGL 0x%X: %s", id, message)
				case:
					log.infof("OpenGL 0x%X: %s", id, message)
				}
			},
			nil,
		)
	}

	// dummy vao so it stops bitching with bufferless rendering
	vao: u32 = ---
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	return Device(hm.add(&global.devices, Gl_Device{})), true
}

free_device :: proc(dev: Device)
{
	hm.remove(&global.devices, dev)
}

Gl_Swapchain_Glue :: struct {
	window:            rawptr,
	swap_buffers_proc: proc(window: rawptr),
}

Swapchain_Glue :: union {
	Gl_Swapchain_Glue,
}

// swpap my chain<3
new_swapchain :: proc(dev: Device, size: [2]u32, glue: Swapchain_Glue) -> Swapchain
{
	gl.Viewport(0, 0, i32(size.x), i32(size.y))
	return hm.add(
		&global.swapchains,
		Gl_Swapchain {
			window = glue.(Gl_Swapchain_Glue).window,
			swap_buffers_proc = glue.(Gl_Swapchain_Glue).swap_buffers_proc,
		},
	)
}

// *unswaps your chains*
free_swapchain :: proc(swapchain: Swapchain)
{
	hm.remove(&global.swapchains, swapchain)
}

resize_swapchain :: proc(swapchain: Swapchain, new_size: [2]u32)
{
	gl.Viewport(0, 0, i32(new_size.x), i32(new_size.y))
}

// Starts a new command buffer.
begin_frame :: proc(dev: Device)
{
	// noop in opengl
}

// Ends the current command buffer.
end_frame :: proc(dev: Device)
{
	// noop in opengl
}

// Makes it so the swapchain shows up on the screen and stuff.
present_swapchain :: proc(dev: Device, swapchain: Swapchain)
{
	swap, ok := hm.get(&global.swapchains, swapchain)
	assert(ok)

	// close enough
	swap.swap_buffers_proc(swap.window)
}

begin_render_pass :: proc(dev: Device, swapchain: Swapchain, clear_color := [4]f32{0, 0, 0, 1})
{
	gl.ClearColor(clear_color.r, clear_color.g, clear_color.b, clear_color.a)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

end_render_pass :: proc(dev: Device)
{
	// noop in opengl
}
