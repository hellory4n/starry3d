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

static St3dMesh el_cubo;
static TrSlice_Color cubes;
static bool loading;
static bool saving;

bool ui_visible = true;

int main(void)
{
	st3d_init("jankler", "assets", 800, 600);
	st3d_ui_new("app:figtree/Figtree-Medium.ttf", 16);
	TrArena arena = tr_arena_new(TR_MB(1));
	cubes = tr_slice_new(&arena, 16 * 16 * 16, sizeof(TrColor));

	// ttriangel
	TrSlice_float vertices;
	// dear god
	TR_SET_SLICE(&arena, &vertices, float,
		0.5f, 0.5f, 0.5f, 0.0f, 1.0f, 0.0f, 0.875f, 0.5f,
		-0.5f, 0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 0.625f, 0.75f,
		-0.5f, 0.5f, 0.5f, 0.0f, 1.0f, 0.0f, 0.625f, 0.5f,
		-0.5f, 0.5f, -0.5f, 0.0f, 0.0f, -1.0f, 0.625f, 0.75f,
		0.5f, -0.5f, -0.5f, 0.0f, 0.0f, -1.0f, 0.375f, 1.0f,
		-0.5f, -0.5f, -0.5f, 0.0f, 0.0f, -1.0f, 0.375f, 0.75f,
		0.5f, 0.5f, -0.5f, 1.0f, 0.0f, 0.0f, 0.625f, 0.0f,
		0.5f, -0.5f, 0.5f, 1.0f, 0.0f, 0.0f, 0.375f, 0.25f,
		0.5f, -0.5f, -0.5f, 1.0f, 0.0f, 0.0f, 0.375f, 0.0f,
		-0.5f, -0.5f, 0.5f, 0.0f, -1.0f, 0.0f, 0.375f, 0.5f,
		0.5f, -0.5f, -0.5f, 0.0f, -1.0f, 0.0f, 0.125f, 0.75f,
		0.5f, -0.5f, 0.5f, 0.0f, -1.0f, 0.0f, 0.125f, 0.5f,
		-0.5f, 0.5f, 0.5f, -1.0f, 0.0f, 0.0f, 0.625f, 0.5f,
		-0.5f, -0.5f, -0.5f, -1.0f, 0.0f, 0.0f, 0.375f, 0.75f,
		-0.5f, -0.5f, 0.5f, -1.0f, 0.0f, 0.0f, 0.375f, 0.5f,
		0.5f, 0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 0.625f, 0.25f,
		-0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 0.375f, 0.5f,
		0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 0.375f, 0.25f,
		0.5f, 0.5f, -0.5f, 0.0f, 1.0f, 0.0f, 0.875f, 0.75f,
		0.5f, 0.5f, -0.5f, 0.0f, 0.0f, -1.0f, 0.625f, 1.0f,
		0.5f, 0.5f, 0.5f, 1.0f, 0.0f, 0.0f, 0.625f, 0.25f,
		-0.5f, -0.5f, -0.5f, 0.0f, -1.0f, 0.0f, 0.375f, 0.75f,
		-0.5f, 0.5f, -0.5f, -1.0f, 0.0f, 0.0f, 0.625f, 0.75f,
		-0.5f, 0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 0.625f, 0.5f,
	);

	// TODO for individual faces, just reuse the vert slice and only add more slices for indices
	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		0, 1, 2,
		3, 4, 5,
		6, 7, 8,
		9, 10, 11,
		12, 13, 14,
		15, 16, 17,
		0, 18, 1,
		3, 19, 4,
		6, 20, 7,
		9, 21, 10,
		12, 22, 13,
		15, 23, 16,
		15, 23, 16
	);

	el_cubo = st3d_mesh_new(&vertices, &indices, true);
	el_cubo.material.color = tr_hex_rgb(0xffff00);
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
			ui_visible = !ui_visible;
		}

		// i'm sorry... i'm sorry... i'm sorry...
		for (size_t x = 0; x < 16; x++) {
			for (size_t y = 0; y < 16; y++) {
				for (size_t z = 0; z < 16; z++) {
					TrColor lecolour = *ST3D_AT3D(cubes, TrColor, 16, 16, x, y, z);
					if (lecolour.a == 0) {
						continue;
					}

					el_cubo.material.color = lecolour;
					st3d_mesh_draw_3d(el_cubo, (TrVec3f){x, y, z}, (TrVec3f){0, 0, 0});
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
		st3d_ui_end();

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(el_cubo.texture);
	st3d_mesh_free(el_cubo);
	st3d_free();
}

static const double speed = 40;
static TrVec3f cam_rot = {-30, -20, 0};
static double view = 50;
static bool wireframe;

static void camera_controller(void)
{
	double dt = st3d_delta_time();

	if (st3d_is_key_held(ST3D_KEY_LEFT))  cam_rot.y -= speed * dt;
	if (st3d_is_key_held(ST3D_KEY_RIGHT)) cam_rot.y += speed * dt;
	if (st3d_is_key_held(ST3D_KEY_UP))    cam_rot.x += speed * dt;
	if (st3d_is_key_held(ST3D_KEY_DOWN))  cam_rot.x -= speed * dt;

	// zoom,
	TrVec2f scroll = st3d_mouse_scroll();
	if (scroll.y > 0) {
		view /= 1.25;
	}
	else if (scroll.y < 0) {
		view *= 1.25;
	}

	st3d_set_camera((St3dCamera){
		// position is in the middle
		.position = (TrVec3f){-6, 8, 8},
		.rotation = cam_rot,
		.view = view,
		// ??
		.near = -10000,
		.far = 10000,
		.perspective = false,
	});

	if (st3d_is_key_just_pressed(ST3D_KEY_F1)) {
		wireframe = !wireframe;
		st3d_set_wireframe(wireframe);
	}
}

TrVec3f selection_pos;

static void model_controller(void)
{
	if (saving || loading) return;

	if (st3d_is_key_just_pressed(ST3D_KEY_W))          selection_pos.z -= 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_A))          selection_pos.x -= 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_S))          selection_pos.z += 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_D))          selection_pos.x += 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_LEFT_SHIFT)) selection_pos.y -= 1;
	if (st3d_is_key_just_pressed(ST3D_KEY_SPACE))      selection_pos.y += 1;

	// TODO we should probably be able to change the dimensions
	selection_pos.x = tr_clamp(selection_pos.x, 0, 15);
	selection_pos.y = tr_clamp(selection_pos.y, 0, 15);
	selection_pos.z = tr_clamp(selection_pos.z, 0, 15);

	// stigma
	if (st3d_is_mouse_just_pressed(ST3D_MOUSE_BUTTON_LEFT)) {
		*ST3D_AT3D(cubes, TrColor, 16, 16, selection_pos.x, selection_pos.y, selection_pos.z) = TR_WHITE;
	}

	if (st3d_is_mouse_just_pressed(ST3D_MOUSE_BUTTON_RIGHT)) {
		*ST3D_AT3D(cubes, TrColor, 16, 16, selection_pos.x, selection_pos.y, selection_pos.z) = TR_TRANSPARENT;
	}

	// help.
	if (ui_visible) {
		el_cubo.material.color = TR_WHITE;
		// i love hacking my own renderer
		glDisable(GL_DEPTH_TEST);
		glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_ZERO);
		st3d_mesh_draw_3d(el_cubo, selection_pos, (TrVec3f){0, 0, 0});
		glEnable(GL_DEPTH_TEST);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}
}

static void main_ui(void)
{
	if (!ui_visible) return;
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
		snprintf(fucky1, sizeof(fucky1), "view: %f", view);
		snprintf(fucky2, sizeof(fucky2), "rotation: %.2f %.2f %.2f", cam_rot.x, cam_rot.y, cam_rot.z);
		snprintf(fucky3, sizeof(fucky3), "selection: %.0f %.0f %.0f", selection_pos.x, selection_pos.y, selection_pos.z);
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
	if (!ui_visible) return;

	// sir
	for (size_t i = 0; i < 16; i++) {
		el_cubo.material.color = ST3D_SELECTION_COLOR;
		st3d_mesh_draw_3d(el_cubo, (TrVec3f){i, 0, 0}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(el_cubo, (TrVec3f){i, 15, 0}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(el_cubo, (TrVec3f){i, 0, 15}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, i, 0}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, i, 15}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(el_cubo, (TrVec3f){15, i, 0}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, 0, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, 0, i}, (TrVec3f){0, 0, 0});
		st3d_mesh_draw_3d(el_cubo, (TrVec3f){15, 0, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){15, 15, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){0, 15, i}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){15, i, 15}, (TrVec3f){0, 0, 0});
		// st3d_mesh_draw_3d(el_cubo, (TrVec3f){i, 15, 15}, (TrVec3f){0, 0, 0});
	}
}

static TrVec3f sel_start;
static TrVec3f sel_end;
static bool selecting;

static void selection_thing(void)
{
	if (!ui_visible) return;

	if (st3d_is_key_just_pressed(ST3D_KEY_M)) {
		selecting = true;
		sel_start = selection_pos;
	}

	if (st3d_is_key_just_pressed(ST3D_KEY_C)) {
		selecting = false;
		sel_start = (TrVec3f){0, 0, 0};
		sel_end = (TrVec3f){0, 0, 0};
	}

	if (selecting) {
		sel_end = selection_pos;
	}

	// fucking hell
	size_t x_start = sel_start.x < sel_end.x ? sel_start.x : sel_end.x;
	size_t x_end   = sel_start.x > sel_end.x ? sel_start.x : sel_end.x;
	size_t y_start = sel_start.y < sel_end.y ? sel_start.y : sel_end.y;
	size_t y_end   = sel_start.y > sel_end.y ? sel_start.y : sel_end.y;
	size_t z_start = sel_start.z < sel_end.z ? sel_start.z : sel_end.z;
	size_t z_end   = sel_start.z > sel_end.z ? sel_start.z : sel_end.z;

	// preview selection
	for (size_t x = x_start; x <= x_end; x++) {
		for (size_t y = y_start; y <= y_end; y++) {
			for (size_t z = z_start; z <= z_end; z++) {
				el_cubo.material.color = ST3D_SELECTION_COLOR;
				st3d_mesh_draw_3d(el_cubo, (TrVec3f){x, y, z}, (TrVec3f){0, 0, 0});
			}
		}
	}

	// fill :)
	if (st3d_is_key_just_pressed(ST3D_KEY_INSERT)) {
		for (size_t x = x_start; x <= x_end; x++) {
			for (size_t y = y_start; y <= y_end; y++) {
				for (size_t z = z_start; z <= z_end; z++) {
					*ST3D_AT3D(cubes, TrColor, 16, 16, x, y, z) = TR_WHITE;
				}
			}
		}

		selecting = false;
		sel_start = (TrVec3f){0, 0, 0};
		sel_end = (TrVec3f){0, 0, 0};
	}

	// delete :)
	if (st3d_is_key_just_pressed(ST3D_KEY_DELETE)) {
		for (size_t x = x_start; x <= x_end; x++) {
			for (size_t y = y_start; y <= y_end; y++) {
				for (size_t z = z_start; z <= z_end; z++) {
					*ST3D_AT3D(cubes, TrColor, 16, 16, x, y, z) = TR_TRANSPARENT;
				}
			}
		}

		selecting = false;
		sel_start = (TrVec3f){0, 0, 0};
		sel_end = (TrVec3f){0, 0, 0};
	}
}

static char save_path[256];
static bool saving_fucked;

static void saver_5000(void)
{
	bool savingfrfrfr = false;

	if (st3d_is_key_just_pressed(ST3D_KEY_F12)) {
		saving = !saving;
		// hide the ui while saving bcuz why not
		ui_visible = !ui_visible;
	}
	if (!saving) return;

	struct nk_context* ctx = st3d_nkctx();

	// dear god
	if (saving_fucked) {
		if (nk_begin(ctx, "Jankler has encountered an inconvenience", nk_rect(100, 100, 400, 200),
		NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
			nk_layout_row_dynamic(ctx, 20, 1);
			nk_label(ctx, "Couldn't save file.", NK_TEXT_ALIGN_LEFT);

			if (nk_button_label(ctx, "oh ok")) {
				saving = false;
				ui_visible = true;
				saving_fucked = false;
			}
		}
		nk_end(ctx);
		return;
	}

	if (nk_begin(ctx, "Jankler Save", nk_rect(100, 100, 400, 200),
	NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
		nk_layout_row_dynamic(ctx, 28, 1);
		nk_label(ctx, "Save as:", NK_TEXT_ALIGN_LEFT);

		nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, save_path, sizeof(save_path) - 1, nk_filter_default);

		if (nk_button_label(ctx, "Save")) {
			// don't want to put that logic under 3 levels of indentation
			savingfrfrfr = true;
		}

		if (nk_button_label(ctx, "Cancel")) {
			saving = false;
			ui_visible = true;
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
	for (size_t i = 0; i < cubes.length; i++) {
		TrColor lecolour = *TR_AT(cubes, TrColor, i);
		if (lecolour.a != 0) len++;
	}

	// now actually get the shit & the fuck
	TrArena tmp = tr_arena_new(len * sizeof(St3dPackedVoxel));
	TrSlice voxelsma = tr_slice_new(&tmp, len, sizeof(St3dPackedVoxel));
	size_t i = 0;
	for (size_t x = 0; x < 16; x++) {
		for (size_t y = 0; y < 16; y++) {
			for (size_t z = 0; z < 16; z++) {
				TrColor lecolour = *ST3D_AT3D(cubes, TrColor, 16, 16, x, y, z);
				if (lecolour.a != 0) {
					*TR_AT(voxelsma, St3dPackedVoxel, i) = (St3dPackedVoxel){
						.x = x,
						.y = y,
						.z = z,
						// TODO palette
						.color = 2,
					};
					i++;
				}
			}
		}
	}

	// save deez
	model.voxels = voxelsma;
	bool success = st3d_stvox_save(model, save_path);
	if (!success) {
		saving_fucked = true;
	}
	else {
		// we're still saving
		// but we're done now so stop
		saving = false;
		ui_visible = true;
	}

	tr_arena_free(&tmp);
}

static char load_path[256];
static bool loading_fucked;

static void loader_5000(void)
{
	bool loadingfrfrfr = false;

	if (st3d_is_key_just_pressed(ST3D_KEY_F11)) {
		loading = !loading;
		// hide the ui while saving bcuz why not
		ui_visible = !ui_visible;
	}
	if (!loading) return;

	struct nk_context* ctx = st3d_nkctx();

	// dear god
	if (loading_fucked) {
		if (nk_begin(ctx, "Jankler has encountered an inconvenience", nk_rect(100, 100, 400, 200),
		NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
			nk_layout_row_dynamic(ctx, 20, 1);
			nk_label(ctx, "Couldn't load file.", NK_TEXT_ALIGN_LEFT);

			if (nk_button_label(ctx, "oh ok")) {
				loading = false;
				ui_visible = true;
				loading_fucked = false;
			}
		}
		nk_end(ctx);
		return;
	}

	if (nk_begin(ctx, "Jankler Load", nk_rect(100, 100, 400, 200),
	NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
		nk_layout_row_dynamic(ctx, 28, 1);
		nk_label(ctx, "Load from:", NK_TEXT_ALIGN_LEFT);

		nk_edit_string_zero_terminated(ctx, NK_EDIT_FIELD, load_path, sizeof(load_path) - 1, nk_filter_default);

		if (nk_button_label(ctx, "Open")) {
			// don't want to put that logic under 3 levels of indentation
			loadingfrfrfr = true;
		}

		if (nk_button_label(ctx, "Cancel")) {
			loading = false;
			ui_visible = true;
		}
	}
	nk_end(ctx);

	if (!loadingfrfrfr) return;

	// actual loading
	TrArena tmp = tr_arena_new(TR_MB(1));
	St3dVoxModel model;
	bool success = st3d_stvox_load(&tmp, load_path, &model);

	if (!success) {
		loading_fucked = true;
	}
	else {
		// put that into the fucking slice we have
		for (size_t i = 0; i < model.voxels.length; i++) {
			St3dPackedVoxel yea = *TR_AT(model.voxels, St3dPackedVoxel, i);
			// TODO palette
			*ST3D_AT3D(cubes, TrColor, 16, 16, yea.x, yea.y, yea.z) = TR_WHITE;
		}

		loading = false;
		ui_visible = true;
	}

	tr_arena_free(&tmp);
}
