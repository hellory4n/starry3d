# Big Massive Models v0.1

Big Massive Models (BMM) is the biggest most massive 3D model format of all time.

This spec is licensed under the [CC0 license](https://creativecommons.org/public-domain/cc0/).

## Why?

The current formats vex me.

## Conventions

- "count" refers to the number of items while "length" refers to the number of bytes
- integers are two's complement little endian
- all strings are UTF-8 without a null terminator
- `#nonzero` specifies that the file is malformed is a field is 0
- coordinates are right-handed, that means +X is right, +Y is up, and -Z is forward (OpenGL style)
- `bool` is 1 bit, `bool8` is 1 bit + 7 bits of padding (true = 1, false = 0)

## Types

These are used throughout the file:

```cpp
struct Vec3 {
	float32 x, y, z;
};

struct Vec4 {
	float32 x, y, z;
};

struct Rgb {
	// all from 0 to 1
	float32 r, g, b;
};

struct Rgba {
	// all from 0 to 1
	float32 r, g, b, a;
};
```

## Header

All BMM files start with the header:

```cpp
struct Header {
	uint8 magic[8] = "\0bmmodel";
	// minor_version should be increased every version, unless there's breaking changes
	// it should still be valid to parse a file with a higher minor_version than what you support
	// v0.x versions can have any breaking changes though
	// (v1.x will be compatible with the last v0.x version)
	uint8 major_version = 0;
	uint8 minor_version = 1;
	uint8 _reserved[246];
};
```
