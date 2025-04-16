#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>

// used for the sliders :D
static float st_pos_x;
static float st_pos_y;
static float st_pos_z;

static float st_rot_x;
static float st_rot_y;
static float st_rot_z;

static void camera_ui(void) {
	struct nk_context* ctx = st3d_nkctx();

	if (nk_begin(ctx, "camera test", nk_rect(25, 350, 300, 250),
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

	// ttriangel
	TrSlice_float vertices;
	TR_SET_SLICE(&arena, &vertices, float,
		// vertices                // colors                  // texcoords
	     100.0f,  100.0f, 0.0f,    1.0f, 1.0f, 1.0f, 0.0f,    1.0f, 1.0f,
		 100.0f, -100.0f, 0.0f,    1.0f, 1.0f, 1.0f, 1.0f,    1.0f, 0.0f,
		-100.0f, -100.0f, 0.0f,    1.0f, 1.0f, 1.0f, 1.0f,    0.0f, 0.0f,
		-100.0f,  100.0f, 0.0f,    1.0f, 1.0f, 1.0f, 0.0f,    0.0f, 1.0f,
	);

	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		0, 1, 2,
		0, 2, 3,
	);

	St3dMesh mtriranfgs = st3d_mesh_new(&vertices, &indices, true);
	mtriranfgs.texture = st3d_texture_new("assets/enough_fckery.jpg");
	// st3d_set_wireframe(true);

	// st3d_set_camera_fov(80);
	// st3d_set_camera_near_far(0.01, 1000);
	// st3d_set_camera_position((TrVec3f){0, 0, -3});
	// st3d_set_camera_rotation((TrRotation){-55, 0, 0});

	st3d_ui_new("assets/figtree/Figtree-Medium.ttf", 16);

	while (!st3d_is_closing()) {
		st3d_begin_drawing(tr_hex_rgb(0x550877));

		st3d_mesh_draw_2d(mtriranfgs, (TrVec2f){200, 200});

		// nuklear calls go inside here
		st3d_ui_begin();
		camera_ui();
		st3d_ui_end();

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(mtriranfgs.texture);
	st3d_mesh_free(mtriranfgs);
	st3d_free();
}
