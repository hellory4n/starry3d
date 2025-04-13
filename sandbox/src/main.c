#include <libtrippin.h>
#include <st3d_render.h>
#include <st3d.h>

int main(void)
{
	st3d_init("sandbox", "assets", 640, 480);
	TrArena arena = tr_arena_new(TR_MB(1));

	// ttriangel
	TrSlice_float verts = tr_slice_new(arena, 9, sizeof(float));
	*(float*)tr_slice_at(verts, 0) = -0.5f;
	*(float*)tr_slice_at(verts, 1) = -0.5f;
	*(float*)tr_slice_at(verts, 2) =  0.0f;
	*(float*)tr_slice_at(verts, 3) =  0.5f;
	*(float*)tr_slice_at(verts, 4) = -0.5f;
	*(float*)tr_slice_at(verts, 5) =  0.0f;
	*(float*)tr_slice_at(verts, 6) =  0.0f;
	*(float*)tr_slice_at(verts, 7) =  0.5f;
	*(float*)tr_slice_at(verts, 8) =  0.0f;

	St3dMesh mtriranfgs = st3d_mesh_new(verts, true);

	while (!st3d_is_closing()) {
		st3d_begin_drawing(tr_hex_rgb(0x734a16));

		st3d_mesh_draw(mtriranfgs);

		st3d_end_drawing();
		st3d_poll_events();
	}
	st3d_free();
}
