package starry

import hm "core:container/handle_map"
import "core:fmt"
import fons "vendor:fontstash"

FontData :: struct {
	handle:  hm.Handle32,
	path:    string,
	font_id: int,
}

load_font_from_memory :: proc(data: []byte, label := "[buffer]") -> (h: hm.Handle32, ok: bool)
{
	font_id := fons.AddFontMem(&global.gfx2d.fonsctx, label, data, freeLoadedData = false)
	if font_id == fons.INVALID {
		// i love c libraries
		fmt.printfln("couldn't load %s: thirdparty error", label)
		return {}, false
	}

	return hm.add(&global.fonts, FontData{path = label, font_id = font_id}), true
}

// lua: `gfx.load_font`
load_font :: proc(path: string) -> (h: hm.Handle32, ok: bool)
{
	buffer, err := read_from_app_dir(path, context.allocator)
	if err != nil {
		fmt.printfln("couldn't load %s: %s", path, err)
		return {}, false
	}
	defer delete(buffer)

	h, ok = load_font_from_memory(buffer, path)
	if ok {
		fmt.printfln("loaded %s (%v)", path, h)
	}
	return
}

// lua: `gfx.Font:__gc`
unload_font :: proc(h: hm.Handle32)
{
	// apparently fontstash doesn't need this
	// but i can't be bothered to remove this function
	// i'll have to replace fontstash eventually so this is actually future-proofing
}

font_data :: proc(h: hm.Handle32) -> FontData
{
	font, ok := hm.get(&global.fonts, h)
	assert(ok)
	return font^
}
