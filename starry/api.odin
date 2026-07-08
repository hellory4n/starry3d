package starryexe

import st "../api/odin"
import "base:runtime"
import "core:fmt"

// reuse the odin binding's definitions
Api :: st.Api

shitfuck :: proc "c" ()
{
	context = runtime.default_context()
	fmt.println(":)")
}

DEFAULT_API :: Api {
	shitfuck = shitfuck,
}
