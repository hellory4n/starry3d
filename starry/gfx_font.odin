package starry

import hm "core:container/handle_map"

Font_Data :: struct {
	handle: hm.Handle32,
	path:   string,
}

// lua: `gfx.load_font`
load_font :: proc(path: string) -> (h: hm.Handle32, ok: bool)
{
	unimplemented("font loading")
}

// lua: `gfx.Font:__gc`
unload_font :: proc(h: hm.Handle32)
{
	// TODO
}

font_data :: proc(h: hm.Handle32) -> Font_Data
{
	unimplemented()
}
