#pragma once

#include <trippin/common.h>

#include <starry/world.h>

namespace sbox {

namespace Texture {
	constexpr st::TextureId GRASS_SIDE = 1;
	constexpr st::TextureId GRASS_TOP = 2;
	constexpr st::TextureId DIRT = 3;
	constexpr st::TextureId THE_J = 4;
	constexpr st::TextureId KIRBY_RIPOFF = 5;
}

st::Texture setup_world();

}
