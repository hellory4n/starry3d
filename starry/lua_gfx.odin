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
	size: [2]f64
	if ok {
		data := texture_data(handle)
		size.x = f64(data.img.width)
		size.y = f64(data.img.height)
	}

	userdata := cast(^hm.Handle32)lua.newuserdata(L, size_of(hm.Handle32))
	userdata^ = handle

	if b32(lua.L_newmetatable(L, "gfx_Texture")) {
		lua.pushcfunction(L, lua_gfx_texture_gc)
		lua.setfield(L, -2, "__gc")

		lua.pushcfunction(L, lua_gfx_texture_index)
		lua.setfield(L, -2, "__index")
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
		lua_push_vec2(L, {f64(data.img.width), f64(data.img.height)})
	case:
		lua.pushnil(L)
	}

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
lua_gfx_clear :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	color: [4]f64
	if !lua.isnoneornil(L, 1) {
		lua.L_checktype(L, 1, i32(lua.TTABLE))
		color = lua_check_vec4(L, 1)
	}

	clear_screen(cast([4]f32)color)
	return 0
}

@(private = "file")
lua_gfx_end_drawing_2d :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	end_drawing_2d()
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
		desc.filter = .NEAREST_NEIGHBOR
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
			texdata := texture_data(desc.texture)
			desc.texture_size = {f32(texdata.img.width), f32(texdata.img.height)}
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
	desc.color = cast([4]f32)lua_check_vec4(L, -1)
	lua.pop(L, 1)

	lua.getfield(L, 1, "font")
	desc.font = (cast(^hm.Handle32)lua.touserdata(L, -1))^
	lua.pop(L, 2)

	lua.getfield(L, 1, "halign")
	if lua.isnil(L, -1) {
		halign_str := lua_check_odin_string(L, -1)
		switch halign_str {
		case "left":
			desc.halign = .LEFT
		case "center":
			desc.halign = .CENTER
		case "right":
			desc.halign = .RIGHT
		case:
			fmt.panicf(
				"unexpected enum %q; should be 'left', 'center', or 'right'",
				halign_str,
			)
		}
	} else {
		desc.halign = .LEFT
	}
	lua.pop(L, 1)

	lua.getfield(L, 1, "valign")
	if lua.isnil(L, -1) {
		valign_str := lua_check_odin_string(L, -1)
		switch valign_str {
		case "top":
			desc.valign = .TOP
		case "middle":
			desc.valign = .MIDDLE
		case "bottom":
			desc.valign = .BOTTOM
		case "baseline":
			desc.valign = .BASELINE
		case:
			fmt.panicf(
				"unexpected enum %q; should be 'top', 'middle', 'bottom', or 'baseline'",
				valign_str,
			)
		}
	} else {
		desc.valign = .BASELINE
	}
	lua.pop(L, 1)

	draw_text(desc)
	return 0
}

lua_open_gfx :: proc "c" (L: ^lua.State)
{
	gfx_reg := []lua.L_Reg {
		{"load_texture", lua_gfx_load_texture},
		{"load_font", lua_gfx_load_font},
		{"clear", lua_gfx_clear},
		{"end_drawing_2d", lua_gfx_end_drawing_2d},
		{"draw_rectangle", lua_gfx_draw_rectangle},
		{"draw_text", lua_gfx_draw_text},
		{nil, nil},
	}
	lua.L_openlib(L, "gfx", raw_data(gfx_reg), 0)
}
