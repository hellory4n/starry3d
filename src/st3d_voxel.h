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

#ifdef __cplusplus
}
#endif

#endif
