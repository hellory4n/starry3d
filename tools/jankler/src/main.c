#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>

static void player_controller(void);

int main(void)
{
	st3d_init("jankler", "assets", 800, 600);
	TrArena arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_float vertices;
	TR_SET_SLICE(&arena, &vertices, float,
		// vertices            // colors                  // texcoords
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

	while (!st3d_is_closing()) {
		st3d_begin_drawing(tr_hex_rgb(0x550877));

		st3d_mesh_draw_3d(mtriranfgs, (TrVec3f){0, 0, 0}, (TrVec3f){64, 65, 62});

		// nuklear calls go inside here
		st3d_ui_begin();
			player_controller();
		st3d_ui_end();

		// st3d_set_camera((St3dCamera){
		// 	.position = (TrVec3f){st_pos_x, st_pos_y, st_pos_z},
		// 	.rotation = (TrVec3f){st_rot_x, st_rot_y, st_rot_z},
		// 	.fov = 90,
		// 	.near = 0.01,
		// 	.far = 1000,
		// });

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_texture_free(mtriranfgs.texture);
	st3d_mesh_free(mtriranfgs);
	st3d_free();
}

const double speed = 2;
TrVec3f cam_pos;

static void player_controller(void)
{
	double dt = st3d_delta_time();

	if (st3d_is_key_held(ST3D_KEY_W)) {
		cam_pos.z -= speed * dt;
	}
	if (st3d_is_key_held(ST3D_KEY_S)) {
		cam_pos.z += speed * dt;
	}
	if (st3d_is_key_held(ST3D_KEY_A)) {
		cam_pos.x -= speed * dt;
	}
	if (st3d_is_key_held(ST3D_KEY_D)) {
		cam_pos.x += speed * dt;
	}
	if (st3d_is_key_held(ST3D_KEY_LEFT_SHIFT)) {
		cam_pos.y -= speed * dt;
	}
	if (st3d_is_key_held(ST3D_KEY_SPACE)) {
		cam_pos.y += speed * dt;
	}

	st3d_set_camera((St3dCamera){
		.position = cam_pos,
		.fov = 90,
		.near = 0.001,
		.far = 10000,
	});
}
