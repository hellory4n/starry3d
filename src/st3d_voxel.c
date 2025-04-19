/*#include <stdio.h>
#include "st3d.h"
#include "st3d_voxel.h"

// vox loader based on https://paulbourke.net/dataformats/vox/

// structs to be used with fread

typedef struct {
	int32_t magic_number;
	int32_t version;
} VoxHeader;

typedef struct {
	// no null terminator because that's how the format works
	char tag[4];
	int32_t len;
	int32_t children_len;
} VoxChunk;

static void read_chunks(FILE* file, St3dVoxModel* model, void* chunks)
{
	// TODO actually write this
}

St3dVoxModel st3d_voxel_new(const char* path)
{
	TrArena tmp = tr_arena_new(ST3D_PATH_SIZE);
	TrString real_path = tr_slice_new(&tmp, ST3D_PATH_SIZE, sizeof(char));
	st3d_path(path, &real_path);

	St3dVoxModel model = {0};

	// we do have to read the file
	FILE* file = fopen(real_path.buffer, "rb");

	// magic number thing
	// we don't care about the version so we just check for the magic number
	VoxHeader header;
	fread(&header, sizeof(VoxHeader), 1, file);

	// a color has the same size as the size of the magic number
	// i know this is cursed
	// the magic number is 'VOX '
	TrColor magic_num = *(TrColor*)(&header.magic_number);
	if (magic_num.r != 'V' || magic_num.g != 'O' || magic_num.b != 'X' || magic_num.a != 'A') {
		fclose(file);
		tr_panic("error loading %s; are you sure this is a .vox file?", path);
	}

	// main chunk
	VoxChunk main;
	fread(&main, sizeof(VoxChunk), 1, file);
	// children_len is the length of the rest of the file
	void* chunks = tr_arena_alloc(&tmp, main.children_len);

	// the rest lmao
	read_chunks(file, &model, chunks);

	tr_liblog("loaded vox model at %s", path);
	return model;
}
*/