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
```

`sandbox/` is the example project setup, using the engineer™™™ build system.

Make sure to get `engineer`, `engineer.lua`, and `libengineer.lua` from there.

Then you should only have to change these lines:

```lua
-- where are your assets
local assets = "assets"
-- where is starry3d
local starrydir = ".."
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
