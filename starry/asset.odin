package starry

import hm "core:container/handle_map"
import "core:fmt"
import "core:mem"
import vmem "core:mem/virtual"
import "core:os"

// Lua: `app.dir`
app_dir :: proc() -> string
{
	if len(global.args.app_dir) > 0 {
		return global.args.app_dir
	}
	return global.exe_dir
}

// Reads a file and all of its contents, relative to the directory of where the engine is located.
read_from_app_dir :: proc(path: string, allocator: mem.Allocator) -> (data: []byte, err: os.Error)
{
	data = os.read_entire_file_from_path(
		fmt.tprintf("%s/%s", app_dir(), path),
		allocator,
	) or_return
	return data, nil
}

init_asset_system :: proc()
{
	global.asset_loaders = make(map[StringId]AssetLoader)

	// asset loaders
	hm.dynamic_init(&global.textures, context.allocator)

	register_asset_loader(
		strid("texture"),
		_texture_load,
		_texture_unload,
		_texture_unload_all,
	)
}

free_asset_system :: proc()
{
	for _, handler in global.asset_loaders {
		handler.unload_all()
		delete(handler.cache)
	}
	delete(global.asset_loaders)
}

// TODO expose asset loaders to lua
// have fun handling callbacks

AssetRef :: struct {
	path:   string,
	type:   StringId,
	handle: hm.Handle32,
}

AssetLoadProc :: #type proc(data: []byte, path: string) -> (h: hm.Handle32, ok: bool)
AssetUnloadProc :: #type proc(h: hm.Handle32)
AssetUnloadAllProc :: #type proc()

@(private)
AssetLoader :: struct {
	load:       AssetLoadProc,
	unload:     AssetUnloadProc,
	unload_all: AssetUnloadAllProc,
	cache:      map[string]AssetRef,
}

register_asset_loader :: proc(
	asset_type: StringId,
	loader: AssetLoadProc,
	unloader: AssetUnloadProc,
	unload_all: AssetUnloadAllProc,
)
{
	assert(loader != nil)
	assert(unloader != nil)

	global.asset_loaders[asset_type] = {
		load       = loader,
		unload     = unloader,
		unload_all = unload_all,
		cache      = make(map[string]AssetRef, global.ctx.allocator),
	}
}

// Forces an asset to be reloaded from its path.
reload :: proc(asset_type: StringId, path: string) -> (h: AssetRef, ok: bool) #optional_ok
{
	context.allocator = global.ctx.allocator

	loader: AssetLoader
	loader, ok = global.asset_loaders[asset_type]
	if !ok {
		fmt.panicf(
			"couldn't load %q: no asset loader for asset type %w. please add one with `register_asset_loader()`.",
			path,
			asset_type,
		)
	}

	if path in loader.cache {
		unload(loader.cache[path])
	}

	data, ferr := read_from_app_dir(path, context.allocator)
	if ferr != nil {
		fmt.printfln("couldn't load %q: %s", path, os.error_string(ferr))
		return {}, false
	}
	defer delete(data)

	h.handle, ok = loader.load(data, path)
	if ok {
		h.path = path
		h.type = asset_type
		loader.cache[path] = h
	} else {
		fmt.printfln("failed loading %q with loader %w", path, asset_type)
	}

	fmt.printfln("loaded %q of type %w", path, asset_type)
	return h, ok
}

// Loads an asset, or fetches it from cache if it was already loaded before.
load :: proc(asset_type: StringId, path: string) -> (h: AssetRef, ok: bool) #optional_ok
{
	loader: AssetLoader
	loader, ok = global.asset_loaders[asset_type]
	if !ok do return

	if path in loader.cache {
		return loader.cache[path], true
	}

	return reload(asset_type, path)
}

// Unloads an asset. Note that the engine already unloads all assets when the game closes,
// so calling this is (usually) unnecessary.
unload :: proc(h: AssetRef)
{
	loader, ok := global.asset_loaders[h.type]
	assert(ok, "what the fuck?")
	assert(loader.unload != nil, "what the fuck?")

	context.allocator = global.ctx.allocator
	loader.unload(h.handle)
	delete_key(&loader.cache, h.path)

	fmt.printfln("unloaded %q of type %w", h.path, h.type)
}
