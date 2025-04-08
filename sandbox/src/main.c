#include <st3d_core.h>
#include <unistd.h>

int main(void)
{
	St3dCtx ctx = st3d_init("Starry3D sandbox", 640, 480);
	sleep(4);
	st3d_free(&ctx);
}
