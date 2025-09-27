#include <starry/app.h>

#include "app.h"

int main()
{
	st::ApplicationSettings settings = {
		.name = "sandbox",
		.app_dir = "assets",
		.log_files = {"log.txt"},
		.window_size = {1300, 700},
	};
	st::run<sbox::Sandbox>(settings);
	return 0;
}
