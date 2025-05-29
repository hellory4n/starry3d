# starry3d v0.3.0

> [!WARNING]
> This is in active development. It may be janky, or worse, busted.

3D renderer for voxel graphics and other fancy crapfrick.

## Features

- Pure C99 and OpenGL 3.3
- Cross platform ish. (windows and linux)
- Probably runs on anything ever
- Optimized for voxel graphics
- UI through [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear), you don't have to do anything, it's
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
- Better rendering API
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
# change "vendor/starry3d" to wherever you want it to be in
git submodule add https://github.com/hellory4n/starry3d vendor/starry3d
```

`sandbox/` is the example project setup, using the engineer™™™ build system.

Make sure to get `engineer`, `engineer.lua`, and `libengineer.lua` from there.

Then you should only have to change these lines:

```lua
-- where are your assets
local assets = "assets"
-- where is starry3d
local starrydir = ".."
local project = eng.newproj("VeryHandsomeGame", "executable", "c99")
project:add_includes({"src"})
-- add your .c files here
project:add_sources({
	"src/main.c"
})
```

Now put this in `src/main.c` and run `./engineer run` to check if it worked:

```c
#include <libtrippin.h>
#include <starry3d.h>
#include <st_ui.h> // includes nuklear.h

int main(void)
{
    tr_init("log.txt");
    st_init((StSettings){
        .app_name = "test",
        // where you put your assets, relative to the executable
        .asset_dir = "assets",
        .resizable = true,
        .window_width = 800,
        .window_height = 600,
    });
    // you need a font for nuklear to work
    st_ui_new("app:default_font.ttf", 16);

    st_set_environment((StEnvironment){
        .sky_color = TR_WHITE,
    });

    // initialize your program here

    while (!st_is_closing()) {
        st_begin_drawing(TR_WHITE);

        // main loop goes here

        st_ui_begin();
            // nuklear calls go here
        st_ui_end();

        st_end_drawing();
        st_poll_events();
    }

    // deinitialize your program here

    st_ui_free();
    st_free();
    tr_free();
}
```

You can run `./engineer help` for more information

## FAQ

### Have you tried [game engine] you fucking moron

No fuck off.

### Why?

Why not.

### Why C? Can't you be a normal human being and use C++ C# Rust Go Zig Odin Nim Sip Cliff Swig Beef (this one is real) Swag S'mores?

I like C.
