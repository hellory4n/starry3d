#include <libtrippin.h>
#include <st3d_render.h>
#include <st3d.h>

int main(void)
{
	st3d_init("sandbox", "assets", 800, 600);
	TrArena arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_float vertices;
	TR_SET_SLICE(&arena, &vertices, float,
		// vertices            // colors                  // texcoords
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

	while (!st3d_is_closing()) {
		st3d_begin_drawing(tr_hex_rgb(0x550877));

		st3d_mesh_draw_2d(mtriranfgs, (TrVec2f){100, 100});

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_texture_free(mtriranfgs.texture);
	st3d_mesh_free(mtriranfgs);
	st3d_free();
}
