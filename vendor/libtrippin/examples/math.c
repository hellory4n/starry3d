#include <time.h>
#include "libtrippin.h"

int main(void) {
	tr_init("log.txt");

	for (size_t i = 0; i < 10; i++) {
		double sorandomxd = tr_rand_double(tr_default_rand(), 1, 10);
		tr_log("%f", sorandomxd);
	}

	// you can make some colors
	TrColor color = tr_hex_rgb(0x448aff);
	tr_log("%.2X%.2X%.2X%.2X", color.r, color.g, color.b, color.a);

	tr_free();
}
