// Implements Dear ImGui support for Starry
package imgui_impl_starry

import stapp ".."
import im "../../thirdparty/imgui"
import "../../thirdparty/imgui/imgui_impl_glfw"
import "../../thirdparty/imgui/imgui_impl_opengl3"
import "../gpu"

init :: proc()
{
	imgui_impl_glfw.InitForOpenGL(stapp.main_window().glfw, true)
	// 3.3 is the minimum starrygpu supports
	imgui_impl_opengl3.Init("#version 330")
}

shutdown :: proc()
{
	imgui_impl_opengl3.Shutdown()
	imgui_impl_glfw.Shutdown()
}

new_frame :: proc()
{
	imgui_impl_opengl3.NewFrame()
	imgui_impl_glfw.NewFrame()
}

render_draw_data :: proc(dev: gpu.Device, draw_data: ^im.DrawData)
{
	imgui_impl_opengl3.RenderDrawData(draw_data)
}
