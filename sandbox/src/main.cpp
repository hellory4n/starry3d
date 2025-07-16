#include <starry/common.hpp>
#include "app.hpp"

int main(void)
{
	st::ApplicationSettings settings = {};
	settings.name = "sandbox";
	settings.app_dir = "assets";
	settings.logfiles = {"log.txt"};
	settings.window_size = {800, 600};

	Sandbox app = {};
	st::run(app, settings);
	return 0;
}
