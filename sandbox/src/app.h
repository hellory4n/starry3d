#pragma once
#include <starry/common.h>

class Sandbox : public st::Application
{
public:
	tr::Result<void, const tr::Error&> init() override;
	tr::Result<void, const tr::Error&> update(float64 dt) override;
	tr::Result<void, const tr::Error&> free() override;
};
