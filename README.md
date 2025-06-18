# starry3d v0.4.0

> [!WARNING]
> This is in active development. It may be janky, or worse, busted.

3D renderer for voxel graphics and other fancy crapfrick.

## Features

- C++14 and OpenGL 3.3
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
- Consider not using OpenGL (coming in 2054)

## Building

### Windows

I have no idea just install WSL lmao

### Linux

You need these installed:
- git
- gcc or clang
- lua
- cmake
- make
- X11 and wayland packages (it depends on your distro)
- mingw64-gcc (optional)

After cloning the repo you should be able to just run:

```sh
# see what options you can use
./engineer help
# actually build
./engineer build
```

## Usage

You need these installed:
- git
- gcc or clang
- lua
- cmake
- make
- X11 and wayland packages (it depends on your distro)
- mingw64-gcc (optional)

Now you need to include Starry3D into your project. It's recommended to do so through Git submodules:

```sh
# change "thirdparty/starry3d" to wherever you want it to be in
git submodule add https://github.com/hellory4n/starry3d thirdparty/starry3d
# starry3d has its own submodules
git submodule update --init --recursive
```

### Option A: Integrating into an existing project

Make sure you're using C++14 or higher, it won't work in anything older.

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
If you're using ImGui:
- `thirdparty/imgui`
- `thirdparty/imgui/backends`

Add these source files: (relative to where you put starry3d)
- `src/st_common.cpp`
- `src/st_render.cpp`
- `src/st_window.cpp`
- `thirdparty/libtrippin/libtrippin.cpp`
If you're using ImGui:
- `src/st_imgui.cpp`
- `thirdparty/imgui/imgui.cpp`
- `thirdparty/imgui/imgui_demo.cpp`
- `thirdparty/imgui/imgui_draw.cpp`
- `thirdparty/imgui/imgui_tables.cpp`
- `thirdparty/imgui/imgui_widgets.cpp`
- `thirdparty/imgui/backends/imgui_impl_glfw.cpp`
- `thirdparty/imgui/backends/imgui_impl_opengl3.cpp`

You also have to link with some libraries:
- Windows (MinGW): `opengl32`, `gdi32`, `winmm`, `comdlg32`, `ole32`, `pthread`
- Linux: `X11`, `Xrandr`, `GL`, `Xinerama`, `m`, `pthread`, `dl`, `rt`

Now put this in your `main.cpp` and run to check if it worked:

```c
#include <libtrippin.hpp>
#include <st_common.hpp>
#include <st_window.hpp>
#include <st_render.hpp>
#include <st_imgui.hpp>

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

### Option B: Using static libraries

Make sure you're using C++14 or higher, it won't work in anything older.

Run this from where you put starry3d:

```sh
./engineer build-lib
```

Now copy these into where you put your libraries:
- `build/static/libtrippin.a`
- `build/static/libstarry3d.a`
- `build/static/libglfw3.a`
- `build/static/libimgui.a` (optional)

Add these to your includes: (relative to where you put starry3d)
- `src/`
- `thirdparty/`
- `thirdparty/libtrippin`
- `thirdparty/glfw/include`
- `thirdparty/stb`
- `thirdparty/whereami/src`
If you're using ImGui:
- `thirdparty/imgui`
- `thirdparty/imgui/backends`

And link with these libraries:
- Windows (MinGW): `starry3d`, `trippin`, `glfw3`, `opengl32`, `gdi32`, `winmm`, `comdlg32`, `ole32`, `pthread`
- Linux: `starry3d`, `trippin`, `glfw3`, `X11`, `Xrandr`, `GL`, `Xinerama`, `m`, `pthread`, `dl`, `rt`

If you're using ImGui you'll also have to link with `imgui`

Now put this in your `main.cpp` and run to check if it worked:

```c
#include <libtrippin.hpp>
#include <st_common.hpp>
#include <st_window.hpp>
#include <st_render.hpp>
#include <st_imgui.hpp>

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

### Option C: Using [engineer](https://github.com/hellory4n/libtrippin/tree/main/engineerbuild)

I have a build system for some reason. `sandbox/` includes an example of this setup.

Make sure to get `engineer`, `engineer.lua`, `libengineer.lua`, and `starry3d.lua` from there.

Then you should only have to change these lines at the start:

```lua
-- where are your assets
local assets = "assets"
-- where is starry3d
local starrydir = "thirdparty/starry3d"
local project = eng.newproj("very_handsome_game", "executable", "c++14")
project:add_includes({"src"})
-- add your .cpp files here
project:add_sources({
	"src/main.cpp"
})
```

Now put this in `src/main.cpp` and run `./engineer run` to check if it worked:

```c
#include <libtrippin.hpp>
#include <st_common.hpp>
#include <st_window.hpp>
#include <st_render.hpp>
#include <st_imgui.hpp>

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

You can run `./engineer help` for more information

## FAQ

### Have you tried [game engine] you fucking moron

No fuck off.

### Why?

Why not.

### Can't you be a normal human being and use Rust Go Zig Odin Nim Sip Cliff Swig Beef (this one is real) Swag S'mores?

No fuck off.
