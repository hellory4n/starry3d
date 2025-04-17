# starry3d v0.1.0

3D library for voxel graphics and other fancy crapfrick.

## Features

For the points with asterisks look at the limitations section

- Pure C99 and OpenGL 3.3
- Cross platform\*
- Probably runs on anything ever
- No external dependencies\*
- Optimized for voxel graphics\*
- UI through [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear), you don't have to do anything, it's
  already there
- Built on [libtrippin](https://github.com/hellory4n/libtrippin) the biggest most massive library of all time
- Licensed under 0BSD so you can do like anything ever with it

## Limitations

- 2D support is nearly non-existent
- Currently only Windows and Linux supported
	- macOS support is possible but I don't have a Mac
	- WebGL support is also possible but I don't really care about that, so I didn't implement that
	- Only tested on Clang and GCC, I don't know if MSVC works
- You do need to install the usual GLFW/OpenGL dependencies on Linux (see the usage section)
- I haven't implemented those fancy optimizations yet

## Usage

Make sure you have gcc/clang (clang is recommended but gcc works too) and make.

It's possible to compile from Windows through MinGW too.

Then you need to install some dependencies:

```sh
# Debian/Ubuntu/Derivatives:
sudo apt install libwayland-dev libxkbcommon-dev xorg-dev

# Fedora
sudo dnf install wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel
```

Linux requires both X11 and Wayland libraries because it chooses either of them at runtime.

Now you need to include Starry3D into your project. It's recommended to do so through Git submodules:

```sh
# change "vendor/starry3d" to wherever you want it to be in
git submodule add https://github.com/hellory4n/starry3d vendor/starry3d
```

`sandbox/` is the example project setup, that's why there's no build script here, it's actually there

You can just steal the makefile from there, but make sure to edit `PROGRAM` to be the name of your project,
and `STARRY3D` to be where you put starry3d.

Now put this in `src/main.c` and run `make run` to check if it worked:

```c
#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>

int main(void)
{
	st3d_init("program", "assets", 800, 600);
	// you need a font for nuklear to work
	st3d_ui_new("assets/default-font.ttf", 16);

	tr_log("initialize your program here");

	while (!st3d_is_closing()) {
		st3d_begin_drawing(TR_WHITE);

		tr_log("main loop goes here");

		st3d_ui_begin();
			tr_log("nuklear calls go here");
		st3d_ui_end();

		st3d_end_drawing();
		st3d_poll_events();
	}

	tr_log("deinitialize your program here");

	st3d_ui_free();
	st3d_free();
}
```

The [makefile](./sandbox/Makefile) has a couple options:

- `make` (no arguments)
	- Compiles the project in release mode (`RELEASE` defined, optimizations enabled)
- `make clean`
	- Removes all executables and stuff.
- `make run`
	- Similar to just `make`, but it also runs the project. This can be used with other options too, that's
	  how Make works
- `make build=debug`
	- Compiles the project in debug mode (debug symbols enabled, `DEBUG` enabled, optimizations disabled)
- `make crosscomp=windows`
	- Cross compiles from Linux to Windows. Requires MinGW GCC as well as Wine for `make run`. Make sure you
	  installed the 64-bit MinGW.

Note that to add more files to the project, you need to add it to `SRCS`

## FAQ

### Have you tried [game engine] you fucking moron

No fuck off.

### Why?

Turns out raylib is giving me esoteric memory issues and it doesn't help that it intentionally avoids
checks for esoteric memory issues. I would rather make my own graphics framework than debug that. Quite the
pickle.

Also voxel graphics require a lot more optimization than usual so it's nice to be able to do that directly in
the renderer instead of trying to hack some esoteric library.

Also why not.

### Why C? Can't you be a normal human being and use C++ C# Rust Go Zig Odin Nim Sip Cliff Swig Beef (this one is real) Swag S'mores?

I like C.

## Todo

- [x] the bloody renderer
- [ ] load .vox files
	- [ ] load data
	- [ ] actually draw it (by having 1 square and then applying different transforms to it)
- [ ] lighting
- [ ] windowing (just a wrapper around glfw)
	- [ ] fancy input crap
	- [ ] remember to include delta time/fps
- [ ] [fancy audio](https://www.youtube.com/watch?v=u6EuAUjq92k)
- [ ] more documentation probably
- [ ] fancy optimization bcuz why not
	- [ ] don't draw a square if you can't even see it
	- [ ] turn it into one draw command because Fast
	- [ ] greedy meshing
	- [ ] level of detail
