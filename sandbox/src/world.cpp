#include "world.h"

#include <trippin/memory.h>

#include <starry/world.h>

void sbox::setup_world()
{
	// atlas
	st::TextureAtlas atlas = st::TextureAtlas::load("app://atlas.png").unwrap();

// texture is last so it aligns nicely
#define SBOX_ADD_TEXTURE(X, Y, T) atlas.add(Texture::T, {16 * (X), 16 * (Y), 16, 16});

	SBOX_ADD_TEXTURE(0, 0, GRASS_SIDE)
	SBOX_ADD_TEXTURE(1, 0, GRASS_TOP)
	SBOX_ADD_TEXTURE(2, 0, DIRT)
	SBOX_ADD_TEXTURE(3, 0, THE_J)
	SBOX_ADD_TEXTURE(4, 0, KIRBY_RIPOFF)

	// models
	tr::Array<st::ModelMesh> mesh_grass = {
		st::ModelCube{
			      .position = {0, 0, 0},
			      .size = {16, 16, 16},
			      .front = Texture::GRASS_SIDE,
			      .back = Texture::GRASS_SIDE,
			      .left = Texture::GRASS_SIDE,
			      .right = Texture::GRASS_SIDE,
			      .top = Texture::GRASS_TOP,
			      .bottom = Texture::DIRT,
			      },
	};
	st::register_model_spec(Model::GRASS, "sandbox::grass", mesh_grass);

	tr::Array<st::ModelMesh> mesh_dirt = {
		st::ModelCube{
			      .position = {0, 0, 0},
			      .size = {16, 16, 16},
			      .front = Texture::DIRT,
			      .back = Texture::DIRT,
			      .left = Texture::DIRT,
			      .right = Texture::DIRT,
			      .top = Texture::DIRT,
			      .bottom = Texture::DIRT,
			      },
	};
	st::register_model_spec(Model::DIRT, "sandbox::dirt", mesh_dirt);

	tr::Array<st::ModelMesh> mesh_the_j = {
		st::ModelCube{
			      .position = {0, 0, 6},
			      .size = {16, 4, 6},
			      .front = Texture::THE_J,
			      .back = Texture::THE_J,
			      .left = Texture::THE_J,
			      .right = Texture::THE_J,
			      .top = Texture::THE_J,
			      .bottom = Texture::THE_J,
			      },
		st::ModelCube{
			      .position = {6, 4, 6},
			      .size = {6, 12, 6},
			      .front = Texture::THE_J,
			      .back = Texture::THE_J,
			      .left = Texture::THE_J,
			      .right = Texture::THE_J,
			      .top = Texture::THE_J,
			      .bottom = Texture::THE_J,
			      },
	};
	st::register_model_spec(Model::THE_J, "sandbox::the_j", mesh_the_j);

	tr::Array<st::ModelMesh> mesh_kirby = {
		st::ModelPlane{
			       .top_left = {0, 16, 8},
			       .top_right = {16, 16, 8},
			       .bottom_left = {0, 0, 8},
			       .bottom_right = {16, 0, 8},
			       .texture_or_color = Texture::KIRBY_RIPOFF,
			       .billboard = true,
			       },
	};
	st::register_model_spec(Model::KIRBY_RIPOFF, "sandbox::kirby_ripoff", mesh_kirby);

	tr::Array<st::ModelMesh> mesh_the_j_cube = {
		st::ModelCube{
			      .position = {0, 0, 0},
			      .size = {16, 16, 16},
			      .front = Texture::THE_J,
			      .back = Texture::THE_J,
			      .left = Texture::THE_J,
			      .right = Texture::THE_J,
			      .top = Texture::THE_J,
			      .bottom = Texture::THE_J,
			      },
	};
	st::register_model_spec(
		Model::THE_J_BUT_ITS_A_CUBE, "sandbox::the_j_but_its_a_cube", mesh_the_j_cube
	);

	atlas.set_current();
}
