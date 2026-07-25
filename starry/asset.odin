package starry

import "core:fmt"
import "core:mem"
import "core:os"

// Lua: `app.dir`
app_dir :: proc() -> string
{
	if len(global.args.app_dir) > 0 {
		return global.args.app_dir
	}
	return global.exe_dir
}

// Reads a file and all of its contents, relative to the directory of where the engine is located.
read_from_exe_dir :: proc(path: string, allocator: mem.Allocator) -> (data: []byte, err: os.Error)
{
	data = os.read_entire_file_from_path(
		fmt.tprintf("%s/%s", app_dir(), path),
		allocator,
	) or_return
	return data, nil
}

// `read_from_exe_dir` except you don't have to copy the whole thing just to add ONE element to it
// (you still have to cast it (so you're not forced to scan the whole string for the length (only
// the stupid C code that can only take in a cstring is forced to scan the whole string)))
read_from_exe_dir_as_cstring :: proc(
	path: string,
	allocator: mem.Allocator,
) -> (
	data: []byte,
	err: os.Error,
)
{
	file := os.open(fmt.tprintf("%s/%s", app_dir(), path)) or_return
	defer os.close(file)

	size := os.seek(file, offset = 0, whence = .End) or_return
	os.seek(file, offset = 0, whence = .Start) or_return

	data = make([]byte, size + 1, allocator)
	os.read(file, data) or_return

	return data, nil
}
