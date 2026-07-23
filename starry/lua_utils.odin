// export a bunch of useful functions from Odin core to lua
package starry

import lua "../thirdparty/luajit"
import "base:runtime"
import "core:c"
import "core:math"
import "core:math/linalg"
import "core:strings"

// TODO not sure how string allocation should work
// lua is gonna copy all of them anyway

lua_string_replace_all :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx
	str_len: c.size_t
	str_cstr := lua.L_checkstring(L, 1, &str_len)
	str := string((cast([^]byte)str_cstr)[:str_len])

	oldstr_len: c.size_t
	oldstr_cstr := lua.L_checkstring(L, 2, &oldstr_len)
	oldstr := string((cast([^]byte)oldstr_cstr)[:oldstr_len])

	newstr_len: c.size_t
	newstr_cstr := lua.L_checkstring(L, 3, &newstr_len)
	newstr := string((cast([^]byte)newstr_cstr)[:newstr_len])

	res, _ := strings.replace_all(str, oldstr, newstr)

	lua.pushlstring(L, cast(cstring)raw_data(res), c.size_t(len(res)))
	return 1
}

// TODO crossing the C-lua boundary is bad for performance
// a pure Lua math implementation would be better for JIT and whatnot

lua_st_round :: proc "c" (L: ^lua.State) -> c.int
{
	// TODO crossing the C-lua boundary is bad for performance
	// a pure Lua implementation would be better for JIT and whatnot
	x := lua.L_checknumber(L, 1)
	lua.pushnumber(L, math.round(x))
	return 1
}

lua_st_euler_to_quat :: proc "c" (L: ^lua.State) -> c.int
{
	x := lua.L_checknumber(L, 1)
	y := lua.L_checknumber(L, 2)
	z := lua.L_checknumber(L, 3)

	q := transmute(runtime.Raw_Quaternion256)linalg.quaternion_from_euler_angles_f64(
		x,
		y,
		z,
		.XYZ,
	)

	lua.pushnumber(L, q.imag)
	lua.pushnumber(L, q.jmag)
	lua.pushnumber(L, q.kmag)
	lua.pushnumber(L, q.real)
	return 4
}

lua_st_quat_to_euler :: proc "c" (L: ^lua.State) -> c.int
{
	imag := lua.L_checknumber(L, 1)
	jmag := lua.L_checknumber(L, 2)
	kmag := lua.L_checknumber(L, 3)
	real := lua.L_checknumber(L, 4)

	q := transmute(quaternion256)runtime.Raw_Quaternion256{imag, jmag, kmag, real}
	x, y, z := linalg.euler_angles_from_quaternion_f64(q, .XYZ)

	lua.pushnumber(L, x)
	lua.pushnumber(L, y)
	lua.pushnumber(L, z)
	return 3
}

lua_open_utils :: proc "c" (L: ^lua.State)
{
	lua.getglobal(L, "string")
	lua.pushcfunction(L, lua_string_replace_all)
	lua.setfield(L, -2, "replace_all")

	lua.getglobal(L, "__st")
	lua.pushcfunction(L, lua_st_round)
	lua.setfield(L, -2, "round")
}
