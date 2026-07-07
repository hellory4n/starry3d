package libstarry

import "base:runtime"
import "core:fmt"

@(export)
st_shitfuck :: proc "c" ()
{
	context = runtime.default_context() // TODO
	fmt.println(":)")
}
