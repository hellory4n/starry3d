package starry

import "core:fmt"
import "core:math"

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

@(export)
st_test :: proc "c" ()
{
	context = global.ctx
	fmt.println(":)")
}
