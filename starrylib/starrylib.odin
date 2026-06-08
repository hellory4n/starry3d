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
import "base:runtime"
import "core:fmt"
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
