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
extern struct {StBlockId key; StVoxModelMap* value;}* st_block_types;
extern struct {TrVec3i key; StBlockId value;}* st_blocks;
extern bool st_wireframe;

static struct {TrVec3i key; TrArena value;}* st_chunk_arenas;
static struct {TrVec3i key; TrSlice_StVoxVertex value;}* st_chunk_vertices;
static struct {TrVec3i key; TrSlice_StTriangle value;}* st_chunk_indices;
static struct {TrVec3i key; StVoxMesh value;}* st_chunk_meshes;

static StShader st_vox_shader;
static uint32_t st_palette_ubo;

void st_vox_render_init(void)
{
	// shadema
	st_vox_shader = st_shader_new(ST_VOX_SHADER_VERTEX, ST_VOX_SHADER_FRAGMENT);

	// setup ubo for the palette
	uint32_t ubo;
	glGenBuffers(1, &ubo);
	glBindBufferBase(GL_UNIFORM_BUFFER, 0, ubo);
	glBufferData(GL_UNIFORM_BUFFER, 256 * sizeof(float) * 4, NULL, GL_DYNAMIC_DRAW);

	uint32_t loc = glGetUniformBlockIndex(st_vox_shader.program, "palette_block");
	glUniformBlockBinding(st_vox_shader.program, loc, 0);
	st_palette_ubo = ubo;
}

void st_vox_render_free(void)
{
	st_shader_free(st_vox_shader);
}

void st_vox_render_on_palette_update(TrSlice_Color palette)
{
	// convert the 4 byte colors to vec4s
	// TrVec4f uses doubles so it doesn't work :)
	typedef struct {
		float x;
		float y;
		float z;
		float w;
	} GlVec4;

	TrArena tmp = tr_arena_new(palette.length * sizeof(GlVec4));
	TrSlice colors = tr_slice_new(&tmp, palette.length, sizeof(GlVec4));

	for (size_t i = 0; i < palette.length; i++) {
		TrColor intcolor = *TR_AT(palette, TrColor, i);
		GlVec4 vec4color = {intcolor.r / 255.0f, intcolor.g / 255.0f, intcolor.b / 255.0f, intcolor.a / 255.0f};
		*TR_AT(colors, GlVec4, i) = vec4color;
	}

	// send palette to the shader
	glBindBuffer(GL_UNIFORM_BUFFER, st_palette_ubo);
	void* ptr = glMapBuffer(GL_UNIFORM_BUFFER, GL_WRITE_ONLY);
	memcpy(ptr, colors.buffer, colors.length * sizeof(GlVec4));
	glUnmapBuffer(GL_UNIFORM_BUFFER);

	tr_arena_free(&tmp);
	tr_liblog("sent palette to the gpu");
}

static void st_init_chunk(TrVec3i pos)
{
	// 4 for a face, 6 faces for a cube, 16x16x16 for 3D, 16 for a chunk, 16 again bcuz it was crashing
	// for some reason
	const size_t vertlen = 4 * 6 * 16 * 16 * 16 * 16 * 16;
	// 2 triangles for a quad, 6 faces for a cube, 16*16*16*16*16 again
	const size_t idxlen = 2 * 6 * 16 * 16 * 16 * 16 * 16;
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
	glVertexAttribPointer(1, 1, GL_UNSIGNED_INT, GL_FALSE, sizeof(StVoxVertex), (void*)offsetof(StVoxVertex, facing));
	glEnableVertexAttribArray(1);
	// color attribute
	glVertexAttribPointer(2, 1, GL_UNSIGNED_INT, GL_FALSE, sizeof(StVoxVertex), (void*)offsetof(StVoxVertex, color));
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

static void st_render_block(TrVec3i pos, TrSlice_StVoxVertex* vertices, TrSlice_StTriangle* indices,
	size_t* vertidx, size_t* idxidx, size_t* idxbutforthesliceandnotopengl)
{
	StBlockId id = hmget(st_blocks, pos);
	StVoxModelMap* voxels = hmget(st_block_types, id);

	for (int64_t i = 0; i < hmlen(voxels); i++) {
		StPackedVoxel vox = {
			.x = voxels[i].key.x,
			.y = voxels[i].key.y,
			.z = voxels[i].key.z,
			.color = voxels[i].value
		};

		// my sincerest apologies
		#define ST_APPEND_VERT(X, Y, Z, Face) \
			*TR_AT(*vertices, StVoxVertex, (*vertidx)++) = \
				(StVoxVertex){{X + pos.x + (pos.x / ST_CHUNK_SIZE), Y + pos.y + (pos.y / ST_CHUNK_SIZE), \
				Z + pos.z + (pos.z / ST_CHUNK_SIZE)}, Face, vox.color};

		#define ST_APPEND_QUAD() do { \
			*TR_AT(*indices, StTriangle, *idxbutforthesliceandnotopengl + 1) = (StTriangle){*idxidx, *idxidx + 1, *idxidx + 3}; \
			*TR_AT(*indices, StTriangle, *idxbutforthesliceandnotopengl + 2) = (StTriangle){*idxidx + 1, *idxidx + 2, *idxidx + 3}; \
			*idxidx += 4; \
			*idxbutforthesliceandnotopengl += 2; \
		} while (false)

		// man
		TrVec3i top = {vox.x, vox.y + 1, vox.z};
		if (hmget(voxels, top) == ST_COLOR_TRANSPARENT) {
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_UP);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_UP);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_UP);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOXEL_SIZE);
			ST_APPEND_QUAD();
		}

		TrVec3i left = {vox.x - 1, vox.y, vox.z};
		if (hmget(voxels, left) == ST_COLOR_TRANSPARENT) {
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_WEST);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_WEST);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_WEST);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_WEST);
			ST_APPEND_QUAD();
		}

		TrVec3i right = {vox.x + 1, vox.y, vox.z};
		if (hmget(voxels, right) == ST_COLOR_TRANSPARENT) {
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_EAST);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_EAST);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_EAST);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_EAST);
			ST_APPEND_QUAD();
		}

		TrVec3i bottom = {vox.x, vox.y - 1, vox.z};
		if (hmget(voxels, bottom) == ST_COLOR_TRANSPARENT) {
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_DOWN);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_DOWN);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_DOWN);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_DOWN);
			ST_APPEND_QUAD();
		}

		TrVec3i front = {vox.x, vox.y, vox.z + 1};
		if (hmget(voxels, front) == ST_COLOR_TRANSPARENT) {
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_NORTH);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_NORTH);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_NORTH);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, (vox.z + 1) / ST_VOXEL_SIZE, ST_VOX_FACE_NORTH);
			ST_APPEND_QUAD();
		}

		TrVec3i back = {vox.x, vox.y, vox.z - 1};
		if (hmget(voxels, back) == ST_COLOR_TRANSPARENT) {
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_SOUTH);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, vox.y / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_SOUTH);
			ST_APPEND_VERT(vox.x / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_SOUTH);
			ST_APPEND_VERT((vox.x + 1) / ST_VOXEL_SIZE, (vox.y + 1) / ST_VOXEL_SIZE, vox.z / ST_VOXEL_SIZE, ST_VOX_FACE_SOUTH);
			ST_APPEND_QUAD();
		}
	}
}

static void st_render_chunk(TrVec3i pos)
{
	// help
	TrSlice_StVoxVertex vertices = hmget(st_chunk_vertices, pos);
	TrSlice_StTriangle indices = hmget(st_chunk_indices, pos);

	// stop fucking crashing
	if (vertices.length == 0) {
		st_init_chunk(pos);
		vertices = hmget(st_chunk_vertices, pos);
		indices = hmget(st_chunk_indices, pos);
	}

	size_t vertidx = 0;
	// TODO a better name
	size_t idxidx = 0;
	size_t idxbutforthesliceandnotopengl = 0;

	// get all the blocks in the chunk
	StCamera cam = st_camera();
	TrVec3i tmp = {ST_CHUNK_SIZE, ST_CHUNK_SIZE, ST_CHUNK_SIZE};
	TrVec3i render_start = TR_V3_SUB(cam.position, tmp);
	TrVec3i render_end = TR_V3_ADD(cam.position, tmp);

	for (int64_t x = render_start.x; x < render_end.x; x++) {
		for (int64_t y = render_start.y; y < render_end.y; y++) {
			for (int64_t z = render_start.z; z < render_end.z; z++) {
				st_render_block((TrVec3i){x, y, z}, &vertices, &indices, &vertidx, &idxidx, &idxbutforthesliceandnotopengl);
			}
		}
	}

	StVoxMesh mesh = hmget(st_chunk_meshes, pos);
	glBindVertexArray(mesh.vao);

	// send new data
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo);
	void* ptr = glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
	memcpy(ptr, vertices.buffer, vertices.length * vertices.elem_size);
	glUnmapBuffer(GL_ARRAY_BUFFER);

	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ebo);
	ptr = glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);
	memcpy(ptr, indices.buffer, indices.length * indices.elem_size);
	glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

	// actually like draw shit
	if (st_wireframe) {
		glDrawElements(GL_LINE_LOOP, idxidx, GL_UNSIGNED_INT, 0);
	}
	else {
		glDrawElements(GL_TRIANGLES, idxidx, GL_UNSIGNED_INT, 0);
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

	// unbind vao
	glBindVertexArray(0);
}
