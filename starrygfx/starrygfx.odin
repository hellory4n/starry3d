/*
# starrygfx

Implements the 2D and 3D Starry renderers.

## gfx2d

Features:
- colored squares, textured squares, shader

Very incomplete.
*/
package starrygfx

import stapp "../starryapp"
import st "../starrylib"
import hm "core:container/handle_map"

// Literally only separate from `init_gfx` so that `samples/gpu_textures` works
init_asset_loaders :: proc()
{
	hm.dynamic_init(&global.textures, stapp.get_engine_allocator())

	stapp.register_asset_loader(
		st.strid("texture"),
		_texture_load,
		_texture_unload,
		_texture_unload_all,
	)
}

// Literally only separate from `init_gfx` so that `samples/gpu_textures` works
free_asset_loaders :: proc()
{
	hm.dynamic_destroy(&global.textures)
}

init_gfx :: proc()
{
	context.allocator = stapp.get_engine_allocator()
	init_asset_loaders()
	init_2d()
}

free_gfx :: proc()
{
	context.allocator = stapp.get_engine_allocator()
	free_asset_loaders()
	free_2d()
}
