package builder

import "base:runtime"
import "core:c/libc"
import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc()
{
	// fuck you
	context.allocator = context.temp_allocator
	defer free_all(context.temp_allocator)

	args: Args
	flags.parse_or_exit(&args, os.args)

	// TODO libstarry is so very special and should be built as a static lib
	// for performance
	odin_args := build_odin_args("libs/starry", args, .Dynamic)
	// easier that way :)
	// TODO don't
	exit_code := libc.system(strings.clone_to_cstring(odin_args))

	if exit_code != 0 {
		fmt.eprintfln("\ncommand %q returned exit code %d, aborting", odin_args, exit_code)
		return
	}
}

Args :: struct {
	release: bool,
}

build_odin_args :: proc(
	pkg: string,
	args: Args,
	build_mode: runtime.Odin_Build_Mode_Type,
) -> string
{
	cflags: strings.Builder
	strings.builder_init(&cflags)
	strings.write_string(&cflags, "odin build ")
	strings.write_string(&cflags, pkg)

	// base args
	strings.write_string(&cflags, " -vet-shadowing -vet-using-stmt")

	switch build_mode {
	case .Executable:
		strings.write_string(&cflags, " -build-mode:exe")
	case .Dynamic:
		strings.write_string(&cflags, " -build-mode:dynamic")
	case .Static:
		strings.write_string(&cflags, " -build-mode:static")
	case .Object:
		strings.write_string(&cflags, " -build-mode:object")
	case .Assembly:
		strings.write_string(&cflags, " -build-mode:assembly")
	case .LLVM_IR:
		strings.write_string(&cflags, " -build-mode:llvm")
	}

	if args.release {
		// TODO is there any benefit to omitting debug symbols other than size?
		strings.write_string(&cflags, " -debug -o:speed")
	} else {
		strings.write_string(&cflags, " -debug -o:none")
	}

	// automagic output filename selection
	if build_mode == .Dynamic && ODIN_OS != .Windows {
		strings.write_string(&cflags, " -out:lib")
		strings.write_string(&cflags, os.base(pkg))
		strings.write_string(&cflags, ".so")
	}

	if build_mode == .Static && ODIN_OS != .Windows {
		strings.write_string(&cflags, " -out:lib")
		strings.write_string(&cflags, os.base(pkg))
		strings.write_string(&cflags, ".a")
	}

	return strings.to_string(cflags)
}
