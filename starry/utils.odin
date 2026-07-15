package starry

import "core:fmt"
import "core:math"
import "core:mem"
import "core:os"
import "core:strings"
import "core:sys/windows"
import "vendor:glfw"

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

@(require_results)
approx_eql_f16 :: #force_inline proc(x, y: f16) -> bool
{
	return abs(x - y) < math.F16_EPSILON
}

@(require_results)
approx_eql_f32 :: #force_inline proc(x, y: f32) -> bool
{
	return abs(x - y) < math.F32_EPSILON
}

@(require_results)
approx_eql_f64 :: #force_inline proc(x, y: f64) -> bool
{
	return abs(x - y) < math.F64_EPSILON
}

// uses an epsilon to check if 2 floats are pretty approximately equal
approx_eql :: proc {
	approx_eql_f16,
	approx_eql_f32,
	approx_eql_f64,
}

win32_to_cstring16 :: proc(s: string, allocator: mem.Allocator) -> cstring16
{
	size := windows.MultiByteToWideChar(windows.CP_UTF8, 0, raw_data(s), -1, nil, 0)
	ensure(size != 0)
	buf := make([]u16, size + 1, allocator)
	res := windows.MultiByteToWideChar(
		windows.CP_UTF8,
		0,
		raw_data(s),
		-1,
		raw_data(buf),
		size,
	)
	ensure(res != 0)
	return cstring16(raw_data(buf))
}

Message_Box_Level :: enum {
	ERROR,
	WARNING,
	INFO,
}

message_box :: proc(level: Message_Box_Level, msg: string)
{
	// TODO use zenity
	when ODIN_OS != .Windows {
		fmt.printfln(msg)
		return
	}

	msg16 := win32_to_cstring16(msg, context.temp_allocator)
	flags: windows.UINT = windows.MB_OK
	switch level {
	case .ERROR:
		flags |= windows.MB_ICONERROR
	case .WARNING:
		flags |= windows.MB_ICONWARNING
	case .INFO:
		flags |= windows.MB_ICONINFORMATION
	}

	windows.MessageBoxW(
		hWnd = nil if main_window() == nil else glfw.GetWin32Window(main_window().glfw),
		lpText = msg16,
		lpCaption = "Starry",
		uType = flags,
	)
}
