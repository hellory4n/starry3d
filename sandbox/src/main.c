#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>
#include <st3d_voxel.h>

// used for the sliders :D
static float st_pos_x;
static float st_pos_y;
static float st_pos_z = 3;

static float st_rot_x;
static float st_rot_y;
static float st_rot_z;

static void camera_ui(void) {
	struct nk_context* ctx = st3d_nkctx();

	if (nk_begin(ctx, "debug", nk_rect(25, 350, 300, 250),
	NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE)) {
		nk_layout_row_dynamic(ctx, 20, 1);
		nk_label(ctx, "position", NK_TEXT_ALIGN_LEFT);

		nk_layout_row_dynamic(ctx, 20, 2);
		nk_label(ctx, "x:", NK_TEXT_ALIGN_LEFT);
		nk_slider_float(ctx, -10, &st_pos_x, 10, 0.01);

		nk_layout_row_dynamic(ctx, 20, 2);
		nk_label(ctx, "y:", NK_TEXT_ALIGN_LEFT);
		nk_slider_float(ctx, -10, &st_pos_y, 10, 0.01);

		nk_layout_row_dynamic(ctx, 20, 2);
		nk_label(ctx, "z:", NK_TEXT_ALIGN_LEFT);
		nk_slider_float(ctx, -10, &st_pos_z, 10, 0.01);

		nk_layout_row_dynamic(ctx, 20, 1);
		nk_label(ctx, "rotation", NK_TEXT_ALIGN_LEFT);

		nk_layout_row_dynamic(ctx, 20, 2);
		nk_label(ctx, "x:", NK_TEXT_ALIGN_LEFT);
		nk_slider_float(ctx, 0, &st_rot_x, 360, 0.01);

		nk_layout_row_dynamic(ctx, 20, 2);
		nk_label(ctx, "y:", NK_TEXT_ALIGN_LEFT);
		nk_slider_float(ctx, 0, &st_rot_y, 360, 0.01);

		nk_layout_row_dynamic(ctx, 20, 2);
		nk_label(ctx, "z:", NK_TEXT_ALIGN_LEFT);
		nk_slider_float(ctx, 0, &st_rot_z, 360, 0.01);
	}
	nk_end(ctx);
}

int main(void)
{
	st3d_init("sandbox", "assets", 800, 600);
	TrArena arena = tr_arena_new(TR_MB(1));

	St3dPalette sir;
	TR_SET_SLICE(&arena, &sir, TrColor,
		TR_TRANSPARENT,
		tr_hex_rgb(0x0e141f),
		tr_hex_rgb(0x273445),
		tr_hex_rgb(0x485a6c),
		tr_hex_rgb(0x667885),
		tr_hex_rgb(0x95a3ab),

		tr_hex_rgb(0x555761),
		tr_hex_rgb(0x7e8087),
		tr_hex_rgb(0xabacae),
		tr_hex_rgb(0xd4d4d4),
		tr_hex_rgb(0xfafafa),

		tr_hex_rgb(0x7a0000),
		tr_hex_rgb(0xa10705),
		tr_hex_rgb(0xc6262e),
		tr_hex_rgb(0xed5353),
		tr_hex_rgb(0xff8c82),

		tr_hex_rgb(0xa62100),
		tr_hex_rgb(0xcc3b02),
		tr_hex_rgb(0xf37329),
		tr_hex_rgb(0xffa154),
		tr_hex_rgb(0xffc27d),

		tr_hex_rgb(0xad5f00),
		tr_hex_rgb(0xd48e15),
		tr_hex_rgb(0xf9c440),
		tr_hex_rgb(0xffe16b),
		tr_hex_rgb(0xfff394),

		tr_hex_rgb(0x206b00),
		tr_hex_rgb(0x3a9104),
		tr_hex_rgb(0x68b723),
		tr_hex_rgb(0x9bdb4d),
		tr_hex_rgb(0xd1ff82),

		tr_hex_rgb(0x007367),
		tr_hex_rgb(0x0e9a83),
		tr_hex_rgb(0x28bca3),
		tr_hex_rgb(0x43d6b5),
		tr_hex_rgb(0x89ffdd),

		tr_hex_rgb(0x002e99),
		tr_hex_rgb(0x0d52bf),
		tr_hex_rgb(0x3689e6),
		tr_hex_rgb(0x64baff),
		tr_hex_rgb(0x8cd5ff),

		tr_hex_rgb(0x452981),
		tr_hex_rgb(0x7239b3),
		tr_hex_rgb(0xa56de2),
		tr_hex_rgb(0xcd9ef7),
		tr_hex_rgb(0xe4c6fa),

		tr_hex_rgb(0x910e38),
		tr_hex_rgb(0xbc245d),
		tr_hex_rgb(0xde3e80),
		tr_hex_rgb(0xf4679d),
		tr_hex_rgb(0xfe9ab8),

		tr_hex_rgb(0x804b00),
		tr_hex_rgb(0xb6802e),
		tr_hex_rgb(0xcfa25e),
		tr_hex_rgb(0xe7c591),
		tr_hex_rgb(0xefdfc4),

		tr_hex_rgb(0x3d211b),
		tr_hex_rgb(0x57392d),
		tr_hex_rgb(0x715344),
		tr_hex_rgb(0x8a715e),
		tr_hex_rgb(0xa3907c),
	);
	st3d_stpal_save(sir, "default.stpal");
	return 0;

	// ttriangel
	TrSlice_float vertices;
	TR_SET_SLICE(&arena, &vertices, float,
		// vertices             // colors                  // texcoords
		-1.0f, -1.0f,  1.0f,    1.0f, 1.0f, 1.0f, 1.0f,    0.0f, 0.0f,
		 1.0f, -1.0f,  1.0f,    1.0f, 1.0f, 1.0f, 1.0f,    1.0f, 0.0f,
	     1.0f,  1.0f, -1.0f,    1.0f, 1.0f, 1.0f, 0.0f,    1.0f, 1.0f,
		-1.0f,  1.0f, -1.0f,    1.0f, 1.0f, 1.0f, 0.0f,    0.0f, 1.0f,
	);

	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		0, 1, 2,
		0, 2, 3,
	);

	St3dMesh mtriranfgs = st3d_mesh_new(&vertices, &indices, true);
	mtriranfgs.texture = st3d_texture_new("app:enough_fckery.jpg");
	// st3d_set_wireframe(true);

	// st3d_set_camera_fov(80);
	// st3d_set_camera_near_far(0.01, 1000);
	// st3d_set_camera_position((TrVec3f){0, 0, -3});
	// st3d_set_camera_rotation((TrRotation){-55, 0, 0});

	st3d_ui_new("app:figtree/Figtree-Medium.ttf", 16);
	bool ui = true;

	while (!st3d_is_closing()) {
		st3d_begin_drawing();

		st3d_mesh_draw_3d(mtriranfgs, (TrVec3f){0, 0, 0}, (TrVec3f){64, 65, 62});

		if (st3d_is_key_just_pressed(ST3D_KEY_ESCAPE)) {
			ui = !ui;
			st3d_set_mouse_enabled(ui);
		}
		TrVec2f pee = st3d_mouse_position();
		tr_log("sjgs %f %f", pee.x, pee.y);

		// nuklear calls go inside here
		if (ui) {
			st3d_ui_begin();
			camera_ui();
			st3d_ui_end();
		}

		st3d_set_camera((St3dCamera){
			.position = (TrVec3f){st_pos_x, st_pos_y, st_pos_z},
			.rotation = (TrVec3f){st_rot_x, st_rot_y, st_rot_z},
			.view = 90,
			.near = 0.01,
			.far = 1000,
		});

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(mtriranfgs.texture);
	st3d_mesh_free(mtriranfgs);
	st3d_free();
}
