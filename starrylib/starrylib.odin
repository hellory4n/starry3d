/*
# The Starry general purpose libraries

This packages features components of Starry which may be put into any program, without depending on
the runtime. It includes:
- the reference BMV implementation
- voxel model API
- magicavoxel's .vox support
- other utilities
*/
package starrylib

import "base:intrinsics"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:os"

VERSION_NUM :: 2026_05_00 // v2026.5.0
VERSION_STR :: "v2026.5.0-dev"
VERSION_MAJOR :: 2026
VERSION_MINOR :: 5
VERSION_PATCH :: 0

// A short string used in many places to uniquely identify something.
//
// Note that if creating those things is fully automatic, it's usually better to use an
// incrementing 32-bit index. For example:
// - model attributes, etc: uses human-assigned tags
// - handles: fully handled by the engine on its own, doesn't need to be human-readable
Tag :: distinct [4]byte

// `st.tag("crap")` looks nicer than `[4]st.Tag{'c', 'r', 'a', 'p'}`
tag :: #force_inline proc "contextless" (src: $T) -> Tag where intrinsics.type_is_string(T)
{
	return Tag{src[0], src[1], src[2], src[3]}
}

// Converts a tag to a readable string
tag_str :: #force_inline proc(src: Tag) -> string
{
	// you probably don't need an allocation but idk
	bytes := make([]byte, 4, context.temp_allocator)
	return string(bytes)
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

Lazy_Logger :: struct {
	logger:          log.Logger,
	file_logger:     log.Logger,
	console_logger:  log.Logger,
	logtxt:          ^os.File,
	can_log_to_file: bool,
}

// Initializes a logger in a very specific way
new_lazy_logger :: proc() -> (lazy: Lazy_Logger, err: os.Error)
{
	TERM_OPTIONS :: log.Options{.Time, .Terminal_Color}
	LOG_OPTIONS :: log.Options{.Time, .Level, .Procedure, .Thread_Id}

	lazy.logtxt, err = os.open("log.txt", {.Write, .Create})
	if err != nil {
		fmt.printfln("couldn't open log.txt: %s", os.error_string(err))
	} else {
		lazy.file_logger = log.create_file_logger(
			lazy.logtxt,
			lowest = .Debug when ODIN_DEBUG else .Info,
			opt = LOG_OPTIONS,
		)
		lazy.can_log_to_file = true
	}

	lazy.console_logger = log.create_console_logger(
		lowest = .Debug when ODIN_DEBUG else .Info,
		opt = TERM_OPTIONS,
	)

	if lazy.can_log_to_file {
		lazy.logger = log.create_multi_logger(lazy.console_logger, lazy.file_logger)
	} else {
		lazy.logger = lazy.console_logger
	}
	return
}

free_lazy_logger :: proc(lazy: ^Lazy_Logger)
{
	if lazy.can_log_to_file {
		log.destroy_multi_logger(lazy.logger)
	}
	log.destroy_console_logger(lazy.console_logger)
	if lazy.can_log_to_file {
		// also closes the file
		log.destroy_file_logger(lazy.file_logger)
	}
	lazy^ = {}
}
