package starry

import lua "../thirdparty/luajit"
import "core:c"
import "core:fmt"

init_lua :: proc()
{
	global.lua = lua.L_newstate()
	L := global.lua
	if L == nil {
		fmt.panicf("couldn't initialize Lua")
	}

	lua.L_openlibs(L)
	lua_run(L, #load("lua/table.lua", cstring))
	lua_run(L, #load("lua/math.lua", cstring))
	lua_run(L, #load("lua/builtin.lua", cstring))
}

free_lua :: proc()
{
	L := global.lua
	lua.close(L)
}

lua_run :: proc(L: ^lua.State, code: cstring) -> bool
{
	if lua.L_dostring(L, code) != i32(lua.OK) {
		lua_error(L)
		return false
	}
	return true
}

lua_error :: proc(L: ^lua.State)
{
	err := lua.tostring(L, -1)
	fmt.println(err)
	lua.pop(L, 1)
}

Lua_Variant :: union {
	lua.Number,
	lua.Integer,
	string,
	cstring,
	b32,
	rawptr,
}

// expects the function to have no returns
call_lua_function :: proc(L: ^lua.State, func_name: cstring, args: ..Lua_Variant) -> (ok: bool)
{
	lua.getglobal(L, func_name)

	for arg in args {
		switch v in arg {
		case lua.Number:
			lua.pushnumber(L, v)
		case lua.Integer:
			lua.pushinteger(L, v)
		case string:
			lua.pushlstring(L, cast(cstring)raw_data(v), c.size_t(len(v)))
		case cstring:
			lua.pushstring(L, v)
		case b32:
			lua.pushboolean(L, v)
		case rawptr:
			lua.pushlightuserdata(L, v)
		case:
			lua.pushnil(L)
		}
	}

	if lua.pcall(L, nargs = i32(len(args)), nresults = 0, errfunc = 0) != i32(lua.OK) {
		lua_error(L)
		return false
	}

	return true
}
