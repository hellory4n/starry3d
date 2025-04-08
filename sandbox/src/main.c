#include <st3d_core.h>

int main(void)
{
	St3dCtx ctx = st3d_init("Starry3D sandbox", 640, 480);
	bool running = true;
    while (running && !RGFW_isPressed(ctx.window, RGFW_escape)) {
        while (RGFW_window_checkEvent(ctx.window)) {
            if (ctx.window->event.type == RGFW_quit) {
                running = false;
                break;
            }
        }
	}
	st3d_free(&ctx);
}
