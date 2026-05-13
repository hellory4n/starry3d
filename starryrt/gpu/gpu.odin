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

import "base:intrinsics"
import "base:runtime"
import hm "core:container/handle_map"
import "core:log"
import "core:mem"
import "core:reflect"
import "core:strings"
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
	handle:        Pipeline,
	id:            u32,
	topology:      Topology,
	front_face:    Winding_Order,
	cull:          Cull_Face,
	vertex_layout: []Vertex_Attribute,
	vertex_size:   int,
	compute:       bool,
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
	handle:   Buffer,
	size:     int,
	id:       u32,
	gltarget: u32,
	glusage:  u32,
}

Texture :: distinct hm.Handle32

@(private)
Gl_Texture :: struct {
	handle: Texture,
	id:     u32,
}

Sampler :: distinct hm.Handle32

@(private)
Gl_Sampler :: struct {
	handle: Sampler,
	id:     u32,
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
					log.errorf("OpenGL 0x%X: %s", id, message)
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

	dev, ok = hm.add(&global.devices, Gl_Device{})
	assert(ok)

	// objectively better defaults than opengl
	set_blend(dev, .SRC_ALPHA, .ONE_MINUS_SRC_ALPHA)

	return dev, true
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

new_pipeline :: proc(
	dev: Device,
	shaders: Shaders,
	topology := Topology.TRIANGLE_LIST,
	front_face := Winding_Order.COUNTER_CLOCKWISE,
	cull := Cull_Face.NONE,
	vertex_layout: []Vertex_Attribute = nil,
	vertex_size: int = 0,
	allocator := context.allocator,
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

	vhuyvfyfhbvhyf := vertex_layout
	if vertex_layout != nil {
		vhuyvfyfhbvhyf = make([]Vertex_Attribute, len(vertex_layout), allocator)
		copy(vhuyvfyfhbvhyf, vertex_layout)
	}

	return hm.add(
			&global.pipelines,
			Gl_Pipeline {
				id = id,
				topology = topology,
				front_face = front_face,
				cull = cull,
				compute = compute,
				vertex_layout = vhuyvfyfhbvhyf,
				vertex_size = vertex_size,
			},
		),
		true
}

free_pipeline :: proc(pipeline: Pipeline, allocator := context.allocator)
{
	p, ok := hm.get(&global.pipelines, pipeline)
	assert(ok)

	gl.DeleteProgram(p.id)
	delete(p.vertex_layout, allocator)
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

// Sets the uniforms for the shader. This is done through evil reflection fuckery:
// Shader code:
// ```glsl
// uniform mat4 u_model;
// uniform mat4 u_view;
// uniform mat4 u_proj;
// ```
// CPU side:
// ```odin
// Uniforms :: struct {
//         model: matrix[4, 4]f32 `gpu:"u_model"`
//         view:  matrix[4, 4]f32 `gpu:"u_view"`
//         proj:  matrix[4, 4]f32 `gpu:"u_proj"`
// }
// ```
//
// Supported types: (GLSL -> Odin)
// - `float` -> `f32`
// - `int` -> `i32`
// - `uint` -> `u32`
// - `vec2` -> `[2]f32`
// - `ivec2` -> `[2]i32`
// - `uvec2` -> `[2]u32`
// - `vec3` -> `[3]f32`
// - `ivec3` -> `[3]i32`
// - `uvec3` -> `[3]u32`
// - `vec4` -> `[4]f32`
// - `ivec4` -> `[4]i32`
// - `uvec4` -> `[4]u32`
// - `mat2` -> `matrix[2, 2]f32`
// - `mat3` -> `matrix[3, 3]f32`
// - `mat4` -> `matrix[4, 4]f32`
// - `mat2x3` -> `matrix[2, 3]f32`
// - `mat3x2` -> `matrix[3, 2]f32`
// - `mat2x4` -> `matrix[2, 4]f32`
// - `mat4x2` -> `matrix[4, 2]f32`
// - `mat3x4` -> `matrix[3, 4]f32`
// - `mat4x3` -> `matrix[4, 3]f32`
// - `sampler2D` -> `i32`
set_uniforms :: proc(dev: Device, uniforms: $T) where intrinsics.type_is_struct(T)
{
	uniforms := uniforms
	d, ok1 := hm.get(&global.devices, dev)
	assert(ok1)

	// TODO cache this i'm begging you
	for field in reflect.struct_fields_zipped(T) {
		name := field.name
		if uname, ok2 := reflect.struct_tag_lookup(field.tag, "gpu"); ok2 {
			name = uname
		}

		loc := gl.GetUniformLocation(
			program = d.current_pipeline.id,
			name = strings.clone_to_cstring(name, context.temp_allocator),
		)
		if loc < 0 {
			log.warnf("uniform %q missing", name)
		}

		// ptr fucking my beloved
		bytes := cast(^byte)&uniforms
		uptr := mem.ptr_offset(bytes, field.offset)

		// fuck
		switch field.type.id {
		case f32:
			val := (cast(^f32)uptr)^
			gl.Uniform1f(loc, val)
		case i32:
			val := (cast(^i32)uptr)^
			gl.Uniform1i(loc, val)
		case u32:
			val := (cast(^u32)uptr)^
			gl.Uniform1ui(loc, val)
		case [2]f32:
			val := (cast(^[2]f32)uptr)^
			gl.Uniform2f(loc, val.x, val.y)
		case [2]i32:
			val := (cast(^[2]i32)uptr)^
			gl.Uniform2i(loc, val.x, val.y)
		case [2]u32:
			val := (cast(^[2]u32)uptr)^
			gl.Uniform2ui(loc, val.x, val.y)
		case [3]f32:
			val := (cast(^[3]f32)uptr)^
			gl.Uniform3f(loc, val.x, val.y, val.z)
		case [3]i32:
			val := (cast(^[3]i32)uptr)^
			gl.Uniform3i(loc, val.x, val.y, val.z)
		case [3]u32:
			val := (cast(^[3]u32)uptr)^
			gl.Uniform3ui(loc, val.x, val.y, val.z)
		case [4]f32:
			val := (cast(^[4]f32)uptr)^
			gl.Uniform4f(loc, val.x, val.y, val.z, val.w)
		case [4]i32:
			val := (cast(^[4]i32)uptr)^
			gl.Uniform4i(loc, val.x, val.y, val.z, val.w)
		case [4]u32:
			val := (cast(^[4]u32)uptr)^
			gl.Uniform4ui(loc, val.x, val.y, val.z, val.w)
		case matrix[2, 2]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix2fv(loc, 1, false, val)
		case matrix[3, 3]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix3fv(loc, 1, false, val)
		case matrix[4, 4]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix4fv(loc, 1, false, val)
		case matrix[2, 3]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix2x3fv(loc, 1, false, val)
		case matrix[3, 2]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix3x2fv(loc, 1, false, val)
		case matrix[2, 4]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix2x4fv(loc, 1, false, val)
		case matrix[4, 2]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix4x2fv(loc, 1, false, val)
		case matrix[3, 4]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix3x4fv(loc, 1, false, val)
		case matrix[4, 3]f32:
			val := cast([^]f32)uptr
			gl.UniformMatrix4x3fv(loc, 1, false, val)
		}
	}
}

Buffer_Target :: enum {
	VERTEX,
	INDEX,
	STORAGE,
}

Buffer_Usage :: enum {
	READ_ONLY,
	MUTABLE,
	STREAMED,
}

new_buffer :: proc(
	dev: Device,
	target: Buffer_Target,
	usage: Buffer_Usage,
	size: int,
	data: []byte = nil,
) -> Buffer
{
	gltarget: u32
	switch target {
	case .VERTEX:
		gltarget = gl.ARRAY_BUFFER
	case .INDEX:
		gltarget = gl.ELEMENT_ARRAY_BUFFER
	case .STORAGE:
		gltarget = gl.SHADER_STORAGE_BUFFER
	}

	glusage: u32
	switch usage {
	case .READ_ONLY:
		glusage = gl.STATIC_DRAW
	case .MUTABLE:
		glusage = gl.DYNAMIC_DRAW
	case .STREAMED:
		glusage = gl.STREAM_DRAW
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
	assert(ok)

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

bind_storage_buffer :: proc(dev: Device, buffer: Buffer, slot: u32)
{
	b, ok := hm.get(&global.buffers, buffer)
	assert(ok)

	b.gltarget = gl.SHADER_STORAGE_BUFFER // TODO this is likely stupid but so is opengl
	gl.BindBuffer(b.gltarget, b.id)
	gl.BindBufferBase(b.gltarget, slot, b.id)
}

Texture_Format :: enum {
	RGB_U8,
	RGBA_U8,
	RGB_F32,
	RGBA_F32,
}

new_texture :: proc(
	dev: Device,
	size: [2]i32,
	input_format: Texture_Format,
	gpu_format: Texture_Format,
	data: []byte,
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
	}

	gl_format: u32
	switch input_format {
	case .RGB_U8, .RGB_F32:
		gl_format = gl.RGB
	case .RGBA_U8, .RGBA_F32:
		gl_format = gl.RGBA
	}

	gl_type: u32
	switch input_format {
	case .RGB_U8, .RGBA_U8:
		gl_type = gl.UNSIGNED_BYTE
	case .RGB_F32, .RGBA_F32:
		gl_type = gl.FLOAT
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
	assert(ok)

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

new_sampler :: proc(dev: Device, wrap: Texture_Wrap, filter: Texture_Filter) -> Sampler
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
	assert(ok)

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
