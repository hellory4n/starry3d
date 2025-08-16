# starry3d v0.5.0

> [!WARNING]
> This is in active development. It may be janky, or worse, busted.

3D renderer for voxel graphics and other fancy crapfrick.

## Features

- C++17
- Cross platform ish. (windows and linux)
- Probably runs on anything ever
- Optimized for voxel graphics
- UI through [ImGui](https://github.com/ocornut/imgui), you don't have to do anything, it's
  already there
- Built on [libtrippin](https://github.com/hellory4n/libtrippin) the biggest most massive library of all time

## Limitations

- 2D support is nearly non-existent
- Currently only Windows and Linux supported
    - It does use [sokol](https://github.com/floooh/sokol) which is cross-platform, but I only tested Windows and Linux

## Building

This is intended for if you want to contribute or test the library (no one will)

### Windows

I have no idea just install WSL lmao

### Linux

You need these installed:
- git
- clang
- lua
- ninja
- X11 and OpenGL dev packages (it depends on your distro)
    - debian/ubuntu/derivatives: `sudo apt install libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev libxkbcommon-dev`
    - fedora/derivatives: `sudo dnf install mesa-libGL-devel libX11-devel libXrandr-devel libXi-devel libXcursor-devel libXinerama-devel`
    - arch/derivatives: `sudo pacman -S mesa libx11 libxrandr libxi libxcursor libxinerama`
- mingw-w64-gcc and mingw-w64-g++ (optional)

Now run `./configure.lua`

Options:
- Compilation mode (`debug`/`release`): release mode enables optimizations, while debug mode disables optimizations, enables debug symbols, and defines `DEBUG`/`_DEBUG`.
- Target platform (`windows`/`linux`): If compiling for windows, uses `mingw-w64-gcc` for cross-compiling.
- Use a sanitizer: You usually don't need this option. This maps directly to a `-fsanitize=` flag, so e.g. `address` becomes `-fsanitize=address` for ASan.
- Generate `compile_commands.json` (`y`/`n`): Generates a `compile_commands.json` file for IDEs (if using clangd) to use.

Now run `ninja` to compile. You'll now have an executable in `build/bin/sandbox`

You can also use `./debugrun.sh` to run it with gdb.

## Usage

You need these installed:
- git
- a C/C++ compiler (note MSVC isn't tested often)
- windowing packages:
    - windows: should come with visual studio
    - debian/ubuntu/derivatives: `sudo apt install libx11-dev libxrandr-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev libxcursor-dev libxinerama-dev libxkbcommon-dev`
    - fedora/derivatives: `sudo dnf install mesa-libGL-devel libX11-devel libXrandr-devel libXi-devel libXcursor-devel libXinerama-devel`
    - arch/derivatives: `sudo pacman -S mesa libx11 libxrandr libxi libxcursor libxinerama`

Now you need to include Starry3D into your project. It's recommended to do so through Git submodules:

```sh
# change "thirdparty/starry3d" to wherever you want it to be in
git submodule add https://github.com/hellory4n/starry3d thirdparty/starry3d
# starry3d has its own submodules
git submodule update --init --recursive
```

### Option A: Integrating into an existing project

Make sure you're using C++17 or higher, it won't work in anything older.

Now add these folders to your includes: (relative to where you put starry3d)
- the starry3d directory itself
- `thirdparty/`
- `thirdparty/libtrippin`
- if you're using ImGui:
    - `thirdparty/imgui`

Add these source files: (relative to where you put starry3d)
- `starry/app.cpp`
- `starry/asset.cpp`
- `starry/internal.cpp`
- `starry/render.cpp`
- `starry/world.cpp`
- `thirdparty/libtrippin/trippin/collection.cpp`
- `thirdparty/libtrippin/trippin/common.cpp`
- `thirdparty/libtrippin/trippin/iofs.cpp`
- `thirdparty/libtrippin/trippin/log.cpp`
- `thirdparty/libtrippin/trippin/math.cpp`
- `thirdparty/libtrippin/trippin/memory.cpp`
- `thirdparty/libtrippin/trippin/string.cpp`
- `thirdparty/libtrippin/trippin/error.cpp`
- If you're using ImGui:
    - `starry/optional/imgui.cpp`
    - `thirdparty/imgui/imgui.cpp`
    - `thirdparty/imgui/imgui_demo.cpp`
    - `thirdparty/imgui/imgui_draw.cpp`
    - `thirdparty/imgui/imgui_tables.cpp`
    - `thirdparty/imgui/imgui_widgets.cpp`

You also have to link with some system libraries:
- Windows (mingw-w64-gcc only): `-lkernel32 -luser32 -lshell32 -lgdi32 -ld3d11 -ldxgi -lpthread -lstdc++ -static`
- Linux: `-lX11 -lXi -lXcursor -lGL -ldl -lm -lstdc++`

And if you're using ImGui you have to define `ST_IMGUI` (it has to be in the project/compile flags)

Now put this in your `main.cpp` and run to check if it worked:

```cpp
#include <starry/app.h>

class Game : public st::Application
{
    tr::Result<void> init() override;
    tr::Result<void> update(float64 dt) override;
    tr::Result<void> free() override;
};

tr::Result<void> Game::init()
{
    tr::log("initialized game");
    return {};
}

tr::Result<void> Game::update(float64 dt)
{
    // you can put imgui calls here too
    // just include <starry/optional/imgui.h> first
    return {};
}

tr::Result<void> Game::free()
{
    tr::log("deinitialized game");
    return {};
}

int main(void)
{
    // see st::ApplicationSettings for all these settings
    st::ApplicationSettings settings = {};
    settings.name = "handsome_game";
    settings.app_dir = "assets";
    settings.logfiles = {"log.txt"};
    settings.window_size = {800, 600};

    Game game = {};
    st::run(game, settings);
    return 0;
}
```

### Option B: Using ninja/lua

Starry3D uses ninja and `configure.lua` for its build process, and this script works with your own projects
too

You're gonna need ninja and lua installed. (cross-compiling to windows requires mingw-w64-g++ but that's optional)

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

```cpp
#include <starry/app.h>

class Game : public st::Application
{
    tr::Result<void> init() override;
    tr::Result<void> update(float64 dt) override;
    tr::Result<void> free() override;
};

tr::Result<void> Game::init()
{
    tr::log("initialized game");
    return {};
}

tr::Result<void> Game::update(float64 dt)
{
    // you can put imgui calls here too
    // just include <starry/optional/imgui.h> first
    return {};
}

tr::Result<void> Game::free()
{
    tr::log("deinitialized game");
    return {};
}

int main(void)
{
    // see st::ApplicationSettings for all these settings
    st::ApplicationSettings settings = {};
    settings.name = "handsome_game";
    settings.app_dir = "assets";
    settings.logfiles = {"log.txt"};
    settings.window_size = {800, 600};

    Game game = {};
    st::run(game, settings);
    return 0;
}
```

Now, to compile, first setup the project with `./configure.lua`

Options:
- Compilation mode (`debug`/`release`): release mode enables optimizations, while debug mode disables optimizations, enables debug symbols, and defines `DEBUG`/`_DEBUG`.
- Target platform (`windows`/`linux`): If compiling for windows, uses `mingw-w64-gcc` for cross-compiling.
- Use a sanitizer: It, well, uses a sanitizer. This maps directly to a `-fsanitize=` flag, so e.g. `address` becomes `-fsanitize=address` for ASan.
- Generate `compile_commands.json` (`y`/`n`): Generates a `compile_commands.json` file for IDEs (if using clangd) to use.

Now run `ninja` to compile. You'll now have an executable in `build/bin/`

## FAQ

### Have you tried \[game engine] you fucking moron

No fuck off.

### Why?

Voxel rendering can be quite the pickle, so I think it's easier and better to just do the whole thing
from scratch. Also why not

### Why C++? Can't you be a normal human being and use Rust Go Zig Odin Nim Sip Cliff Swig Beef (this one is real) Swag S'mores?

No fuck off.
