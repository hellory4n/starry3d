#pragma once
#include <starry/common.hpp>

class Sandbox : public st::Application
{
	tr::Result<void, tr::Error> init() override;
	tr::Result<void, tr::Error> update(float64 dt) override;
	tr::Result<void, tr::Error> free() override;
};
