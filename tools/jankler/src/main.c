#include <glad/gl.h>
#include <stdio.h>
#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>
#include <st3d_voxel.h>

#define ST3D_SELECTION_COLOR tr_hex_rgba(0xffffff77)

// why the fuck would you need a 3d array
#define ST3D_AT3D(slice, type, sizey, sizez, x, y, z) TR_AT(slice, type, x * (sizey * sizez) + y * sizez + z)

static void camera_controller(void);
static void model_controller(void);
static void main_ui(void);
static void draw_gizmo_things(void);
static void selection_thing(void);
static void saver_5000(void);
static void loader_5000(void);
static void color_picker(void);

static St3dMesh jk_el_cubo;
static TrSlice_uint8 jk_cubes;
static uint8_t jk_current_color = ST3D_COLOR_WHITE_1;
static bool jk_loading;
static bool jk_saving;

bool jk_ui_visible = true;

int main(void)
{
	st3d_init("jankler", "assets", 800, 600);
	st3d_ui_new("app:figtree/Figtree-Medium.ttf", 16);
	st3d_set_palette("app:default.stpal");
	TrArena arena = tr_arena_new(TR_MB(1));
	jk_cubes = tr_slice_new(&arena, 16 * 16 * 16, sizeof(uint8_t));

	// ttriangel
	TrSlice_float vertices;
	// dear god
	TR_SET_SLICE(&arena, &vertices, float,
		-0.5f, -0.5f, +0.5f,   0, 0, 1,    0.0f, 0.0f,
		+0.5f, -0.5f, +0.5f,   0, 0, 1,    1.0f, 0.0f,
		+0.5f, +0.5f, +0.5f,   0, 0, 1,    1.0f, 1.0f,
		-0.5f, +0.5f, +0.5f,   0, 0, 1,    0.0f, 1.0f,

		+0.5f, -0.5f, -0.5f,   0, 0,-1,    0.0f, 0.0f,
		-0.5f, -0.5f, -0.5f,   0, 0,-1,    1.0f, 0.0f,
		-0.5f, +0.5f, -0.5f,   0, 0,-1,    1.0f, 1.0f,
		+0.5f, +0.5f, -0.5f,   0, 0,-1,    0.0f, 1.0f,

		-0.5f, -0.5f, -0.5f,  -1, 0, 0,    0.0f, 0.0f,
		-0.5f, -0.5f, +0.5f,  -1, 0, 0,    1.0f, 0.0f,
		-0.5f, +0.5f, +0.5f,  -1, 0, 0,    1.0f, 1.0f,
		-0.5f, +0.5f, -0.5f,  -1, 0, 0,    0.0f, 1.0f,

		+0.5f, -0.5f, +0.5f,   1, 0, 0,    0.0f, 0.0f,
		+0.5f, -0.5f, -0.5f,   1, 0, 0,    1.0f, 0.0f,
		+0.5f, +0.5f, -0.5f,   1, 0, 0,    1.0f, 1.0f,
		+0.5f, +0.5f, +0.5f,   1, 0, 0,    0.0f, 1.0f,

		-0.5f, +0.5f, +0.5f,   0, 1, 0,    0.0f, 0.0f,
		+0.5f, +0.5f, +0.5f,   0, 1, 0,    1.0f, 0.0f,
		+0.5f, +0.5f, -0.5f,   0, 1, 0,    1.0f, 1.0f,
		-0.5f, +0.5f, -0.5f,   0, 1, 0,    0.0f, 1.0f,

		-0.5f, -0.5f, -0.5f,   0,-1, 0,    0.0f, 0.0f,
		+0.5f, -0.5f, -0.5f,   0,-1, 0,    1.0f, 0.0f,
		+0.5f, -0.5f, +0.5f,   0,-1, 0,    1.0f, 1.0f,
		-0.5f, -0.5f, +0.5f,   0,-1, 0,    0.0f, 1.0f,
	);

	// TODO for individual faces, just reuse the vert slice and only add more slices for indices
	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		0, 2, 1, 0, 3, 2,
		4, 6, 5, 4, 7, 6,
		8, 10, 9, 8, 11, 10,
		12, 14, 13, 12, 15, 14,
		16, 18, 17, 16, 19, 18,
		20, 22, 21, 20, 23, 22,
	);

	jk_el_cubo = st3d_mesh_new(&vertices, &indices, true);
	jk_el_cubo.material.color = tr_hex_rgb(0xffff00);
	// el_cubo.texture = st3d_texture_new("app:enough_fckery.jpg");
	// st3d_set_wireframe(true);

	st3d_set_environment((St3dEnvironment){
		.sky_color = tr_hex_rgb(0x03A9F4),
		.ambient_color = tr_hex_rgb(0x212121),
		.sun = {
			.direction = {0.5, 1.0, -0.75},
			.color = TR_WHITE,
		},
	});

	while (!st3d_is_closing()) {
		st3d_begin_drawing();

		if (st3d_is_key_just_pressed(ST3D_KEY_TAB)) {
			jk_ui_visible = !jk_ui_visible;
		}

		// i'm sorry... i'm sorry... i'm sorry...
		for (size_t x = 0; x < 16; x++) {
			for (size_t y = 0; y < 16; y++) {
				for (size_t z = 0; z < 16; z++) {
					uint8_t lecolourindexè = *ST3D_AT3D(jk_cubes, uint8_t, 16, 16, x, y, z);
					TrColor lecolour = st3d_get_color(lecolourindexè);
					if (lecolour.a == 0) {
						continue;
					}

					jk_el_cubo.material.color = lecolour;
					st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){x, y, z}, (TrVec3f){0, 0, 0});
				}
			}
		}
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, 0, 0}, (TrVec3f){0, 0, 0});

		camera_controller();
		model_controller();
		draw_gizmo_things();
		selection_thing();

		// nuklear calls go inside here
		st3d_ui_begin();
			saver_5000();
			loader_5000();
			main_ui();
			color_picker();
		st3d_ui_end();

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(jk_el_cubo.texture);
	st3d_mesh_free(jk_el_cubo);
	st3d_free();
}

static const double jk_speed = 40;
static TrVec3f jk_cam_rot = {-30, -20, 0};
static double jk_view = 50;
static bool jk_wireframe;

static void camera_controller(void)
{
	double dt = st3d_delta_time();

	if (st3d_is_key_held(ST3D_KEY_LEFT))  jk_cam_rot.y -= jk_speed * dt;
	if (st3d_is_key_held(ST3D_KEY_RIGHT)) jk_cam_rot.y += jk_speed * dt;
	if (st3d_is_key_held(ST3D_KEY_UP))    jk_cam_rot.x += jk_speed * dt;
	if (st3d_is_key_held(ST3D_KEY_DOWN))  jk_cam_rot.x -= jk_speed * dt;

	// zoom,
	TrVec2f scroll = st3d_mouse_scroll();
	if (scroll.y > 0) {
		jk_view /= 1.25;
	}
	else if (scroll.y < 0) {
		jk_view *= 1.25;
	}

	st3d_set_camera((St3dCamera){
		// position is in the middle
		.position = (TrVec3f){-6, 8, 8},
		.rotation = jk_cam_rot,
		.view = jk_view,
		// ??
		.near = -10000,
		.far = 10000,
		.perspective = false,
	});

	if (st3d_is_key_just_pressed(ST3D_KEY_F1)) {
		jk_wireframe = !jk_wireframe;
		st3d_set_wireframe(jk_wireframe);
	}
}

TrVec3f jk_selection_pos;

static void model_controller(void)
{
	if (jk_saving || jk_loading) return;

	if (st3d_is_key_just_pressed(ST3D_KEY_W))          jk_selection_pos.z -= 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_A))          jk_selection_pos.x -= 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_S))          jk_selection_pos.z += 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_D))          jk_selection_pos.x += 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_LEFT_SHIFT)) jk_selection_pos.y -= 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_SPACE))      jk_selection_pos.y += 1;

	// TODO we should probably be able to change the dimensions
	jk_selection_pos.x = tr_clamp(jk_selection_pos.x, 0, 15);
	jk_selection_pos.y = tr_clamp(jk_selection_pos.y, 0, 15);
	jk_selection_pos.z = tr_clamp(jk_selection_pos.z, 0, 15);

	// stigma
	if (st3d_is_mouse_just_pressed(ST3D_MOUSE_BUTTON_LEFT)) {
		*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, jk_selection_pos.x, jk_selection_pos.y, jk_selection_pos.z) = jk_current_color;
	}

	if (st3d_is_mouse_just_pressed(ST3D_MOUSE_BUTTON_RIGHT)) {
		*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, jk_selection_pos.x, jk_selection_pos.y, jk_selection_pos.z) = ST3D_COLOR_TRANSPARENT;
	}

	// help.
	if (jk_ui_visible) {
		jk_el_cubo.material.color = TR_WHITE;
		// i love hacking my own renderer
		glDisable(GL_DEPTH_TEST);
		glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ZERO);
		st3d_mesh_draw_3d(jk_el_cubo, jk_selection_pos, (TrVec3f){0, 0, 0});
		glEnable(GL_DEPTH_TEST);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
}

static void main_ui(void)
{
	if (!jk_ui_visible) return;
	struct nk_context* ctx = st3d_nkctx();

	if (nk_begin(ctx, "JanklerTM Pro v0.1.0", nk_rect(0, 0, 200, 600),
	NK_WINDOW_BORDER | NK_WINDOW_TITLE | NK_WINDOW_SCALABLE)) {
		nk_layout_row_dynamic(ctx, 20, 1);
		nk_label(ctx, "Advanced Voxel Modelling Software", NK_TEXT_ALIGN_CENTERED);

		struct nk_color istg = {255, 255, 255, 255};
		nk_label_colored(ctx, "How To Use This Disaster", NK_TEXT_ALIGN_CENTERED, istg);
		nk_label(ctx, "- scroll to zoom", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- arrow keys to rotate", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- wasd and shift or space to", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "fly", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- left click to place", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- right click to remove", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- remember you're limited", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "to 16x16x16", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- press tab to hide the UI", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- press F1 for wireframe", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- press M to start selection", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- press insert to fill selection", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- press delete to annihilate", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "selection", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- press C to cancel selection", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- press F12 to save", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "- i know the transparency is", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "fucked", NK_TEXT_ALIGN_LEFT);

		nk_label_colored(ctx, "Help Me", NK_TEXT_ALIGN_CENTERED, istg);

		// man
		char fucky1[64];
		char fucky2[64];
		char fucky3[64];
		char fucky4[64];
		snprintf(fucky1, sizeof(fucky1), "view: %f", jk_view);
		snprintf(fucky2, sizeof(fucky2), "rotation: %.2f %.2f %.2f", jk_cam_rot.x, jk_cam_rot.y, jk_cam_rot.z);
		snprintf(fucky3, sizeof(fucky3), "selection: %.0f %.0f %.0f", jk_selection_pos.x, jk_selection_pos.y, jk_selection_pos.z);
		snprintf(fucky4, sizeof(fucky4), "fps: %.0f", st3d_fps());
		nk_label(ctx, fucky1, NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, fucky2, NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, fucky3, NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, fucky4, NK_TEXT_ALIGN_LEFT);
	}
	nk_end(ctx);
}

static void draw_gizmo_things(void)
{
	if (!jk_ui_visible) return;

	// sir
	for (size_t i = 0; i < 16; i++) {
		jk_el_cubo.material.color = ST3D_SELECTION_COLOR;
		st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){i, 0, 0}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){i, 15, 0}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){i, 0, 15}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){0, i, 0}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, i, 15}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){15, i, 0}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){0, 0, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, 0, i}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){15, 0, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){15, 15, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, 15, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){15, i, 15}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){i, 15, 15}, (TrVec3f){0, 0, 0});
	}
}

static TrVec3f jk_sel_start;
static TrVec3f jk_sel_end;
static bool jk_selecting;

static void selection_thing(void)
{
	if (!jk_ui_visible) return;

	if (st3d_is_key_just_pressed(ST3D_KEY_M)) {
		jk_selecting = true;
		jk_sel_start = jk_selection_pos;
	}

	if (st3d_is_key_just_pressed(ST3D_KEY_C)) {
		jk_selecting = false;
		jk_sel_start = (TrVec3f){0, 0, 0};
		jk_sel_end = (TrVec3f){0, 0, 0};
	}

	if (jk_selecting) {
		jk_sel_end = jk_selection_pos;
	}

	// fucking hell
	size_t x_start = jk_sel_start.x < jk_sel_end.x ? jk_sel_start.x : jk_sel_end.x;
	size_t x_end   = jk_sel_start.x > jk_sel_end.x ? jk_sel_start.x : jk_sel_end.x;
	size_t y_start = jk_sel_start.y < jk_sel_end.y ? jk_sel_start.y : jk_sel_end.y;
	size_t y_end   = jk_sel_start.y > jk_sel_end.y ? jk_sel_start.y : jk_sel_end.y;
	size_t z_start = jk_sel_start.z < jk_sel_end.z ? jk_sel_start.z : jk_sel_end.z;
	size_t z_end   = jk_sel_start.z > jk_sel_end.z ? jk_sel_start.z : jk_sel_end.z;

	// preview selection
	for (size_t x = x_start; x <= x_end; x++) {
		for (size_t y = y_start; y <= y_end; y++) {
			for (size_t z = z_start; z <= z_end; z++) {
				jk_el_cubo.material.color = ST3D_SELECTION_COLOR;
				st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){x, y, z}, (TrVec3f){0, 0, 0});
			}
		}
	}

	// fill :)
	if (st3d_is_key_just_pressed(ST3D_KEY_INSERT)) {
		for (size_t x = x_start; x <= x_end; x++) {
			for (size_t y = y_start; y <= y_end; y++) {
				for (size_t z = z_start; z <= z_end; z++) {
					*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, x, y, z) = jk_current_color;
				}
			}
		}

		jk_selecting = false;
		jk_sel_start = (TrVec3f){0, 0, 0};
		jk_sel_end = (TrVec3f){0, 0, 0};
	}

	// delete :)
	if (st3d_is_key_just_pressed(ST3D_KEY_DELETE)) {
		for (size_t x = x_start; x <= x_end; x++) {
			for (size_t y = y_start; y <= y_end; y++) {
				for (size_t z = z_start; z <= z_end; z++) {
					*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, x, y, z) = ST3D_COLOR_TRANSPARENT;
				}
			}
		}

		jk_selecting = false;
		jk_sel_start = (TrVec3f){0, 0, 0};
		jk_sel_end = (TrVec3f){0, 0, 0};
	}
}

static char jk_save_path[256];
static bool jk_saving_fucked;

static void saver_5000(void)
{
	bool savingfrfrfr = false;

	if (st3d_is_key_just_pressed(ST3D_KEY_F12)) {
		jk_saving = !jk_saving;
		// hide the ui while saving bcuz why not
		jk_ui_visible = !jk_ui_visible;
	}
	if (!jk_saving) return;

	struct nk_context* ctx = st3d_nkctx();

	// dear god
	if (jk_saving_fucked) {
		if (nk_begin(ctx, "Jankler has encountered an inconvenience", nk_rect(100, 100, 400, 200),
		NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
			nk_layout_row_dynamic(ctx, 20, 1);
			nk_label(ctx, "Couldn't save file.", NK_TEXT_ALIGN_LEFT);

			if (nk_button_label(ctx, "oh ok")) {
				jk_saving = false;
				jk_ui_visible = true;
				jk_saving_fucked = false;
			}
		}
		nk_end(ctx);
		return;
	}

	if (nk_begin(ctx, "Jankler Save", nk_rect(100, 100, 400, 200),
	NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
		nk_layout_row_dynamic(ctx, 28, 1);
		nk_label(ctx, "Save as:", NK_TEXT_ALIGN_LEFT);

		nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, jk_save_path, sizeof(jk_save_path) - 1, nk_filter_default);

		if (nk_button_label(ctx, "Save")) {
			// don't want to put that logic under 3 levels of indentation
			savingfrfrfr = true;
		}

		if (nk_button_label(ctx, "Cancel")) {
			jk_saving = false;
			jk_ui_visible = true;
		}
	}
	nk_end(ctx);

	if (!savingfrfrfr) return;

	// actual saving
	St3dVoxModel model = {
		.dimensions = {16, 16, 16, 16},
	};

	// first get how many voxels are there
	// so we don't waste space with transparent voxels
	size_t len = 0;
	for (size_t i = 0; i < jk_cubes.length; i++) {
		TrColor lecolour = st3d_get_color(*TR_AT(jk_cubes, uint8_t, i));
		if (lecolour.a != 0) len++;
	}

	// now actually get the shit & the fuck
	TrArena tmp = tr_arena_new(len * sizeof(St3dPackedVoxel));
	TrSlice voxelsma = tr_slice_new(&tmp, len, sizeof(St3dPackedVoxel));
	size_t i = 0;
	for (size_t x = 0; x < 16; x++) {
		for (size_t y = 0; y < 16; y++) {
			for (size_t z = 0; z < 16; z++) {
				uint8_t lecolourindexèe = *ST3D_AT3D(jk_cubes, uint8_t, 16, 16, x, y, z);
				if (lecolourindexèe != ST3D_COLOR_TRANSPARENT) {
					*TR_AT(voxelsma, St3dPackedVoxel, i) = (St3dPackedVoxel){
						.x = x,
						.y = y,
						.z = z,
						.color = jk_current_color,
					};
					i++;
				}
			}
		}
	}

	// save deez
	model.voxels = voxelsma;
	bool success = st3d_stvox_save(model, jk_save_path);
	if (!success) {
		jk_saving_fucked = true;
	}
	else {
		// we're still saving
		// but we're done now so stop
		jk_saving = false;
		jk_ui_visible = true;
	}

	tr_arena_free(&tmp);
}

static char jk_load_path[256];
static bool jk_loading_fucked;

static void loader_5000(void)
{
	bool loadingfrfrfr = false;

	if (st3d_is_key_just_pressed(ST3D_KEY_F11)) {
		jk_loading = !jk_loading;
		// hide the ui while saving bcuz why not
		jk_ui_visible = !jk_ui_visible;
	}
	if (!jk_loading) return;

	struct nk_context* ctx = st3d_nkctx();

	// dear god
	if (jk_loading_fucked) {
		if (nk_begin(ctx, "Jankler has encountered an inconvenience", nk_rect(100, 100, 400, 200),
		NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
			nk_layout_row_dynamic(ctx, 20, 1);
			nk_label(ctx, "Couldn't load file.", NK_TEXT_ALIGN_LEFT);

			if (nk_button_label(ctx, "oh ok")) {
				jk_loading = false;
				jk_ui_visible = true;
				jk_loading_fucked = false;
			}
		}
		nk_end(ctx);
		return;
	}

	if (nk_begin(ctx, "Jankler Load", nk_rect(100, 100, 400, 200),
	NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
		nk_layout_row_dynamic(ctx, 28, 1);
		nk_label(ctx, "Load from:", NK_TEXT_ALIGN_LEFT);

		nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, jk_load_path, sizeof(jk_load_path) - 1, nk_filter_default);

		if (nk_button_label(ctx, "Open")) {
			// don't want to put that logic under 3 levels of indentation
			loadingfrfrfr = true;
		}

		if (nk_button_label(ctx, "Cancel")) {
			jk_loading = false;
			jk_ui_visible = true;
		}
	}
	nk_end(ctx);

	if (!loadingfrfrfr) return;

	// actual loading
	TrArena tmp = tr_arena_new(TR_MB(1));
	St3dVoxModel model;
	bool success = st3d_stvox_load(&tmp, jk_load_path, &model);

	if (!success) {
		jk_loading_fucked = true;
	}
	else {
		// the old model will be annihilated
		for (size_t x = 0; x < 16; x++) {
			for (size_t y = 0; y < 16; y++) {
				for (size_t z = 0; z < 16; z++) {
					*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, x, y, z) = ST3D_COLOR_TRANSPARENT;
				}
			}
		}

		// put that into the fucking slice we have
		for (size_t i = 0; i < model.voxels.length; i++) {
			St3dPackedVoxel yea = *TR_AT(model.voxels, St3dPackedVoxel, i);
			*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, yea.x, yea.y, yea.z) = yea.color;
		}

		jk_loading = false;
		jk_ui_visible = true;
	}

	tr_arena_free(&tmp);
}

static void color_picker(void) {}
