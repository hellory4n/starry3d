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

namespace Model {
	constexpr st::Model GRASS = 1;
	constexpr st::Model DIRT = 2;
	constexpr st::Model THE_J = 3;
	constexpr st::Model KIRBY_RIPOFF = 4;
	constexpr st::Model THE_J_BUT_ITS_A_CUBE = 5;
	// balls   bamlls
};

void setup_world();

}
