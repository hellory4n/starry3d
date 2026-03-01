# Development setup

## Prerequisites

You need these installed:
- Git
- A C compiler (gcc, clang, msvc)
- [Odin](https://odin-lang.org) v2026.02
- Windowing libraries for your OS
    - on Windows you *may* have to install Visual Studio
    - on Linux install the X11 and Wayland dev packages:
        - Debian, Ubuntu, etc: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
        - Fedora: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`
        - Arch: `sudo pacman -S glfw` should pull all other dependencies
- [Vulkan SDK](https://vulkan.lunarg.com/sdk/home) on Linux
- [Just](https://github.com/casey/just)

## Odin libraries

After building the C libraries, you can use Just again to run specific projects. For example `just run-sandbox`

Including Starry in new projects is a bit more involved. There are 2 packages:
- `starryrt/`: the big heavy engine and runtime
- `starrylib/`: general utilities that work without the runtime
- `thirdparty/`: any dependencies used by starryrt

Starrylib can be used by any project by just copy and pasting it, since it only depends on `core:*` and `vendor:stb/image`.
If you want the full engine, you need to copy both `starryrt/`, `starrylib/`, and `thirdparty/`.
