#include <glad/gl.h>
#include <stdio.h>
#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>

#define ST3D_SELECTION_COLOR tr_hex_rgba(0xffffff77)

static void camera_controller(void);
static void model_controller(void);
static void main_ui(void);

static St3dMesh el_cubo;

int main(void)
{
	st3d_init("jankler", "assets", 800, 600);
	st3d_ui_new("app:figtree/Figtree-Medium.ttf", 16);
	TrArena arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_float vertices;
	// dear god
	TR_SET_SLICE(&arena, &vertices, float,
		-1.000000,  1.000000, -1.000000,  -0.000000,  1.000000, -0.000000,  0.875000, 0.500000,
		1.000000,  1.000000,  1.000000,  -0.000000,  1.000000, -0.000000,  0.625000, 0.750000,
		1.000000,  1.000000, -1.000000,  -0.000000,  1.000000, -0.000000,  0.625000, 0.500000,
		1.000000,  1.000000,  1.000000,  -0.000000, -0.000000,  1.000000,  0.625000, 0.750000,
		-1.000000, -1.000000,  1.000000,  -0.000000, -0.000000,  1.000000,  0.375000, 1.000000,
		1.000000, -1.000000,  1.000000,  -0.000000, -0.000000,  1.000000,  0.375000, 0.750000,
		-1.000000,  1.000000,  1.000000,  -1.000000, -0.000000, -0.000000,  0.625000, 0.000000,
		-1.000000, -1.000000, -1.000000,  -1.000000, -0.000000, -0.000000,  0.375000, 0.250000,
		-1.000000, -1.000000,  1.000000,  -1.000000, -0.000000, -0.000000,  0.375000, 0.000000,
		1.000000, -1.000000, -1.000000,  -0.000000, -1.000000, -0.000000,  0.375000, 0.500000,
		-1.000000, -1.000000,  1.000000,  -0.000000, -1.000000, -0.000000,  0.125000, 0.750000,
		-1.000000, -1.000000, -1.000000,  -0.000000, -1.000000, -0.000000,  0.125000, 0.500000,
		1.000000,  1.000000, -1.000000,   1.000000, -0.000000,  0.000000,  0.625000, 0.500000,
		1.000000, -1.000000,  1.000000,   1.000000, -0.000000,  0.000000,  0.375000, 0.750000,
		1.000000, -1.000000, -1.000000,   1.000000, -0.000000,  0.000000,  0.375000, 0.500000,
		-1.000000,  1.000000, -1.000000,  -0.000000, -0.000000, -1.000000,  0.625000, 0.250000,
		1.000000, -1.000000, -1.000000,  -0.000000, -0.000000, -1.000000,  0.375000, 0.500000,
		-1.000000, -1.000000, -1.000000,  -0.000000, -0.000000, -1.000000,  0.375000, 0.250000,
		-1.000000,  1.000000,  1.000000,  -0.000000,  1.000000, -0.000000,  0.875000, 0.750000,
		-1.000000,  1.000000,  1.000000,  -0.000000, -0.000000,  1.000000,  0.625000, 1.000000,
		-1.000000,  1.000000, -1.000000,  -1.000000, -0.000000, -0.000000,  0.625000, 0.250000,
		1.000000, -1.000000,  1.000000,  -0.000000, -1.000000, -0.000000,  0.375000, 0.750000,
		1.000000,  1.000000,  1.000000,   1.000000, -0.000000,  0.000000,  0.625000, 0.750000,
		1.000000,  1.000000, -1.000000,  -0.000000, -0.000000, -1.000000,  0.625000, 0.500000,
	);

	// TODO for individual faces, just reuse the vert slice and only add more slices for indices
	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		0,  1,  2,   3,  4,  5,   6,  7,  8,   9, 10, 11,
		12, 13, 14,  15, 16, 17,   0, 18,  1,   3, 19,  4,
		6, 20,  7,  9, 21, 10,  12, 22, 13,  15, 23, 16
	);

	el_cubo = st3d_mesh_new(&vertices, &indices, true);
	el_cubo.material.color = tr_hex_rgb(0xffff00);
	// el_cubo.texture = st3d_texture_new("app:enough_fckery.jpg");
	// st3d_set_wireframe(true);

	st3d_set_environment((St3dEnvironment){
		.sky_color = tr_hex_rgb(0x03A9F4),
		.sun_color = TR_WHITE,
	});

	while (!st3d_is_closing()) {
		st3d_begin_drawing();

		for (size_t x = 0; x < 16; x++) {
			for (size_t y = 0; y < 16; y++) {
				for (size_t z = 0; z < 16; z++) {
					st3d_mesh_draw_3d(el_cubo, (TrVec3f){x, y, z}, (TrVec3f){0, 0, 0});
				}
			}
		}

		camera_controller();
		model_controller();

		// nuklear calls go inside here
		st3d_ui_begin();
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

const double speed_ish = 45.0 / 2;
static TrVec3f cam_rot = {-speed_ish, speed_ish, 0};
static double view = 10;

static void camera_controller(void)
{
	// double dt = st3d_delta_time();

	if (st3d_is_key_just_pressed(ST3D_KEY_LEFT))  cam_rot.y += speed_ish;
	if (st3d_is_key_just_pressed(ST3D_KEY_RIGHT)) cam_rot.y -= speed_ish;
	if (st3d_is_key_just_pressed(ST3D_KEY_UP))    cam_rot.x += speed_ish;
	if (st3d_is_key_just_pressed(ST3D_KEY_DOWN))  cam_rot.x -= speed_ish;

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
		.position = (TrVec3f){8, 8, 8},
		.rotation = cam_rot,
		.view = view,
		// ??
		.near = -10000,
		.far = 10000,
		.perspective = false,
	});
}

TrVec3f selection_pos;

static void model_controller(void)
{
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

	// help.
	// st3d_set_wireframe(true);
	// el_cubo.material.color = ST3D_SELECTION_COLOR;
	// st3d_mesh_draw_3d(el_cubo, selection_pos, (TrVec3f){0, 0, 0});
	// el_cubo.material.color = TR_WHITE;
	// st3d_set_wireframe(false);
}

static void main_ui(void)
{
	struct nk_context* ctx = st3d_nkctx();

	if (nk_begin(ctx, "JanklerTM Pro v0.1.0", nk_rect(25, 325, 300, 250),
	NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE | NK_WINDOW_SCALABLE)) {
		nk_layout_row_dynamic(ctx, 20, 1);
		nk_label(ctx, "Advanced Voxel Modelling Software", NK_TEXT_ALIGN_CENTERED);

		struct nk_color istg = {255, 255, 255, 255};
		nk_label_colored(ctx, "How To Use This Disaster", NK_TEXT_ALIGN_CENTERED, istg);
		nk_label(ctx, "scroll to zoom", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "arrow keys to rotate", NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, "wasd and shift or space to select", NK_TEXT_ALIGN_LEFT);

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
