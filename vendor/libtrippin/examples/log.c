#include "libtrippin.h"

int main(void) {
	tr_init("log.txt");

	tr_liblog("im having a stroke");
	tr_log("im having a stroke (not libtrippin)");
	tr_warn("we will all die.");
	tr_error("im died");

	tr_assert(false, "seems %s", "bad");
	tr_panic("AAAAAAAHHHH");

	tr_free();
}
