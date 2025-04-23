#include <stdio.h>
#include "st3d_voxel.h"

bool st3d_stvox_save(St3dVoxModel model, const char* path)
{
	FILE* file = fopen(path, "wb");
	if (file == NULL) {
		return false;
	}

	// header
	St3dStarryvoxHeader header = {
		.magic = {'s', 't', 'a', 'r', 'v', 'o', 'x', '!'},
		.version = 10,
		.data_len = model.voxels.length,
		.dimensions = {
			.x = model.dimensions.x,
			.y = model.dimensions.y,
			.z = model.dimensions.z,
			.baseline = model.dimensions.baseline,
		},
	};

	fwrite(&header, sizeof(St3dStarryvoxHeader), 1, file);

	// data
	fwrite(model.voxels.buffer, sizeof(St3dPackedVoxel), model.voxels.length, file);

	fclose(file);
	return true;
}
