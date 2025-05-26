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
#include <glad/gl.h>
#include <linmath.h>
#include "st_common.h"
#include "st_render.h"
#include "st_voxel.h"
#include "shader/vox.glsl.h"
#include "st_window.h"

typedef struct {
	// Slice of StMesh
	TrSlice meshes;
} StVoxMeshes;

typedef struct {
	uint16_t group;
	uint16_t block;
} StBlockId;

typedef enum {
	ST_VOX_FACE_WEST,
	ST_VOX_FACE_EAST,
	ST_VOX_FACE_NORTH,
	ST_VOX_FACE_SOUTH,
	ST_VOX_FACE_UP,
	ST_VOX_FACE_DOWN,
} StVoxFace;

typedef struct {
	struct {
		float x;
		float y;
		float z;
	} pos;
	float facing;
	// Color index
	float color;
} StVoxVertex;

typedef struct {
	uint32_t vao;
	uint32_t vbo;
	uint32_t ebo;
	uint32_t indices_len;
} StVoxMesh;

typedef TrSlice TrSlice_StVoxVertex;

static TrArena st_arena;
static TrSlice_Color st_palette;

typedef struct {TrVec3i key; uint8_t value;} StShutUpCompilerThisIsTheSameType;

static struct {StBlockId key; StShutUpCompilerThisIsTheSameType* value;}* st_block_types;
static struct {TrVec3i key; StBlockId value;}* st_blocks;

static struct {TrVec3i key; TrArena value;}* st_chunk_arenas;
static struct {TrVec3i key; TrSlice_StVoxVertex value;}* st_chunk_vertices;
static struct {TrVec3i key; TrSlice_StTriangle value;}* st_chunk_indices;
static struct {TrVec3i key; StVoxMesh value;}* st_chunk_meshes;

static StShader st_vox_shader;

void st_vox_init(void)
{
	st_arena = tr_arena_new(TR_MB(1));
	StBlockId defaul = {0, 0};
	hmdefault(st_blocks, defaul);
	hmdefault(st_block_types, NULL);

	// shadema
	st_vox_shader = st_shader_new(ST_VOX_SHADER_VERTEX, ST_VOX_SHADER_FRAGMENT);

	tr_liblog("initialized voxel engine");
}

void st_vox_free(void)
{
	st_shader_free(st_vox_shader);
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
	StShutUpCompilerThisIsTheSameType* voxels;
	for (size_t i = 0; i < model.voxels.length; i++) {
		StPackedVoxel vox = *TR_AT(model.voxels, StPackedVoxel, i);
		TrVec3i pos = {vox.x, vox.y, vox.z};
		hmput(voxels, pos, vox.color);
	}
	StBlockId id = {group, block};
	hmput(st_block_types, id, voxels);

	// basic awful mesh generation
	/*StVoxMeshes meshes = {
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
	hmput(st_block_types, sir, meshes);*/
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
	StShutUpCompilerThisIsTheSameType* man = hmget(st_block_types, id);
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

static void st_init_chunk(TrVec3i pos)
{
	// 4 for a face, 6 faces for a cube, 16x16x16 for 3D, 16 for a chunk
	const size_t vertlen = 4 * 6 * 16 * 16 * 16 * 16;
	// 2 triangles for a quad, 6 faces for a cube, 16*16*16*16 again
	const size_t idxlen = 2 * 6 * 16 * 16 * 16 * 16;
	const size_t bufsize = (vertlen * sizeof(StVoxVertex)) + (idxlen * sizeof(StTriangle));

	TrArena arenama = tr_arena_new(bufsize);
	TrSlice_StVoxVertex vertices = tr_slice_new(&arenama, vertlen, sizeof(StVoxVertex));
	TrSlice_StTriangle indices = tr_slice_new(&arenama, idxlen, sizeof(StTriangle));

	hmput(st_chunk_arenas, pos, arenama);
	hmput(st_chunk_vertices, pos, vertices);
	hmput(st_chunk_indices, pos, indices);

	// setup meshes
	StVoxMesh mesh = {
		.indices_len = indices.length * 3,
	};
	glGenVertexArrays(1, &mesh.vao);
	glBindVertexArray(mesh.vao);

	// vbo
	glGenBuffers(1, &mesh.vbo);
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo);

	// null makes it so it just allocates vram for future use
	glBufferData(GL_ARRAY_BUFFER, vertlen * sizeof(StVertex), NULL, GL_DYNAMIC_DRAW);

	// position attribute
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(StVoxVertex), (void*)offsetof(StVoxVertex, pos));
	glEnableVertexAttribArray(0);
	// facing attribute
	glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, sizeof(StVoxVertex), (void*)offsetof(StVoxVertex, facing));
	glEnableVertexAttribArray(1);
	// color attribute
	glVertexAttribPointer(2, 1, GL_FLOAT, GL_FALSE, sizeof(StVoxVertex), (void*)offsetof(StVoxVertex, color));
	glEnableVertexAttribArray(2);

	// ebo
	glGenBuffers(1, &mesh.ebo);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * sizeof(StTriangle), NULL, GL_DYNAMIC_DRAW);

	// unbind vao
	glBindVertexArray(0);

	hmput(st_chunk_meshes, pos, mesh);
	tr_liblog("created buffers for chunk %li, %li, %li", pos.x, pos.y, pos.z);
}

// checks the camera position to see if it's on a new chunk
static void st_auto_chunkomator(void)
{
	StCamera cam = st_camera();

	// is it new?
	TrVec3i chunk_pos = TR_V3_SDIV(cam.position, ST_CHUNK_SIZE);
	if (hmget(st_chunk_arenas, chunk_pos).buffer == NULL) {
		st_init_chunk(chunk_pos);
	}
}

// sets all the shader uniforms
static void st_update_shader(void)
{
	// TODO st_render.c really should be rewritten at some point to be more flexible
	mat4x4 view, proj;
	StCamera cam = st_camera();

	// perspective
	if (cam.perspective) {
		mat4x4 view_pos, view_rot;
		mat4x4_identity(view_pos);
		mat4x4_identity(view_rot);
		mat4x4_translate(view_pos, -cam.position.x, -cam.position.y, -cam.position.z);

		mat4x4_rotate_X(view_rot, view_rot, tr_deg2rad(cam.rotation.x));
		mat4x4_rotate_Y(view_rot, view_rot, tr_deg2rad(cam.rotation.y));
		mat4x4_rotate_Z(view_rot, view_rot, tr_deg2rad(cam.rotation.z));

		mat4x4_mul(view, view_rot, view_pos);

		TrVec2i winsize = st_window_size();
		mat4x4_perspective(proj, tr_deg2rad(cam.view), (double)winsize.x / winsize.y,
			cam.near, cam.far);
	}
	// orthographic
	else {
		mat4x4 view_pos, view_rot;
		mat4x4_identity(view_pos);
		mat4x4_identity(view_rot);
		mat4x4_translate(view_pos, -cam.position.x, cam.position.y, -cam.position.z);

		mat4x4_rotate_X(view_rot, view_rot, tr_deg2rad(cam.rotation.x));
		mat4x4_rotate_Y(view_rot, view_rot, tr_deg2rad(cam.rotation.y));
		mat4x4_rotate_Z(view_rot, view_rot, tr_deg2rad(cam.rotation.z));

		mat4x4_mul(view, view_pos, view_rot);

		TrVec2i winsize = st_window_size();
		double ortho_height = cam.view * ((double)winsize.y / winsize.x);

		double left = -cam.view / 2.0;
		double right = cam.view / 2.0;
		double bottom = -ortho_height / 2.0;
		double top = ortho_height / 2.0;

		mat4x4_ortho(proj, left, right, top, bottom, cam.near, cam.far);
	}

	StEnvironment env = st_environment();
	st_shader_set_mat4f(st_vox_shader, "u_view", (float*)view);
	st_shader_set_mat4f(st_vox_shader, "u_proj", (float*)proj);
	st_shader_set_vec3f(st_vox_shader, "u_sun_color",
		(TrVec3f){env.sun.color.r / 255.0f, env.sun.color.g / 255.0f,
		env.sun.color.b / 255.0f});
	st_shader_set_vec3f(st_vox_shader, "u_ambient",
		(TrVec3f){env.ambient_color.r / 255.0f, env.ambient_color.g / 255.0f,
		env.ambient_color.b / 255.0f});
	st_shader_set_vec3f(st_vox_shader, "u_sun_dir", env.sun.direction);
}

static void st_render_chunk(TrVec3i pos)
{
	// help
	TrSlice_StVoxVertex vertices = hmget(st_chunk_vertices, pos);
	TrSlice_StTriangle indices = hmget(st_chunk_indices, pos);
	size_t vertidx;
	size_t idxidx; // TODO a better name

	// get all the blocks in the chunk
	StCamera cam = st_camera();
	TrVec3i tmp = {ST_CHUNK_SIZE, ST_CHUNK_SIZE, ST_CHUNK_SIZE};
	TrVec3i render_start = TR_V3_SUB(cam.position, tmp);
	TrVec3i render_end = TR_V3_ADD(cam.position, tmp);

	// i know this is cursed but hear me out
	for (int64_t x = render_start.x; x < render_end.x; x++) {
	for (int64_t y = render_start.y; y < render_end.y; y++) {
	for (int64_t z = render_start.z; z < render_end.z; z++) {
		TrVec3i vox = {x, y, z};
		StBlockId id = hmget(st_blocks, pos);
		StShutUpCompilerThisIsTheSameType* voxels = hmget(st_block_types, id);

		// would be too obnoxious to change all the calls to this
		#define ST_APPEND_VERT(vx, vy, vz, f, c) \
			*TR_AT(vertices, StVoxVertex, vertidx++) = {{vx, vy, vz}, f, c};

		// mate
		TrVec3i top = {vox.x, vox.y + 1, vox.z};
		if (hmget(voxels, top) == ST_COLOR_TRANSPARENT) {
			// yesterday i went outside with my mamas mason jar caught a lovely butterfly
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_UP, hmget(voxels, vox));
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
		};
	}
	}
	}
}

void st_vox_draw(void)
{
	st_auto_chunkomator();

	StCamera cam = st_camera();
	cam.position.x = round(cam.position.x);
	cam.position.y = round(cam.position.y);
	cam.position.z = round(cam.position.z);

	st_update_shader();

	// just making sure
	glBindTexture(GL_TEXTURE_2D, 0);

	// actually render
	// TODO this is where the render distance goes
	TrVec3i chunk_pos = TR_V3_SDIV(cam.position, ST_CHUNK_SIZE);
	st_render_chunk(chunk_pos);
}
