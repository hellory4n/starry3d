package starry

import "base:runtime"
import hm "core:container/handle_map"
import "core:math"
import "core:math/linalg"
import "gpu"

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

// transmute my beloved
#assert(size_of(i32) == size_of(hm.Handle32))
#assert(size_of(i64) == size_of(hm.Handle64))
#assert(size_of([2]f32) == size_of(C_Vec2))
#assert(size_of([3]f32) == size_of(C_Vec3))
#assert(size_of([4]f32) == size_of(C_Vec4))

@(export)
st_app_gpu :: proc "c" () -> i32
{
	context = global.ctx
	return transmute(i32)gpu_device()
}

@(export)
stgpu_begin_render_pass :: proc "c" (
	dev: i32,
	framebuffer: i32,
	color_load_op: i32,
	color_store_op: i32,
	depth_load_op: i32,
	depth_store_op: i32,
	clear_color_r: f32,
	clear_color_g: f32,
	clear_color_b: f32,
	clear_color_a: f32,
	clear_depth: f32,
)
{
	context = global.ctx
	gpu.begin_render_pass(
		transmute(gpu.Device)dev,
		transmute(gpu.Framebuffer)framebuffer,
		gpu.Load_Op(color_load_op),
		gpu.Store_Op(color_store_op),
		gpu.Load_Op(depth_load_op),
		gpu.Store_Op(depth_store_op),
		{clear_color_r, clear_color_g, clear_color_b, clear_color_a},
		clear_depth,
	)
}

@(export)
stgpu_end_render_pass :: proc "c" (dev: i32)
{
	context = global.ctx
	gpu.end_render_pass(transmute(gpu.Device)dev)
}

@(export)
stgpu_default_framebuffer :: proc "c" (dev: i32) -> i32
{
	context = global.ctx
	return transmute(i32)gpu.default_framebuffer(transmute(gpu.Device)dev)
}
