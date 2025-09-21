# Building

> [!NOTE]
> This is the guide for building the library itself (and related projects such as [sandbox](../../sandbox/README.md) and the other one I'll make once the renderer is done). For using starry in your own projects, see [the setup guide](../getting_started/setup.md)

## Requirements

- Linux or macOS (developing from Windows isn't supported, sorry)
- git
- lua
- clang
- ninja build
- cmake
- linux only: X11 and Wayland dev packages
    - ubuntu/debian: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
    - fedora: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`

Also make sure you cloned with `--recursive` (e.g. `git clone https://github.com/hellory4n/starry3d --recursive`)

## Actually building frfr

Run `./configure.lua` to configure the project. The options are pretty straightforward, just use your eyeballs to read.

> [!NOTE]
> `./configure.lua` doesn't have to run every time you build the project, only when either:
> - you first cloned the repo
> - you have to update the build settings
> - you edited the build script

Now run `ninja` to compile. The executable will be in `./build/bin/sandbox`.
