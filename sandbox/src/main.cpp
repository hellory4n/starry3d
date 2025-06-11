#include <stdio.h>
#include <libtrippin.hpp>
#include <st_common.hpp>

int main(void)
{
	tr::use_log_file("log.txt");
	tr::init();
	st::init();

	// ...

	tr::free();
	st::free();
	return 0;
}
