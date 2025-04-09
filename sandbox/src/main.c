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
	// st3d_path(&ctx, "usr:deez.fck", bufdeez, 260);
	// tr_log(TR_LOG_INFO, "stigma %s", bufdeez);
	while (!st3d_is_closing(&ctx)) {
		st3d_poll_events(&ctx);
		st3d_swap_buffers(&ctx);
	}
	st3d_free(&ctx);
}
