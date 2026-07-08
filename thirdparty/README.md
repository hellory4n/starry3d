# Thirdparty libraries

This list does not include libraries from `vendor:`.

## imgui

- Source: https://gitlab.com/L-4/odin-imgui
- Commit: [`daa7298c62995440fd1b484c0d2f05afde055b33`](https://gitlab.com/L-4/odin-imgui/-/commit/daa7298c62995440fd1b484c0d2f05afde055b33)
- License: MIT (Copyright (c) 2024 Trevin Sorenson)
- Files extracted:
	- `imgui_impl_glfw/imgui_impl_glfw.odin`
	- `imgui_impl_opengl3/imgui_impl_opengl3.odin`
	- `imconfig.odin`
	- `imgui.odin`
	- `imgui_enabled.odin`
	- `imconfig.odin`
	- `imgui.odin`
	- `imgui_enabled.odin` (modified)
	- `imgui_internal.odin`
	- `imgui_js.odin`
	- `imgui_linux_x64.a` (custom build)
	- `imgui_manual.odin`
	- `imgui_windows_x64.lib`
	- `lib_name.odin`
	- `LICENSE`

## luajit

Based on Odin v2026.07's `vendor:lua/5.1` package, but with the binaries replaced by [LuaJIT](https://luajit.org) commit `acb223497d84c65139a7eaaac395b42f112249ac` (custom build)

See `luajit/LICENSE` for licensing information.
