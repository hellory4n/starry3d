/*
 * Starry3D: C voxel game engine
 * More information at https://github.com/hellory4n/starry3d
 *
 * Copyright (C) 2025 by hellory4n <hellory4n@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this
 * software for any purpose with or without fee is hereby
 * granted.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS
 * ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
 * WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
 * TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
 * USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#ifndef _ST_COMMON_H
#define _ST_COMMON_H
#include <time.h>
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// Starry3D version :D
#define ST_VERSION "v0.3.0"

// Default size for buffers storing paths. It's 260 because that's the limit on Windows.
#define ST_PATH_SIZE 260

typedef struct {
	// Used for the window title and user directory (e.g. `%APPDATA%/handsome_app`, or
	// `~/.local/share/handsome_app`)
	char app_name[32];
	// The assets directory, relative to the executable
	char asset_dir[32];
	// If true, the user can resize the window.
	bool resizable;
	uint32_t window_width;
	uint32_t window_height;
} StSettings;

// Initializes Starry3D duh.
void st_init(StSettings settings);

// Deinitializes Starry3D duh.
void st_free(void);

// Gets the directory of the executable, and writes it into out
void st_app_dir(TrString* out);

// Gets the directory where you're supposed to save things, and outputs it into out
void st_user_dir(TrString* out);

// Shorthand for getting paths. Start with `app:` to get from the assets directory, and `usr:`
// to get from the directory where you save things. For example, `app:images/bob.png`, and `usr:espionage.txt`.
// Writes the actual path to out, which should be at least 260 characters because Windows.
void st_path(const char* s, TrString* out);

typedef void (*StTimerCallback)(void);

// Timer, useful for when you want to waiting for something
typedef struct {
	// Called when the timer is done
	StTimerCallback callback;
	// How long the timer lasts, in seconds
	double duration;
	// How much time is left, in seconds
	double time_left;
	// If true, the timer repeats when it's over
	bool repeat;
	// If true, the timer is currently timing
	bool playing;
} StTimer;

// Creates a new timer. Duration is in seconds.
StTimer* st_timer_new(double duration, bool repeat, StTimerCallback callback);

// Starts the timer so it actually starts timing.
void st_timer_start(StTimer* timer);

// Stops the timer from timing.
void st_timer_stop(StTimer* timer);

// internal
void st_update_all_timers(void);

// i'm not gonna bother making this work on windows
#ifdef ST_LINUX
#include <sys/time.h>

// I love l'optimìsation
typedef struct {
	struct timeval start;
	struct timeval end;
} StBenchmark;

// I love l'optimìsation
static inline StBenchmark st_benchmark_start(void)
{
	StBenchmark benchmark;
	gettimeofday(&benchmark.start, NULL);
	return benchmark;
}

// Stops the benchmark and logs the result
static inline void st_benchmark_end(StBenchmark benchmark)
{
	gettimeofday(&benchmark.end, NULL);
	tr_log("benchmark completed, took %li µs", benchmark.end.tv_usec - benchmark.start.tv_usec);
}

#endif

#ifdef __cplusplus
}
#endif

#endif
