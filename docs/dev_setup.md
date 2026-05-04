# Development setup

## Prerequisites

You need these installed:
- Git
- A C compiler (GCC, Clang, Microsoft Visual C++)
- Windowing libraries for your OS
    - on Windows install the Windows SDK
    - on Linux install the X11 and Wayland dev packages:
        - Debian, Ubuntu, etc: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
        - Fedora: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`
        - Arch: `sudo pacman -S glfw` should pull all other dependencies
- [Odin](https://odin-lang.org) v2026.04
- [Slang shader compiler](https://shader-slang.org/)
- [Just command runner](https://github.com/casey/just)

## Building

While you can run `odin build`/`odin run` like you can with any other Odin project, it's recommended that you use the Just wrappers:
- `just run-sandbox` to run the sandbox project
- `just test` to run tests

## Using Starry in new projects

The Starry engine is split into 3 main directories:
- `starryrt/`: the big heavy engine and runtime
- `starrylib/`: functions that work without the runtime
- `thirdparty/`: any dependencies used by starryrt

Starrylib can be used by any project by just downloading it, since it only depends on the Odin standard libraries.
If you want the full engine, you need to copy both `starryrt/`, `starrylib/`, and `thirdparty/`.
