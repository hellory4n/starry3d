# Big Massive Voxels v1.1

Big Massive Voxels (BMV) is the biggest most massive voxel format of all time.

This spec is licensed under the [CC0 license](https://creativecommons.org/public-domain/cc0/).

## Conventions

- "count" refers to the number of items while "length" refers to the number of bytes
- integers are two's complement little endian
- all strings are UTF-8 without a null terminator
- `#nonzero` specifies that the file is malformed is a field is 0
- coordinates are right-handed, that means +X is right, +Y is up, and -Z is forward
- coordinates are signed, with (0, 0, 0) being the center
- `bool` is 1 bit, `bool8` is 1 bit + 7 bits of padding

## Header

All BMV files start with the header:

```cpp
struct Header {
	uint8 magic[8] = "\0bmvoxel";
	// minor_version should be increased every version, unless there's breaking changes
	// it should still be valid to parse a file with a higher minor_version than what you support
	uint8 major_version = 1;
	uint8 minor_version = 0;
};
```

## Metadata section

Immediately after the header is the metadata section. The metadata section includes a list of metaprops:

```cpp
struct Metaprop {
	// unique ID/key for the prop
	// 0-128 are reserved for the standard
	uint16 tag;
	uint32 length;
	uint8 payload[length];
};
```

Only one metaprop of each tag is allowed. Metaprops may be in any order.

The full structure for the metadata section is:

```cpp
struct Metadata_Section {
	uint8 magic[8] = "metadata";
	uint16 metaprop_count;
	Metaprop metaprops[metaprop_count];
}
```

### Standard metaprops

A few metaprops are useful enough to be part of the standard:

```cpp
// required
struct Size_Metaprop {
	uint16 tag = 0;
	uint32 length = 12;
	struct {
		// all must be less than 2^31
		uint32 size_x #nonzero;
		uint32 size_y #nonzero;
		uint32 size_z #nonzero;
	} payload;
};

// optional
struct Compression_Metaprop {
	uint16 tag = 1;
	uint32 length = 2;
	struct {
		enum : uint16 {
			LZ4 = 1,
		} algorithm;
	} payload;
};

// optional
struct Copyright_Metaprop {
	uint16 tag = 2;
	uint32 length; // dynamic
	struct {
		uint32 year;
		uint32 name_length;
		uint8 name_str[name_length];
		uint32 author_length;
		uint8 author_str[author_length];
		uint32 license_length;
		uint8 license_str[license_length];
		uint32 contact_length;
		uint8 contact_str[contact_length];
	} payload;
};
```

## Data section

Immediately after the metadata section there's the data section:

```cpp
struct Data_Section {
	uint8 tag[8] = "propdata";
	uint32 voxel_count;
	// may be compressed if Compression_Metaprop is available
	Voxel voxels[voxel_count];
};

struct Voxel {
	int32 x;
	int32 y;
	int32 z;
	uint16 prop_count;
	Prop props[prop_count];
};

struct Prop {
	// unique ID/key for the prop
	// 0-128 are reserved for the standard
	uint16 tag;
	// unlike metaprops, all props must fit in 32-bits
	uint32 payload;
};
```

Only one prop of each tag is allowed. Props may be in any order.

### Standard props

A few props are useful enough to be part of the standard:

```cpp
struct Color_Prop {
	uint16 tag = 0;
	// equivalent to 0xRRGGBBAA
	// sRGB colorspace
	// all channels from 0 to 255
	uint8 a, b, g, r;
}
```

## Changelog

**v1.1**
- changed license from zlib to CC0, clarified some things

**v1.0**
- first finished draft

**v0.1**
- first draft
