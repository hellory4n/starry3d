// export a bunch of useful functions to lua
package starry

import lua "../thirdparty/luajit"
import "base:runtime"
import "core:c"
import "core:math"
import "core:math/linalg"

// TODO crossing the C-lua boundary is bad for performance
// a pure Lua math implementation would be better for JIT and whatnot

@(private = "file")
lua_st_round :: proc "c" (L: ^lua.State) -> c.int
{
	x := lua.L_checknumber(L, 1)
	lua.pushnumber(L, math.round(x))
	return 1
}

@(private = "file")
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

@(private = "file")
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
	reg := []lua.L_Reg {
		{"round", lua_st_round},
		{"euler_to_quat", lua_st_euler_to_quat},
		{"quat_to_euler", lua_st_quat_to_euler},
		{nil, nil},
	}
	lua.newtable(L)
	lua.L_setfuncs(L, raw_data(reg), 0)
	lua.setglobal(L, "__st")
}
