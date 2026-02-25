package starrylib

import "base:intrinsics"
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

// mr odin why would you ever do that
vector_cast :: #force_inline proc(
	$N: int,
	$Dst: typeid,
	src: [N]$Src,
) -> [2]Dst where intrinsics.type_is_numeric(Dst),
	intrinsics.type_is_numeric(Src)
{
	result: [N]Dst
	#unroll for i in 0 ..< N {
		result[i] = cast(Dst)src[i]
	}
	return result
}
