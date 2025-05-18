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
	struct {TrVec3i key; uint8_t value;}* voxels;
	for (size_t i = 0; i < model.voxels.length; i++) {
		StPackedVoxel vox = *TR_AT(model.voxels, StPackedVoxel, i);
		TrVec3i pos = {vox.x, vox.y, vox.z};
		hmput(voxels, pos, vox.color);
	}

	// basic awful mesh generation
	StVoxMeshes meshes = {
		.meshes = tr_slice_new(&st_arena, model.voxels.length, sizeof(StMesh)),
	};

	TrArena temp = tr_arena_new(TR_MB(1));
	for (size_t i = 0, meshidx = 0; i < model.voxels.length; i++) {
		StPackedVoxel vox = *TR_AT(model.voxels, StPackedVoxel, i);

		// culling
		// we only render faces if there's air around them
		StVertex* vertices = NULL;
		uint32_t* indices = NULL;
		uint32_t idxidx = 0; // TODO a good name

		// what am i doing lmao
		// this was before i turned st_mesh_new to use StVertex instead of a bunch of floats but now
		// macros are being annoying so i'm keeping it because its easier than changing 60 billion trillion
		// calls
		#define ST_APPEND_VERT(vx, vy, vz, nx, ny, nz, u, v) do { \
			StVertex tmpdeez = {{vx, vy, vz}, {nx, ny, nz}, {u, v}}; \
			arrput(vertices, tmpdeez); \
		} while (false);

		// mate
		TrVec3i top = {vox.x, vox.y + 1, vox.z};
		if (hmget(voxels, top) == ST_COLOR_TRANSPARENT) {
			// don't realloc() 1 billion trillion times
			arrsetcap(vertices, arrlen(vertices) + ((3 + 3 + 2) * 4));

			// yesterday i went outside with my mamas mason jar caught a lovely butterfly
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0, 1, 0, 0.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0, 1, 0, 1.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0, 1, 0, 1.0f, 1.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0, 1, 0, 0.0f, 1.0f);

			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 2);
			arrput(indices, idxidx + 1);
			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 3);
			arrput(indices, idxidx + 2);
			idxidx += 4;
		}

		TrVec3i left = {vox.x - 1, vox.y, vox.z};
		if (hmget(voxels, left) == ST_COLOR_TRANSPARENT) {
			// don't realloc() 1 billion trillion times
			arrsetcap(vertices, arrlen(vertices) + ((3 + 3 + 2) * 4));

			// when i woke up today looked in on my fairy pet she had withered all away no more sighing in her breast
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,  -1, 0, 0, 0.0f, 0.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,  -1, 0, 0, 1.0f, 0.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE,  -1, 0, 0, 1.0f, 1.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE,  -1, 0, 0, 0.0f, 1.0f);

			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 2);
			arrput(indices, idxidx + 1);
			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 3);
			arrput(indices, idxidx + 2);
			idxidx += 4;
		}

		TrVec3i right = {vox.x + 1, vox.y, vox.z};
		if (hmget(voxels, right) == ST_COLOR_TRANSPARENT) {
			// don't realloc() 1 billion trillion times
			arrsetcap(vertices, arrlen(vertices) + ((3 + 3 + 2) * 4));

			// im sorry for what i did i did what my body told me to i didnt mean to do you any harm
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 1, 0, 0, 0.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 1, 0, 0, 1.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 1, 0, 0, 1.0f, 1.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 1, 0, 0, 0.0f, 1.0f);

			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 2);
			arrput(indices, idxidx + 1);
			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 3);
			arrput(indices, idxidx + 2);
			idxidx += 4;
		}

		TrVec3i bottom = {vox.x, vox.y - 1, vox.z};
		if (hmget(voxels, bottom) == ST_COLOR_TRANSPARENT) {
			// don't realloc() 1 billion trillion times
			arrsetcap(vertices, arrlen(vertices) + ((3 + 3 + 2) * 4));

			// everytime i pin down what i think i want it slips away the ghost slips away
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0,-1, 0, 0.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0,-1, 0, 1.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0,-1, 0, 1.0f, 1.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0,-1, 0, 0.0f, 1.0f);

			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 2);
			arrput(indices, idxidx + 1);
			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 3);
			arrput(indices, idxidx + 2);
			idxidx += 4;
		}

		TrVec3i front = {vox.x, vox.y, vox.z + 1};
		if (hmget(voxels, front) == ST_COLOR_TRANSPARENT) {
			// don't realloc() 1 billion trillion times
			arrsetcap(vertices, arrlen(vertices) + ((3 + 3 + 2) * 4));

			// smell you on my hand for days i cant wash away your scent if im dog then youre a bitch
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0, 0, 1, 0.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0, 0, 1, 1.0f, 0.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0, 0, 1, 1.0f, 1.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, 0, 0, 1, 0.0f, 1.0f);

			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 2);
			arrput(indices, idxidx + 1);
			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 3);
			arrput(indices, idxidx + 2);
			idxidx += 4;
		}

		TrVec3i back = {vox.x, vox.y, vox.z - 1};
		if (hmget(voxels, back) == ST_COLOR_TRANSPARENT) {
			// don't realloc() 1 billion trillion times
			arrsetcap(vertices, arrlen(vertices) + ((3 + 3 + 2) * 4));

			// i guess youre as real as me maybe i can live with that maybe i need fantasy life of chasing butterfly
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0, 0,-1, 0.0f, 0.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0, 0,-1, 1.0f, 0.0f);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0, 0,-1, 1.0f, 1.0f);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, 0, 0,-1, 0.0f, 1.0f);

			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 2);
			arrput(indices, idxidx + 1);
			arrput(indices, idxidx + 0);
			arrput(indices, idxidx + 3);
			arrput(indices, idxidx + 2);
			idxidx += 4;
		}

		if (vertices != NULL) {
			// convert the stb arrays to slices
			TrSlice final_vertices = tr_slice_new(&temp, arrlen(vertices), sizeof(StVertex));
			TrSlice_uint32 final_indices = tr_slice_new(&temp, arrlen(indices), sizeof(uint32_t));
			final_vertices.buffer = vertices;
			final_indices.buffer = indices;

			StMesh mesh = st_mesh_new(&final_vertices, &final_indices, false);
			mesh.material.color = st_get_color(vox.color);
			*TR_AT(meshes.meshes, StMesh, meshidx) = mesh;

			meshidx++;
		}

		arrfree(vertices);
		arrfree(indices);
	}
	tr_arena_free(&temp);
	hmfree(voxels);

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
	// does the block type exist?
	StBlockId id = {group, block};
	StVoxMeshes meshes = hmget(st_block_types, id);
	tr_assert(meshes.meshes.length != 0, "block type %i:%i doesn't exist", group, block);

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
	StBlockId id = hmget(st_blocks, pos);
	// that's the default value, hmget doesn't return null because it's not a pointer
	if (id.group == 0 && id.block == 0) {
		return;
	}
	StVoxMeshes meshes = hmget(st_block_types, id);

	for (size_t i = 0; i < meshes.meshes.length; i++) {
		StMesh mesh = *TR_AT(meshes.meshes, StMesh, i);

		// currently there's some blank space in the slice because i have a good heart albeit insane
		// condemn him to the infirmary
		if (mesh.vao == 0) {
			continue;
		}

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
