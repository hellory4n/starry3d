#pragma once

#include <trippin/common.h>

#include <starry/world.h>

namespace sbox {

constexpr st::TextureId TEXTURE_GRASS_SIDE = 1;
constexpr st::TextureId TEXTURE_GRASS_TOP = 2;
constexpr st::TextureId TEXTURE_DIRT = 3;
constexpr st::TextureId TEXTURE_THE_J = 4;
constexpr st::TextureId TEXTURE_KIRBY_RIPOFF = 5;

constexpr st::Model MODEL_GRASS = 1;
constexpr st::Model MODEL_DIRT = 2;
constexpr st::Model MODEL_THE_J = 3;
constexpr st::Model MODEL_KIRBY_RIPOFF = 4;
constexpr st::Model MODEL_THE_J_BUT_ITS_A_CUBE = 5;

void setup_world();

}
