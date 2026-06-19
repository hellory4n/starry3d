/*
# The Starry general purpose libraries

This packages features components of Starry which may be put into any program, without depending on
the runtime.
*/
package starrylib

import "base:intrinsics"
import "base:runtime"
import "core:fmt"
import "core:io"
import "core:log"
import "core:mem"
import "core:os"

VERSION_NUM :: 2026_06_00 // v2026.6.0
VERSION_STR :: "v2026.6.0-dev"
VERSION_MAJOR :: 2026
VERSION_MINOR :: 6
VERSION_PATCH :: 0

// A short string used in many places to uniquely identify something.
//
// Note that if creating those things is fully automatic, it's usually better to use an
// incrementing 32-bit index, or `core:container/handle_map`.
Tag32 :: distinct [4]byte

// A short string used in many places to uniquely identify something.
//
// Note that if creating those things is fully automatic, it's usually better to use an
// incrementing 32-bit index, or `core:container/handle_map`.
Tag64 :: distinct [8]byte

// `st.tag32("crap")` looks nicer than `st.Tag32{'c', 'r', 'a', 'p'}`
tag32 :: #force_inline proc "contextless" (src: $T) -> Tag32 where intrinsics.type_is_string(T)
{
	return Tag32{src[0], src[1], src[2], src[3]}
}

// `st.tag64("crapfric")` looks nicer than `st.Tag64{'c', 'r', 'a', 'p', 'f', 'r', 'i', 'c'}`
tag64 :: #force_inline proc "contextless" (src: $T) -> Tag64 where intrinsics.type_is_string(T)
{
	return Tag64{src[0], src[1], src[2], src[3], src[4], src[5], src[6], src[7]}
}

Tag32_Formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> (ok: bool)
{
	tag := cast(^Tag32)arg.data
	switch verb {
	case 'v', 's':
		_, err := io.write(fi.writer, tag[:])
		if err != nil do return false
	case 'q':
		_, err := io.write_rune(fi.writer, '"')
		if err != nil do return false
		_, err = io.write(fi.writer, tag[:])
		if err != nil do return false
		_, err = io.write_rune(fi.writer, '"')
		if err != nil do return false
	case 'w':
		_, err := io.write_string(fi.writer, "st.tag32(\"")
		if err != nil do return false
		_, err = io.write(fi.writer, tag[:])
		if err != nil do return false
		_, err = io.write_string(fi.writer, "\")")
		if err != nil do return false
	case:
		return false
	}
	return true
}

Tag64_Formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> (ok: bool)
{
	tag := cast(^Tag64)arg.data
	switch verb {
	case 'v', 's':
		_, err := io.write(fi.writer, tag[:])
		if err != nil do return false
	case 'q':
		_, err := io.write_rune(fi.writer, '"')
		if err != nil do return false
		_, err = io.write(fi.writer, tag[:])
		if err != nil do return false
		_, err = io.write_rune(fi.writer, '"')
		if err != nil do return false
	case 'w':
		_, err := io.write_string(fi.writer, "st.tag64(\"")
		if err != nil do return false
		_, err = io.write(fi.writer, tag[:])
		if err != nil do return false
		_, err = io.write_string(fi.writer, "\")")
		if err != nil do return false
	case:
		return false
	}
	return true
}

Better_Context :: struct {
	ctx:             runtime.Context,
	track:           ^mem.Tracking_Allocator,
	temp_track:      ^mem.Tracking_Allocator,
	logger:          log.Logger,
	file_logger:     log.Logger,
	console_logger:  log.Logger,
	logtxt:          ^os.File,
	can_log_to_file: bool,
	track_allocs:    bool,
}

// Creates a context with a logger and tracking allocator setup. Remember to actually set it as
// your context (`context = better.ctx`)
init_better_context :: proc(track_allocs := true) -> (better: Better_Context)
{
	better.ctx = runtime.default_context()
	better.track_allocs = track_allocs
	TERM_OPTIONS :: log.Options{.Time, .Terminal_Color}
	LOG_OPTIONS :: log.Options{.Time, .Level, .Procedure}

	ferr: os.Error
	better.logtxt, ferr = os.open("log.txt", {.Write, .Create})
	if ferr != nil {
		fmt.printfln("couldn't open log.txt: %s", os.error_string(ferr))
	} else {
		better.file_logger = log.create_file_logger(
			better.logtxt,
			lowest = .Debug when ODIN_DEBUG else .Info,
			opt = LOG_OPTIONS,
		)
		better.can_log_to_file = true
	}

	better.console_logger = log.create_console_logger(
		lowest = .Debug when ODIN_DEBUG else .Info,
		opt = TERM_OPTIONS,
	)

	if better.can_log_to_file {
		better.logger = log.create_multi_logger(better.console_logger, better.file_logger)
	} else {
		better.logger = better.console_logger
	}
	better.ctx.logger = better.logger

	if better.track_allocs {
		// heap allocated otherwise you get a stack use after free error...somehow
		better.track = new(mem.Tracking_Allocator)
		better.temp_track = new(mem.Tracking_Allocator)

		mem.tracking_allocator_init(better.track, context.allocator)
		mem.tracking_allocator_init(better.temp_track, context.temp_allocator)
		better.ctx.allocator = mem.tracking_allocator(better.track)
		better.ctx.temp_allocator = mem.tracking_allocator(better.temp_track)
	}

	// TODO might be a bit too sneaky
	if fmt._user_formatters == nil {
		fmt.set_user_formatters(new(map[typeid]fmt.User_Formatter))
	}
	err := fmt.register_user_formatter(type_info_of(Tag32).id, Tag32_Formatter)
	assert(err == .None)
	err = fmt.register_user_formatter(type_info_of(Tag64).id, Tag64_Formatter)
	assert(err == .None)

	return
}

free_better_context :: proc(better: ^Better_Context)
{
	if better.can_log_to_file {
		log.destroy_multi_logger(better.logger)
	}
	log.destroy_console_logger(better.console_logger)
	if better.can_log_to_file {
		// also closes the file
		log.destroy_file_logger(better.file_logger)
	}

	if better.track_allocs {
		poor_mans_valgrind(better.track^)
		poor_mans_valgrind(better.temp_track^)
		mem.tracking_allocator_destroy(better.track)
		mem.tracking_allocator_destroy(better.temp_track)

		context.allocator = runtime.default_allocator()
		free(better.track)
		free(better.temp_track)
	}

	better^ = {}
}

poor_mans_valgrind :: proc(track: mem.Tracking_Allocator)
{
	if len(track.allocation_map) > 0 {
		log.errorf("=== %v allocations not freed: ===", len(track.allocation_map))
		for _, entry in track.allocation_map {
			log.debugf("%v bytes @ %v", entry.size, entry.location)
		}
	}
	if len(track.bad_free_array) > 0 {
		log.errorf("=== %v incorrect frees: ===", len(track.bad_free_array))
		for entry in track.bad_free_array {
			log.debugf("%p @ %v", entry.memory, entry.location)
		}
	}
}
