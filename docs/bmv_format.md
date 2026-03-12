# Big Massive Voxels v0.5

Big Massive Voxels (BMV) is the biggest most massive voxel format of all time.

This spec is licensed under the [CC0 license](https://creativecommons.org/public-domain/cc0/).

## Why?

BMV has many advantages over the current "standard", MagicaVoxel's .vox:
- the incredible jump to 32-bits, that means full 32-bit color and models bigger than 256x256x256
- compression through LZ4
- able to encode voxel data other than color (material, game-specific attributes, etc)
- highly extensible
- fully open-source

## Conventions

- "count" refers to the number of items while "length" refers to the number of bytes
- integers are two's complement little endian
- all strings are UTF-8 without a null terminator
- `#nonzero` specifies that the file is malformed is a field is 0
- coordinates are right-handed, that means +X is right, +Y is up, and -Z is forward
- coordinates are signed, with (0, 0, 0) being the center
- `bool` is 1 bit, `bool8` is 1 bit + 7 bits of padding (true = 1, false = 0)

## Header

All BMV files start with the header:

```cpp
struct Header {
	uint8 magic[8] = "\0bmvoxel";
	// minor_version should be increased every version, unless there's breaking changes
	// it should still be valid to parse a file with a higher minor_version than what you support
	// v0.x versions can have any breaking changes though
	// (v1.x will be compatible with the last v0.x version)
	uint8 major_version = 0;
	uint8 minor_version = 5;
};
```

## Metadata section

Immediately after the header is the metadata section. The metadata section includes a list of meta-attributes:

```cpp
struct Meta_Attribute {
	// unique ID/key for the attribute
	uint8 tag[4];
	uint32 length;
	uint8 payload[length];
};
```

Only one meta-attribute of each tag is allowed. Meta-attributes may be in any order.

The full structure for the metadata section is:

```cpp
struct Metadata_Section {
	uint8 magic[8] = "metadata";
	uint32 attr_count;
	Meta_Attribute attrs[attr_count];
}
```

### Standard meta-attributes

A few meta-attributes are useful enough to be part of the standard:

```cpp
// required
struct Size_Meta_Attribute {
	uint8 tag[4] = "size";
	uint32 length = 12;
	struct {
		// all must be less than 2^31
		uint32 size_x #nonzero;
		uint32 size_y #nonzero;
		uint32 size_z #nonzero;
	} payload;
};

// optional
struct Compression_Meta_Attribute {
	uint8 tag[4] = "cmps";
	uint32 length = 1;
	struct {
		enum : uint8 {
			LZ4 = 0,
			NONE = 255,
		} algorithm;
	} payload;
};
// NOTE: if the cmps meta-attribute is missing, the file is assumed to have no compression
// however LZ4 should be the default when writing to a file, hence why it gets the 0 value
```

## Solid mask section

Immediately after the metadata section there's the solid mask section, which indicates which voxels in the model are solid:

```cpp
struct Solid_Mask_Section {
	uint8 magic[8] = "solidmsk";
	// may be compressed if the `cmps` meta-attribute is present
	bool8 bits[...];
}
```

`bits` is a compressable row-major 3D array of bools with padding, with the size specified by the `size` meta-attribute. This means that for the position `[x, y, z]`, its index would be `x * (size.y * size.z) + y * size.z + z`.

## Attribute data section

Immediately after the metadata section there's one or more data sections, with each section being for a specific voxel tag:

```cpp
struct Data_Section {
	uint8 magic[8] = "attrdata";
	uint8 attr_tag[4];
	// may be compressed if the `cmps` meta-attribute is present
	uint32 data[...];
}
```

`data` is a compressable row-major 3D array, with the size specified by the `size` meta-attribute. This means that for the position `[x, y, z]`, its index would be `x * (size.y * size.z) + y * size.z + z`.

The values in the indexes corresponding to non-solid voxels is undefined. (preferably 0)

Only one section of each voxel attribute tag is allowed. Attributes may be in any order.

### Standard attributes

A few attributes are useful enough to be part of the standard:

```cpp
// tag: "rgba"
struct Rgba_Attribute {
	// equivalent to 0xRRGGBBAA
	// sRGB colorspace
	// all channels from 0 to 255
	uint8 a, b, g, r;
}
```

## Changelog

**v0.5**
- made LZ4 compression the default, as the format sucks ass without it. also why the fuck was that 16-bits

**v0.4**
- changes :), first version to be implemented

**v0.3**
- changes :)

**v0.2**
- first "finished" draft

**v0.1**
- first draft
