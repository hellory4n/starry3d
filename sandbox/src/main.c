#include "libtrippin.h"
#include "st3d_window.h"
#include <st3d_core.h>
#include <unistd.h>

int main(void)
{
	St3dCtx ctx = st3d_init("sandbox", "assets", 640, 480);

	char bufdeez[260];
	st3d_path(&ctx, "app:deez.fck", bufdeez, 260);
	tr_log(TR_LOG_INFO, "stigma %s", bufdeez);

	char bufdeez2[260];
	st3d_path(&ctx, "usr:deez.fck", bufdeez2, 260);
	tr_log(TR_LOG_INFO, "stigma %s", bufdeez2);

	while (!st3d_is_closing(&ctx)) {
		if (st3d_is_key_just_pressed(&ctx, ST3D_KEY_SPACE)) {
			st3d_close(&ctx);
		}

		if (st3d_is_key_just_released(&ctx, ST3D_KEY_ESCAPE)) {
			st3d_close(&ctx);
		}

		if (st3d_is_key_held(&ctx, ST3D_KEY_F5)) {
			st3d_close(&ctx);
			tr_log(TR_LOG_ERROR, "SIGMA!!");
		}

		st3d_poll_events(&ctx);
		st3d_swap_buffers(&ctx);
	}
	st3d_free(&ctx);
}
