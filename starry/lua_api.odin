package starry

import "core:fmt"

// this is where we bind starry to lua
// except we actually bind to C, and export these symbols
// we can then access the functions through luajit's ffi module
// if it works it works.

@(export)
stlua_test :: proc "c" ()
{
	context = global.ctx
	fmt.println(":)")
}
