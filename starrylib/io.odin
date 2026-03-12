package starrylib

import "base:intrinsics"
import "core:os"

write_int_to_file :: proc(
	file: ^os.File,
	val: $T,
) -> (
	n: int,
	err: os.Error,
) where intrinsics.type_is_integer(T)
{
	tmp := val
	return os.write_ptr(file, &tmp, size_of(T))
}

write_float_to_file :: proc(
	file: ^os.File,
	val: $T,
) -> (
	n: int,
	err: os.Error,
) where intrinsics.type_is_float(T)
{
	tmp := val
	return os.write_ptr(file, &tmp, size_of(T))
}

// returns the current position in the file
file_tell :: proc(file: ^os.File) -> (pos: i64, err: os.Error)
{
	return os.seek(file, 0, .Current)
}
