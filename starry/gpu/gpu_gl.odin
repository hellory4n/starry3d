/*
# Starrygpu

The non-vexing low-level postmodern graphics API.

Starrygpu is also known as Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr. Jr. OBE (🇪🇸 Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OIB) (Joel Pablo for short)

Joel Pablo name is also QuejaPalronicador

QuejaPalronicadorf name is also Qurjs fhycmjjjjjjjjjjjjjjjjjç

Qurjs fhycmjjjjjjjjjjjjjjjjjç foyr6th name is QuejaGontificador

Emerson Victor Kyler Gandalf Joel Pablo Daquavious II Sr. Jr. OBE (🇪🇸 Émerez Víctor Quejador Gandalf Joel Pablo Decavio II Sr. Jr. OIB) or QuejaPalronicador or Qurjs fhycmjjjjjjjjjjjjjjjjjç can produce mind boggling effects.
*/
package starrygpu

import "base:runtime"
import hm "core:container/handle_map"
import "core:fmt"
import "core:mem"
import gl "vendor:OpenGL"

// TODO separate the OpenGL implementation into its own file
// i really can't be bothered to do that rn

// TODO custom validation layers

Device :: distinct hm.Handle32
Pipeline :: distinct hm.Handle32
Shader :: distinct hm.Handle32
Buffer :: distinct hm.Handle32
Texture :: distinct hm.Handle32
Sampler :: distinct hm.Handle32
Framebuffer :: distinct hm.Handle32

@(private)
Gl_Device :: struct {
	handle:              Device,
	current_pipeline:    Gl_Pipeline,
	window:              rawptr,
	swap_buffers_proc:   proc(window: rawptr),
	default_framebuffer: Framebuffer,
}

@(private)
Gl_Pipeline :: struct {
	handle:        Pipeline,
	id:            u32,
	topology:      Topology,
	front_face:    Winding_Order,
	cull:          Cull_Face,
	vertex_layout: []Vertex_Attribute,
	vertex_size:   int,
	compute:       bool,
}

@(private)
Gl_Shader :: struct {
	handle: Shader,
	id:     u32,
}

@(private)
Gl_Buffer :: struct {
	handle:   Buffer,
	size:     int,
	id:       u32,
	gltarget: u32,
	glusage:  u32,
}

@(private)
Gl_Texture :: struct {
	handle: Texture,
	id:     u32,
}

@(private)
Gl_Sampler :: struct {
	handle: Sampler,
	id:     u32,
}

@(private)
Gl_Framebuffer :: struct {
	handle:                   Framebuffer,
	id:                       u32,
	color_attachments:        [dynamic]Gl_Framebuffer_Attachment,
	depth_stencil_attachment: Gl_Framebuffer_Attachment,
}

@(private)
Gl_Framebuffer_Attachment :: struct {
	handle:       Texture,
	id:           u32,
	renderbuffer: bool,
}

global: struct {
	allocator:    mem.Allocator,
	devices:      hm.Dynamic_Handle_Map(Gl_Device, Device),
	pipelines:    hm.Dynamic_Handle_Map(Gl_Pipeline, Pipeline),
	shaders:      hm.Dynamic_Handle_Map(Gl_Shader, Shader),
	buffers:      hm.Dynamic_Handle_Map(Gl_Buffer, Buffer),
	textures:     hm.Dynamic_Handle_Map(Gl_Texture, Texture),
	samplers:     hm.Dynamic_Handle_Map(Gl_Sampler, Sampler),
	framebuffers: hm.Dynamic_Handle_Map(Gl_Framebuffer, Framebuffer),
}

// Initializes the global state used by the GPU backend.
init_instance :: proc(allocator := context.allocator)
{
	global.allocator = allocator
	hm.dynamic_init(&global.devices, allocator)
	hm.dynamic_init(&global.pipelines, allocator)
	hm.dynamic_init(&global.shaders, allocator)
	hm.dynamic_init(&global.buffers, allocator)
	hm.dynamic_init(&global.textures, allocator)
	hm.dynamic_init(&global.samplers, allocator)
	hm.dynamic_init(&global.framebuffers, allocator)
}

// Deinitializes the global state used by the GPU backend.
free_instance :: proc()
{
	hm.dynamic_destroy(&global.devices)
	hm.dynamic_destroy(&global.pipelines)
	hm.dynamic_destroy(&global.shaders)
	hm.dynamic_destroy(&global.buffers)
	hm.dynamic_destroy(&global.textures)
	hm.dynamic_destroy(&global.samplers)
	hm.dynamic_destroy(&global.framebuffers)
}

Gl_Version :: enum {
	CORE_33,
	CORE_43,
	CORE_46,
}

Gl_Init_Glue :: struct {
	get_proc_address_proc: gl.Set_Proc_Address_Type,
	gl_version:            Gl_Version,
	window:                rawptr,
	swap_buffers_proc:     proc(window: rawptr),
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
	switch gl_glue.gl_version {
	case .CORE_33:
		gl.load_up_to(3, 3, gl_glue.get_proc_address_proc)
	case .CORE_43:
		gl.load_up_to(4, 3, gl_glue.get_proc_address_proc)
	case .CORE_46:
		gl.load_up_to(4, 6, gl_glue.get_proc_address_proc)
	}

	// this segfaults?????????????
	// when ODIN_DEBUG {
	// 	gl.Enable(gl.DEBUG_OUTPUT)
	// 	gl.Enable(gl.DEBUG_OUTPUT_SYNCHRONOUS)
	// 	gl.DebugMessageCallback(
	// 		proc "c" (
	// 			source: u32,
	// 			type: u32,
	// 			id: u32,
	// 			severity: u32,
	// 			length: i32,
	// 			message: cstring,
	// 			userparam: rawptr,
	// 		)
	// 		{
	// 			// TODO pass context as userdata dumbass
	// 			// you could use context's own `user_ptr` if you ever needed
	// 			context = runtime.default_context()
	// 			switch severity {
	// 			case gl.DEBUG_SEVERITY_HIGH:
	// 				fmt.errorf("OpenGL 0x%X: %s", id, message)
	// 			case gl.DEBUG_SEVERITY_MEDIUM:
	// 			case gl.DEBUG_SEVERITY_LOW:
	// 				fmt.warnf("OpenGL 0x%X: %s", id, message)
	// 			case:
	// 				fmt.infof("OpenGL 0x%X: %s", id, message)
	// 			}
	// 		},
	// 		userParam = nil,
	// 	)
	// }

	// dummy vao so it stops bitching with bufferless rendering
	vao: u32 = ---
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	// dummy/default framebuffer
	default_fb := hm.add(&global.framebuffers, Gl_Framebuffer{id = 0})

	dev = hm.add(
		&global.devices,
		Gl_Device {
			window = gl_glue.window,
			swap_buffers_proc = gl_glue.swap_buffers_proc,
			default_framebuffer = default_fb,
		},
	)

	// objectively better defaults than opengl
	set_blend(dev, .SRC_ALPHA, .ONE_MINUS_SRC_ALPHA)

	return dev, true
}

free_device :: proc(dev: Device)
{
	hm.remove(&global.devices, dev)
}

resize_swapchain :: proc(dev: Device, new_size: [2]i32)
{
	// noop in opengl
	// i think glViewport handles that?
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
present_and_swap_buffers :: proc(dev: Device)
{
	d, ok := hm.get(&global.devices, dev)
	assert(ok)

	// close enough
	d.swap_buffers_proc(d.window)
}

Load_Op :: enum i32 {
	DONT_CARE = 0,
	LOAD      = 1,
	CLEAR     = 2,
}

Store_Op :: enum i32 {
	DONT_CARE = 0,
	STORE     = 1,
}

begin_render_pass :: proc(
	dev: Device,
	framebuffer: Framebuffer,
	color_load_op: Load_Op,
	color_store_op: Store_Op = .STORE,
	depth_load_op: Load_Op = .DONT_CARE,
	depth_store_op: Store_Op = .DONT_CARE,
	clear_color: [4]f32 = {},
	clear_depth: f32 = 0,
)
{
	fb, ok := hm.get(&global.framebuffers, framebuffer)
	assert(ok)

	gl.BindFramebuffer(gl.FRAMEBUFFER, fb.id)

	clear_bits: u32
	if color_load_op == .CLEAR {
		gl.ClearColor(clear_color.r, clear_color.g, clear_color.b, clear_color.a)
		clear_bits |= gl.COLOR_BUFFER_BIT
	}

	if depth_load_op == .CLEAR {
		gl.ClearDepthf(clear_depth)
		clear_bits |= gl.DEPTH_BUFFER_BIT
	}

	if clear_bits != 0 {
		gl.Clear(clear_bits)
	}
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
	label := "a Starry shader",
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

		fmt.printfln("compiling shader %q failed: %s", label, info_log)
		return shader, false
	}

	return hm.add(&global.shaders, Gl_Shader{id = id}), true
}

free_shader :: proc(shader: Shader)
{
	s, ok := hm.get(&global.shaders, shader)
	if !ok do return

	gl.DeleteShader(s.id)
	hm.remove(&global.shaders, shader)
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

Vertex_Attribute_Type :: enum {
	INT32,
	UINT32,
	FLOAT32,
	FLOAT64,
	VEC2_INT32,
	VEC2_UINT32,
	VEC2_FLOAT32,
	VEC2_FLOAT64,
	VEC3_INT32,
	VEC3_UINT32,
	VEC3_FLOAT32,
	VEC3_FLOAT64,
	VEC4_INT32,
	VEC4_UINT32,
	VEC4_FLOAT32,
	VEC4_FLOAT64,
}

Vertex_Attribute :: struct {
	name:       string,
	// Use with `offset_of`
	offset:     uintptr,
	type:       Vertex_Attribute_Type,
	normalized: bool,
}

Binding_Type :: enum {
	UNIFORM_BUFFER,
	STORAGE_BUFFER,
	TEXTURE,
	SAMPLER,
}

Binding :: struct {
	type:  Binding_Type,
	slot:  u32,
	count: Binding_Count,
}

Binding_Count :: union #no_nil {
	Single_Binding,
	u32,
}

Single_Binding :: distinct u32 // dummy type

Render_Pipeline_Settings :: struct {
	vertex_shader:   Shader,
	fragment_shader: Shader,
	topology:        Topology,
	front_face:      Winding_Order,
	cull:            Cull_Face,
	vertex_layout:   []Vertex_Attribute,
	vertex_size:     int,
}

// TODO should be #no_nil but Compute_Pipeline_Desc doesn't exist yet
Pipeline_Settings :: union {
	Render_Pipeline_Settings,
}

new_pipeline :: proc(
	dev: Device,
	settings: Pipeline_Settings,
	bindings: []Binding = nil,
	label := "a Starry pipeline",
) -> (
	pipeline: Pipeline,
	ok: bool,
) #optional_ok
{
	id: u32
	compute: bool
	render_desc := settings.(Render_Pipeline_Settings)

	switch s in settings {
	case Render_Pipeline_Settings:
		compute = false

		vert, frag: ^Gl_Shader
		vert, ok = hm.get(&global.shaders, s.vertex_shader)
		assert(ok)
		frag, ok = hm.get(&global.shaders, s.fragment_shader)
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

			fmt.printfln("compiling pipeline failed: %s", info_log)
			return pipeline, false
		}
	}

	vhuyvfyfhbvhyf := render_desc.vertex_layout
	if render_desc.vertex_layout != nil {
		vhuyvfyfhbvhyf = make(
			[]Vertex_Attribute,
			len(render_desc.vertex_layout),
			global.allocator,
		)
		copy(vhuyvfyfhbvhyf, render_desc.vertex_layout)
	}

	return hm.add(
			&global.pipelines,
			Gl_Pipeline {
				id = id,
				topology = render_desc.topology,
				front_face = render_desc.front_face,
				cull = render_desc.cull,
				compute = compute,
				vertex_layout = vhuyvfyfhbvhyf,
				vertex_size = render_desc.vertex_size,
			},
		),
		true
}

free_pipeline :: proc(pipeline: Pipeline)
{
	p, ok := hm.get(&global.pipelines, pipeline)
	if !ok do return

	gl.DeleteProgram(p.id)
	delete(p.vertex_layout, global.allocator)
	hm.remove(&global.pipelines, pipeline)
}

bind_pipeline :: proc(dev: Device, pipeline: Pipeline)
{
	p, ok1 := hm.get(&global.pipelines, pipeline)
	assert(ok1)
	d, ok2 := hm.get(&global.devices, dev)
	assert(ok2)
	d.current_pipeline = p^

	// alledgedly this is "fine" to call every frame on "modern drivers"
	for attr, i in p.vertex_layout {
		attr_is_int: bool
		switch attr.type {
		case .INT32,
		     .UINT32,
		     .VEC2_INT32,
		     .VEC2_UINT32,
		     .VEC3_INT32,
		     .VEC3_UINT32,
		     .VEC4_INT32,
		     .VEC4_UINT32:
			attr_is_int = true

		case .FLOAT32,
		     .FLOAT64,
		     .VEC2_FLOAT32,
		     .VEC2_FLOAT64,
		     .VEC3_FLOAT32,
		     .VEC3_FLOAT64,
		     .VEC4_FLOAT32,
		     .VEC4_FLOAT64:
			attr_is_int = false
		}

		attr_size: i32 = -8
		switch attr.type {
		case .INT32, .UINT32, .FLOAT32, .FLOAT64:
			attr_size = 1

		case .VEC2_INT32, .VEC2_UINT32, .VEC2_FLOAT32, .VEC2_FLOAT64:
			attr_size = 2

		case .VEC3_INT32, .VEC3_UINT32, .VEC3_FLOAT32, .VEC3_FLOAT64:
			attr_size = 3

		case .VEC4_INT32, .VEC4_UINT32, .VEC4_FLOAT32, .VEC4_FLOAT64:
			attr_size = 4
		}

		attr_gl_type: u32
		switch attr.type {
		case .INT32, .VEC2_INT32, .VEC3_INT32, .VEC4_INT32:
			attr_gl_type = gl.INT

		case .UINT32, .VEC2_UINT32, .VEC3_UINT32, .VEC4_UINT32:
			attr_gl_type = gl.UNSIGNED_INT

		case .FLOAT32, .VEC2_FLOAT32, .VEC3_FLOAT32, .VEC4_FLOAT32:
			attr_gl_type = gl.FLOAT

		case .FLOAT64, .VEC2_FLOAT64, .VEC3_FLOAT64, .VEC4_FLOAT64:
			attr_gl_type = gl.DOUBLE
		}

		if attr_is_int {
			gl.VertexAttribIPointer(
				index = u32(i),
				size = attr_size,
				type = attr_gl_type,
				stride = i32(p.vertex_size),
				pointer = attr.offset,
			)
		} else {
			gl.VertexAttribPointer(
				index = u32(i),
				size = attr_size,
				type = attr_gl_type,
				normalized = attr.normalized,
				stride = i32(p.vertex_size),
				pointer = attr.offset,
			)
		}

		gl.EnableVertexAttribArray(u32(i))
	}

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

draw_indexed :: proc(dev: Device, index_count: u32, instance_count := u32(1))
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

	gl.DrawElementsInstanced(
		topology,
		i32(index_count),
		gl.UNSIGNED_INT,
		nil,
		i32(instance_count),
	)
}

Buffer_Flags :: bit_set[Buffer_Flag]

Buffer_Flag :: enum {
	TRANSFER_SRC,
	TRANSFER_DST,
	DYNAMIC, // frequently updated
}

Buffer_Target :: enum {
	VERTEX,
	INDEX,
	UNIFORM,
	STORAGE,
}

Buffer_Targets :: bit_set[Buffer_Target]

new_buffer :: proc(
	dev: Device,
	targets: Buffer_Targets,
	usage: Buffer_Flags,
	size: int,
	data: []byte = nil,
	label := "a Starry buffer",
) -> Buffer
{
	// idiot proofing
	if data != nil {
		target_count := 0
		if Buffer_Target.VERTEX in targets do target_count += 1
		if Buffer_Target.INDEX in targets do target_count += 1
		if Buffer_Target.UNIFORM in targets do target_count += 1
		if Buffer_Target.STORAGE in targets do target_count += 1

		if target_count == 0 {
			panic(
				"trying to fill buffer at creation, but no target is specified. should be VERTEX, INDEX, UNIFORM, or STORAGE.",
			)
		}
		if target_count > 1 {
			panic(
				"trying to fill buffer at creation, but more than one target is being specified; choose only one (VERTEX, INDEX, UNIFORM, or STORAGE)",
			)
		}
	}

	gltarget: u32
	if Buffer_Target.VERTEX in targets {
		gltarget = gl.ARRAY_BUFFER
	} else if Buffer_Target.INDEX in targets {
		gltarget = gl.ELEMENT_ARRAY_BUFFER
	} else if Buffer_Target.UNIFORM in targets {
		gltarget = gl.UNIFORM_BUFFER
	} else if Buffer_Target.STORAGE in targets {
		gltarget = gl.SHADER_STORAGE_BUFFER
	}

	glusage: u32
	if Buffer_Flag.DYNAMIC in usage {
		glusage = gl.STATIC_DRAW
	} else {
		glusage = gl.DYNAMIC_DRAW
	}

	id: u32
	gl.GenBuffers(1, &id)
	gl.BindBuffer(gltarget, id)

	if data == nil {
		gl.BufferData(gltarget, size, nil, glusage)
	} else {
		assert(len(data) == size)
		gl.BufferData(gltarget, size, raw_data(data), glusage)
	}

	return hm.add(
		&global.buffers,
		Gl_Buffer{id = id, size = size, gltarget = gltarget, glusage = glusage},
	)
}

free_buffer :: proc(buffer: Buffer)
{
	b, ok := hm.get(&global.buffers, buffer)
	if !ok do return

	gl.DeleteBuffers(1, &b.id)
	hm.remove(&global.buffers, buffer)
}

update_buffer :: proc(dev: Device, buffer: Buffer, data: []byte, offset: u32 = 0)
{
	b, ok := hm.get(&global.buffers, buffer)
	assert(ok)

	gl.BindBuffer(b.gltarget, b.id)
	if offset == 0 && len(data) == b.size {
		gl.BufferData(b.gltarget, len(data), raw_data(data), b.glusage)
	} else {
		gl.BufferSubData(b.gltarget, int(offset), len(data), raw_data(data))
	}
}

bind_vertex_buffer :: proc(dev: Device, buffer: Buffer)
{
	b, ok := hm.get(&global.buffers, buffer)
	assert(ok)

	b.gltarget = gl.ARRAY_BUFFER // TODO this is likely stupid but so is opengl
	gl.BindBuffer(b.gltarget, b.id)
}

bind_index_buffer :: proc(dev: Device, buffer: Buffer)
{
	b, ok := hm.get(&global.buffers, buffer)
	assert(ok)

	b.gltarget = gl.ELEMENT_ARRAY_BUFFER // TODO this is likely stupid but so is opengl
	gl.BindBuffer(b.gltarget, b.id)
}

bind_uniform_buffer :: proc(dev: Device, buffer: Buffer, slot: u32)
{
	b, ok := hm.get(&global.buffers, buffer)
	assert(ok)

	b.gltarget = gl.UNIFORM_BUFFER // TODO this is likely stupid but so is opengl
	gl.BindBufferBase(b.gltarget, slot, b.id)
}

bind_storage_buffer :: proc(dev: Device, buffer: Buffer, slot: u32)
{
	b, ok := hm.get(&global.buffers, buffer)
	assert(ok)

	b.gltarget = gl.SHADER_STORAGE_BUFFER // TODO this is likely stupid but so is opengl
	gl.BindBuffer(b.gltarget, b.id)
	gl.BindBufferBase(b.gltarget, slot, b.id)
}

Texture_Format :: enum {
	GRAYSCALE_U8,
	GRAYSCALE_F32,
	GRAYSCALE_ALPHA_U8,
	GRAYSCALE_ALPHA_F32,
	RGB_U8,
	RGBA_U8,
	RGB_F32,
	RGBA_F32,
	DEPTH_F32,
}

// If data is nil, this only allocates the data for later use
new_texture :: proc(
	dev: Device,
	size: [2]i32,
	gpu_format: Texture_Format,
	input_format: Texture_Format,
	data: []byte = nil,
	label := "a Starry texture",
) -> Texture
{
	id: u32
	gl.GenTextures(1, &id)
	gl.BindTexture(gl.TEXTURE_2D, id)

	gl_internal_format: i32
	switch gpu_format {
	case .RGB_U8:
		gl_internal_format = gl.RGB8
	case .RGBA_U8:
		gl_internal_format = gl.RGBA8
	case .RGB_F32:
		gl_internal_format = gl.RGB32F
	case .RGBA_F32:
		gl_internal_format = gl.RGBA32F
	case .DEPTH_F32:
		gl_internal_format = gl.DEPTH_COMPONENT32F
	case .GRAYSCALE_U8:
		gl_internal_format = gl.R8
	case .GRAYSCALE_F32:
		gl_internal_format = gl.R32F
	case .GRAYSCALE_ALPHA_U8:
		gl_internal_format = gl.RG8
	case .GRAYSCALE_ALPHA_F32:
		gl_internal_format = gl.RG32F
	}

	gl_format: u32
	switch input_format {
	case .RGB_U8, .RGB_F32:
		gl_format = gl.RGB
	case .RGBA_U8, .RGBA_F32:
		gl_format = gl.RGBA
	case .DEPTH_F32:
		gl_format = gl.DEPTH_COMPONENT
	case .GRAYSCALE_U8, .GRAYSCALE_F32:
		gl_format = gl.RED
	case .GRAYSCALE_ALPHA_U8, .GRAYSCALE_ALPHA_F32:
		gl_format = gl.RG
	}

	gl_type: u32
	switch input_format {
	case .RGB_U8, .RGBA_U8, .GRAYSCALE_U8, .GRAYSCALE_ALPHA_U8:
		gl_type = gl.UNSIGNED_BYTE
	case .RGB_F32, .RGBA_F32, .GRAYSCALE_F32, .GRAYSCALE_ALPHA_F32, .DEPTH_F32:
		gl_type = gl.FLOAT
	}

	// TODO probably wrong
	#partial switch input_format {
	case .GRAYSCALE_U8, .GRAYSCALE_F32, .GRAYSCALE_ALPHA_U8, .GRAYSCALE_ALPHA_F32:
		gl.PixelStorei(gl.UNPACK_ALIGNMENT, 1)
	case:
		gl.PixelStorei(gl.UNPACK_ALIGNMENT, 4)
	}

	gl.TexImage2D(
		target = gl.TEXTURE_2D,
		level = 0,
		internalformat = gl_internal_format,
		width = size.x,
		height = size.y,
		border = 0,
		format = gl_format,
		type = gl_type,
		pixels = raw_data(data),
	)

	return hm.add(&global.textures, Gl_Texture{id = id})
}

free_texture :: proc(texture: Texture)
{
	t, ok := hm.get(&global.textures, texture)
	if !ok do return

	gl.DeleteTextures(1, &t.id)
	hm.remove(&global.textures, texture)
}

// What should happen when texture coordinates go beyond 0-1. Example: https://learnopengl.com/img/getting-started/texture_wrapping.png
Texture_Wrap :: enum {
	TILE,
	MIRRORED_TILE,
	CLAMP_TO_EDGE,
	CLAMP_TO_BORDER,
}

Texture_Filter :: enum {
	NEAREST_NEIGHBOR,
	BILINEAR,
}

new_sampler :: proc(
	dev: Device,
	wrap: Texture_Wrap,
	filter: Texture_Filter,
	label := "a Starry sampler",
) -> Sampler
{
	id: u32
	gl.GenSamplers(1, &id)

	switch wrap {
	case .TILE:
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_S, gl.REPEAT)
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_T, gl.REPEAT)
	case .MIRRORED_TILE:
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_S, gl.MIRRORED_REPEAT)
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT)
	case .CLAMP_TO_EDGE:
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
	case .CLAMP_TO_BORDER:
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_BORDER)
		gl.SamplerParameteri(id, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_BORDER)
	}

	switch filter {
	case .NEAREST_NEIGHBOR:
		gl.SamplerParameteri(id, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
		gl.SamplerParameteri(id, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	case .BILINEAR:
		gl.SamplerParameteri(id, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
		gl.SamplerParameteri(id, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	}

	return hm.add(&global.samplers, Gl_Sampler{id = id})
}

free_sampler :: proc(sampler: Sampler)
{
	s, ok := hm.get(&global.samplers, sampler)
	if !ok do return

	gl.DeleteSamplers(1, &s.id)
	hm.remove(&global.samplers, sampler)
}

bind_texture :: proc(dev: Device, texture: Texture, slot: u32)
{
	t, ok := hm.get(&global.textures, texture)
	assert(ok)

	gl.ActiveTexture(gl.TEXTURE0 + slot)
	gl.BindTexture(gl.TEXTURE_2D, t.id)
}

bind_sampler :: proc(dev: Device, sampler: Sampler, slot: u32)
{
	s, ok := hm.get(&global.samplers, sampler)
	assert(ok)

	gl.BindSampler(slot, s.id)
}

set_viewport :: proc(dev: Device, pos: [2]i32, size: [2]i32)
{
	gl.Viewport(pos.x, pos.y, size.x, size.y)
}

// If position or size are nil, it disables scissor testing, which is equivalent to
// `set_scissor(dev, pos = {0, 0}, window_size())`
set_scissor :: proc(dev: Device, pos, size: Maybe([2]i32))
{
	if pos == nil || size == nil {
		gl.Disable(gl.SCISSOR_TEST)
	} else {
		gl.Enable(gl.SCISSOR_TEST)
		gl.Scissor(pos.?.x, pos.?.y, size.?.x, size.?.y)
	}
}

// See https://docs.gl/gl4/glBlendFunc for the mildly fancy equations that each value does
Blend_Factor :: enum {
	ZERO,
	ONE,
	SRC_COLOR,
	ONE_MINUS_SRC_COLOR,
	DST_COLOR,
	ONE_MINUS_DST_COLOR,
	SRC_ALPHA,
	ONE_MINUS_SRC_ALPHA,
	DST_ALPHA,
	ONE_MINUS_DST_ALPHA,
	CONSTANT_COLOR,
	ONE_MINUS_CONSTANT_COLOR,
	CONSTANT_ALPHA,
	ONE_MINUS_CONSTANT_ALPHA,
	SRC_ALPHA_SATURATE,
	SRC1_COLOR,
	ONE_MINUS_SRC1_COLOR,
	SRC1_ALPHA,
	ONE_MINUS_SRC1_ALPHA,
}

set_blend :: proc(
	dev: Device,
	src_factor: Blend_Factor,
	dst_factor: Blend_Factor,
	constant_color := [4]f32{0, 0, 0, 0},
)
{
	stgpu_blend_to_gl_blend :: #force_inline proc(x: Blend_Factor) -> u32
	{
		switch x {
		case .ZERO:
			return gl.ZERO
		case .ONE:
			return gl.ONE
		case .SRC_COLOR:
			return gl.SRC_COLOR
		case .ONE_MINUS_SRC_COLOR:
			return gl.ONE_MINUS_SRC_COLOR
		case .DST_COLOR:
			return gl.DST_COLOR
		case .ONE_MINUS_DST_COLOR:
			return gl.ONE_MINUS_DST_COLOR
		case .SRC_ALPHA:
			return gl.SRC_ALPHA
		case .ONE_MINUS_SRC_ALPHA:
			return gl.ONE_MINUS_SRC_ALPHA
		case .DST_ALPHA:
			return gl.DST_ALPHA
		case .ONE_MINUS_DST_ALPHA:
			return gl.ONE_MINUS_DST_ALPHA
		case .CONSTANT_COLOR:
			return gl.CONSTANT_COLOR
		case .ONE_MINUS_CONSTANT_COLOR:
			return gl.ONE_MINUS_CONSTANT_COLOR
		case .CONSTANT_ALPHA:
			return gl.CONSTANT_ALPHA
		case .ONE_MINUS_CONSTANT_ALPHA:
			return gl.ONE_MINUS_CONSTANT_ALPHA
		case .SRC_ALPHA_SATURATE:
			return gl.SRC_ALPHA_SATURATE
		case .SRC1_COLOR:
			return gl.SRC1_COLOR
		case .ONE_MINUS_SRC1_COLOR:
			return gl.ONE_MINUS_SRC1_COLOR
		case .SRC1_ALPHA:
			return gl.SRC1_ALPHA
		case .ONE_MINUS_SRC1_ALPHA:
			return gl.ONE_MINUS_SRC1_ALPHA
		}
		unreachable()
	}

	gl.Enable(gl.BLEND)
	gl.BlendFunc(stgpu_blend_to_gl_blend(src_factor), stgpu_blend_to_gl_blend(dst_factor))
	gl.BlendColor(constant_color.r, constant_color.g, constant_color.b, constant_color.a)
}

Attachment :: struct {
	format:     Texture_Format,
	write_only: bool,
}

new_framebuffer :: proc(
	dev: Device,
	size: [2]i32,
	color_attachments: []Attachment,
	depth_stencil_attachment: Maybe(Attachment) = nil,
	label := "a Starry framebuffer",
) -> Framebuffer
{
	new_renderbuffer :: proc(dev: Device, size: [2]i32, format: Texture_Format) -> u32
	{
		id: u32 = ---
		gl.GenRenderbuffers(1, &id)
		gl.BindRenderbuffer(gl.RENDERBUFFER, id)
		defer gl.BindRenderbuffer(gl.RENDERBUFFER, 0)

		gl_internal_format: u32
		switch format {
		case .RGB_U8:
			gl_internal_format = gl.RGB8
		case .RGBA_U8:
			gl_internal_format = gl.RGBA8
		case .RGB_F32:
			gl_internal_format = gl.RGB32F
		case .RGBA_F32:
			gl_internal_format = gl.RGBA32F
		case .GRAYSCALE_U8:
			gl_internal_format = gl.R8
		case .GRAYSCALE_F32:
			gl_internal_format = gl.R32F
		case .GRAYSCALE_ALPHA_U8:
			gl_internal_format = gl.RG8
		case .GRAYSCALE_ALPHA_F32:
			gl_internal_format = gl.RG32F
		case .DEPTH_F32:
			gl_internal_format = gl.DEPTH_COMPONENT32F
		}

		gl.RenderbufferStorage(gl.RENDERBUFFER, gl_internal_format, size.x, size.y)

		return id
	}

	fb := Gl_Framebuffer{}

	gl.GenFramebuffers(1, &fb.id)
	gl.BindFramebuffer(gl.FRAMEBUFFER, fb.id)
	defer gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

	for attachment, i in color_attachments {
		if !attachment.write_only {
			texture_handle := new_texture(
				dev,
				size,
				gpu_format = attachment.format,
				input_format = attachment.format,
			)
			texture := hm.get(&global.textures, texture_handle)

			gl.FramebufferTexture2D(
				gl.FRAMEBUFFER,
				gl.COLOR_ATTACHMENT0 + u32(i),
				gl.TEXTURE_2D,
				texture.id,
				level = 0,
			)

			append(
				&fb.color_attachments,
				Gl_Framebuffer_Attachment {
					handle = texture_handle,
					id = texture.id,
					renderbuffer = false,
				},
			)
		} else {
			rbo := new_renderbuffer(dev, size, attachment.format)
			gl.FramebufferRenderbuffer(
				gl.FRAMEBUFFER,
				gl.COLOR_ATTACHMENT0 + u32(i),
				gl.RENDERBUFFER,
				rbo,
			)

			append(
				&fb.color_attachments,
				Gl_Framebuffer_Attachment{id = rbo, renderbuffer = true},
			)
		}
	}

	switch attachment in depth_stencil_attachment {
	case Attachment:
		attachment_type: u32
		switch attachment.format {
		case .DEPTH_F32:
			attachment_type = gl.DEPTH_ATTACHMENT

		case .GRAYSCALE_U8:
		case .GRAYSCALE_F32:
		case .GRAYSCALE_ALPHA_U8:
		case .GRAYSCALE_ALPHA_F32:
		case .RGB_U8:
		case .RGBA_U8:
		case .RGB_F32:
		case .RGBA_F32:
			fmt.panicf("expected depth/stencil attachment, got color attachment")
		}

		if !attachment.write_only {
			fb.depth_stencil_attachment.handle = new_texture(
				dev,
				size,
				gpu_format = attachment.format,
				input_format = attachment.format,
			)
			texture := hm.get(&global.textures, fb.depth_stencil_attachment.handle)
			fb.depth_stencil_attachment.id = texture.id
			fb.depth_stencil_attachment.renderbuffer = false

			gl.FramebufferTexture2D(
				gl.FRAMEBUFFER,
				attachment_type,
				gl.TEXTURE_2D,
				texture.id,
				level = 0,
			)
		} else {
			rbo := new_renderbuffer(dev, size, attachment.format)
			gl.FramebufferRenderbuffer(
				gl.FRAMEBUFFER,
				attachment_type,
				gl.RENDERBUFFER,
				rbo,
			)

			fb.depth_stencil_attachment = {
				id           = rbo,
				renderbuffer = true,
			}
		}
	}

	status := gl.CheckFramebufferStatus(gl.FRAMEBUFFER)
	if status != gl.FRAMEBUFFER_COMPLETE {
		fmt.printfln("couldn't create framebuffer (gl framebuffer status 0x%X)", status)
		return {}
	}

	return hm.add(&global.framebuffers, fb)
}

free_framebuffer :: proc(framebuffer: Framebuffer)
{
	fb, ok := hm.get(&global.framebuffers, framebuffer)
	if !ok do return

	gl.DeleteFramebuffers(1, &fb.id)

	for attachment in fb.color_attachments {
		if attachment.renderbuffer {
			mate := attachment.id
			gl.DeleteRenderbuffers(1, &mate)
		} else {
			free_texture(attachment.handle)
		}
	}

	hm.remove(&global.framebuffers, framebuffer)
}

default_framebuffer :: proc(dev: Device) -> Framebuffer
{
	d, ok := hm.get(&global.devices, dev)
	assert(ok)

	return d.default_framebuffer
}

framebuffer_color_attachment :: proc(framebuffer: Framebuffer, idx: i32) -> Texture
{
	fb, ok := hm.get(&global.framebuffers, framebuffer)
	assert(ok)

	// default framebuffer
	if fb.id == 0 {
		unimplemented("opengl is goofy and i don't feel safe doing this")
	} else {
		// TODO this sucks
		if fb.color_attachments[idx].renderbuffer {
			fmt.printfln("framebuffer attachment %d is write-only", idx)
			return {}
		}

		return fb.color_attachments[idx].handle
	}
}

framebuffer_depth_stencil_attachment :: proc(framebuffer: Framebuffer) -> Texture
{
	fb, ok := hm.get(&global.framebuffers, framebuffer)
	assert(ok)

	// default framebuffer
	if fb.id == 0 {
		unimplemented("opengl is goofy and i don't feel safe doing this")
	} else {
		// TODO this sucks
		if fb.depth_stencil_attachment.renderbuffer {
			fmt.printfln("framebuffer depth/stencil attachment is write-only")
			return {}
		}

		return fb.depth_stencil_attachment.handle
	}
}
