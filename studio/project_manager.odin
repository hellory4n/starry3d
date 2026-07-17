package studio

import im "../thirdparty/imgui"

ui_project_manager :: proc()
{
	// don't soft-lock yourself
	im.Begin("Project Manager", &global.popups.project_manager if is_project_loaded() else nil)
	defer im.End()

	im.Text("man")
}
