# Starryvox/Starrypal formats

Starryvox is the most biggest most massive voxel format of all time. Starryvox stores voxel data while
Starrypal stores color palettes. They're in the same file because they're very similar.

Starryvox should have the extension `.stvox` while Starrypal should have the extension `.stpal`.

## Header

The header, as the name implies, is at the start of the file. This is the Starryvox header:

```c
struct StarryvoxHeader {
    // should be "starvox!", no null terminator
    uint8_t magic[8];
    // should be 10 (for v0.1.0) as that's the only version
    uint32_t version;

    struct {
        // coordinates follow the same convention as opengl
        // but (0, 0, 0) is the bottom left instead of the center
        uint8_t x;
        uint8_t y;
        uint8_t z;
        // baseline size for models
        // for example you could have all of your models be 16x16x16
        // then you can refer to 3 blocks as just 3 instead of 48
        uint8_t baseline;
    } dimensions;

    // padding, reserved for future versions
    // the size of this struct should always be 64 bytes
    uint8_t padding[48];
}
```

Starrypal has a similar header but without the dimensions:

```c
struct StarrypalHeader {
    // should be "starpal!", no null terminator
    uint8_t magic[8];
    // should be 10 (for v0.1.0) as that's the only version
    uint32_t version;

    // padding, reserved for future versions
    // the size of this struct should always be 64 bytes
    uint8_t padding[52];
}
```

## Data

The data section comes immediately after the header and is in chunks of 4 bytes.

The difference between Starryvox and Starrypal is in what's stored in those 4 bytes:

```c
struct StarryvoxChunk {
    // coordinates follow the same convention as opengl
    // but (0, 0, 0) is the bottom left instead of the center
    uint8_t x;
    uint8_t y;
    uint8_t z;

    // index in whatever the current palette is
    // starts at 0
    uint8_t color;
}

struct StarrypalChunk {
    uint8_t r; // red
    uint8_t g; // green
    uint8_t b; // blue
    uint8_t a; // alpha (transparency)
}
```

## Palette indexes

While being able to change palettes is what we in the community refer to as "cool", one issue is that
palettes could use completely different indexes. So for example on one palette 57 is blue, and on the other
one it's red. Quite the pickle.

To solve that, here's a list of colors indexes that should look somewhat similar across palettes,
based on [X11 color names](https://en.wikipedia.org/wiki/X11_color_names#Color_name_chart)
