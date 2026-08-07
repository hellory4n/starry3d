// added by starry!
package harfbuzz

import ft "../freetype"
import "core:c"

// TODO : check Windows library name
when ODIN_OS == .Windows {
	foreign import hb "windows/harfbuzz.lib"
} else when ODIN_OS == .Linux {
	foreign import hb "system:harfbuzz"
}

@(default_calling_convention = "c", link_prefix = "hb_")
foreign hb
{
	/*
	hb_font_t *
	hb_ft_font_create (FT_Face ft_face, hb_destroy_func_t destroy);*/
	ft_font_create :: proc(ft_face: ft.Face, destroy: destroy_func_t) -> ^font_t ---

	/*void
	hb_ft_font_set_load_flags (hb_font_t *font, int load_flags);*/
	ft_font_set_load_flags :: proc(font: ^font_t, load_flags: ft.Load_Flags) ---
}
