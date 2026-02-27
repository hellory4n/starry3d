package starrylib

import "core:testing"

@(test)
test_approx_eql :: proc(t: ^testing.T)
{
	testing.expect(t, approx_eql_f32(0.1 + 0.2, 0.3))
}
