package starry

import "base:runtime"
import "core:math"
import "core:math/linalg"

// this is where we bind starry to lua
// except we actually bind to C, and export these symbols
// we can then access the functions through luajit's ffi module
// if it works it works.

// why the fuck isn't this in the lua std
@(export)
st_round :: proc(x: f32) -> f32
{
	return math.round(x)
}

C_Vec2 :: struct {
	x, y: f32,
}
C_Vec3 :: struct {
	x, y, z: f32,
}
C_Vec4 :: struct {
	x, y, z, w: f32,
}

// can't get this right, just use the odin version
@(export)
st_euler_to_quat :: proc(x, y, z: f32) -> C_Vec4
{
	q := transmute(runtime.Raw_Quaternion128)linalg.quaternion_from_euler_angles(x, y, z, .XYZ)
	return {x = q.imag, y = q.jmag, z = q.kmag, w = q.real}
}

// can't get this right, just use the odin version
@(export)
st_quat_to_euler :: proc(x, y, z, w: f32) -> C_Vec3
{
	q := transmute(quaternion128)runtime.Raw_Quaternion128 {
		imag = x,
		jmag = y,
		kmag = z,
		real = w,
	}
	t1, t2, t3 := linalg.euler_angles_from_quaternion_f32(q, .XYZ)
	return {x = t1, y = t2, z = t3}
}
