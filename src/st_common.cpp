#include <libtrippin.hpp>
#include "st_common.hpp"

void st::init()
{
	tr::info("initialized starry3d %s", st::VERSION);
}

void st::free()
{
	tr::info("deinitialized starry3d %s", st::VERSION);
}
