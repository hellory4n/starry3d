#include <libtrippin.h>
#include <st3d_render.h>
#include <st3d.h>

int main(void)
{
	st3d_init("sandbox", "assets", 640, 480);
	TrArena arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_float vertices = tr_slice_new(arena, 12, sizeof(float));
	*(float*)tr_slice_at(vertices, 0)  =  0.5f;
	*(float*)tr_slice_at(vertices, 1)  =  0.5f;
	*(float*)tr_slice_at(vertices, 2)  =  0.0f;
	*(float*)tr_slice_at(vertices, 3)  =  0.5f;
	*(float*)tr_slice_at(vertices, 4)  = -0.5f;
	*(float*)tr_slice_at(vertices, 5)  =  0.0f;
	*(float*)tr_slice_at(vertices, 6)  = -0.5f;
	*(float*)tr_slice_at(vertices, 7)  = -0.5f;
	*(float*)tr_slice_at(vertices, 8)  =  0.0f;
	*(float*)tr_slice_at(vertices, 9)  = -0.5f;
	*(float*)tr_slice_at(vertices, 10) =  0.5f;
	*(float*)tr_slice_at(vertices, 11) =  0.0f;

	TrSlice_uint32 indices = tr_slice_new(arena, 6, sizeof(uint32_t));
	*(uint32_t*)tr_slice_at(indices, 0) = 0;
	*(uint32_t*)tr_slice_at(indices, 1) = 1;
	*(uint32_t*)tr_slice_at(indices, 2) = 3;
	*(uint32_t*)tr_slice_at(indices, 3) = 1;
	*(uint32_t*)tr_slice_at(indices, 4) = 2;
	*(uint32_t*)tr_slice_at(indices, 5) = 3;

	St3dMesh mtriranfgs = st3d_mesh_new(vertices, indices, true);
	// st3d_set_wireframe(true);

	while (!st3d_is_closing()) {
		st3d_begin_drawing(TR_BLACK);

		st3d_mesh_draw(mtriranfgs);

		st3d_end_drawing();
		st3d_poll_events();
	}
	st3d_free();
}
