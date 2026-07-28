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

lua_open_gfx :: proc "c" (L: ^lua.State)
{
	gfx_reg := []lua.L_Reg {
		{"load_texture", lua_gfx_load_texture},
		{"load_texture_from_memory", lua_gfx_load_texture_from_memory},
		{"clear", lua_gfx_clear},
		{"end_drawing_2d", lua_gfx_end_drawing_2d},
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
