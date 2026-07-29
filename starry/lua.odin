package starry

import lua "../thirdparty/luajit"
import "core:c"
import "core:fmt"

init_lua :: proc()
{
	// TODO lua allocates many small objects, use a custom allocator
	// https://blog.voxagon.se/2012/12/22/small-object-allocator.html
	global.lua = lua.L_newstate()
	L := global.lua
	if L == nil {
		fmt.panicf("couldn't initialize Lua")
	}

	lua.atpanic(L, proc "c" (L: ^lua.State) -> c.int
	{
		context = global.ctx
		fmt.printfln("lua panic: %s", lua.tostring(L, -1))
		lua.L_traceback(L, L, nil, 1)
		fmt.printfln("%s", lua.tostring(L, -1))
		panic("aborting")
	})

	// yes it has to be this exact order
	lua.L_openlibs(L)
	lua_open_app(L)
	lua_run_bytes(L, #load("../lualibs/boot.lua"), "(preloaded) lualibs/boot.lua")
	lua_open_utils(L)
	lua_run_bytes(L, #load("../lualibs/table.lua"), "(preloaded) lualibs/preloaded/boot.lua")
	lua_run_bytes(L, #load("../lualibs/math.lua"), "(preloaded) lualibs/math.lua")
	lua_open_gfx(L)
}

free_lua :: proc()
{
	L := global.lua
	lua.close(L)
}

lua_run :: proc(L: ^lua.State, path: string) -> bool
{
	if lua.L_loadfile(L, fmt.ctprintf("%s/%s", app_dir(), path)) != lua.OK {
		lua_error(L)
		return false
	}

	if lua.pcall(L, 0, 0, 0) != i32(lua.OK) {
		lua_error(L)
	}
	return true
}

lua_run_bytes :: proc(L: ^lua.State, code: []byte, label: cstring = "unknown script") -> bool
{
	if lua.L_loadbuffer(L, raw_data(code), len(code), label) != lua.OK {
		lua_error(L)
		return false
	}

	if lua.pcall(L, 0, 0, 0) != i32(lua.OK) {
		lua_error(L)
	}
	return true
}

lua_error :: proc(L: ^lua.State)
{
	err := lua.tostring(L, -1)
	fmt.println(err)
	lua.pop(L, 1)
}

lua_msg_handler :: proc "c" (L: ^lua.State) -> c.int
{
	msg := lua.tostring(L, 1)
	if msg == nil {
		if lua.L_callmeta(L, 1, "__tostring") != 0 {
			msg = lua.tostring(L, -1)
		} else {
			msg = "(error object isn't a string)"
		}
	}

	// append stack trace
	lua.L_traceback(L, L, msg, 1) // level 1 to skip this function
	return 1
}

lua_call :: proc(L: ^lua.State, nargs, nresults: c.int)
{
	msgh := lua.gettop(L) - nargs
	lua.pushcfunction(L, lua_msg_handler)
	lua.insert(L, msgh)

	if lua.pcall(L, nargs, nresults, msgh) != i32(lua.OK) {
		lua_error(L)
	}

	lua.remove(L, msgh)
}

// get string arg and handle length properly
lua_check_odin_string :: proc "c" (L: ^lua.State, num_arg: c.int) -> string
{
	slen: c.size_t
	cstr := lua.L_checkstring(L, num_arg, &slen)
	return string((cast([^]byte)cstr)[:slen])
}

lua_push_odin_string :: proc "c" (L: ^lua.State, s: string)
{
	lua.pushlstring(L, cast(cstring)raw_data(s), c.size_t(len(s)))
}

lua_check_vec2 :: proc "c" (L: ^lua.State, num_arg: c.int) -> (res: [2]f64)
{
	lua.L_checktype(L, num_arg, i32(lua.TTABLE))

	lua.getfield(L, num_arg, "x")
	res.x = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	lua.getfield(L, num_arg, "y")
	res.y = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	return res
}

lua_check_vec3 :: proc "c" (L: ^lua.State, num_arg: c.int) -> (res: [3]f64)
{
	lua.L_checktype(L, num_arg, i32(lua.TTABLE))

	lua.getfield(L, num_arg, "x")
	res.x = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	lua.getfield(L, num_arg, "y")
	res.y = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	lua.getfield(L, num_arg, "z")
	res.z = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	return res
}

lua_check_vec4 :: proc "c" (L: ^lua.State, num_arg: c.int) -> (res: [4]f64)
{
	lua.L_checktype(L, num_arg, i32(lua.TTABLE))

	lua.getfield(L, num_arg, "x")
	res.x = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	lua.getfield(L, num_arg, "y")
	res.y = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	lua.getfield(L, num_arg, "z")
	res.z = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	lua.getfield(L, num_arg, "w")
	res.w = lua.L_optnumber(L, -1, def = 0)
	lua.pop(L, 1)

	return res
}

lua_push_vec2 :: proc "c" (L: ^lua.State, v: [2]f64)
{
	lua.newtable(L)
	lua.getglobal(L, "Vec2")
	lua.setmetatable(L, -2)
	lua.pushnumber(L, lua.Number(v[0]))
	lua.setfield(L, -2, "x")
	lua.pushnumber(L, lua.Number(v[1]))
	lua.setfield(L, -2, "y")
}

lua_push_vec3 :: proc "c" (L: ^lua.State, v: [3]f64)
{
	lua.newtable(L)
	lua.getglobal(L, "Vec3")
	lua.setmetatable(L, -2)
	lua.pushnumber(L, lua.Number(v[0]))
	lua.setfield(L, -2, "x")
	lua.pushnumber(L, lua.Number(v[1]))
	lua.setfield(L, -2, "y")
	lua.pushnumber(L, lua.Number(v[2]))
	lua.setfield(L, -2, "z")
}

lua_push_vec4 :: proc "c" (L: ^lua.State, v: [4]f64)
{
	lua.newtable(L)
	lua.getglobal(L, "Vec4")
	lua.setmetatable(L, -2)
	lua.pushnumber(L, lua.Number(v[0]))
	lua.setfield(L, -2, "x")
	lua.pushnumber(L, lua.Number(v[1]))
	lua.setfield(L, -2, "y")
	lua.pushnumber(L, lua.Number(v[2]))
	lua.setfield(L, -2, "z")
	lua.pushnumber(L, lua.Number(v[3]))
	lua.setfield(L, -2, "w")
}
