package starrylib

import "core:math"

@(require_results)
approx_eql_f16 :: #force_inline proc(x, y: f16) -> bool
{
	return abs(x - y) < math.F16_EPSILON
}

@(require_results)
approx_eql_f32 :: #force_inline proc(x, y: f32) -> bool
{
	return abs(x - y) < math.F32_EPSILON
}

@(require_results)
approx_eql_f64 :: #force_inline proc(x, y: f64) -> bool
{
	return abs(x - y) < math.F64_EPSILON
}

// uses an epsilon to check if 2 floats are pretty approximately equal
approx_eql :: proc {
	approx_eql_f16,
	approx_eql_f32,
	approx_eql_f64,
}
