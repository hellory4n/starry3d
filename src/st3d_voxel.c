#include <stdio.h>
#include "st3d.h"
#include "st3d_voxel.h"

static TrArena st3d_arena;
static TrSlice_Color st3d_palette;

void st3di_vox_init(void)
{
	st3d_arena = tr_arena_new(TR_KB(128));
	tr_liblog("initialized voxel engine");
}

void st3di_vox_free(void)
{
	tr_arena_free(&st3d_arena);
	tr_liblog("freed voxel engine");
}

bool st3d_stvox_save(St3dVoxModel model, const char* path)
{
	FILE* file = fopen(path, "wb");
	if (file == NULL) {
		tr_warn("couldn't save stvox to %s", path);
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
	tr_liblog("saved stvox model to %s", path);
	return true;
}

bool st3d_stvox_load(TrArena* arena, const char* path, St3dVoxModel* out)
{
	// TODO probably gonna segfault
	TrString fullpath = tr_slice_new(arena, ST3D_PATH_SIZE, sizeof(char));
	if (strncmp(path, "app:", 4) == 0 || strncmp(path, "usr:", 4) == 0) {
		st3d_path(path, &fullpath);
	}
	else {
		strncpy(fullpath.buffer, path, fullpath.length - 1);
	}

	// actually load
	FILE* file = fopen(fullpath.buffer, "rb");
	if (file == NULL) {
		tr_warn("couldn't load stvox from %s", path);
		return false;
	}

	St3dStarryvoxHeader headerihardlyknower;
	fread(&headerihardlyknower, sizeof(St3dStarryvoxHeader), 1, file);

	// check magic number
	if (headerihardlyknower.magic[0] != 's' || headerihardlyknower.magic[1] != 't' ||
	headerihardlyknower.magic[2] != 'a' || headerihardlyknower.magic[3] != 'r' ||
	headerihardlyknower.magic[4] != 'v' || headerihardlyknower.magic[5] != 'o' ||
	headerihardlyknower.magic[6] != 'x' || headerihardlyknower.magic[7] != '!') {
		tr_warn("stvox file at %s is either corrupted or not a starryvox file", path);
		fclose(file);
		return false;
	}

	// check version
	if (headerihardlyknower.version != 10) {
		tr_warn("stvox file at %s has an unsupported stvox version", path);
		fclose(file);
		return false;
	}

	// like load the shitfuck
	out->dimensions.x = headerihardlyknower.dimensions.x;
	out->dimensions.y = headerihardlyknower.dimensions.y;
	out->dimensions.z = headerihardlyknower.dimensions.z;
	out->dimensions.baseline = headerihardlyknower.dimensions.baseline;
	out->voxels = tr_slice_new(arena, headerihardlyknower.data_len, sizeof(St3dPackedVoxel));
	fread(out->voxels.buffer, sizeof(St3dPackedVoxel), headerihardlyknower.data_len, file);

	fclose(file);
	tr_liblog("loaded stvox model from %s", path);
	return true;
}

bool st3d_stpal_save(St3dPalette palette, const char* path)
{
	FILE* file = fopen(path, "wb");
	if (file == NULL) {
		tr_warn("couldn't save stpal to %s", path);
		return false;
	}

	// header
	St3dStarrypalHeader header = {
		.magic = {'s', 't', 'a', 'r', 'p', 'a', 'l', '!'},
		.version = 10,
		.data_len = palette.length,
	};

	fwrite(&header, sizeof(St3dStarrypalHeader), 1, file);

	// data
	fwrite(palette.buffer, sizeof(TrColor), palette.length, file);

	fclose(file);
	tr_liblog("saved stpal palette to %s", path);
	return true;
}

bool st3d_set_palette(const char* path)
{
	// TODO probably gonna segfault
	TrString fullpath = tr_slice_new(&st3d_arena, ST3D_PATH_SIZE, sizeof(char));
	if (strncmp(path, "app:", 4) == 0 || strncmp(path, "usr:", 4) == 0) {
		st3d_path(path, &fullpath);
	}
	else {
		strncpy(fullpath.buffer, path, fullpath.length - 1);
	}

	// actually load
	FILE* file = fopen(fullpath.buffer, "rb");
	if (file == NULL) {
		tr_warn("couldn't load stpal from %s", path);
		return false;
	}

	St3dStarrypalHeader headerihardlyknower;
	fread(&headerihardlyknower, sizeof(St3dStarrypalHeader), 1, file);

	// check magic number
	if (headerihardlyknower.magic[0] != 's' || headerihardlyknower.magic[1] != 't' ||
	headerihardlyknower.magic[2] != 'a' || headerihardlyknower.magic[3] != 'r' ||
	headerihardlyknower.magic[4] != 'p' || headerihardlyknower.magic[5] != 'a' ||
	headerihardlyknower.magic[6] != 'l' || headerihardlyknower.magic[7] != '!') {
		tr_warn("stpal file at %s is either corrupted or not a starrypal file", path);
		fclose(file);
		return false;
	}

	// check version
	if (headerihardlyknower.version != 10) {
		tr_warn("stpal file at %s has an unsupported stpal version", path);
		fclose(file);
		return false;
	}

	// like load the shitfuck
	st3d_palette = tr_slice_new(&st3d_arena, headerihardlyknower.data_len, sizeof(TrColor));
	fread(st3d_palette.buffer, sizeof(TrColor), headerihardlyknower.data_len, file);

	fclose(file);
	tr_liblog("loaded stpal palette from %s", path);
	return true;
}

TrColor st3d_get_color(uint8_t i)
{
	return *TR_AT(st3d_palette, TrColor, i);
}
