// export a bunch of useful functions from Odin core to lua
package starry

import lua "../thirdparty/luajit"
import "base:runtime"
import "core:c"
import "core:math"
import "core:math/linalg"
import "gpu"

// TODO crossing the C-lua boundary is bad for performance
// a pure Lua math implementation would be better for JIT and whatnot

@(private = "file")
lua_st_round :: proc "c" (L: ^lua.State) -> c.int
{
	// TODO crossing the C-lua boundary is bad for performance
	// a pure Lua implementation would be better for JIT and whatnot
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

// placeholder until there's a renderer
@(private = "file")
lua_st_glorious_red_square :: proc "c" (L: ^lua.State) -> c.int
{
	context = global.ctx

	lua.L_checktype(L, 1, i32(lua.TTABLE))

	lua.getfield(L, 1, "x")
	red := lua.L_optnumber(L, -1, def = 0.0)
	lua.pop(L, 1)

	lua.getfield(L, 1, "y")
	green := lua.L_optnumber(L, -1, def = 0.0)
	lua.pop(L, 1)

	lua.getfield(L, 1, "z")
	blue := lua.L_optnumber(L, -1, def = 0.0)
	lua.pop(L, 1)

	dev := gpu_device()
	gpu.begin_render_pass(
		dev,
		framebuffer = gpu.default_framebuffer(dev),
		color_load_op = .CLEAR,
		clear_color = cast([4]f32)[4]f64{red, green, blue, 1},
	)
	gpu.end_render_pass(dev)
	return 0
}

lua_open_utils :: proc "c" (L: ^lua.State)
{
	lua.getglobal(L, "__st")
	lua.pushcfunction(L, lua_st_round)
	lua.setfield(L, -2, "round")
	lua.pushcfunction(L, lua_st_euler_to_quat)
	lua.setfield(L, -2, "euler_to_quat")
	lua.pushcfunction(L, lua_st_quat_to_euler)
	lua.setfield(L, -2, "quat_to_euler")
	lua.pushcfunction(L, lua_st_glorious_red_square)
	lua.setfield(L, -2, "glorious_red_square")
}
