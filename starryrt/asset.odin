package starryrt

@(private)
init_assets :: proc()
{
	engine.texture_cache = make(map[string]Texture)
}

@(private)
free_assets :: proc()
{
	for _, texture in engine.texture_cache {
		unload_texture(texture)
	}
	delete(engine.texture_cache)
}
