#include <libtrippin.hpp>
#include <st_common.hpp>
#include <st_window.hpp>
#include <st_render.hpp>
#include <st_imgui.hpp>

int main(void)
{
	tr::use_log_file("log.txt");
	tr::init();

	st::init("sandbox", "assets");
	st::WindowOptions window;
	window.title = "sandbox";
	window.size = {1280, 720};
	window.resizable = true;
	st::open_window(window);
	st::imgui::init();

	while (!st::is_window_closing()) {
		st::poll_events();
		st::clear_screen(tr::Color::rgb(0x734a16));

		if (st::is_key_just_released(st::Key::F8)) {
			st::close_window();
		}

		st::imgui::begin();
			ImGui::ShowDemoWindow();
		st::imgui::end();

		st::end_drawing();
	}

	st::imgui::free();
	st::free_window();
	st::free();

	tr::free();
	return 0;
}
