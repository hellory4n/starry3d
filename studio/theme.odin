package studio

import im "../thirdparty/imgui"

set_theme :: proc()
{
	colors := &im.GetStyle().Colors
	colors[im.Col.Text] = {1.00, 1.00, 1.00, 1.00}
	colors[im.Col.TextDisabled] = {0.50, 0.50, 0.50, 1.00}
	colors[im.Col.WindowBg] = {0.05, 0.05, 0.07, 0.9}
	colors[im.Col.TitleBg] = {0.00, 0.00, 0.00, 1.00}
	colors[im.Col.TitleBgActive] = {0.447, 0.223, 0.886, 1.00}
	colors[im.Col.TitleBgCollapsed] = {0.00, 0.00, 0.00, 1.00}
	colors[im.Col.MenuBarBg] = {0.14, 0.14, 0.14, 1.00}
	colors[im.Col.ScrollbarBg] = {0.05, 0.05, 0.05, 0.54}
	colors[im.Col.ScrollbarGrab] = {0.34, 0.34, 0.34, 0.54}
	colors[im.Col.ScrollbarGrabHovered] = {0.40, 0.40, 0.40, 0.54}
	colors[im.Col.ScrollbarGrabActive] = {0.56, 0.56, 0.56, 0.54}
	colors[im.Col.CheckMark] = {0.33, 0.67, 0.86, 1.00}
	colors[im.Col.SliderGrab] = {0.34, 0.34, 0.34, 0.54}
	colors[im.Col.SliderGrabActive] = {0.56, 0.56, 0.56, 0.54}
	colors[im.Col.Button] = {0.05, 0.05, 0.05, 0.54}
	colors[im.Col.ButtonHovered] = {0.19, 0.19, 0.19, 0.54}
	colors[im.Col.ButtonActive] = {0.20, 0.22, 0.23, 1.00}
	colors[im.Col.Header] = {0.00, 0.00, 0.00, 0.52}
	colors[im.Col.HeaderHovered] = {0.00, 0.00, 0.00, 0.36}
	colors[im.Col.HeaderActive] = {0.20, 0.22, 0.23, 0.33}
	colors[im.Col.Separator] = {0.28, 0.28, 0.28, 0.29}
	colors[im.Col.SeparatorHovered] = {0.44, 0.44, 0.44, 0.29}
	colors[im.Col.SeparatorActive] = {0.40, 0.44, 0.47, 1.00}
	colors[im.Col.ResizeGrip] = {0.28, 0.28, 0.28, 0.29}
	colors[im.Col.ResizeGripHovered] = {0.44, 0.44, 0.44, 0.29}
	colors[im.Col.ResizeGripActive] = {0.40, 0.44, 0.47, 1.00}
	colors[im.Col.Tab] = {0.00, 0.00, 0.00, 0.52}
	colors[im.Col.TabHovered] = {0.14, 0.14, 0.14, 1.00}
	colors[im.Col.TabSelected] = {0.20, 0.20, 0.20, 0.36}
	colors[im.Col.TabDimmed] = {0.00, 0.00, 0.00, 0.52}
	colors[im.Col.TabDimmedSelected] = {0.14, 0.14, 0.14, 1.00}
	colors[im.Col.DockingPreview] = {0.33, 0.67, 0.86, 1.00}
	colors[im.Col.DockingEmptyBg] = {0.00, 0.00, 0.00, 0.00}
	colors[im.Col.PlotLines] = {1.00, 0.00, 0.00, 1.00}
	colors[im.Col.PlotLinesHovered] = {1.00, 0.00, 0.00, 1.00}
	colors[im.Col.PlotHistogram] = {1.00, 0.00, 0.00, 1.00}
	colors[im.Col.PlotHistogramHovered] = {1.00, 0.00, 0.00, 1.00}
	colors[im.Col.TableHeaderBg] = {0.00, 0.00, 0.00, 0.52}
	colors[im.Col.TableBorderStrong] = {0.00, 0.00, 0.00, 0.52}
	colors[im.Col.TableBorderLight] = {0.28, 0.28, 0.28, 0.29}
	colors[im.Col.TableRowBg] = {0.00, 0.00, 0.00, 0.00}
	colors[im.Col.TableRowBgAlt] = {1.00, 1.00, 1.00, 0.06}
	colors[im.Col.TextSelectedBg] = {0.20, 0.22, 0.23, 1.00}
	colors[im.Col.DragDropTarget] = {0.33, 0.67, 0.86, 1.00}
	colors[im.Col.NavWindowingHighlight] = {1.00, 0.00, 0.00, 0.70}
	colors[im.Col.NavWindowingDimBg] = {1.00, 0.00, 0.00, 0.20}
	colors[im.Col.ModalWindowDimBg] = {1.00, 0.00, 0.00, 0.35}

	style := im.GetStyle()
	style.WindowPadding = {8.00, 8.00}
	style.FramePadding = {5.00, 2.00}
	style.CellPadding = {6.00, 6.00}
	style.ItemSpacing = {6.00, 6.00}
	style.ItemInnerSpacing = {6.00, 6.00}
	style.TouchExtraPadding = {0.00, 0.00}
	style.IndentSpacing = 25
	style.ScrollbarSize = 15
	style.GrabMinSize = 10
	style.WindowBorderSize = 1
	style.ChildBorderSize = 1
	style.PopupBorderSize = 1
	style.FrameBorderSize = 1
	style.TabBorderSize = 1
	style.WindowRounding = 2
	style.ChildRounding = 2
	style.FrameRounding = 1
	style.PopupRounding = 2
	style.ScrollbarRounding = 9
	style.GrabRounding = 3
	style.LogSliderDeadzone = 4
	style.TabRounding = 4
}
