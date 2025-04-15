#include <stdio.h>
#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>

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
		struct nk_colorf bg = {0.10f, 0.18f, 0.24f, 1.0f};
		struct nk_context* ctx = st3d_nkctx();
		if (nk_begin(ctx, "Demo", nk_rect(50, 50, 230, 250),
		NK_WINDOW_BORDER|NK_WINDOW_MOVABLE|NK_WINDOW_SCALABLE|
		NK_WINDOW_MINIMIZABLE|NK_WINDOW_TITLE))
		{
			enum {EASY, HARD};
			static int op = EASY;
			static int property = 20;
			nk_layout_row_static(ctx, 30, 80, 1);
			if (nk_button_label(ctx, "button"))
				fprintf(stdout, "button pressed\n");

			nk_layout_row_dynamic(ctx, 30, 2);
			if (nk_option_label(ctx, "easy", op == EASY)) op = EASY;
			if (nk_option_label(ctx, "hard", op == HARD)) op = HARD;

			nk_layout_row_dynamic(ctx, 25, 1);
			nk_property_int(ctx, "Compression:", 0, &property, 100, 10, 1);

			nk_layout_row_dynamic(ctx, 20, 1);
			nk_label(ctx, "background:", NK_TEXT_LEFT);
			nk_layout_row_dynamic(ctx, 25, 1);
			if (nk_combo_begin_color(ctx, nk_rgb_cf(bg), nk_vec2(nk_widget_width(ctx),400))) {
				nk_layout_row_dynamic(ctx, 120, 1);
				bg = nk_color_picker(ctx, bg, NK_RGBA);
				nk_layout_row_dynamic(ctx, 25, 1);
				bg.r = nk_propertyf(ctx, "#R:", 0, bg.r, 1.0f, 0.01f,0.005f);
				bg.g = nk_propertyf(ctx, "#G:", 0, bg.g, 1.0f, 0.01f,0.005f);
				bg.b = nk_propertyf(ctx, "#B:", 0, bg.b, 1.0f, 0.01f,0.005f);
				bg.a = nk_propertyf(ctx, "#A:", 0, bg.a, 1.0f, 0.01f,0.005f);
				nk_combo_end(ctx);
			}
		}

		nk_end(ctx);
		st3d_ui_end();

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(mtriranfgs.texture);
	st3d_mesh_free(mtriranfgs);
	st3d_free();
}
