/*
# Starrygpu

The non-vexing low-level postmodern graphics API.

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
	handle:           Device,
	current_pipeline: Gl_Pipeline,
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
	handle:     Pipeline,
	id:         u32,
	topology:   Topology,
	front_face: Winding_Order,
	cull:       Cull_Face,
	compute:    bool,
}

Shader :: distinct hm.Handle32

@(private)
Gl_Shader :: struct {
	handle: Shader,
	id:     u32,
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

Shader_Stage :: enum {
	VERTEX,
	FRAGMENT,
	COMPUTE,
}

// `native_code` depends on the backend:
// - GLSL on OpenGL
new_shader :: proc(
	dev: Device,
	native_code: []byte,
	stage: Shader_Stage,
	entry_point := "main",
) -> (
	shader: Shader,
	ok: bool,
) #optional_ok
{
	glstage: u32
	switch stage {
	case .VERTEX:
		glstage = gl.VERTEX_SHADER
	case .FRAGMENT:
		glstage = gl.FRAGMENT_SHADER
	case .COMPUTE:
		glstage = gl.COMPUTE_SHADER
	}

	id := gl.CreateShader(glstage)
	mate := cstring(raw_data(native_code))
	gl.ShaderSource(id, 1, &mate, nil)
	gl.CompileShader(id)

	success: i32 = ---
	gl.GetShaderiv(id, gl.COMPILE_STATUS, &success)

	if success == 0 {
		info_log_buf: [1024]byte
		gl.GetShaderInfoLog(id, len(info_log_buf), nil, raw_data(info_log_buf[:]))
		info_log := cstring(raw_data(info_log_buf[:]))

		log.errorf("compiling shader failed: %s", info_log)
		return shader, false
	}

	return hm.add(&global.shaders, Gl_Shader{id = id})
}

free_shader :: proc(shader: Shader)
{
	s, ok := hm.get(&global.shaders, shader)
	assert(ok)

	gl.DeleteShader(s.id)
	hm.remove(&global.shaders, shader)
}

Render_Shaders :: struct {
	vertex:   Shader,
	fragment: Shader,
}

Shaders :: union {
	Render_Shaders,
}

Topology :: enum {
	// Vertices 0, 1, and 2 form a triangle. Vertices 3, 4, and 5 form a triangle. And so on.
	TRIANGLE_LIST,
	/// Every group of 3 adjacent vertices forms a triangle. The face direction of the strip is
	/// determined by the winding of the first triangle. Each successive triangle will have its
	/// effective face order reversed, so the system compensates for that by testing it in the
	/// opposite way. A vertex stream of n length will generate n-2 triangles.
	TRIANGLE_STRIP,
	/// The first vertex is always held fixed. From there on, every group of 2 adjacent vertices
	/// form a triangle with the first. So with a vertex stream, you get a list of triangles
	/// like so: (0, 1, 2) (0, 2, 3), (0, 3, 4), etc. A vertex stream of n length will
	/// generate n-2 triangles.
	TRIANGLE_FAN,
}

Winding_Order :: enum {
	CLOCKWISE,
	COUNTER_CLOCKWISE,
}

Cull_Face :: enum {
	NONE,
	FRONT_FACE,
	BACK_FACE,
	FRONT_AND_BACK_FACES,
}

new_pipeline :: proc(
	dev: Device,
	shaders: Shaders,
	topology := Topology.TRIANGLE_LIST,
	front_face := Winding_Order.COUNTER_CLOCKWISE,
	cull := Cull_Face.NONE,
) -> (
	pipeline: Pipeline,
	ok: bool,
) #optional_ok
{
	id: u32
	compute: bool

	switch s in shaders {
	case Render_Shaders:
		compute = false

		vert, frag: ^Gl_Shader
		vert, ok = hm.get(&global.shaders, s.vertex)
		assert(ok)
		frag, ok = hm.get(&global.shaders, s.fragment)
		assert(ok)

		id = gl.CreateProgram()
		gl.AttachShader(id, vert.id)
		gl.AttachShader(id, frag.id)
		gl.LinkProgram(id)

		success: i32 = ---
		gl.GetProgramiv(id, gl.LINK_STATUS, &success)

		if success == 0 {
			info_log_buf: [1024]byte
			gl.GetProgramInfoLog(id, len(info_log_buf), nil, raw_data(info_log_buf[:]))
			info_log := cstring(raw_data(info_log_buf[:]))

			log.errorf("compiling pipeline failed: %s", info_log)
			return pipeline, false
		}
	}

	return hm.add(
			&global.pipelines,
			Gl_Pipeline {
				id = id,
				topology = topology,
				front_face = front_face,
				cull = cull,
				compute = compute,
			},
		),
		true
}

free_pipeline :: proc(pipeline: Pipeline)
{
	p, ok := hm.get(&global.pipelines, pipeline)
	assert(ok)

	gl.DeleteProgram(p.id)
	hm.remove(&global.pipelines, pipeline)
}

bind_pipeline :: proc(dev: Device, pipeline: Pipeline)
{
	p, ok1 := hm.get(&global.pipelines, pipeline)
	assert(ok1)
	d, ok2 := hm.get(&global.devices, dev)
	assert(ok2)
	d.current_pipeline = p^

	gl.UseProgram(p.id)

	if p.compute {
		unimplemented("lnmao")
	} else {
		switch p.front_face {
		case .CLOCKWISE:
			gl.FrontFace(gl.CW)
		case .COUNTER_CLOCKWISE:
			gl.FrontFace(gl.CCW)
		}

		if p.cull == .NONE {
			gl.Disable(gl.CULL_FACE)
		} else {
			gl.Enable(gl.CULL_FACE)
			switch p.cull {
			case .FRONT_FACE:
				gl.CullFace(gl.FRONT)
			case .BACK_FACE:
				gl.CullFace(gl.BACK)
			case .FRONT_AND_BACK_FACES:
				gl.CullFace(gl.FRONT_AND_BACK)
			case .NONE:
				unreachable()
			}
		}
	}
}

draw :: proc(dev: Device, vertex_count: u32, instance_count := u32(1), first_vertex := u32(0))
{
	d, ok := hm.get(&global.devices, dev)
	assert(ok)

	topology: u32
	switch d.current_pipeline.topology {
	case .TRIANGLE_LIST:
		topology = gl.TRIANGLES
	case .TRIANGLE_STRIP:
		topology = gl.TRIANGLE_STRIP
	case .TRIANGLE_FAN:
		topology = gl.TRIANGLE_FAN
	}

	gl.DrawArraysInstanced(topology, i32(first_vertex), i32(vertex_count), i32(instance_count))
}
