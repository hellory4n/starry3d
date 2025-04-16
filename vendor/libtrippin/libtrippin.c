/*
 * libtrippin v1.2.1
 *
 * Most biggest most massive standard library thing for C of all time
 * More information at https://github.com/hellory4n/libtrippin
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

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifndef _WIN32
#include <signal.h>
#endif
#include <time.h>
#include <math.h>
#include "libtrippin.h"

static FILE* tr_logfile;
static TrRand tr_randdeez;

void tr_init(const char* log_file)
{
	tr_logfile = fopen(log_file, "w");
	tr_assert(log_file != NULL, "couldn't open %s", log_file);

	tr_randdeez = tr_rand_new(time(NULL));

	tr_liblog("initialized libtrippin %s", TR_VERSION);
}

void tr_free(void)
{
	// liblog requires that file so we close it after
	tr_liblog("deinitialized libtrippin");
	if (tr_logfile != NULL) {
		fclose(tr_logfile);
	}
}

// TODO maybe don't copy the same function 6 times with slightly different formatting and
// sometimes it dies

void tr_log(const char* fmt, ...)
{
	// you understand mechanical hands are the ruler of everything (ah)
	char timestr[32];
	time_t now = time(NULL);
	struct tm* tm_info = localtime(&now);
	strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", tm_info);

	// TODO maybe increase in the future?
	char buf[256];
	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, sizeof(buf), fmt, args);

	if (tr_logfile == NULL) {
		printf(
			TR_CONSOLE_COLOR_WARN
			"[%s] no log file available. did you forget to call tr_init()?\n"
			TR_CONSOLE_COLOR_RESET,
			timestr
		);
	}
	else {
		fprintf(tr_logfile, "[%s] %s\n", timestr, buf);
		fflush(tr_logfile);
	}

	printf("[%s] %s\n", timestr, buf);
	fflush(stdout);

	va_end(args);
}

void tr_liblog(const char* fmt, ...)
{
	// you understand mechanical hands are the ruler of everything (ah)
	char timestr[32];
	time_t now = time(NULL);
	struct tm* tm_info = localtime(&now);
	strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", tm_info);

	// TODO maybe increase in the future?
	char buf[256];
	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, sizeof(buf), fmt, args);

	if (tr_logfile == NULL) {
		printf(
			TR_CONSOLE_COLOR_WARN
			"[%s] no log file available. did you forget to call tr_init()?\n"
			TR_CONSOLE_COLOR_RESET,
			timestr
		);
	}
	else {
		fprintf(tr_logfile, "[%s] %s\n", timestr, buf);
		fflush(tr_logfile);
	}

	printf(TR_CONSOLE_COLOR_LIB_INFO "[%s] %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
	fflush(stdout);

	va_end(args);
}

void tr_warn(const char* fmt, ...)
{
	// you understand mechanical hands are the ruler of everything (ah)
	char timestr[32];
	time_t now = time(NULL);
	struct tm* tm_info = localtime(&now);
	strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", tm_info);

	// TODO maybe increase in the future?
	char buf[256];
	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, sizeof(buf), fmt, args);

	if (tr_logfile == NULL) {
		printf(
			TR_CONSOLE_COLOR_WARN
			"[%s] no log file available. did you forget to call tr_init()?\n"
			TR_CONSOLE_COLOR_RESET,
			timestr
		);
	}
	else {
		fprintf(tr_logfile, "[%s] %s\n", timestr, buf);
		fflush(tr_logfile);
	}

	printf(TR_CONSOLE_COLOR_WARN "[%s] %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
	fflush(stdout);

	va_end(args);
}

void tr_error(const char* fmt, ...)
{
	// you understand mechanical hands are the ruler of everything (ah)
	char timestr[32];
	time_t now = time(NULL);
	struct tm* tm_info = localtime(&now);
	strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", tm_info);

	// TODO maybe increase in the future?
	char buf[256];
	va_list args;
	va_start(args, fmt);
	vsnprintf(buf, sizeof(buf), fmt, args);

	if (tr_logfile == NULL) {
		printf(
			TR_CONSOLE_COLOR_WARN
			"[%s] no log file available. did you forget to call tr_init()?\n"
			TR_CONSOLE_COLOR_RESET,
			timestr
		);
	}
	else {
		fprintf(tr_logfile, "[%s] %s\n", timestr, buf);
		fflush(tr_logfile);
	}

	printf(TR_CONSOLE_COLOR_ERROR "[%s] %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
	fflush(stdout);

	va_end(args);
}

void tr_assert(bool x, const char* msg, ...)
{
	if (x) {
		return;
	}

	// you understand mechanical hands are the ruler of everything (ah)
	char timestr[32];
	time_t now = time(NULL);
	struct tm* tm_info = localtime(&now);
	strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", tm_info);

	// TODO maybe increase in the future?
	char buf[256];
	va_list args;
	va_start(args, msg);
	vsnprintf(buf, sizeof(buf), msg, args);

	if (tr_logfile == NULL) {
		printf(
			TR_CONSOLE_COLOR_WARN
			"[%s] no log file available. did you forget to call tr_init()?\n"
			TR_CONSOLE_COLOR_RESET,
			timestr
		);
	}
	else {
		fprintf(tr_logfile, "[%s] %s\n", timestr, buf);
		fflush(tr_logfile);
	}

	printf(TR_CONSOLE_COLOR_ERROR "[%s] failed assert: %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
	fflush(stdout);

	va_end(args);
	// TODO there's probably a windows equivalent but i don't care
	#ifndef _WIN32
	raise(SIGTRAP);
	#endif
}

void tr_panic(const char* msg, ...)
{
	// you understand mechanical hands are the ruler of everything (ah)
	char timestr[32];
	time_t now = time(NULL);
	struct tm* tm_info = localtime(&now);
	strftime(timestr, sizeof(timestr), "%Y-%m-%d %H:%M:%S", tm_info);

	// TODO maybe increase in the future?
	char buf[256];
	va_list args;
	va_start(args, msg);
	vsnprintf(buf, sizeof(buf), msg, args);

	if (tr_logfile == NULL) {
		printf(
			TR_CONSOLE_COLOR_WARN
			"[%s] no log file available. did you forget to call tr_init()?\n"
			TR_CONSOLE_COLOR_RESET,
			timestr
		);
	}
	else {
		fprintf(tr_logfile, "[%s] %s\n", timestr, buf);
		fflush(tr_logfile);
	}

	printf(TR_CONSOLE_COLOR_ERROR "[%s] panic: %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
	fflush(stdout);

	va_end(args);
	// TODO there's probably a windows equivalent but i don't care
	#ifndef _WIN32
	raise(SIGTRAP);
	#endif
}

TrArena tr_arena_new(size_t size)
{
	TrArena arena = {.size = size};
	arena.buffer = calloc(1, size);
	if (arena.buffer == NULL) {
		tr_panic("couldn't allocate arena");
	}
	return arena;
}

void tr_arena_free(TrArena* arena)
{
	free(arena->buffer);
	arena->buffer = NULL;
}

void* tr_arena_alloc(TrArena* arena, size_t size)
{
	// it's gonna segfault anyway
	// might as well complain instead of mysteriously dying
	size_t end = (size_t)arena->alloc_pos + size;
	if (end > arena->size) {
		tr_panic("arena allocation out of bounds");
	}

	void* data = (void*)((uint8_t*)arena->buffer + arena->alloc_pos);
	arena->alloc_pos += size;
	return data;
}

TrSlice tr_slice_new(TrArena* arena, size_t length, size_t elem_size)
{
	TrSlice slicema = {.length = length, .elem_size = elem_size};
	slicema.buffer = tr_arena_alloc(arena, length * elem_size);
	return slicema;
}

void* tr_slice_at(TrSlice* slice, size_t idx)
{
	if (idx >= slice->length) {
		tr_panic("index out of range: %zu", idx);
	}

	size_t offset = slice->elem_size * idx;
	return (void*)((uint8_t*)slice->buffer + offset);
}

TrSlice2D tr_slice2d_new(TrArena* arena, size_t width, size_t height, size_t elem_size)
{
	TrSlice2D slicema = {.elem_size = elem_size, .width = width, .height = height};
	slicema.buffer = tr_arena_alloc(arena, width * height * elem_size);
	return slicema;
}

void* tr_slice2d_at(TrSlice2D* slice, size_t x, size_t y)
{
	if (x >= slice->width || y >= slice->height) {
		tr_panic("index out of range: %zu, %zu", x, y);
	}

	size_t offset = slice->elem_size * (slice->width * x + y);
	return (void*)((uint8_t*)slice->buffer + offset);
}

TrRand* tr_default_rand(void)
{
	return &tr_randdeez;
}

TrRand tr_rand_new(uint64_t seed)
{
	TrRand man = {0};
	// i think this is how you implement splitmix64?
	man.s[0] = seed;
	for (size_t i = 1; i < 4; i++) {
		man.s[i] = (man.s[i - 1] += UINT64_C(0x9E3779B97F4A7C15));
		man.s[i] = (man.s[i] ^ (man.s[i] >> 30)) * UINT64_C(0xBF58476D1CE4E5B9);
		man.s[i] = (man.s[i] ^ (man.s[i] >> 27)) * UINT64_C(0x94D049BB133111EB);
		man.s[i] = man.s[i] ^ (man.s[i] >> 31);
	}
	return man;
}

// theft
static inline uint64_t rotl(const uint64_t x, int k) {
	return (x << k) | (x >> (64 - k));
}

double tr_rand_double(TrRand* rand, double min, double max)
{
	// theft
	const uint64_t result = rand->s[0] + rand->s[3];

	const uint64_t t = rand->s[1] << 17;

	rand->s[2] ^= rand->s[0];
	rand->s[3] ^= rand->s[1];
	rand->s[1] ^= rand->s[2];
	rand->s[0] ^= rand->s[3];

	rand->s[2] ^= t;

	rand->s[3] = rotl(rand->s[3], 45);

	// not theft
	// man is 0 to 1
	// 18446744073709551616.0 is UINT64_MAX but with the last digit changed because
	// clang was complaining
	double man = (double)result / 18446744073709551616.0;
	return (man * max) + min;
}

uint64_t tr_rand_u64(TrRand* rand, uint64_t min, uint64_t max)
{
	return (uint64_t)round(tr_rand_double(rand, (double)min, (double)max));
}

int64_t tr_rand_i64(TrRand* rand, int64_t min, int64_t max)
{
	return (int64_t)round(tr_rand_double(rand, (double)min, (double)max));
}

// apparently the linker has a skill issue so we have to put inline functions here
double tr_rect_area(TrRect r);
bool tr_rect_intersects(TrRect a, TrRect b);
bool tr_rect_has_point(TrRect rect, TrVec2f point);
TrColor tr_rgba(uint8_t r, uint8_t g, uint8_t b, uint8_t a);
TrColor tr_rgb(uint8_t r, uint8_t g, uint8_t b);
TrColor tr_hex_rgba(uint32_t hex);
TrColor tr_hex_rgb(uint32_t hex);
double tr_deg2rad(double deg);
double tr_rad2deg(double rad);
double tr_clamp(double val, double min, double max);
double tr_lerp(double a, double b, double t);
double tr_inverse_lerp(double a, double b, double v);
double tr_remap(double v, double src_min, double src_max, double dst_min, double dst_max);
