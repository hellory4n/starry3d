#pragma once
#include <trippin/common.h>
#include <trippin/memory.h>

#include <starry/app.h>
#include <starry/gpu.h>

namespace sbox {

class Sandbox : public st::Application
{
	static constexpr float64 MOUSE_SENSITIVITY = 0.15f;
	static constexpr float32 PLAYER_SPEED = 5.0f;

	bool _ui_enabled = true;

	tr::Arena arena = {};

	st::ShaderProgram program = {};
	st::Mesh mesh = {};
	st::Texture texture = {};

	void player_controller(float64 dt) const;

public:
	tr::Result<void> init() override;
	tr::Result<void> update(float64 dt) override;
	tr::Result<void> draw() override;
	tr::Result<void> gui() override;
	tr::Result<void> free() override;
};

}
