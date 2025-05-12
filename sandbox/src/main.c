#include <libtrippin.h>
#include <starry3d.h>

// used for the sliders :D
static float st_pos_x;
static float st_pos_y;
static float st_pos_z = 5;

static float st_rot_x;
static float st_rot_y;
static float st_rot_z;

static void camera_ui(void)
{
	struct nk_context* ctx = st_nkctx();

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
	tr_init("log.txt");
	st_init((StSettings){
		.app_name = "sandbox",
		.asset_dir = "assets",
		.resizable = true,
		.window_width = 800,
		.window_height = 600,
	});
	st_ui_new("app:figtree/Figtree-Medium.ttf", 16);

	TrArena arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_float vertices;
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

	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		0, 2, 1, 0, 3, 2,
		4, 6, 5, 4, 7, 6,
		8, 10, 9, 8, 11, 10,
		12, 14, 13, 12, 15, 14,
		16, 18, 17, 16, 19, 18,
		20, 22, 21, 20, 23, 22,
	);

	StMesh mtriranfgs = st_mesh_new(&vertices, &indices, true);
	mtriranfgs.material.color = tr_hex_rgb(0xffff00);
	// mtriranfgs.texture = st_texture_new("app:enough_fckery.jpg");
	// st_set_wireframe(true);

	st_set_environment((StEnvironment){
		.sky_color = tr_hex_rgb(0x03a9f4),
		.ambient_color = tr_hex_rgb(0xaaaaaa),
		.sun = {
			.direction = {0.5, 1.0, -0.75},
			.color = TR_WHITE,
		},
	});

	bool ui = true;
	while (!st_is_closing()) {
		st_begin_drawing();

		st_mesh_draw_3d(mtriranfgs, (TrVec3f){0, 0, 0}, (TrVec3f){64, 65, 0});

		if (st_is_key_just_pressed(ST_KEY_ESCAPE)) {
			ui = !ui;
			st_set_mouse_enabled(ui);
		}
		// TrVec2f pee = st_mouse_position();
		// tr_log("sjgs %f %f", pee.x, pee.y);

		// nuklear calls go inside here
		if (ui) {
			st_ui_begin();
			camera_ui();
			st_ui_end();
		}

		st_set_camera((StCamera){
			.position = (TrVec3f){st_pos_x, st_pos_y, st_pos_z},
			.rotation = (TrVec3f){st_rot_x, st_rot_y, st_rot_z},
			.view = 90,
			.near = 0.01,
			.far = 1000,
			.perspective = true,
		});

		st_end_drawing();
		st_poll_events();
	}

	st_ui_free();

	st_texture_free(mtriranfgs.texture);
	st_mesh_free(mtriranfgs);
	st_free();
	tr_arena_free(&arena);
	tr_free();
}
