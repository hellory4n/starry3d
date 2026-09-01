package starry

import "base:intrinsics"
import "base:runtime"
import "core:fmt"

// returns starry's custom context (logger, panic handler)
init_starry_context :: proc() -> (ctx: runtime.Context)
{
	ctx = runtime.default_context()
	ctx.assertion_failure_proc = _assertion_failure
	return ctx
}

@(private)
_assertion_failure :: proc(prefix, message: string, loc: runtime.Source_Code_Location) -> !
{
	// i'm annoying
	prefix := prefix
	switch prefix {
	case "runtime assertion":
		prefix = "failed assertion"
	}

	str := fmt.tprintf("%s at %v", prefix, loc)
	if len(message) > 0 {
		str = fmt.tprintf("%s: %s", str, message)
	}

	fmt.println(str)
	message_box(.ERROR, str)
	intrinsics.trap()
}
