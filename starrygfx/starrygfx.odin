package starrygfx

import stapp "../starryapp"
import gpu "../starryapp/gpu"
import st "../starrylib"
import hm "core:container/handle_map"

@(private)
global: struct {
	textures:       hm.Dynamic_Handle_Map(Texture_Data, hm.Handle32),
	material_types: map[st.Tag64]Internal_Material,
}

// Literally only separate from `init_gfx` so that `samples/gpu_textures` works
init_asset_loaders :: proc()
{
	hm.dynamic_init(&global.textures, stapp.get_engine_allocator())

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

init_gfx :: proc()
{
	context.allocator = stapp.get_engine_allocator()
	init_asset_loaders()
	
	global.material_types = make(map[st.Tag64]Internal_Material)
}

free_gfx :: proc()
{
	context.allocator = stapp.get_engine_allocator()
	
	for _, material in global.material_types {
		gpu.free_pipeline(material.pipeline)
	}
	delete(global.material_types)

	free_asset_loaders()
}
