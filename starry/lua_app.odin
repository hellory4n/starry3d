package starry

import lua "../thirdparty/luajit"
import "core:c"

@(private = "file")
lua_app_now_secs :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := now_secs()
	lua.pushnumber(L, lua.Number(res))
	return 1
}

@(private = "file")
lua_app_delta_time :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := delta_time()
	lua.pushnumber(L, lua.Number(res))
	return 1
}

@(private = "file")
lua_app_dir :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := app_dir()
	lua.pushlstring(L, cast(cstring)raw_data(res), c.size_t(len(res)))
	return 1
}

@(private = "file")
lua_app_read_from_app_dir :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	path := string(lua.L_checkstring(L, 1))

	data, err := read_from_app_dir(path, context.allocator)
	defer delete(data)

	lua.pushlstring(L, cast(cstring)raw_data(data), c.size_t(len(data)))
	lua.pushboolean(L, b32(err == nil)) // ok
	return 2
}

@(private = "file")
lua_app_mouse_pos :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := mouse_pos()
	lua.newtable(L)
	lua.getglobal(L, "Vec2")
	lua.setmetatable(L, -2)
	lua.pushnumber(L, lua.Number(res[0]))
	lua.setfield(L, -2, "x")
	lua.pushnumber(L, lua.Number(res[1]))
	lua.setfield(L, -2, "y")
	return 1
}

@(private = "file")
lua_app_delta_mouse_pos :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := delta_mouse_pos()
	lua.newtable(L)
	lua.getglobal(L, "Vec2")
	lua.setmetatable(L, -2)
	lua.pushnumber(L, lua.Number(res[0]))
	lua.setfield(L, -2, "x")
	lua.pushnumber(L, lua.Number(res[1]))
	lua.setfield(L, -2, "y")
	return 1
}

@(private = "file")
lua_app_key_just_pressed :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	key := key_from_string(lua_check_odin_string(L, 1))
	res := key_just_pressed(key)
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_key_held :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	key := key_from_string(string(lua.L_checkstring(L, 1)))
	res := key_held(key)
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_key_just_released :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	key := key_from_string(lua_check_odin_string(L, 1))
	arg := key_just_released(key)
	lua.pushboolean(L, b32(arg))
	return 1
}

@(private = "file")
lua_app_key_not_pressed :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	key := key_from_string(lua_check_odin_string(L, 1))
	res := key_not_pressed(key)
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_mouse_just_pressed :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	btn := mouse_button_from_string(lua_check_odin_string(L, 1))
	res := mouse_just_pressed(btn)
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_mouse_held :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	btn := mouse_button_from_string(lua_check_odin_string(L, 1))
	res := mouse_held(btn)
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_mouse_just_released :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	btn := mouse_button_from_string(lua_check_odin_string(L, 1))
	res := mouse_just_released(btn)
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_mouse_not_pressed :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	btn := mouse_button_from_string(lua_check_odin_string(L, 1))
	res := mouse_not_pressed(btn)
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_frame_size :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := frame_sizef()
	lua.newtable(L)
	lua.getglobal(L, "Vec2")
	lua.setmetatable(L, -2)
	lua.pushnumber(L, lua.Number(res[0]))
	lua.setfield(L, -2, "x")
	lua.pushnumber(L, lua.Number(res[1]))
	lua.setfield(L, -2, "y")
	return 1
}

@(private = "file")
lua_app_aspect_ratio :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := aspect_ratio()
	lua.pushnumber(L, lua.Number(res))
	return 1
}

@(private = "file")
lua_app_high_dpi :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := high_dpi()
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_scale_factor :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := scale_factor()
	lua.pushnumber(L, lua.Number(res))
	return 1
}

@(private = "file")
lua_app_lock_mouse :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	lock := lua_check_boolean(L, 1)
	lock_mouse(lock)
	return 0
}

@(private = "file")
lua_app_mouse_locked :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := mouse_locked()
	lua.pushboolean(L, b32(res))
	return 1
}

@(private = "file")
lua_app_request_quit :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	request_quit()
	return 0
}

@(private = "file")
lua_app_set_title :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	title := lua_check_odin_string(L, 1)
	set_title(title)
	return 0
}

@(private = "file")
lua_app_mouse_scroll :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	res := mouse_scroll()
	lua_push_vec2(L, cast([2]f64)res)
	return 1
}

lua_open_app :: proc "c" (L: ^lua.State)
{
	mod := []lua.L_Reg {
		{"now_secs", lua_app_now_secs},
		{"delta_time", lua_app_delta_time},
		{"dir", lua_app_dir},
		{"read_from_app_dir", lua_app_read_from_app_dir},
		{"mouse_pos", lua_app_mouse_pos},
		{"delta_mouse_pos", lua_app_delta_mouse_pos},
		{"key_just_pressed", lua_app_key_just_pressed},
		{"key_held", lua_app_key_held},
		{"key_just_released", lua_app_key_just_released},
		{"key_not_pressed", lua_app_key_not_pressed},
		{"mouse_just_pressed", lua_app_mouse_just_pressed},
		{"mouse_held", lua_app_mouse_held},
		{"mouse_just_released", lua_app_mouse_just_released},
		{"mouse_not_pressed", lua_app_mouse_not_pressed},
		{"frame_size", lua_app_frame_size},
		{"aspect_ratio", lua_app_aspect_ratio},
		{"high_dpi", lua_app_high_dpi},
		{"scale_factor", lua_app_scale_factor},
		{"lock_mouse", lua_app_lock_mouse},
		{"mouse_locked", lua_app_mouse_locked},
		{"request_quit", lua_app_request_quit},
		{"set_title", lua_app_set_title},
		{"mouse_scroll", lua_app_mouse_scroll},
		{nil, nil},
	}
	lua.L_openlib(L, "app", raw_data(mod), 0)
}
