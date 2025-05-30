#include <stdio.h>
#include <libtrippin.h>
#include <starry3d.h>
#include <st_ui.h>
#include "camera.h"

static void sb_game_new(void);
static void sb_game_update(void);
static void sb_game_ui(void);
static void sb_game_free(void);

int main(void)
{
	tr_init("log.txt");
	st_init((StSettings){
		.app_name = "sandbox",
		.asset_dir = "assets",
		.resizable = true,
		.window_width = 800,
		.window_height = 600,
	});
	st_set_vsync(false);
	st_cull_face(ST_CULL_FACE_NONE);
	st_ui_new("app:figtree/Figtree-Medium.ttf", 16);

	st_set_environment((StEnvironment){
		.sky_color = tr_hex_rgb(0x03a9f4),
		.ambient_color = tr_hex_rgb(0xaaaaaa),
		.sun = {
			.direction = {0.5, 1.0, -0.75},
			.color = TR_WHITE,
		},
	});

	sb_game_new();

	while (!st_is_closing()) {
		st_begin_drawing();

		sb_game_update();
		st_vox_draw();

		// nuklear calls go inside here
		st_ui_begin();
			sb_game_ui();
		st_ui_end();

		st_end_drawing();
		st_poll_events();
	}

	sb_game_free();
	st_ui_free();
	st_free();
	tr_free();
}

static TrArena arena;
static StMesh mtriranfgs;

static void sb_sigma_callback(void)
{
	tr_log("Ligma!");
}

static void sb_game_new(void)
{
	arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_StVertex vertices;
	TR_SET_SLICE(&arena, &vertices, StVertex,
		{{-0.5f, -0.5f, +0.5f}, {0, 0, 1}, {0.0f, 0.0f}},
		{{+0.5f, -0.5f, +0.5f}, {0, 0, 1}, {1.0f, 0.0f}},
		{{+0.5f, +0.5f, +0.5f}, {0, 0, 1}, {1.0f, 1.0f}},
		{{-0.5f, +0.5f, +0.5f}, {0, 0, 1}, {0.0f, 1.0f}},

		{{+0.5f, -0.5f, -0.5f}, {0, 0,-1}, {0.0f, 0.0f}},
		{{-0.5f, -0.5f, -0.5f}, {0, 0,-1}, {1.0f, 0.0f}},
		{{-0.5f, +0.5f, -0.5f}, {0, 0,-1}, {1.0f, 1.0f}},
		{{+0.5f, +0.5f, -0.5f}, {0, 0,-1}, {0.0f, 1.0f}},

		{{-0.5f, -0.5f, -0.5f}, {-1, 0, 0}, {0.0f, 0.0f}},
		{{-0.5f, -0.5f, +0.5f}, {-1, 0, 0}, {1.0f, 0.0f}},
		{{-0.5f, +0.5f, +0.5f}, {-1, 0, 0}, {1.0f, 1.0f}},
		{{-0.5f, +0.5f, -0.5f}, {-1, 0, 0}, {0.0f, 1.0f}},

		{{+0.5f, -0.5f, +0.5f}, {1, 0, 0}, {0.0f, 0.0f}},
		{{+0.5f, -0.5f, -0.5f}, {1, 0, 0}, {1.0f, 0.0f}},
		{{+0.5f, +0.5f, -0.5f}, {1, 0, 0}, {1.0f, 1.0f}},
		{{+0.5f, +0.5f, +0.5f}, {1, 0, 0}, {0.0f, 1.0f}},

		{{-0.5f, +0.5f, +0.5f}, {0, 1, 0}, {0.0f, 0.0f}},
		{{+0.5f, +0.5f, +0.5f}, {0, 1, 0}, {1.0f, 0.0f}},
		{{+0.5f, +0.5f, -0.5f}, {0, 1, 0}, {1.0f, 1.0f}},
		{{-0.5f, +0.5f, -0.5f}, {0, 1, 0}, {0.0f, 1.0f}},

		{{-0.5f, -0.5f, -0.5f}, {0,-1, 0}, {0.0f, 0.0f}},
		{{+0.5f, -0.5f, -0.5f}, {0,-1, 0}, {1.0f, 0.0f}},
		{{+0.5f, -0.5f, +0.5f}, {0,-1, 0}, {1.0f, 1.0f}},
		{{-0.5f, -0.5f, +0.5f}, {0,-1, 0}, {0.0f, 1.0f}},
	);

	TrSlice_StTriangle indices;
	TR_SET_SLICE(&arena, &indices, StTriangle,
		{0, 2, 1}, {0, 3, 2},
		{4, 6, 5}, {4, 7, 6},
		{8, 10, 9}, {8, 11, 10},
		{12, 14, 13}, {12, 15, 14},
		{16, 18, 17}, {16, 19, 18},
		{20, 22, 21}, {20, 23, 22},
	);

	mtriranfgs = st_mesh_new(&vertices, &indices, true);
	mtriranfgs.material.color = tr_hex_rgb(0xffff00);
	// mtriranfgs.texture = st_texture_new("app:enough_fckery.jpg");

	st_set_palette("app:default.stpal");

	st_register_block(1, 0, "app:fuck.stvox");

	st_place_block(1, 0, (TrVec3i){1, 0, 0});

	StTimer* timer = st_timer_new(1, true, sb_sigma_callback);
	st_timer_start(timer);
}

static bool sb_ui = false;

static void sb_game_update(void)
{
	// bloody hell
	if (st_is_key_just_pressed(ST_KEY_ESCAPE)) {
		sb_ui = !sb_ui;
	}
	st_set_mouse_enabled(sb_ui);

	// the cube of horror is optional
	if (st_is_key_just_pressed(ST_KEY_F2)) {
		for (int64_t x = 0; x < 16; x++) {
			for (int64_t y = 0; y < 16; y++) {
				for (int64_t z = 0; z < 16; z++) {
					st_place_block(1, 0, (TrVec3i){x, y, z});
				}
			}
		}
	}
	if (st_is_key_just_pressed(ST_KEY_F3)) {
		for (int64_t x = 16; x < 32; x++) {
			for (int64_t y = 0; y < 16; y++) {
				for (int64_t z = 0; z < 16; z++) {
					st_place_block(1, 0, (TrVec3i){x, y, z});
				}
			}
		}
	}
	if (st_is_key_just_pressed(ST_KEY_F4)) {
		for (int64_t x = 32; x < 64; x++) {
			for (int64_t y = 0; y < 16; y++) {
				for (int64_t z = 0; z < 16; z++) {
					st_place_block(1, 0, (TrVec3i){x, y, z});
				}
			}
		}
	}

	st_mesh_draw_3d(mtriranfgs, (TrVec3f){-2, 0, -2}, (TrVec3f){0, 0, 0});
	sb_camera_update();
}

static void sb_game_free(void)
{
	st_mesh_free(mtriranfgs);
	tr_arena_free(&arena);
}

static bool sb_wireframe = false;

static void sb_game_ui(void)
{
	if (st_is_key_just_pressed(ST_KEY_F1)) {
		sb_wireframe = !sb_wireframe;
		st_set_wireframe(sb_wireframe);
	}

	struct nk_context* ctx = st_nkctx();
	if (nk_begin(ctx, "mate", nk_rect(0, 0, 200, 100), NK_WINDOW_BORDER)) {
		nk_layout_row_dynamic(ctx, 20, 1);

		char ihateyou[64];
		snprintf(ihateyou, sizeof(ihateyou), "fps: %.0f", st_fps());
		nk_label(ctx, ihateyou, NK_TEXT_ALIGN_LEFT);

		StCamera cam = st_camera();
		char ihateyoutoo[64];
		snprintf(ihateyoutoo, sizeof(ihateyoutoo), "position: %.3f %.3f %.3f", cam.position.x, cam.position.y, cam.position.z);
		nk_label(ctx, ihateyoutoo, NK_TEXT_ALIGN_LEFT);

		char ihateyoutootoo[64];
		snprintf(ihateyoutootoo, sizeof(ihateyoutoo), "chunk: %.0f %.0f %.0f", cam.position.x / 16, cam.position.y / 16, cam.position.z / 16);
		nk_label(ctx, ihateyoutootoo, NK_TEXT_ALIGN_LEFT);
	}
	nk_end(ctx);
}
