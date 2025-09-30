#include "world.h"

#include <starry/world.h>

void sbox::setup_world()
{
	st::TextureAtlas atlas = st::TextureAtlas::load("app://atlas.png").unwrap();

// texture is last so it aligns nicely
#define SBOX_ADD_TEXTURE(X, Y, T) atlas.add(Texture::T, {16 * (X), 16 * (Y), 16, 16});

	SBOX_ADD_TEXTURE(0, 0, GRASS_SIDE)
	SBOX_ADD_TEXTURE(1, 0, GRASS_TOP)
	SBOX_ADD_TEXTURE(2, 0, DIRT)
	SBOX_ADD_TEXTURE(3, 0, THE_J)
	SBOX_ADD_TEXTURE(4, 0, KIRBY_RIPOFF)

	atlas.set_current();
}
