#include <trippin/common.hpp>
#include <trippin/log.hpp>
#include <starry/common.hpp>
#include <starry/imgui.hpp>

// TODO put this in another header
class Sandbox : public st::Application
{
	void init() override;
	void update(float64 dt) override;
	void free() override;
};

void Sandbox::init()
{
	tr::log("initialized sandbox :)");
}

void Sandbox::update(float64) {}

void Sandbox::free()
{
	tr::log("freed sandbox :)");
}

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
