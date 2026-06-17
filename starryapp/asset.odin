package starryapp

import st "../starrylib"
import hm "core:container/handle_map"
import "core:log"
import "core:os"
import "core:strings"

@(private)
init_assets :: proc(asset_dir: string)
{
	engine.asset_dir = fetch_asset_dir(asset_dir)
	engine.asset_handlers = make(map[st.Tag]Asset_Handler)
}

@(private)
free_assets :: proc()
{
	for _, handler in engine.asset_handlers {
		handler.destroy_all()
	}
	delete(engine.asset_handlers)
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
	log.errorf("    tried: ./%s", asset_dir)
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
		log.errorf("couldn't load %q: %s", path, os.error_string(err))
		return {}, false
	}

	return data, true
}

ASSET_IMAGE := st.tag("imag")
ASSET_MODEL := st.tag("modl")
ASSET_AUDIO := st.tag("audi")

Asset_Loader_Proc :: #type proc(data: []byte, path: string) -> (h: hm.Handle32, ok: bool)
Asset_Destroyer_Proc :: #type proc(h: hm.Handle32)
Asset_Destroy_All_Proc :: #type proc()

@(private)
Asset_Handler :: struct {
	loader:         Asset_Loader_Proc,
	destroyer:      Asset_Destroyer_Proc,
	destroy_all:    Asset_Destroy_All_Proc,
	// insane?
	cache:          map[string]hm.Handle32,
	handle_to_path: map[hm.Handle32]string,
}

register_asset_loader :: proc(
	tag: st.Tag,
	loader: Asset_Loader_Proc,
	destroyer: Asset_Destroyer_Proc,
	destroy_all: Asset_Destroy_All_Proc,
)
{
	assert(loader != nil)
	assert(destroyer != nil)

	engine.asset_handlers[tag] = {
		loader         = loader,
		destroyer      = destroyer,
		destroy_all    = destroy_all,
		cache          = make(map[string]hm.Handle32, engine.ctx.allocator),
		handle_to_path = make(map[hm.Handle32]string, engine.ctx.allocator),
	}
}

// Forces an asset to be reloaded from its path.
reload :: proc(asset_type: st.Tag, path: string) -> (h: hm.Handle32, ok: bool) #optional_ok
{
	handler: Asset_Handler
	handler, ok = engine.asset_handlers[asset_type]
	if !ok {
		log.panicf(
			"couldn't load %q: no asset loader for asset_type %q. please add one with `register_asset_loader()`.",
			path,
			st.tag_str(asset_type),
		)
	}

	// TODO better errors than "FIGURE IT OUT IDIOT"
	// for now we rely on everywhere else printing the errors for us

	data: []byte
	data, ok = load_asset_bytes(path, engine.ctx.allocator)
	if !ok do return

	h, ok = handler.loader(data, path)
	if ok {
		handler.cache[path] = h
		handler.handle_to_path[h] = path
	}
	return h, ok
}

// Loads an asset, or fetches it from cache if it was already loaded before.
load :: proc(asset_type: st.Tag, path: string) -> (h: hm.Handle32, ok: bool) #optional_ok
{
	handler: Asset_Handler
	handler, ok = engine.asset_handlers[asset_type]
	if !ok do return

	if path in handler.cache {
		return handler.cache[path], true
	}
	return reload(asset_type, path)
}

// Unloads an asset. Note that the engine already unloads all assets when the game closes,
// so calling this is (usually) unnecessary.
unload :: proc(asset_type: st.Tag, h: hm.Handle32)
{
	handler, ok := engine.asset_handlers[asset_type]
	assert(ok, "what the fuck?")
	assert(handler.destroyer != nil, "what the fuck?")

	handler.destroyer(h)
	path := handler.handle_to_path[h]
	delete_key(&handler.cache, path)
	delete_key(&handler.handle_to_path, h)
}
