#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>
#include <st3d_voxel.h>

static void camera_shitfuck(void);

int main(void)
{
	st3d_init("sandbox", "assets", 800, 600);
	TrArena arena = tr_arena_new(TR_MB(1));

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
	st3d_set_palette("app:default.stpal");
	bool ui = true;

	st3d_set_environment((St3dEnvironment){
		.sky_color = tr_hex_rgb(0x03A9F4),
		.ambient_color = tr_hex_rgb(0xaaaaaa),
		.sun = {
			.direction = {0.5, 1.0, -0.75},
			.color = TR_WHITE,
		},
	});

	while (!st3d_is_closing()) {
		st3d_begin_drawing();

		st3d_mesh_draw_3d(mtriranfgs, (TrVec3f){0, 0, 0}, (TrVec3f){64, 65, 62});

		if (st3d_is_key_just_pressed(ST3D_KEY_ESCAPE)) {
			ui = !ui;
			st3d_set_mouse_enabled(ui);
		}

		// nuklear calls go inside here
		if (ui) {
			st3d_ui_begin();
			st3d_ui_end();
		}
		else {
			camera_shitfuck();
		}

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(mtriranfgs.texture);
	st3d_mesh_free(mtriranfgs);
	st3d_free();
}

static void camera_shitfuck(void)
{
	// tr_log("sigmy");
}
