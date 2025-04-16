#ifndef _ST3D_VOXEL_H
#define _ST3D_VOXEL_H
#include "st3d_render.h"

#ifdef __cplusplus
extern "C" {
#endif

// Your voxel models are expected to have the same size :)
#ifndef ST3D_VOXEL_SIZE
	#define ST3D_VOXEL_SIZE 16
#endif

// They're all uint8s to save space
typedef struct {
	uint8_t x;
	uint8_t y;
	uint8_t z;
	// Index from the palette
	uint8_t color;
} St3dVoxel;

typedef struct {
	TrSlice voxels;
} St3dVoxModel;

// .vox files have palettes :)
void st3d_palette_set(TrSlice_Color colors);

// Gets a color from the palette
TrColor st3d_palette_get(uint8_t idx);

// Loads a .vox file
St3dVoxModel st3d_voxel_new(const char* path);

#ifdef __cplusplus
}
#endif

#endif
