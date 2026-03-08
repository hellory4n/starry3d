package starrylib

import "core:testing"

@(test)
t_approx_eql :: proc(t: ^testing.T)
{
	testing.expect(t, approx_eql_f32(0.1 + 0.2, 0.3))
}

@(test)
t_vector_cast :: proc(t: ^testing.T)
{
	src := [3]i32{1, 2, 3}
	dst := vector_cast(3, f32, src)
	testing.expect(t, approx_eql(dst.x, 1))
	testing.expect(t, approx_eql(dst.y, 2))
	testing.expect(t, approx_eql(dst.z, 3))
}

@(test)
t_unpack_rgba_from_u32 :: proc(t: ^testing.T)
{
	src: u32 = 0x11223344
	dst := unpack_rgba_from_u32(src)
	testing.expect_value(t, dst.r, 0x11)
	testing.expect_value(t, dst.g, 0x22)
	testing.expect_value(t, dst.b, 0x33)
	testing.expect_value(t, dst.a, 0x44)
}

@(test)
t_unpack_argb_from_u32 :: proc(t: ^testing.T)
{
	src: u32 = 0x11223344
	dst := unpack_argb_from_u32(src)
	testing.expect_value(t, dst.a, 0x11)
	testing.expect_value(t, dst.r, 0x22)
	testing.expect_value(t, dst.g, 0x33)
	testing.expect_value(t, dst.b, 0x44)
}

@(test)
t_flatten_unflatten_3d_idx :: proc(t: ^testing.T)
{
	SIZE :: [3]int{256, 128, 64}
	src := [3]int{67, 38, 61}
	tmp := flatten_3d_idx(SIZE, src)
	dst := unflatten_3d_idx(SIZE, tmp)
	testing.expect_value(t, dst, src)
}
