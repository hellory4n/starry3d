package imgui_impl_opengl3

import imgui "../"

when      ODIN_OS == .Windows { foreign import lib "../imgui_windows_x64.lib" }
else when ODIN_OS == .Linux   { foreign import lib "../imgui_linux_x64.a" }
else when ODIN_OS == .Darwin  {
	when ODIN_ARCH == .amd64 { foreign import lib "../imgui_darwin_x64.a" } else { foreign import lib "../imgui_darwin_arm64.a" }
}

// imgui_impl_opengl3.h
// Last checked `v1.92.8-docking` (2a08c87)
@(link_prefix="ImGui_ImplOpenGL3_")
foreign lib {
	// Backend API
	Init           :: proc(glsl_version: cstring = nil) -> bool ---
	Shutdown       :: proc() ---
	NewFrame       :: proc() ---
	RenderDrawData :: proc(draw_data: ^imgui.DrawData) ---

	// (Optional) Called by Init/NewFrame/Shutdown
	CreateDeviceObjects  :: proc() -> bool ---
	DestroyDeviceObjects :: proc() ---

	// (Advanced) Use e.g. if you need to precisely control the timing of texture updates (e.g. for staged rendering), by setting ImDrawData::Textures = nullptr to handle this manually.
	UpdateTexture :: proc(tex: ^imgui.TextureData) ---
}
