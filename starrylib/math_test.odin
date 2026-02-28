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
