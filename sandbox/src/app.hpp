#pragma once
#include <starry/common.hpp>

class Sandbox : public st::Application
{
	void init() override;
	void update(float64 dt) override;
	void free() override;
};
