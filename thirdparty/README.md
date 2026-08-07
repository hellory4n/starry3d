# Thirdparty libraries

This list does not include libraries from `vendor:`.

## imgui

- Source: https://gitlab.com/L-4/odin-imgui
- Commit: [`a116eb1ceaa6acde60219efdd56bf6c2e1aedf4c`](https://gitlab.com/L-4/odin-imgui/-/commit/a116eb1ceaa6acde60219efdd56bf6c2e1aedf4c)
- License: MIT (Copyright (c) 2024 Trevin Sorenson)
- Files extracted:
	- `imgui_impl_glfw/imgui_impl_glfw.odin`
	- `imgui_impl_opengl3/imgui_impl_opengl3.odin`
	- `imconfig.odin`
	- `imgui.odin`
	- `imconfig.odin`
	- `imgui.odin`
	- `imgui_internal.odin`
	- `imgui_js.odin`
	- `imgui_linux_x64.a` (custom build)
	- `imgui_manual.odin`
	- `imgui_windows_x64.lib`
	- `lib_name.odin`
	- `LICENSE`

## luajit

Based on Odin v2026.07's `vendor:lua/5.1` package (+ backports from later versions), but with the binaries replaced by [LuaJIT](https://luajit.org) commit `acb223497d84c65139a7eaaac395b42f112249ac`

The binaries were built using:
- Linux: `make BUILDMODE=static STATIC_CC="gcc -fPIC"`
- Windows: `msvcbuild.bat static`

See `luajit/LICENSE` for licensing information.

## freetype

- Source: https://github.com/englerj/odin-freetype
- Commit: [`300736e1d1a03b431b22efbe8354e9333609e283`](https://github.com/englerj/odin-freetype/commit/300736e1d1a03b431b22efbe8354e9333609e283)
- License:
	- `freetype.odin`: MIT (Copyright (c) 2021 Josh Engler)
	- Binaries: FreeType License (Copyright 1996-2002, 2006 by David Turner, Robert Wilhelm, and Werner Lemberg)
- Files extracted:
	- `freetype.odin` (modified linking)
	- `LICENSE` (from odin-imgui)
	- `FTL.TXT` (from FreeType)

Binaries are from release v2.14.3.

## harfbuzz

- Source: https://codeberg.org/mgavioli/odin-harfbuzz
- Commit: [`f29df67c8270efa64493a935ba53ea9ad329638e`](https://codeberg.org/mgavioli/odin-harfbuzz/commit/f29df67c8270efa64493a935ba53ea9ad329638e)
- License:
	- `*.odin`: 2-Clause BSD (Copyright (c) 2024-2026, Maurizio M. Gavioli and contributors)
	- Binaries: MIT (see `COPYING.txt` for copyright)
- Files extracted: (modified linking on all `.odin` files)
	- `harfbuzz/`
	- `harfbuzz/aat/`
	- `harfbuzz/ot/`
	- `harfbuzz/style/`
	- `harfbuzz/subset/`
	- `freetype.odin` is custom

Binaries are from release v13.2.1, built with:

```bat
meson setup build --default-library=static --buildtype=release --wrap-mode=default -Dtests=disabled -Dutilities=disabled -Ddocs=disabled -Dintrospection=disabled -Dfreetype=enabled -Dsubset=disabled -Db_vscrt=mt -Dcpp_link_args="/NODEFAULTLIB:msvcrt" -Dc_link_args="/NODEFAULTLIB:msvcrt"
meson compile -C build
```

Weirdly this builds as `libharfbuzz.a` on Windows, but you can safely rename it to `harfbuzz.lib`.
