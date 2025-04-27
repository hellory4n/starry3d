#ifndef _JK_FAST_VOXEL_RAYCAST_H
#define _JK_FAST_VOXEL_RAYCAST_H
#include <libtrippin.h>

// ported from https://github.com/fenomas/fast-voxel-raycast/blob/master/index.js

// Gets a voxel and returns true if it should block the ray
typedef bool (*jk_vox_should_block_func)(int64_t x, int64_t y, int64_t z);

// Returns whether any voxel was hit
bool jk_raycast(jk_vox_should_block_func get_voxel, TrVec3f start, TrVec3f dir, double raylen,
TrVec3f* out_hit_pos, TrVec3f* out_hit_norm);

#endif
