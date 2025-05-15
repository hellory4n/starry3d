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

#include <math.h>
#include <stdio.h>
#include <stb_ds.h>
#include "st_common.h"
#include "st_render.h"
#include "st_voxel.h"

typedef struct {
	// Slice of StMesh
	TrSlice meshes;
} StVoxMeshes;

typedef struct {
	uint16_t group;
	uint16_t block;
} StBlockId;

static TrArena st_arena;
static TrSlice_Color st_palette;
static struct {StBlockId key; StVoxMeshes value;}* st_block_types;
static struct {TrVec3i key; StBlockId value;}* st_blocks;

void st_vox_init(void)
{
	st_arena = tr_arena_new(TR_MB(8));
	StBlockId defaul = {0, 0};
	hmdefault(st_blocks, defaul);
	tr_liblog("initialized voxel engine");
}

void st_vox_free(void)
{
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
	return true;
}

TrColor st_get_color(uint8_t i)
{
	return *TR_AT(st_palette, TrColor, i);
}

void st_register_block(uint16_t group, uint16_t block, const char* path)
{
	StVoxModel model;
	if (!st_vox_load(&st_arena, path, &model)) {
		tr_panic("you energumen %s was not found", path);
	}

	// basic awful mesh generation
	StVoxMeshes meshes = {
		.meshes = tr_slice_new(&st_arena, model.voxels.length, sizeof(StMesh)),
	};

	TrArena temp = tr_arena_new(TR_MB(1));
	for (size_t i = 0; i < model.voxels.length; i++) {
		StPackedVoxel vox = *TR_AT(model.voxels, StPackedVoxel, i);

		TrSlice_float vertices;
		//c hrist
		// i wont even try to format this
		TR_SET_SLICE(&temp, &vertices, float,
			vox.x / ST_VOXEL_SIZE,     vox.y / ST_VOXEL_SIZE,     (vox.z + 1) / ST_VOXEL_SIZE / ST_VOXEL_SIZE,   0, 0, 1,    0.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE,     (vox.z + 1) / ST_VOXEL_SIZE,   0, 0, 1,    1.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,   0, 0, 1,    1.0f, 1.0f,
			vox.x / ST_VOXEL_SIZE,     (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,   0, 0, 1,    0.0f, 1.0f,

			(vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE,     vox.z / ST_VOXEL_SIZE,       0, 0,-1,    0.0f, 0.0f,
			vox.x / ST_VOXEL_SIZE,     vox.y / ST_VOXEL_SIZE,     vox.z / ST_VOXEL_SIZE,       0, 0,-1,    1.0f, 0.0f,
			vox.x / ST_VOXEL_SIZE,     (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,       0, 0,-1,    1.0f, 1.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,       0, 0,-1,    0.0f, 1.0f,

			vox.x / ST_VOXEL_SIZE,     vox.y / ST_VOXEL_SIZE,     vox.z / ST_VOXEL_SIZE,      -1, 0, 0,    0.0f, 0.0f,
			vox.x / ST_VOXEL_SIZE,     vox.y / ST_VOXEL_SIZE,     (vox.z + 1) / ST_VOXEL_SIZE,  -1, 0, 0,    1.0f, 0.0f,
			vox.x / ST_VOXEL_SIZE,     (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,  -1, 0, 0,    1.0f, 1.0f,
			vox.x / ST_VOXEL_SIZE,     (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,      -1, 0, 0,    0.0f, 1.0f,

			(vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE,     (vox.z + 1) / ST_VOXEL_SIZE,   1, 0, 0,    0.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE,     vox.z / ST_VOXEL_SIZE,       1, 0, 0,    1.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,       1, 0, 0,    1.0f, 1.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,   1, 0, 0,    0.0f, 1.0f,

			vox.x / ST_VOXEL_SIZE,     (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,   0, 1, 0,    0.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,   0, 1, 0,    1.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,       0, 1, 0,    1.0f, 1.0f,
			vox.x / ST_VOXEL_SIZE,     (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,       0, 1, 0,    0.0f, 1.0f,

			vox.x / ST_VOXEL_SIZE,     vox.y / ST_VOXEL_SIZE,     vox.z / ST_VOXEL_SIZE,       0,-1, 0,    0.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE,     vox.z / ST_VOXEL_SIZE,       0,-1, 0,    1.0f, 0.0f,
			(vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE,     (vox.z + 1) / ST_VOXEL_SIZE,   0,-1, 0,    1.0f, 1.0f,
			vox.x / ST_VOXEL_SIZE,     vox.y / ST_VOXEL_SIZE,     (vox.z + 1) / ST_VOXEL_SIZE,   0,-1, 0,    0.0f, 1.0f,
		);

		TrSlice_uint32 indices;
		TR_SET_SLICE(&temp, &indices, uint32_t,
			0, 2, 1, 0, 3, 2,
			4, 6, 5, 4, 7, 6,
			8, 10, 9, 8, 11, 10,
			12, 14, 13, 12, 15, 14,
			16, 18, 17, 16, 19, 18,
			20, 22, 21, 20, 23, 22,
		);

		StMesh mesh = st_mesh_new(&vertices, &indices, false);
		mesh.material.color = st_get_color(vox.color);
		*TR_AT(meshes.meshes, StMesh, i) = mesh;
	}
	tr_arena_free(&temp);

	// mate
	StBlockId sir = {group, block};
	hmput(st_block_types, sir, meshes);
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

static void st_draw_block(TrVec3i pos)
{
	StBlockId blockid = hmget(st_blocks, pos);
	StVoxMeshes meshes = hmget(st_block_types, blockid);

	for (size_t i = 0; i < meshes.meshes.length; i++) {
		StMesh mesh = *TR_AT(meshes.meshes, StMesh, i);
		st_mesh_draw_3d(mesh, (TrVec3f){pos.x, pos.y, pos.z}, (TrVec3f){0, 0, 0});
	}
}

void st_vox_draw(void)
{
	StCamera cam = st_camera();
	cam.position.x = round(cam.position.x);
	cam.position.y = round(cam.position.y);
	cam.position.z = round(cam.position.z);

	// we don't render everything at once to not explode your pc :)
	TrVec3i tmp = {ST_CHUNK_SIZE, ST_CHUNK_SIZE, ST_CHUNK_SIZE};
	TrVec3i render_start = TR_V3_SUB(cam.position, tmp);
	TrVec3i render_end = TR_V3_ADD(cam.position, tmp);

	for (int64_t x = render_start.x; x < render_end.x; x++) {
		for (int64_t y = render_start.y; y < render_end.y; y++) {
			for (int64_t z = render_start.z; z < render_end.z; z++) {
				st_draw_block((TrVec3i){x, y, z});
			}
		}
	}
}
