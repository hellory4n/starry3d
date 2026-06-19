package hello

import stapp "../../starryapp"
import st "../../starrylib"
import hm "core:container/handle_map"
import "core:log"
import "core:strings"

// each asset type (or rather asset loader) has a tag
// by convention, this starts with `ASSET_`
ASSET_MY_ASSET := st.tag64("myasset!") // must be 8 characters

// Asset_Handle is simply a wrapper for hm.Handle32
// so we also need a handle map:
global: struct {
	my_assets: hm.Dynamic_Handle_Map(My_Asset_Data, hm.Handle32),
}

My_Asset_Data :: struct {
	handle:   hm.Handle32,
	whatever: string,
}

my_asset_load :: proc(data: []byte, path: string) -> (h: hm.Handle32, ok: bool)
{
	// do something with the bytes
	text := strings.clone(string(data))

	ok = true
	h = hm.add(&global.my_assets, My_Asset_Data{whatever = text})
	return
}

my_asset_unload :: proc(h: hm.Handle32)
{
	my_asset, ok := hm.get(&global.my_assets, h)
	assert(ok)

	// do something with the asset
	delete(my_asset.whatever)

	hm.remove(&global.my_assets, h)
}

// when the engine closes, all remaining assets are automatically freed
// the engine doesn't know our handle map though, so we have to define this too:
my_asset_unload_all :: proc()
{
	iter := hm.iterator_make(&global.my_assets)
	for _, h in hm.iterate(&iter) {
		my_asset_unload(h)
	}
}

// use the asset after it has been loaded:
my_asset_text :: proc(h: stapp.Asset_Handle) -> string
{
	my_asset, ok := hm.get(&global.my_assets, h.handle)
	assert(ok)
	assert(h.type == ASSET_MY_ASSET)

	return my_asset.whatever
}

new_app :: proc()
{
	stapp.register_asset_loader(
		ASSET_MY_ASSET,
		my_asset_load,
		my_asset_unload,
		my_asset_unload_all,
	)

	// use this asset type:
	asset := stapp.load(ASSET_MY_ASSET, "data.txt")
	log.infof("my asset has: %s", my_asset_text(asset))
}

main :: proc()
{
	ctx := st.init_better_context()
	defer st.free_better_context(&ctx)
	context = ctx.ctx

	stapp.run(
		app_name = "custom asset loaders",
		app_version = {0, 1, 0},
		asset_dir = "samples/custom_asset_loaders",
		init_proc = new_app,
		// no free_proc! amazing!
	)
}
