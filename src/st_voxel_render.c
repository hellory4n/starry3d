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

#include <glad/gl.h>
#include <stb_ds.h>
#include <linmath.h>
#include "st_window.h"
#include "st_render.h"
#include "st_voxel.h"
#include "st_voxel_render.h"
#include "shader/vox.glsl.h"

// man
typedef struct {TrVec3i key; uint8_t value;} StVoxModelMap;
extern TrSlice_Color st_palette;
extern struct {StBlockId key; StVoxModelMap* value;}* st_block_types;
extern struct {TrVec3i key; StBlockId value;}* st_blocks;

static struct {TrVec3i key; TrArena value;}* st_chunk_arenas;
static struct {TrVec3i key; TrSlice_StVoxVertex value;}* st_chunk_vertices;
static struct {TrVec3i key; TrSlice_StTriangle value;}* st_chunk_indices;
static struct {TrVec3i key; StVoxMesh value;}* st_chunk_meshes;

static StShader st_vox_shader;

void st_vox_render_init(void)
{
	// shadema
	st_vox_shader = st_shader_new(ST_VOX_SHADER_VERTEX, ST_VOX_SHADER_FRAGMENT);
}

void st_vox_render_free(void)
{
	st_shader_free(st_vox_shader);
}

void st_vox_render_on_palette_update(TrSlice_Color palette)
{
	// send palette to the shader
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

static void st_render_block(TrVec3i pos)
{}

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
