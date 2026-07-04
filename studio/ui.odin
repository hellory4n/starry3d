package studio

import stapp "../starryapp"
import st "../starrylib"
import im "../thirdparty/imgui"

studio_ui_init :: proc()
{
	set_theme()
}

studio_ui_free :: proc()
{
	// TODO
}

studio_ui :: proc()
{
	dockspace()
	menu_bar()
	im.ShowDemoWindow()

	if global.popups.about do about_window(&global.popups.about)
}

dockspace :: proc()
{
	window_flags := im.WindowFlags {
		.NoDocking,
		.NoTitleBar,
		.NoCollapse,
		.NoResize,
		.NoMove,
		.NoBringToFrontOnFocus,
		.NoNavFocus,
		.NoBackground,
		.MenuBar,
	}

	viewport := im.GetMainViewport()
	im.SetNextWindowPos(viewport.Pos)
	im.SetNextWindowSize(viewport.Size)
	im.SetNextWindowViewport(viewport.ID_)

	im.PushStyleVarImVec2(.WindowPadding, {0, 0})
	im.Begin("Studio", flags = window_flags)
	defer im.End()
	im.PopStyleVar()
}

menu_bar :: proc()
{
	if im.BeginMainMenuBar() {
		defer im.EndMainMenuBar()

		if im.BeginMenu("Starry") {
			defer im.EndMenu()
			if im.MenuItem("Online documentation") {
				open_url("https://github.com/hellory4n/starry3d/tree/main/docs")
			}

			if im.MenuItem("About Starry") {
				global.popups.about = true
			}

			if im.MenuItem("Quit", "Alt+F4" if ODIN_OS == .Windows else "") {
				stapp.request_quit()
			}
		}

		if im.BeginMenu("File") {
			defer im.EndMenu()
			if im.MenuItem("Undo", "Ctrl+Z") {  }
			if im.MenuItem("Redo", "Ctrl+Y") {  }
		}
	}
}

about_window :: proc(p_open: ^bool)
{
	window_size := im.GetWindowViewport().Size * {0.4, 0.5}
	im.SetNextWindowSize(window_size, cond = .Appearing)

	// TODO i know it says "don't use" on .Modal but somehow it's the only way to make it
	// properly centered, as calculating the position manually mysteriously leaves the
	// window slightly off-center
	im.Begin("About Starry", p_open, {.Modal, .NoResize})
	defer im.End()

	im.Text("The Starry Project %s", st.VERSION_STR)
	im.TextLinkOpenURL("Source code", URL_SOURCE_CODE)
	im.SameLine()
	im.TextLinkOpenURL("Documentation", URL_DOCUMENTATION)
	im.Separator()

	if im.BeginTabBar("about tabs", {.NoTooltip}) {
		defer im.EndTabBar()

		if im.BeginTabItem("Build info") {
			defer im.EndTabItem()
			copy_to_clipboard := im.Button("Copy to clipboard")

			child_size := im.Vec2{0, im.GetTextLineHeightWithSpacing() * 18}
			im.BeginChild("build info", child_size, {.FrameStyle})
			defer im.EndChild()

			if copy_to_clipboard {
				im.LogToClipboard()
			}
			defer if copy_to_clipboard {
				im.LogFinish()
			}

			im.Text("OS: %s", st.temp_cstr(ODIN_OS_STRING))
			im.Text("Architecture: %s", st.temp_cstr(ODIN_ARCH_STRING))
			im.Text("Micro-architecture: %s", st.temp_cstr(ODIN_MICROARCH_STRING))
			im.Text("Debug: %s", "true" when ODIN_DEBUG else "false")
			im.Text(
				"Assertions enabled: %s",
				"false" when ODIN_DISABLE_ASSERT else "true",
			)
			im.Text("Built with Odin %s", st.temp_cstr(ODIN_VERSION))
		}

		if im.BeginTabItem("License") {
			defer im.EndTabItem()

			// TODO render proper markdown here
			// this will do for now
			LICENSES :: #load("../COPYRIGHT.md", cstring)
			im.InputTextMultiline(
				"##licenses",
				LICENSES,
				len(LICENSES) + 1,
				size = im.GetContentRegionAvail(),
				flags = {.WordWrap, .ReadOnly},
			)
		}
	}
}
