package studio

import st "../starry"
import im "../thirdparty/imgui"

ui_studio :: proc()
{
	ui_dockspace()
	ui_menu_bar()
	im.ShowDemoWindow()

	if global.popups.about do ui_about_window(&global.popups.about)
}

ui_dockspace :: proc()
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

ui_menu_bar :: proc()
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
				st.request_quit()
			}
		}

		if im.BeginMenu("File") {
			defer im.EndMenu()
			if im.MenuItem("Undo", "Ctrl+Z") {  }
			if im.MenuItem("Redo", "Ctrl+Y") {  }
		}
	}
}

ui_about_window :: proc(p_open: ^bool)
{
	window_size := im.GetWindowViewport().Size * {0.4, 0.5}
	im.SetNextWindowSize(window_size, cond = .Appearing)

	im.Begin("About Starry", p_open, {.NoResize})
	defer im.End()

	im.Text("The Starry Project %s", st.VERSION_STR)
	im.TextLinkOpenURL("Source code", URL_SOURCE_CODE)
	im.SameLine()
	im.TextLinkOpenURL("Documentation", URL_DOCUMENTATION)
	im.Separator()

	if im.BeginTabBar("about tabs", {.NoTooltip}) {
		defer im.EndTabBar()

		if im.BeginTabItem("License") {
			defer im.EndTabItem()

			LICENSE :: #load("../LICENSE", cstring)
			im.InputTextMultiline(
				"##license",
				LICENSE,
				len(LICENSE) + 1,
				size = im.GetContentRegionAvail(),
				flags = {.WordWrap, .ReadOnly},
			)
		}

		if im.BeginTabItem("Thirdparty licenses") {
			defer im.EndTabItem()

			LICENSES :: #load("../3rdparty_licenses.txt", cstring)
			im.InputTextMultiline(
				"##3rdparty",
				LICENSES,
				len(LICENSES) + 1,
				size = im.GetContentRegionAvail(),
				flags = {.WordWrap, .ReadOnly},
			)
		}

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
	}
}
