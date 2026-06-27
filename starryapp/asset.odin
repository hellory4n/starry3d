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
	engine.asset_loaders = make(map[st.String_Id]Asset_Loader)
}

@(private)
free_assets :: proc()
{
	for _, handler in engine.asset_loaders {
		handler.unload_all()
		delete(handler.cache)
	}
	delete(engine.asset_loaders)
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

Asset_Ref :: struct {
	path:   string,
	type:   st.String_Id,
	handle: hm.Handle32,
}

Asset_Load_Proc :: #type proc(data: []byte, path: string) -> (h: hm.Handle32, ok: bool)
Asset_Unload_Proc :: #type proc(h: hm.Handle32)
Asset_Unload_All_Proc :: #type proc()

@(private)
Asset_Loader :: struct {
	load:       Asset_Load_Proc,
	unload:     Asset_Unload_Proc,
	unload_all: Asset_Unload_All_Proc,
	cache:      map[string]Asset_Ref,
}

register_asset_loader :: proc(
	asset_type: st.String_Id,
	loader: Asset_Load_Proc,
	unloader: Asset_Unload_Proc,
	unload_all: Asset_Unload_All_Proc,
)
{
	assert(loader != nil)
	assert(unloader != nil)

	engine.asset_loaders[asset_type] = {
		load       = loader,
		unload     = unloader,
		unload_all = unload_all,
		cache      = make(map[string]Asset_Ref, engine.ctx.allocator),
	}
}

// Forces an asset to be reloaded from its path.
reload :: proc(asset_type: st.String_Id, path: string) -> (h: Asset_Ref, ok: bool) #optional_ok
{
	context.allocator = engine.ctx.allocator

	loader: Asset_Loader
	loader, ok = engine.asset_loaders[asset_type]
	if !ok {
		log.panicf(
			"couldn't load %q: no asset loader for asset_type %w. please add one with `register_asset_loader()`.",
			path,
			asset_type,
		)
	}

	// TODO better errors than "FIGURE IT OUT IDIOT"
	// for now we rely on everywhere else printing the errors for us

	if path in loader.cache {
		unload(loader.cache[path])
	}

	data: []byte
	data, ok = load_asset_bytes(path)
	if !ok {
		return
	}
	defer delete(data)

	h.handle, ok = loader.load(data, path)
	if ok {
		h.path = path
		h.type = asset_type
		loader.cache[path] = h
	}

	log.infof("loaded %q of type %w", path, asset_type)
	return h, ok
}

// Loads an asset, or fetches it from cache if it was already loaded before.
load :: proc(asset_type: st.String_Id, path: string) -> (h: Asset_Ref, ok: bool) #optional_ok
{
	loader: Asset_Loader
	loader, ok = engine.asset_loaders[asset_type]
	if !ok do return

	if path in loader.cache {
		return loader.cache[path], true
	}

	return reload(asset_type, path)
}

// Unloads an asset. Note that the engine already unloads all assets when the game closes,
// so calling this is (usually) unnecessary.
unload :: proc(h: Asset_Ref)
{
	loader, ok := engine.asset_loaders[h.type]
	assert(ok, "what the fuck?")
	assert(loader.unload != nil, "what the fuck?")

	context.allocator = engine.ctx.allocator
	loader.unload(h.handle)
	delete_key(&loader.cache, h.path)

	log.infof("unloaded %q of type %w", h.path, h.type)
}
