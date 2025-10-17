#include "world.h"

#include <trippin/memory.h>

#include <starry/world.h>

void sbox::setup_world()
{
	// atlas
	st::TextureAtlas atlas = st::TextureAtlas::load("app://atlas.png").unwrap();

// texture is last so it aligns nicely
#define SBOX_ADD_TEXTURE(X, Y, T) atlas.add(T, {16 * (X), 16 * (Y), 16, 16});

	SBOX_ADD_TEXTURE(0, 0, TEXTURE_GRASS_SIDE)
	SBOX_ADD_TEXTURE(1, 0, TEXTURE_GRASS_TOP)
	SBOX_ADD_TEXTURE(2, 0, TEXTURE_DIRT)
	SBOX_ADD_TEXTURE(3, 0, TEXTURE_THE_J)
	SBOX_ADD_TEXTURE(4, 0, TEXTURE_KIRBY_RIPOFF)

	// models
	tr::Array<st::ModelMesh> mesh_grass = {
		st::ModelCube{
			      .position = {0, 0, 0},
			      .size = {16, 16, 16},
			      .front = TEXTURE_GRASS_SIDE,
			      .back = TEXTURE_GRASS_SIDE,
			      .left = TEXTURE_GRASS_SIDE,
			      .right = TEXTURE_GRASS_SIDE,
			      .top = TEXTURE_GRASS_TOP,
			      .bottom = TEXTURE_DIRT,
			      },
	};
	st::register_model_spec(MODEL_GRASS, "sandbox::grass", mesh_grass);

	tr::Array<st::ModelMesh> mesh_dirt = {
		st::ModelCube{
			      .position = {0, 0, 0},
			      .size = {16, 16, 16},
			      .front = TEXTURE_DIRT,
			      .back = TEXTURE_DIRT,
			      .left = TEXTURE_DIRT,
			      .right = TEXTURE_DIRT,
			      .top = TEXTURE_DIRT,
			      .bottom = TEXTURE_DIRT,
			      },
	};
	st::register_model_spec(MODEL_DIRT, "sandbox::dirt", mesh_dirt);

	tr::Array<st::ModelMesh> mesh_the_j = {
		st::ModelCube{
			      .position = {0, 0, 6},
			      .size = {16, 4, 6},
			      .front = TEXTURE_THE_J,
			      .back = TEXTURE_THE_J,
			      .left = TEXTURE_THE_J,
			      .right = TEXTURE_THE_J,
			      .top = TEXTURE_THE_J,
			      .bottom = TEXTURE_THE_J,
			      },
		st::ModelCube{
			      .position = {6, 4, 6},
			      .size = {6, 12, 6},
			      .front = TEXTURE_THE_J,
			      .back = TEXTURE_THE_J,
			      .left = TEXTURE_THE_J,
			      .right = TEXTURE_THE_J,
			      .top = TEXTURE_THE_J,
			      .bottom = TEXTURE_THE_J,
			      },
	};
	st::register_model_spec(MODEL_THE_J, "sandbox::the_j", mesh_the_j);

	tr::Array<st::ModelMesh> mesh_kirby = {
		st::ModelPlane{
			       .top_left = {0, 16, 8},
			       .top_right = {16, 16, 8},
			       .bottom_left = {0, 0, 8},
			       .bottom_right = {16, 0, 8},
			       .texture_or_color = TEXTURE_KIRBY_RIPOFF,
			       .billboard = true,
			       },
	};
	st::register_model_spec(MODEL_KIRBY_RIPOFF, "sandbox::kirby_ripoff", mesh_kirby);

	tr::Array<st::ModelMesh> mesh_the_j_cube = {
		st::ModelCube{
			      .position = {0, 0, 0},
			      .size = {16, 16, 16},
			      .front = TEXTURE_THE_J,
			      .back = TEXTURE_THE_J,
			      .left = TEXTURE_THE_J,
			      .right = TEXTURE_THE_J,
			      .top = TEXTURE_THE_J,
			      .bottom = TEXTURE_THE_J,
			      },
	};
	st::register_model_spec(
		MODEL_THE_J_BUT_ITS_A_CUBE, "sandbox::the_j_but_its_a_cube", mesh_the_j_cube
	);

	atlas.set_current();
}
