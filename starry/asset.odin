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
// Lua: `app.read_from_app_dir`
read_from_app_dir :: proc(path: string, allocator: mem.Allocator) -> (data: []byte, err: os.Error)
{
	data = os.read_entire_file_from_path(
		fmt.tprintf("%s/%s", app_dir(), path),
		allocator,
	) or_return
	return data, nil
}
