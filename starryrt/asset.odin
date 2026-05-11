package starryrt

import "core:log"
import "core:os"
import "core:strings"

@(private)
init_assets :: proc(asset_dir: string)
{
	engine.asset_dir = fetch_asset_dir(asset_dir)
	engine.texture_cache = make(map[string]Texture)
}

@(private)
free_assets :: proc()
{
	for _, texture in engine.texture_cache {
		unload_texture(texture)
	}
	delete(engine.texture_cache)
	delete(engine.asset_dir)
	delete(engine.exe_dir)
}

@(private)
fetch_asset_dir :: #force_inline proc(asset_dir: string) -> string
{
	// find the asset dir
	err: os.Error
	engine.exe_dir, err = os.get_executable_directory(context.allocator)
	if err != nil {
		log.warnf("couldn't get executable directory; using current working directory")
		engine.exe_dir = "."
		// note: everything is cloned because otherwise delete() breaks and
		// also im a lazy bastard
		return strings.clone(".")
	}

	// user didn't choose an asset dir
	if asset_dir == "." || asset_dir == "" {
		return strings.clone(engine.exe_dir)
	}

	if os.exists(asset_dir) {
		return strings.clone(asset_dir)
	}

	path_from_exe_dir := strings.join({engine.exe_dir, asset_dir}, sep = "/")
	if os.exists(path_from_exe_dir) {
		return path_from_exe_dir
	}

	log.errorf("couldn't find asset directory")
	log.errorf("    tried: %s/%s", os.get_working_directory(context.allocator), asset_dir)
	log.errorf("    tried: %s", path_from_exe_dir)
	log.panicf("panicking")
}

// Loads an asset file relative to the asset directory.
load_asset_bytes :: proc(path: string, allocator := context.allocator) -> (data: []byte, ok: bool)
{
	// TODO android has its own asset loading function, use that
	real_path := strings.join(
		{engine.asset_dir, path},
		sep = "/",
		allocator = context.temp_allocator,
	)

	err: os.Error
	data, err = os.read_entire_file_from_path(real_path, allocator)
	if err != nil {
		return {}, false
	}

	return data, true
}
