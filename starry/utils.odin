package starry

import "core:os"
import "core:strings"

VERSION_STR :: "v26.7.0-dev"
VERSION_NUM :: 26_07_01
VERSION_MAJOR :: 26
VERSION_MINOR :: 7
VERSION_PATCH :: 0
VERSION_PRERELEASE :: true
COPYRIGHT :: "Copyright (c) 2025-2026 hellory4n <hellory4n@gmail.com>"

// For the laziest of hands
temp_cstr :: proc(src: string) -> cstring
{
	return strings.clone_to_cstring(src, context.temp_allocator)
}

// returns the current position in the file
file_position :: proc(file: ^os.File) -> (pos: i64, err: os.Error)
{
	return os.seek(file, 0, .Current)
}
