#pragma once
#include <starry/app.h>

class Sandbox : public st::Application
{
	static constexpr float32 MOUSE_SENSITIVITY = 0.25f;
	static constexpr float32 PLAYER_SPEED = 5.0f;

	bool _ui_enabled = true;

	void player_controller(float64 dt) const;

public:
	tr::Result<void> init() override;
	tr::Result<void> update(float64 dt) override;
	tr::Result<void> free() override;
};
