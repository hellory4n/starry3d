# Development setup

> [!NOTE]
> This is intended for developing the engine. Look elsewhere (todo) to create a new project.

## Prerequisites

You need these installed:
- Git
- A C compiler (GCC, Clang, MSVC)
- [Odin](https://odin-lang.org) v2026.05
- [Just command runner](https://github.com/casey/just)
- On Windows: Windows SDK
- On Linux:
        - Debian, Ubuntu, etc: `sudo apt install libglfw3-dev libassimp-dev`
        - Fedora: `sudo dnf install glfw-devel assimp-devel`
        - Arch: `sudo pacman -S glfw assimp`

## Building

While you can run `odin build`/`odin run` like you can with any other Odin project, it's recommended that you use the Just wrappers:
- `just test` to run tests
- `just --list` to list example projects, you can run then with e.g. `just run-hello`
