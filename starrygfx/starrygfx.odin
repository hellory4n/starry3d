package starrygfx

import stapp "../starryapp"
import hm "core:container/handle_map"

@(private)
global: struct {
	textures: hm.Dynamic_Handle_Map(Texture_Data, hm.Handle32),
}

// Literally only separate from `init_gfx` so that `samples/gpu_textures` works
init_asset_loaders :: proc(allocator := context.allocator)
{
	hm.dynamic_init(&global.textures, allocator)

	stapp.register_asset_loader(
		ASSET_TEXTURE,
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

init_gfx :: proc(allocator := context.allocator)
{
	init_asset_loaders(allocator)
}

free_gfx :: proc()
{
	free_asset_loaders()
}
