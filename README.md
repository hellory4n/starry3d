# starry3d v0.5.0

> [!WARNING]
> This is in active development. It may be janky, or worse, busted.

3D renderer for voxel graphics and other fancy crapfrick.

## Features

- C++17 and OpenGL 3.3
- Cross platform ish. (windows and linux)
- Probably runs on anything ever
- Optimized for voxel graphics
- UI through [ImGui](https://github.com/ocornut/imgui), you don't have to do anything, it's
  already there
- Built on [libtrippin](https://github.com/hellory4n/libtrippin) the biggest most massive library of all time

## Limitations

- 2D support is nearly non-existent
- Currently only Windows and Linux supported
    - macOS support is possible but I don't have a Mac
    - WebGL support is also possible but I don't care about that enough to support it
    - Only tested on Clang and GCC, getting it to compile with MSVC/Visual Studio would take some work
    - I don't want to torture myself with Android just yet

## Features coming soon™ (never)

- Physics
- Particles
- Networking
- More platforms
- Decent 2D
- Consider using Vulkan (coming in 2054)

## Building

This is intended for if you want to contribute or test the library (no one will)

### Windows

I have no idea just install WSL lmao

### Linux

You need these installed:
- git
- clang
- lua
- cmake (on ubuntu you also need `pkg-config`)
- make
- ninja
- X11 and wayland dev packages (it depends on your distro)
    - debian/ubuntu/derivatives: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
    - fedora/derivatives: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`
- mingw-w64-gcc and mingw-w64-g++ (optional)

Now run `lua configure.lua`

Options:
- Compilation mode (`debug`/`release`): release mode enables optimizations, while debug mode disables
optimizations, enables debug symbols, and defines `DEBUG`/`_DEBUG`.
- Target platform (`windows`/`linux`): If compiling for windows, uses `mingw-w64-gcc` for cross-compiling.
- Use a sanitizer: You usually don't need this option. This maps directly to a `-fsanitize=` flag, so e.g.
`address` becomes `-fsanitize=address` for ASan.
- Generate `compile_commands.json` (`y`/`n`): Generates a `compile_commands.json` file for IDEs (if using
clangd) to use.

Now run `ninja` to compile. You'll now have an executable in `build/bin/sandbox`

You can also use `./debugrun.sh` to run it with gdb.

## Usage

You need these installed:
- git
- clang
- X11 and wayland dev packages (it depends on your distro)
    - debian/ubuntu/derivatives: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
    - fedora/derivatives: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`
- mingw-w64-gcc and mingw-w64-g++ (optional)

Now you need to include Starry3D into your project. It's recommended to do so through Git submodules:

```sh
# change "thirdparty/starry3d" to wherever you want it to be in
git submodule add https://github.com/hellory4n/starry3d thirdparty/starry3d
# starry3d has its own submodules
git submodule update --init --recursive
```

### Option A: Integrating into an existing project

Make sure you're using C++17 or higher, it won't work in anything older.

Note that compiling on Visual Studio isn't tested, and I don't know if it works or not.

First you need GLFW, you could either link against a [precompiled version](https://github.com/glfw/glfw/releases/tag/3.4) or [compile it yourself](https://www.glfw.org/docs/latest/compile.html). Both static and shared
libraries should work.

Now add these folders to your includes: (relative to where you put starry3d)
- `src/`
- `thirdparty/`
- `thirdparty/libtrippin`
- `thirdparty/glfw/include`
- `thirdparty/stb`
- `thirdparty/whereami/src`
- If you're using ImGui:
    - `thirdparty/imgui`
    - `thirdparty/imgui/backends`

Add these source files: (relative to where you put starry3d)
- `src/st_common.cpp`
- `src/st_render.cpp`
- `src/st_window.cpp`
- `thirdparty/libtrippin/trippin/collection.cpp`
- `thirdparty/libtrippin/trippin/common.cpp`
- `thirdparty/libtrippin/trippin/iofs.cpp`
- `thirdparty/libtrippin/trippin/log.cpp`
- `thirdparty/libtrippin/trippin/math.cpp`
- `thirdparty/libtrippin/trippin/memory.cpp`
- `thirdparty/libtrippin/trippin/string.cpp`
- If you're using ImGui:
    - `src/st_imgui.cpp`
    - `thirdparty/imgui/imgui.cpp`
    - `thirdparty/imgui/imgui_demo.cpp`
    - `thirdparty/imgui/imgui_draw.cpp`
    - `thirdparty/imgui/imgui_tables.cpp`
    - `thirdparty/imgui/imgui_widgets.cpp`
    - `thirdparty/imgui/backends/imgui_impl_glfw.cpp`
    - `thirdparty/imgui/backends/imgui_impl_opengl3.cpp`

You also have to link with some libraries on top of glfw:
- Windows (MinGW): `opengl32`, `gdi32`, `winmm`, `comdlg32`, `ole32`, `pthread`
- Linux: `X11`, `Xrandr`, `GL`, `Xinerama`, `m`, `pthread`, `dl`, `rt`

Now put this in your `main.cpp` and run to check if it worked:

```c
#include <trippin/common.hpp>
#include <trippin/log.hpp>
#include <starry/common.hpp>
#include <starry/window.hpp>
#include <starry/render.hpp>
#include <starry/imgui.hpp>

// TODO implement them
static void init_game() {}
static void update_game() {}
static void free_game() {}

int main(void)
{
    tr::use_log_file("log.txt");
    tr::init();

    st::init("very_handsome_game", "assets");
    st::WindowOptions window;
    window.title = "Very Handsome Game™";
    window.size = {1280, 720};
    window.resizable = true;
    st::open_window(window);
    st::imgui::init();

    init_game();

    while (!st::is_window_closing()) {
        st::poll_events();
        st::clear_screen(tr::Color::rgb(0x734a16));

        update_game();

        st::imgui::begin();
            // imgui goes here
        st::imgui::end();

        st::end_drawing();
    }

    free_game();

    st::imgui::free();
    st::free_window();
    st::free();

    tr::free();
    return 0;
}
```

### Option B: Using ninja/lua

Starry3D uses ninja and `configure.lua` for its build process, and this script works with your own projects
too.

You need CMake (on ubuntu you also need `pkg-config`), Make, Ninja, and Lua installed.

Copy `configure.lua` and edit this part at the start:

```lua
-- the project name
project = "JohnGaming"
-- where you put starry3d
starrydir = "thirdparty/starry3d"
-- the build directory duh
builddir = "build"

-- the assets folder
assetssrc = "assets"
-- where it'll be copied at the end
assetsdst = "build/bin/assets"

-- imgui is optional :)
imgui_enabled = true

-- put your .cpp files and include folders here
srcs = {
    "src/main.cpp",
}

includes = {
    "src"
}
```

Now put this in `src/main.cpp`:

```c
#include <trippin/common.hpp>
#include <trippin/log.hpp>
#include <starry/common.hpp>
#include <starry/window.hpp>
#include <starry/render.hpp>
#include <starry/imgui.hpp>

// TODO implement them
static void init_game() {}
static void update_game() {}
static void free_game() {}

int main(void)
{
    tr::use_log_file("log.txt");
    tr::init();

    st::init("very_handsome_game", "assets");
    st::WindowOptions window;
    window.title = "Very Handsome Game™";
    window.size = {1280, 720};
    window.resizable = true;
    st::open_window(window);
    st::imgui::init();

    init_game();

    while (!st::is_window_closing()) {
        st::poll_events();
        st::clear_screen(tr::Color::rgb(0x734a16));

        update_game();

        st::imgui::begin();
            // imgui goes here
        st::imgui::end();

        st::end_drawing();
    }

    free_game();

    st::imgui::free();
    st::free_window();
    st::free();

    tr::free();
    return 0;
}
```

Now, to compile, first setup the project with `lua configure.lua`

Options:
- Compilation mode (`debug`/`release`): release mode enables optimizations, while debug mode disables
optimizations, enables debug symbols, and defines `DEBUG`/`_DEBUG`.
- Target platform (`windows`/`linux`): If compiling for windows, uses `mingw-w64-gcc` for cross-compiling.
- Use a sanitizer: You usually don't need this option. This maps directly to a `-fsanitize=` flag, so e.g.
`address` becomes `-fsanitize=address` for ASan.
- Generate `compile_commands.json` (`y`/`n`): Generates a `compile_commands.json` file for IDEs (if using
clangd) to use.

Now run `ninja` to compile. You'll now have an executable in `build/bin/`

## FAQ

### Have you tried [game engine] you fucking moron

No fuck off.

### Why?

Why not.

### Why C++? Can't you be a normal human being and use Rust Go Zig Odin Nim Sip Cliff Swig Beef (this one is real) Swag S'mores?

No fuck off.
