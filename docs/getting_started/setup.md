# Getting started

> [!NOTE]
> This is the guide for using starry in your own projects. For building the library itself as well as other projects, see [the building guide](../developing/building.md)

## Requirements

- git
- a C++20 compatible compiler
- linux only: X11 and Wayland dev packages
    - ubuntu/debian: `sudo apt install libwayland-dev libxkbcommon-dev xorg-dev`
    - fedora: `sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel`

## But how does one starry?

### 1. Acquire starry

The first step is to download starry. We recommend doing this by using Git submodules: (and that's what the rest of this guide is based on)

```sh
# change "thirdparty/starry3d" to wherever you want it to be in
$ git submodule add https://github.com/hellory4n/starry3d thirdparty/starry3d
# starry3d has its own submodules
$ git submodule update --init --recursive
```

### 2. Acquire GLFW

[GLFW](https://www.glfw.org) is quite an important part of starry innit mate. You can either [download a precompiled version](github.com/glfw/glfw/releases/tag/3.4) and link against that, or, [compile it yourself](https://www.glfw.org/docs/latest/compile_guide.html).

### 3. Compiling starry

Add these directories to your includes:
- `<starry3d>/`
- `<starry3d>/thirdparty/libtrippin/`
- `<starry3d>/thirdparty/glfw/include/`
- if you're using ImGui:
    - `<starry3d>/thirdparty/imgui/`
    - `<starry3d>/thirdparty/imgui/backends/`

Add these source files:
- `<starry3d>/starry/app.cpp`
- `<starry3d>/starry/gpu.cpp`
- `<starry3d>/starry/internal.cpp`
- `<starry3d>/starry/render.cpp`
- `<starry3d>/starry/world.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/collection.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/common.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/error.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/iofs.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/log.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/math.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/memory.cpp`
- `<starry3d>/thirdparty/libtrippin/trippin/string.cpp`
- If you're using ImGui:
    - `<starry3d>/starry/imgui.cpp`
    - `<starry3d>/thirdparty/imgui/imgui.cpp`
    - `<starry3d>/thirdparty/imgui/imgui_demo.cpp`
    - `<starry3d>/thirdparty/imgui/imgui_draw.cpp`
    - `<starry3d>/thirdparty/imgui/imgui_tables.cpp`
    - `<starry3d>/thirdparty/imgui/imgui_widgets.cpp`
    - `<starry3d>/thirdparty/imgui/backends/imgui_impl_opengl3.cpp`
    - `<starry3d>/thirdparty/imgui/backends/imgui_impl_glfw.cpp`

Using ImGui also requires defining `ST_IMGUI` *for the entire project*

You'll also have to link with some system libraries:

- Windows (MinGW): `-lopengl32 -lgdi32 -lwinmm -lcomdlg32 -lole32`
- Linux: `-lX11 -lXrandr -lGL -lXinerama -lm -lpthread -ldl -lrt`

## 4. Example code

Put this in your `main.cpp` to check if it worked:

```cpp
#include <starry/app.h>

// you'd usually put this on its own file
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

int main()
{
        st::ApplicationSettings settings = {
                .name = "handsome_game",
                .app_dir = "assets",
                .log_files = {"log.txt"},
                .window_size = {800, 600},
        }
        Game game = {};
        st::run(game, settings);
        return 0;
}
```
