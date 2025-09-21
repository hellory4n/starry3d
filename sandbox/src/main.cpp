#include <starry/app.h>

#include "app.h"

int main()
{
	st::ApplicationSettings settings = {
		.name = "sandbox",
		.app_dir = "assets",
		.log_files = {"log.txt"},
		.window_size = {800, 600},
	};

	sbox::Sandbox app = {};
	st::run(app, settings);
	return 0;
}
