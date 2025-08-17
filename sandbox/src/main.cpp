#include <starry/app.h>

#include "app.h"

int main()
{
	st::ApplicationSettings settings = {};
	settings.name = "sandbox";
	settings.app_dir = "assets";
	settings.logfiles = {"log.txt"};
	settings.window_size = {800, 600};

	sbox::Sandbox app = {};
	st::run(app, settings);
	return 0;
}
