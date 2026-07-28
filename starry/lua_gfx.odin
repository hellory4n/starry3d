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

	lua.newtable(L)
	lua.L_setmetatable(L, "gfx_Texture")
	lua.pushinteger(L, lua.Integer(transmute(u32)handle))
	lua.setfield(L, -2, "id")
	lua_push_vec2(L, size)
	lua.setfield(L, -2, "size")
	lua_push_odin_string(L, path)
	lua.setfield(L, -2, "path")

	lua.pushboolean(L, b32(ok))
	return 2
}

@(private = "file")
lua_gfx_load_texture_from_memory :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	buffer := lua_check_odin_string(L, 1)

	handle, ok := load_texture_from_memory(transmute([]byte)buffer)
	size: [2]f64
	if ok {
		data := texture_data(handle)
		size.x = f64(data.img.width)
		size.y = f64(data.img.height)
	}

	lua.newtable(L)
	lua.L_setmetatable(L, "gfx_Texture")
	lua.pushinteger(L, lua.Integer(transmute(u32)handle))
	lua.setfield(L, -2, "id")
	lua_push_vec2(L, size)
	lua.setfield(L, -2, "size")
	lua_push_odin_string(L, "[buffer]")
	lua.setfield(L, -2, "path")

	lua.pushboolean(L, b32(ok))
	return 2
}

lua_gfx_texture_gc :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	lua.L_checktype(L, 1, i32(lua.TTABLE))
	lua.getfield(L, 1, "id")
	handle := transmute(hm.Handle32)u32(lua.L_optinteger(L, -1, 0))
	lua.pop(L, 1)

	unload_texture(handle)
	return 0
}

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

lua_gfx_end_drawing_2d :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	end_drawing_2d()
	return 0
}

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

	lua.getfield(L, 1, "texture")
	if !lua.isnil(L, -1) {
		lua.getfield(L, -1, "id")
		desc.texture = transmute(hm.Handle32)u32(lua.L_optinteger(L, -1, 0))
		lua.pop(L, 1)
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

lua_open_gfx :: proc "c" (L: ^lua.State)
{
	gfx_reg := []lua.L_Reg {
		{"load_texture", lua_gfx_load_texture},
		{"load_texture_from_memory", lua_gfx_load_texture_from_memory},
		{"clear", lua_gfx_clear},
		{"end_drawing_2d", lua_gfx_end_drawing_2d},
		{"draw_rectangle", lua_gfx_draw_rectangle},
		{nil, nil},
	}
	lua.L_openlib(L, "gfx", raw_data(gfx_reg), 0)

	lua.L_newmetatable(L, "gfx_Texture")
	lua.pushvalue(L, -1)
	lua.setfield(L, -2, "__index")
	// TODO not sure if this is being called
	lua.pushcfunction(L, lua_gfx_texture_gc)
	lua.setfield(L, -2, "__gc")
}
