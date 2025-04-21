#include <stdio.h>
#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>

static void player_controller(void);
static void main_ui(void);

int main(void)
{
	st3d_init("jankler", "assets", 800, 600);
	TrArena arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_float vertices;
	TR_SET_SLICE(&arena, &vertices, float,
		-0.5f, -0.5f,  0.5f,  1,1,1,1,  0.0f, 0.0f,
		 0.5f, -0.5f,  0.5f,  1,1,1,1,  1.0f, 0.0f,
		 0.5f,  0.5f,  0.5f,  1,1,1,1,  1.0f, 1.0f,
		-0.5f,  0.5f,  0.5f,  1,1,1,1,  0.0f, 1.0f,

		 0.5f, -0.5f, -0.5f,  1,1,1,1,  0.0f, 0.0f,
		-0.5f, -0.5f, -0.5f,  1,1,1,1,  1.0f, 0.0f,
		-0.5f,  0.5f, -0.5f,  1,1,1,1,  1.0f, 1.0f,
		 0.5f,  0.5f, -0.5f,  1,1,1,1,  0.0f, 1.0f,

		-0.5f, -0.5f, -0.5f,  1,1,1,1,  0.0f, 0.0f,
		-0.5f, -0.5f,  0.5f,  1,1,1,1,  1.0f, 0.0f,
		-0.5f,  0.5f,  0.5f,  1,1,1,1,  1.0f, 1.0f,
		-0.5f,  0.5f, -0.5f,  1,1,1,1,  0.0f, 1.0f,

		 0.5f, -0.5f,  0.5f,  1,1,1,1,  0.0f, 0.0f,
		 0.5f, -0.5f, -0.5f,  1,1,1,1,  1.0f, 0.0f,
		 0.5f,  0.5f, -0.5f,  1,1,1,1,  1.0f, 1.0f,
		 0.5f,  0.5f,  0.5f,  1,1,1,1,  0.0f, 1.0f,

		-0.5f,  0.5f,  0.5f,  1,1,1,1,  0.0f, 0.0f,
		 0.5f,  0.5f,  0.5f,  1,1,1,1,  1.0f, 0.0f,
		 0.5f,  0.5f, -0.5f,  1,1,1,1,  1.0f, 1.0f,
		-0.5f,  0.5f, -0.5f,  1,1,1,1,  0.0f, 1.0f,

		-0.5f, -0.5f, -0.5f,  1,1,1,1,  0.0f, 0.0f,
		 0.5f, -0.5f, -0.5f,  1,1,1,1,  1.0f, 0.0f,
		 0.5f, -0.5f,  0.5f,  1,1,1,1,  1.0f, 1.0f,
		-0.5f, -0.5f,  0.5f,  1,1,1,1,  0.0f, 1.0f
	);

	// TODO for individual faces, just reuse the vert slice and only add more slices for indices
	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		// front
		0,  1,  2,    2,  3,  0,
		// back
		4,  5,  6,    6,  7,  4,
		// left
		8,  9,  10,   10, 11, 8,
		// right
		12, 13, 14,   14, 15, 12,
		// top
		16, 17, 18,   18, 19, 16,
		// bottom
		20, 21, 22,   22, 23, 20
	);

	St3dMesh mtriranfgs = st3d_mesh_new(&vertices, &indices, true);
	mtriranfgs.texture = st3d_texture_new("app:enough_fckery.jpg");
	// st3d_set_wireframe(true);

	st3d_ui_new("app:figtree/Figtree-Medium.ttf", 16);

	while (!st3d_is_closing()) {
		st3d_begin_drawing(TR_WHITE);

		st3d_mesh_draw_3d(mtriranfgs, (TrVec3f){0, 0, 0}, (TrVec3f){0, 0, 0}, tr_hex_rgb(0x550877));

		// nuklear calls go inside here
		st3d_ui_begin();
			main_ui();
		st3d_ui_end();

		player_controller();

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(mtriranfgs.texture);
	st3d_mesh_free(mtriranfgs);
	st3d_free();
}

const double speed = 50;
static TrVec3f cam_rot;
static double view = 10;

static void player_controller(void)
{
	double dt = st3d_delta_time();

	if (st3d_is_key_held(ST3D_KEY_LEFT))  cam_rot.y += speed * dt;
	if (st3d_is_key_held(ST3D_KEY_RIGHT)) cam_rot.y -= speed * dt;
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
		.position = (TrVec3f){0, 0, 0},
		.rotation = cam_rot,
		.view = view,
		// ??
		.near = -1,
		.far = 10000,
		.perspective = false,
	});
}

static void main_ui(void)
{
	struct nk_context* ctx = st3d_nkctx();

	if (nk_begin(ctx, "JanklerTM Pro v0.1.0", nk_rect(25, 325, 300, 250),
	NK_WINDOW_BORDER | NK_WINDOW_MOVABLE | NK_WINDOW_TITLE | NK_WINDOW_SCALABLE)) {
		nk_layout_row_dynamic(ctx, 20, 1);
		nk_label(ctx, "Advanced Voxel Modelling Software", NK_TEXT_ALIGN_CENTERED);

		struct nk_color istg = {255, 255, 255, 255};
		nk_label_colored(ctx, "Camera", NK_TEXT_ALIGN_CENTERED, istg);

		// man
		char fucky1[64];
		char fucky2[64];
		snprintf(fucky1, sizeof(fucky1), "view: %f", view);
		snprintf(fucky2, sizeof(fucky2), "rotation: %.2f %.2f %.2f", cam_rot.x, cam_rot.y, cam_rot.z);
		nk_label(ctx, fucky1, NK_TEXT_ALIGN_LEFT);
		nk_label(ctx, fucky2, NK_TEXT_ALIGN_LEFT);
	}
	nk_end(ctx);
}
