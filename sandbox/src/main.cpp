#include <libtrippin.hpp>
#include <st_common.hpp>
#include <st_window.hpp>

int main(void)
{
	tr::use_log_file("log.txt");
	tr::init();

	st::init();
	st::WindowOptions window;
	window.title = "sandbox";
	window.size = {1280, 720};
	window.resizable = true;
	st::open_window(window);

	while (!st::is_window_closing()) {
		st::poll_events();
	}

	st::free_window();
	st::free();

	tr::free();
	return 0;
}
