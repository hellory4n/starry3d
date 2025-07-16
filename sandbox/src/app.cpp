#include <starry/render.hpp>
#include "app.hpp"

void Sandbox::init()
{
	st::init_triangle();
	tr::log("initialized sandbox :)");
}

void Sandbox::update(float64)
{
	st::draw_triangle();
}

void Sandbox::free()
{
	st::free_triangle();
	tr::log("freed sandbox :)");
}
