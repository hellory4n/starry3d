# BMV File Format v0.1

> [!NOTE]
> i didn't finish this lmao

Big Massive Voxels (BMV) is a voxel file format intended for both voxel assets and art, and, data used by fully interactive voxel games.

## Why though / xkcd 927

Looking at the existing voxel formats:

- MagicaVoxel's `.vox` lacks compression, more than 255 colors, is really just a big dumb list of position + palette index with optional extensions, and you definitely can't use it for user data
- Qubicle's format doesn't seem to have any documentation ever (and i'm not gonna buy it just to discover how it works)
- PNG stacks (and formats based on them) are torturous and don't allow custom metadata
- couldn't find if there's any other formats that people among us actually use

Quite the pickle.

## Conventions

- "count" refers to the number of items while "length" refers to the number of bytes
- structs are represented with a format similar to Zig's packed structs, with no implicit padding and `bool` being 1 bit.
- `byte` is used instead of `u8` for cases where it isn't just a small integer.
- `[N]string` is also used, N is in bytes, encoding is UTF-8, NOT null terminated
- `@nonzero` specifies that the file is malformed if a certain value is 0
- files are always little-endian
- coordinates are OpenGL-style, that means +X is right, +Y is up, and -Z is forward. coordinates are signed, with (0, 0, 0) being the center.

## Header

All BMV files immediately start with the header:

```zig
const Header = struct {
    magic: [8]string = "bigvox:)",
    // different tools and files with different minor versions should generally be compatible with
    // each other, and the implementation should follow that
    // different major versions means breaking changes
    major_version: u8 = 0,
    minor_version: u8 = 1,

    compression_format: u8,
    color_format: u8,
    size_x: u32 @nonzero,
    size_y: u32 @nonzero,
    size_z: u32 @nonzero,

    _reserved1: u56,
    // visual separation between header and content, visible when opening in a hex editor
    _reserved2: u8 = '|',
};
```

The color formats supported are:
- 32 bit RGBA = 0
- 16 bit palette indexes to 32 bit RGBA colors = 1
- 8 bit palette indexes to 32 bit RGBA colors = 1

An alpha of 0 always means there is no voxel at that place.

The compression formats supported are:
- no compression = 0
- [Zstandard](https://facebook.github.io/zstd) level 3 compression = 1

## Voxel property table

Custom properties can be added to individual voxels in what's called "voxel properties" (or "props" for short). To save space, the type and default value for each property is stored here, so the voxels themselves mostly only have to store the values themselves (more on that later). You can also specify a default value for if the property isn't present.

```zig
const VoxelPropertyTable = struct {
    prop_count: u8 @nonzero,
    voxel_prop_descs: []VoxelPropertyDesc,
};

const VoxelPropertyDesc = struct {
    magic: [4]string,
    type: u8,
    default_value: []byte,
};
```

The types supported are:
- bool = 0
- int8 = 1, int16 = 2, int32 = 3, int64 = 4
- uint8 = 5, uint16 = 6, uint32 = 7, uint64 = 8
- float32 = 9, float64 = 10
- array = 11

Array values are stored as type (u8, same values), followed by the item count (uint32), and then the data. Arrays of arrays are not supported. An UTF-8 string can be represented by an array of uint8s.

The length of the default value of course depends on the type.

## Tags

Similar to formats such as `.tiff`, RIFF, and `.vox`, BMV mostly consists of tagged chunks, or just tags. These are described as follows:

```zig
const Tag = struct {
    magic: [4]string,
    length: u32 @nonzero,
    data: []byte,
};
```

Unknown tags should be skipped, instead of being treated as invalid. Multiple tags of the same type are also allowed.

## `cpal` tag

The color palette tag describes the color palette used by the file. It should only be used if the color format is a palette format.

```zig
const PaletteTag = struct {
    // actual format depends on the color format
    colors: []byte,
};
```

If there is no color palette tag in the entire file, and the color format is a palette format, the file is malformed.

## `voxl` tag

The voxel tag describes real voxel data. This is done using a [brickmap](https://studenttheses.uu.nl/bitstream/handle/20.500.12932/20460/final.pdf), which provides a good balance between space efficiency and writing efficiency. (sparse voxel octrees are too slow to write for our use case)

TODO finish this shit

probably gonna use structures of arrays so that props work

```zig
const VoxelTag = struct {
    // TODO
};
```

## Full file structure

Putting everything together we get:

```zig
const BmvFile = struct {
    header: Header,
    voxel_prop_table: VoxelPropertyTable,
    tags: []Tag,
};
```
