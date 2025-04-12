#include <st3d.h>

int main(void)
{
	st3d_init("sandbox", "assets", 640, 480);
	while (!st3d_is_closing()) {
		st3d_end_drawing(tr_hex_rgba(0x734a16));
		st3d_poll_events();
	}
	st3d_free();
}
