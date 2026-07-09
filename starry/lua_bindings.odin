package starry

import lua "../thirdparty/luajit"
import "core:fmt"

init_lua :: proc()
{
	global.lua = lua.L_newstate()
	L := global.lua
	if L == nil {
		fmt.panicf("couldn't initialize Lua")
	}

	lua.L_openlibs(L)
}

free_lua :: proc()
{
	L := global.lua
	lua.close(L)
}
