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

import "core:sys/windows"

Backend :: enum {
	UNSUPPORTED,
	DIRECT3D_11,
}

// Returns the selected graphics API used internally
query_backend :: proc() -> Backend
{
	when ODIN_OS == .Windows {
		return .DIRECT3D_11
	} else {
		unimplemented()
	}
}

D3D11_Glue :: struct {
	hwnd: windows.HWND,
}

// Puts the graphics API and window system together
Glue :: union {
	D3D11_Glue,
}

// Initializes the graphics context
new_ctx :: proc(
	glue: Glue,
	app_name: string = "A Starry app",
	app_version: [3]i32 = {0, 0, 0},
	engine_name: string = "A Starrygpu engine",
	engine_version: [3]i32 = {0, 0, 0},
)
{
	switch query_backend() {
	case .DIRECT3D_11:
		d3d11_new_ctx(glue, app_name, app_version, engine_name, engine_version)
	case .UNSUPPORTED:
		unimplemented()
	}
}

// Frees the graphics context
free_ctx :: proc()
{
	switch query_backend() {
	case .DIRECT3D_11:
		d3d11_free_ctx()
	case .UNSUPPORTED:
		unimplemented()
	}
}

Load_Action :: enum {
	// Keep existing contents
	LOAD,
	// All contents reset and set to a constant
	CLEAR,
	// Existing contents are undefined and ignored
	IGNORE,
}

Store_Action :: enum {
	// Rendered contents will be stored in memory and can be read later
	STORE,
	// Existing contents are undefined and ignored
	IGNORE,
}

// render my pass<3
start_render_pass :: proc(
	frame_load_action: Load_Action,
	frame_store_action: Store_Action,
	frame_clear_color: [4]f32,
)
{
	switch query_backend() {
	case .DIRECT3D_11:
		d3d11_start_render_pass(frame_load_action, frame_store_action, frame_clear_color)
	case .UNSUPPORTED:
		unimplemented()
	}
}

end_render_pass :: proc()
{
	switch query_backend() {
	case .DIRECT3D_11:
		d3d11_end_render_pass()
	case .UNSUPPORTED:
		unimplemented()
	}
}

swap_buffers :: proc()
{
	switch query_backend() {
	case .DIRECT3D_11:
		d3d11_swap_buffers()
	case .UNSUPPORTED:
		unimplemented()
	}
}

recreate_swapchain :: proc()
{
	switch query_backend() {
	case .DIRECT3D_11:
		d3d11_recreate_swapchain()
	case .UNSUPPORTED:
		unimplemented()
	}
}

set_viewport :: proc(top_left: [2]i32, size: [2]i32, min_depth: i32, max_depth: i32)
{
	switch query_backend() {
	case .DIRECT3D_11:
		d3d11_set_viewport(top_left, size, min_depth, max_depth)
	case .UNSUPPORTED:
		unimplemented()
	}
}
