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

    // padding, reserved for future versions
    // the size of this struct should always be 64 bytes
    uint8_t padding[52];
} St3dStarrypalHeader;

// Saves a Starryvox model into a file. This doesn't support the `app:` or `usr:` prefixes. Returns true
// if it succeeded.
bool st3d_stvox_save(St3dVoxModel model, const char* path);

#ifdef __cplusplus
}
#endif

#endif
