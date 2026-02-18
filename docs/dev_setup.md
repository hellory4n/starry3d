# Development setup

> [!NOTE]
> This is intended for people who want to build the library, either for other projects or to contribute.

## Prerequisites

You need these installed:
- Git
- A C compiler (gcc, clang, msvc)
- [Odin](https://odin-lang.org) v2025.11 or higher
- Windowing libraries for your OS
    - on Windows you *may* have to install Visual Studio
    - on Linux install the X11 and Wayland dev packages:
        - Debian, Ubuntu, etc: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
        - Fedora: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`
        - Arch: `sudo pacman -S glfw` should pull all other dependencies
- [Vulkan SDK](https://vulkan.lunarg.com/sdk/home)
- [Just](https://github.com/casey/just)
- [Premake 5](https://premake.github.io)

## Building C libraries

Starry depends on a few C libraries. You can build all of them with `just -f build_clibs.just`, and it should do everything automatically.

If necessary you can rebuild specific libraries or set variables to something else. Just look at `just --help`.

## Odin libraries

After building the C libraries, you can use Just again to run specific projects. For example `just run-sandbox`

Including Starry in new projects is a bit more involved. There are 2 main projects:
- `starryrt`: the big heavy engine and runtime
- `starrylib`: general utilities that work without the runtime

`starrylib` only depends on `core:*`, so it can be just copied and pasted into a new project.

As for `starryrt`, it depends on the C libraries as well as other libraries in `thirdparty/`. Everything not prefixed with `c-` is an Odin package and should be able to be copied and pasted as well. You probably want to copy `build_clibs.just` as well, to not have to rely on pre-compiled binaries for the C libraries.
