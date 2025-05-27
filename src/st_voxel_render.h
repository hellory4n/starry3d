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

#ifndef _ST_VOXEL_RENDER_H
#define _ST_VOXEL_RENDER_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

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

// internal
void st_vox_render_init(void);
// internal
void st_vox_render_free(void);
// internal
void st_vox_render_on_palette_update(TrSlice_Color palette);

// Renders every block ever.
void st_vox_draw(void);

#ifdef __cplusplus
}
#endif

#endif