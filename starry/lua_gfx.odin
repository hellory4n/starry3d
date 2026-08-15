package starry

import lua "../thirdparty/luajit"
import "core:c"
import hm "core:container/handle_map"
import "core:fmt"

@(private = "file")
lua_gfx_load_texture :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	path := lua_check_odin_string(L, 1)
	handle, ok := load_texture(path)

	userdata := cast(^hm.Handle32)lua.newuserdata(L, size_of(hm.Handle32))
	userdata^ = handle

	if b32(lua.L_newmetatable(L, "gfx_Texture")) {
		lua.pushcfunction(L, lua_gfx_texture_gc)
		lua.setfield(L, -2, "__gc")

		lua.pushcfunction(L, lua_gfx_texture_index)
		lua.setfield(L, -2, "__index")

		lua.pushcfunction(L, lua_gfx_texture_tostring)
		lua.setfield(L, -2, "__tostring")
	}
	lua.setmetatable(L, -2)

	lua.pushboolean(L, b32(ok))
	return 2
}

@(private = "file")
lua_gfx_texture_gc :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	handle := cast(^hm.Handle32)lua.touserdata(L, 1)
	unload_texture(handle^)
	return 0
}

@(private = "file")
lua_gfx_texture_index :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	handle := cast(^hm.Handle32)lua.touserdata(L, 1)
	data := texture_data(handle^)

	field := lua_check_odin_string(L, 2)

	// trick the user into thinking this is a table
	switch field {
	case "path":
		lua_push_odin_string(L, data.path)
	case "size":
		lua_push_vec2(L, cast([2]f64)texture_size(handle^))
	case:
		lua.pushnil(L)
	}

	return 1
}

@(private = "file")
lua_gfx_texture_tostring :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	handle := cast(^hm.Handle32)lua.touserdata(L, 1)
	lua_push_odin_string(L, fmt.tprintf("Texture{idx = %d, gen = %d}", handle.idx, handle.gen))
	return 1
}

@(private = "file")
lua_gfx_load_font :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	path := lua_check_odin_string(L, 1)

	handle, ok := load_font(path)

	userdata := cast(^hm.Handle32)lua.newuserdata(L, size_of(hm.Handle32))
	userdata^ = handle

	if b32(lua.L_newmetatable(L, "gfx_Font")) {
		lua.pushcfunction(L, lua_gfx_font_gc)
		lua.setfield(L, -2, "__gc")

		lua.pushcfunction(L, lua_gfx_font_index)
		lua.setfield(L, -2, "__index")

		lua.pushcfunction(L, lua_gfx_font_tostring)
		lua.setfield(L, -2, "__tostring")
	}
	lua.setmetatable(L, -2)

	lua.pushboolean(L, b32(ok))
	return 2
}

@(private = "file")
lua_gfx_font_gc :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	handle := cast(^hm.Handle32)lua.touserdata(L, 1)
	unload_font(handle^)
	return 0
}

@(private = "file")
lua_gfx_font_index :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	handle := cast(^hm.Handle32)lua.touserdata(L, 1)
	data := font_data(handle^)

	field := lua_check_odin_string(L, 2)

	// trick the user into thinking this is a table
	switch field {
	case "path":
		lua_push_odin_string(L, data.path)
	case:
		lua.pushnil(L)
	}

	return 1
}

@(private = "file")
lua_gfx_font_tostring :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	handle := cast(^hm.Handle32)lua.touserdata(L, 1)
	lua_push_odin_string(L, fmt.tprintf("Font{idx = %d, gen = %d}", handle.idx, handle.gen))
	return 1
}

@(private = "file")
lua_gfx_begin_render_pass :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	lua.L_checktype(L, 1, i32(lua.TTABLE))
	desc: RenderPassDesc

	lua.getfield(L, 1, "clear_color")
	if !lua.isnil(L, -1) {
		desc.clear_color = cast([4]f32)lua_check_vec4(L, -1)
	}
	lua.pop(L, 1)

	begin_render_pass(desc)
	return 0
}

@(private = "file")
lua_gfx_end_render_pass :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	end_render_pass()
	return 0
}

@(private = "file")
lua_gfx_set_scissor :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx

	pos: Maybe([2]f32)
	if lua.isnoneornil(L, 1) {
		pos = nil
	} else {
		pos = cast([2]f32)lua_check_vec2(L, 1)
	}

	size: Maybe([2]f32)
	if lua.isnoneornil(L, 2) {
		size = nil
	} else {
		size = cast([2]f32)lua_check_vec2(L, 2)
	}

	set_scissor(pos, size)
	return 0
}

@(private = "file")
lua_gfx_draw_rectangle :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	lua.L_checktype(L, 1, i32(lua.TTABLE))

	desc: DrawRectangleDesc
	lua.getfield(L, 1, "pos")
	desc.pos = cast([2]f32)lua_check_vec2(L, -1)
	lua.pop(L, 1)

	lua.getfield(L, 1, "size")
	desc.size = cast([2]f32)lua_check_vec2(L, -1)
	lua.pop(L, 1)

	lua.getfield(L, 1, "rot")
	if !lua.isnil(L, -1) {
		desc.rot = f32(lua.L_checknumber(L, -1))
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "origin")
	if !lua.isnil(L, -1) {
		desc.origin = cast([2]f32)lua_check_vec2(L, -1)
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "texture")
	if !lua.isnil(L, -1) {
		desc.texture = (cast(^hm.Handle32)lua.touserdata(L, -1))^
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "color")
	if !lua.isnil(L, -1) {
		desc.color = cast([4]f32)lua_check_vec4(L, -1)
	} else {
		desc.color = {1, 1, 1, 1}
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "filter")
	if !lua.isnil(L, -1) {
		filterstr := lua_check_odin_string(L, -1)
		switch filterstr {
		case "nearest":
			desc.filter = .NEAREST_NEIGHBOR
		case "linear":
			desc.filter = .BILINEAR
		case:
			fmt.panicf(
				"unexpected filter %q, should be 'nearest' or 'linear'",
				filterstr,
			)
		}
	} else {
		desc.filter = .BILINEAR
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "texture_pos")
	if !lua.isnil(L, -1) {
		desc.texture_pos = cast([2]f32)lua_check_vec2(L, -1)
	} else {
		desc.texture_pos = {0, 0}
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "texture_size")
	if !lua.isnil(L, -1) {
		desc.texture_size = cast([2]f32)lua_check_vec2(L, -1)
	} else {
		if texture_is_valid(desc.texture) {
			desc.texture_size = texture_size(desc.texture)
		}
	}
	lua.pop(L, 1)

	draw_rectangle(desc)
	return 0
}

@(private = "file")
lua_gfx_draw_text :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	lua.L_checktype(L, 1, i32(lua.TTABLE))
	desc: DrawTextDesc

	lua.getfield(L, 1, "text")
	desc.text = lua_check_odin_string(L, -1)
	lua.pop(L, 1)

	lua.getfield(L, 1, "pos")
	desc.pos = cast([2]f32)lua_check_vec2(L, -1)
	lua.pop(L, 1)

	lua.getfield(L, 1, "size")
	desc.size = f32(lua.L_checknumber(L, -1))
	lua.pop(L, 1)

	lua.getfield(L, 1, "color")
	if !lua.isnil(L, -1) {
		desc.color = cast([4]f32)lua_check_vec4(L, -1)
	} else {
		desc.color = {1, 1, 1, 1}
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "font")
	if !lua.isnil(L, -1) {
		desc.font = (cast(^hm.Handle32)lua.touserdata(L, -1))^
	} else {
		desc.font = global.default_font
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "line_spacing")
	if !lua.isnil(L, -1) {
		desc.line_spacing = f32(lua.L_checknumber(L, -1))
	} else {
		desc.line_spacing = 1.25
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "wrap")
	if !lua.isnil(L, -1) {
		wrap_str := lua_check_odin_string(L, -1)
		switch wrap_str {
		case "word":
			desc.wrap = .WORD
		case "character":
			desc.wrap = .CHARACTER
		case:
			fmt.panicf(
				"unexpected wrap %q, should be nil, 'character', or 'word'",
				wrap_str,
			)
		}
	}
	lua.pop(L, 1)

	if desc.wrap != .OFF {
		lua.getfield(L, 1, "bounds")
		desc.bounds = cast([2]f32)lua_check_vec2(L, -1)
		lua.pop(L, 1)
	}

	draw_text(desc)
	return 0
}

lua_open_gfx :: proc "c" (L: ^lua.State)
{
	gfx_reg := []lua.L_Reg {
		{"load_texture", lua_gfx_load_texture},
		{"load_font", lua_gfx_load_font},
		{"begin_render_pass", lua_gfx_begin_render_pass},
		{"end_render_pass", lua_gfx_end_render_pass},
		{"set_scissor", lua_gfx_set_scissor},
		{"draw_rectangle", lua_gfx_draw_rectangle},
		{"draw_text", lua_gfx_draw_text},
		{nil, nil},
	}
	lua.L_openlib(L, "gfx", raw_data(gfx_reg), 0)
}
