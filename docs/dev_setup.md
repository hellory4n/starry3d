# Development setup

> [!NOTE]
> This is intended for people who want to build the library, either for other projects or to contribute.

First you need these installed:
- [Zig](https://ziglang.org/) v0.15.2 (v0.16 is untested, probably broken)
- Windowing libraries for your OS
    - on Windows you *may* have to install Visual Studio
    - on Linux install the X11 and Wayland dev packages:
        - Debian, Ubuntu, etc: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
        - Fedora: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`
        - Arch: `sudo pacman -S glfw` should pull all other dependencies
- glslc and spirv-cross

Now you should be able to just run `zig build`. To run sandbox (the test project), run `zig build run-sandbox`.
