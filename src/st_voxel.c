/*
 * Starry3D: C voxel game engine
 * More information at https://github.com/hellory4n/starry3d
 *
 * Copyright (C) 2025 by hellory4n <hellory4n@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this
 * software for any purpose with or without fee is hereby
 * granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <stdio.h>
#include <stb_ds.h>
#include <glad/gl.h>
#include <linmath.h>
#include "st_common.h"
#include "st_voxel_render.h"
#include "st_voxel.h"

typedef struct {
	// Slice of StMesh
	TrSlice meshes;
} StVoxMeshes;

static TrArena st_arena;

// shared with st_voxel_render.c
typedef struct {TrVec3i key; uint8_t value;} StVoxModelMap;
TrSlice_Color st_palette;
struct {StBlockId key; StVoxModelMap* value;}* st_block_types;
struct {TrVec3i key; StBlockId value;}* st_blocks;

void st_vox_init(void)
{
	st_arena = tr_arena_new(TR_MB(1));
	StBlockId defaul = {0, 0};
	hmdefault(st_blocks, defaul);
	hmdefault(st_block_types, NULL);

	st_vox_render_init();

	tr_liblog("initialized voxel engine");
}

void st_vox_free(void)
{
	st_vox_render_free();
	tr_arena_free(&st_arena);
	tr_liblog("freed voxel engine");
}

bool st_vox_save(StVoxModel model, const char* path)
{
	FILE* file = fopen(path, "wb");
	if (file == NULL) {
		tr_warn("couldn't save stvox to %s", path);
		return false;
	}

	// header
	StStarryvoxHeader header = {
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

	fwrite(&header, sizeof(StStarryvoxHeader), 1, file);

	// data
	fwrite(model.voxels.buffer, sizeof(StPackedVoxel), model.voxels.length, file);

	fclose(file);
	tr_liblog("saved stvox model to %s", path);
	return true;
}

bool st_vox_load(TrArena* arena, const char* path, StVoxModel* out)
{
	tr_assert(arena != NULL, "arena != NULL");
	tr_assert(out != NULL, "out != NULL");

	// TODO probably gonna segfault
	TrString fullpath = tr_slice_new(arena, ST_PATH_SIZE, sizeof(char));
	if (strncmp(path, "app:", 4) == 0 || strncmp(path, "usr:", 4) == 0) {
		st_path(path, &fullpath);
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

	StStarryvoxHeader headerihardlyknower;
	fread(&headerihardlyknower, sizeof(StStarryvoxHeader), 1, file);

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
	out->voxels = tr_slice_new(arena, headerihardlyknower.data_len, sizeof(StPackedVoxel));
	fread(out->voxels.buffer, sizeof(StPackedVoxel), headerihardlyknower.data_len, file);

	fclose(file);
	tr_liblog("loaded stvox model from %s", path);
	return true;
}

bool st_pal_save(StPalette palette, const char* path)
{
	FILE* file = fopen(path, "wb");
	if (file == NULL) {
		tr_warn("couldn't save stpal to %s", path);
		return false;
	}

	// header
	StStarrypalHeader header = {
		.magic = {'s', 't', 'a', 'r', 'p', 'a', 'l', '!'},
		.version = 10,
		.data_len = palette.length,
	};

	fwrite(&header, sizeof(StStarrypalHeader), 1, file);

	// data
	fwrite(palette.buffer, sizeof(TrColor), palette.length, file);

	fclose(file);
	tr_liblog("saved stpal palette to %s", path);
	return true;
}

bool st_set_palette(const char* path)
{
	// TODO probably gonna segfault
	TrString fullpath = tr_slice_new(&st_arena, ST_PATH_SIZE, sizeof(char));
	if (strncmp(path, "app:", 4) == 0 || strncmp(path, "usr:", 4) == 0) {
		st_path(path, &fullpath);
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

	StStarrypalHeader headerihardlyknower;
	fread(&headerihardlyknower, sizeof(StStarrypalHeader), 1, file);

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
	st_palette = tr_slice_new(&st_arena, headerihardlyknower.data_len, sizeof(TrColor));
	fread(st_palette.buffer, sizeof(TrColor), headerihardlyknower.data_len, file);

	fclose(file);
	tr_liblog("loaded stpal palette from %s", path);
	st_vox_render_on_palette_update(st_palette);
	return true;
}

TrColor st_get_color(uint8_t i)
{
	return *TR_AT(st_palette, TrColor, i);
}

void st_register_block(uint16_t group, uint16_t block, const char* path)
{
	tr_assert(group != 0, "group 0 is used to mean there's no block, use something else");
	StVoxModel model;
	if (!st_vox_load(&st_arena, path, &model)) {
		tr_panic("you energumen %s was not found", path);
	}

	// put voxels in a hashmap
	StVoxModelMap* voxels;
	for (size_t i = 0; i < model.voxels.length; i++) {
		StPackedVoxel vox = *TR_AT(model.voxels, StPackedVoxel, i);
		TrVec3i pos = {vox.x, vox.y, vox.z};
		hmput(voxels, pos, vox.color);
	}

	StBlockId id = {group, block};
	hmput(st_block_types, id, voxels);
	tr_liblog("registered block type %i:%i (from %s)", group, block, path);
}

bool st_get_block_type(TrVec3i pos, uint16_t* out_group, uint16_t* out_block)
{
	StBlockId id = hmget(st_blocks, pos);
	// that's the default value, hmget doesn't return null because it's not a pointer
	if (id.block == 0 && id.group == 0) {
		return false;
	}

	tr_assert(out_group != NULL, "out_group != NULL");
	tr_assert(out_block != NULL, "out_block != NULL");
	*out_group = id.group;
	*out_block = id.block;
	return true;
}

bool st_has_block(TrVec3i pos)
{
	uint16_t tmp1, tmp2;
	return st_get_block_type(pos, &tmp1, &tmp2);
}

void st_place_block(uint16_t group, uint16_t block, TrVec3i pos)
{
	// does the block type exist?
	StBlockId id = {group, block};
	StVoxModelMap* man = hmget(st_block_types, id);
	tr_assert(man != NULL, "block type %i:%i doesn't exist", group, block);

	StBlockId sir = {group, block};
	hmput(st_blocks, pos, sir);
}

bool st_break_block(TrVec3i pos)
{
	if (!st_has_block(pos)) {
		return false;
	}
	hmdel(st_blocks, pos);
	return true;
}
