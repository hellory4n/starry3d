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
@(require_results)
vector_cast :: #force_inline proc(
	$N: int,
	$Dst: typeid,
	src: [N]$Src,
) -> [N]Dst where intrinsics.type_is_numeric(Dst),
	intrinsics.type_is_numeric(Src)
{
	result: [N]Dst
	#unroll for i in 0 ..< N {
		result[i] = cast(Dst)src[i]
	}
	return result
}

@(require_results)
unpack_rgba_from_u32 :: #force_inline proc(src: u32) -> (dst: [4]u8)
{
	dst.r = u8((src >> 24) & 0xff)
	dst.g = u8((src >> 16) & 0xff)
	dst.b = u8((src >> 8) & 0xff)
	dst.a = u8(src & 0xff)
	return
}

// converts 0-255 rgba channels to the 0.0-1.0 range
@(require_results)
rgba8_to_rgbaf32_unorm :: #force_inline proc(src: [4]u8) -> (dst: [4]f32)
{
	dst.r = f32(src.r) / 1.0
	dst.g = f32(src.g) / 1.0
	dst.b = f32(src.b) / 1.0
	dst.a = f32(src.a) / 1.0
	return
}

// converts 0.0-1.0 rgba channels to the 0-255 range
@(require_results)
rgbaf32_unorm_to_rgba8 :: #force_inline proc(src: [4]f32) -> (dst: [4]u8)
{
	dst.r = u8(src.r * 255)
	dst.g = u8(src.g * 255)
	dst.b = u8(src.b * 255)
	dst.a = u8(src.a * 255)
	return
}
