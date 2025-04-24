#ifndef _ST3D_VOXEL_H
#define _ST3D_VOXEL_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// Used for coordinates
#ifndef ST3D_VOXEL_SIZE
	#define ST3D_VOXEL_SIZE 16
#endif

// Highly optimized highly handsome single voxel.
typedef struct {
	uint8_t x;
	uint8_t y;
	uint8_t z;
	uint8_t color;
} St3dPackedVoxel;

typedef struct {
	struct {
		uint8_t x;
		uint8_t y;
		uint8_t z;
		// Baseline size for models. For example you could have all of your models be 16x16x16,
		// then you can refer to 3 blocks as just 3 instead of 48
		uint8_t baseline;
	} dimensions;

	// Type is St3dPackedVoxel
	TrSlice voxels;
} St3dVoxModel;

// Used for saving/loading Starryvox files
typedef struct StarryvoxHeader {
	// should be "starvox!", no null terminator
	uint8_t magic[8];
	// should be 10 (for v0.1.0) as that's the only version
	uint32_t version;

	// length of the data section, in amount of items, not bytes
	uint32_t data_len;

	struct {
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
	uint8_t padding[44];
} St3dStarryvoxHeader;

// Used for saving/loading Starrypal files
typedef struct {
	// should be "starpal!", no null terminator
	uint8_t magic[8];
	// should be 10 (for v0.1.0) as that's the only version
	uint32_t version;
    // length of the data section, in amount of items, not bytes
	uint32_t data_len;

	// padding, reserved for future versions
	// the size of this struct should always be 64 bytes
	uint8_t padding[48];
} St3dStarrypalHeader;

// Palette.
typedef TrSlice_Color St3dPalette;

// Color names that should probably work on any palette or smth.
typedef enum {
	ST3D_COLOR_TRANSPARENT,
	ST3D_COLOR_BLACK_5,
	ST3D_COLOR_BLACK_4,
	ST3D_COLOR_BLACK_3,
	ST3D_COLOR_BLACK_2,
	ST3D_COLOR_BLACK_1,
	ST3D_COLOR_WHITE_5,
	ST3D_COLOR_WHITE_4,
	ST3D_COLOR_WHITE_3,
	ST3D_COLOR_WHITE_2,
	ST3D_COLOR_WHITE_1,
	ST3D_COLOR_STRAWBERRY_5,
	ST3D_COLOR_STRAWBERRY_4,
	ST3D_COLOR_STRAWBERRY_3,
	ST3D_COLOR_STRAWBERRY_2,
	ST3D_COLOR_STRAWBERRY_1,
	ST3D_COLOR_ORANGE_5,
	ST3D_COLOR_ORANGE_4,
	ST3D_COLOR_ORANGE_3,
	ST3D_COLOR_ORANGE_2,
	ST3D_COLOR_ORANGE_1,
	ST3D_COLOR_BANANA_5,
	ST3D_COLOR_BANANA_4,
	ST3D_COLOR_BANANA_3,
	ST3D_COLOR_BANANA_2,
	ST3D_COLOR_BANANA_1,
	ST3D_COLOR_LIME_5,
	ST3D_COLOR_LIME_4,
	ST3D_COLOR_LIME_3,
	ST3D_COLOR_LIME_2,
	ST3D_COLOR_LIME_1,
	ST3D_COLOR_MINT_5,
	ST3D_COLOR_MINT_4,
	ST3D_COLOR_MINT_3,
	ST3D_COLOR_MINT_2,
	ST3D_COLOR_MINT_1,
	ST3D_COLOR_BLUEBERRY_5,
	ST3D_COLOR_BLUEBERRY_4,
	ST3D_COLOR_BLUEBERRY_3,
	ST3D_COLOR_BLUEBERRY_2,
	ST3D_COLOR_BLUEBERRY_1,
	ST3D_COLOR_GRAPE_5,
	ST3D_COLOR_GRAPE_4,
	ST3D_COLOR_GRAPE_3,
	ST3D_COLOR_GRAPE_2,
	ST3D_COLOR_GRAPE_1,
	ST3D_COLOR_BUBBLEGUM_5,
	ST3D_COLOR_BUBBLEGUM_4,
	ST3D_COLOR_BUBBLEGUM_3,
	ST3D_COLOR_BUBBLEGUM_2,
	ST3D_COLOR_BUBBLEGUM_1,
	ST3D_COLOR_LATTE_5,
	ST3D_COLOR_LATTE_4,
	ST3D_COLOR_LATTE_3,
	ST3D_COLOR_LATTE_2,
	ST3D_COLOR_LATTE_1,
	ST3D_COLOR_COCOA_5,
	ST3D_COLOR_COCOA_4,
	ST3D_COLOR_COCOA_3,
	ST3D_COLOR_COCOA_2,
	ST3D_COLOR_COCOA_1,
} St3dColors;

void st3di_vox_init(void);
void st3di_vox_free(void);

// Saves a Starryvox model into a file. This doesn't support the `app:` or `usr:` prefixes. Returns true
// if it succeeded.
bool st3d_stvox_save(St3dVoxModel model, const char* path);

// Loads a Starryvox model from a file, and writes the result into `out`. Supports the `app:` or `usr:`
// prefixes. Returns true if it succeeded.
bool st3d_stvox_load(TrArena* arena, const char* path, St3dVoxModel* out);

// Saves a Starrypal palette into a file. This doesn't support the `app:` or `usr:` prefixes. Returns true
// if it succeeded.
bool st3d_stpal_save(St3dPalette palette, const char* path);

// Loads a Starrypal palette from a file, and sets it as the palette that will be used everywhere ever.
// Supports the `app:` or `usr:` prefixes. Returns true if it succeeded.
bool st3d_set_palette(const char* path);

// Gets a color from the current palette.
TrColor st3d_get_color(uint8_t i);

#ifdef __cplusplus
}
#endif

#endif
