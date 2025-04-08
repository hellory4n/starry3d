/*
 * libtrippin v1.0.2
 *
 * Most biggest most massive standard library thing for C of all time
 * More information at https://github.com/hellory4n/libtrippin
 *
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to <https://unlicense.org/>
 */

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// so clang shuts up
#ifdef DEBUG
#include <signal.h>
#endif
#include <time.h>
#include <math.h>
#include "libtrippin.h"

static FILE* logfile;
static TrRand randdeez;

void tr_init(const char* log_file)
{
	logfile = fopen(log_file, "w");
	tr_assert(log_file != NULL, "couldn't open %s", log_file);

	randdeez = tr_rand_new(time(NULL));

	tr_log(TR_LOG_LIB_INFO, "initialized libtrippin %s", TR_VERSION);
}

void tr_free(void)
{
	fclose(logfile);

	// this causes a leak in the math example??????????????????????? according to asan
	// tr_log(TR_LOG_LIB_INFO, "deinitialized libtripping");
}

void tr_log(TrLogLevel level, const char* fmt, ...)
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

	fprintf(logfile, "[%s] %s\n", timestr, buf);
	switch (level) {
	case TR_LOG_LIB_INFO:
		printf(TR_CONSOLE_COLOR_LIB_INFO "[%s] %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
		break;
	case TR_LOG_INFO:
		printf("[%s] %s\n", timestr, buf);
		break;
	case TR_LOG_WARNING:
		printf(TR_CONSOLE_COLOR_WARN "[%s] %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
		break;
	case TR_LOG_ERROR:
		printf(TR_CONSOLE_COLOR_ERROR "[%s] %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
		break;
	}
	fflush(logfile);
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

	fprintf(logfile, "[%s] %s\n", timestr, buf);
	printf(TR_CONSOLE_COLOR_ERROR "[%s] failed assert: %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
	fflush(logfile);
	fflush(stdout);

	va_end(args);

	#ifdef DEBUG
	raise(SIGTRAP);
	#else
	exit(1);
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

	fprintf(logfile, "[%s] %s\n", timestr, buf);
	printf(TR_CONSOLE_COLOR_ERROR "[%s] panic: %s\n" TR_CONSOLE_COLOR_RESET, timestr, buf);
	fflush(logfile);
	fflush(stdout);

	va_end(args);

	#ifdef DEBUG
	raise(SIGTRAP);
	#else
	exit(1);
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

void tr_arena_free(TrArena arena)
{
	free(arena.buffer);
}

void* tr_arena_alloc(TrArena arena, size_t size)
{
	// it's gonna segfault anyway
	// might as well complain instead of mysteriously dying
	size_t end = (size_t)arena.alloc_pos + size;
	if (end > arena.size) {
		tr_panic("arena allocation out of bounds");
	}

	void* data = (void*)((char*)arena.buffer + arena.alloc_pos);
	return data;
}

TrSlice tr_slice_new(TrArena arena, size_t length, size_t elem_size)
{
	TrSlice slicema = {.length = length, .elem_size = elem_size};
	slicema.buffer = tr_arena_alloc(arena, length * elem_size);
	return slicema;
}

void* tr_slice_at(TrSlice slice, size_t idx)
{
	if (idx >= slice.length || idx < 0) {
		tr_panic("index out of range: %zu", idx);
	}

	size_t offset = slice.elem_size * idx;
	return (void*)((char*)slice.buffer + offset);
}

TrSlice2D tr_slice2d_new(TrArena arena, size_t width, size_t height, size_t elem_size)
{
	TrSlice2D slicema = {.elem_size = elem_size, .width = width, .height = height};
	slicema.buffer = tr_arena_alloc(arena, width * height * elem_size);
	return slicema;
}

void* tr_slice2d_at(TrSlice2D slice, size_t x, size_t y)
{
	if (x >= slice.width || x < 0 || y >= slice.height || y < 0) {
		tr_panic("index out of range: %zu, %zu", x, y);
	}

	size_t offset = slice.elem_size * (slice.width * x + y);
	return (void*)((char*)slice.buffer + offset);
}

double tr_rect_area(TrRect r)
{
	return r.w * r.h;
}

bool tr_rect_intersects(TrRect a, TrRect b)
{
	// man
	if (a.x >= (b.x + b.w)) {
		return false;
	}
	if ((a.x + a.w) <= b.y) {
		return false;
	}
	if (a.y >= (b.y + b.h)) {
		return false;
	}
	if ((a.y + a.h) <= b.y) {
		return false;
	}
	return true;
}

bool tr_rect_has_point(TrRect rect, TrVec2f point)
{
	if (point.x < rect.x) {
		return false;
	}
	if (point.y < rect.y) {
		return false;
	}

	if (point.x >= (rect.x + rect.w)) {
		return false;
	}
	if (point.y >= (rect.y + rect.h)) {
		return false;
	}

	return true;
}

TrRand* tr_default_rand(void)
{
	return &randdeez;
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

double tr_deg2rad(double deg)
{
	return deg * (PI / 180.0);
}

double tr_rad2deg(double rad)
{
	return rad * (180 / PI);
}

double tr_clamp(double val, double min, double max)
{
	if (val < min) return min;
	else if (val > max) return max;
	else return val;
}

double tr_lerp(double a, double b, double t)
{
	return (1.0 - t) * a + t * b;
}

double tr_inverse_lerp(double a, double b, double v)
{
	return (v - a) / (b - a);
}

double st_remap(double v, double src_min, double src_max, double dst_min, double dst_max)
{
	return tr_lerp(dst_min, dst_max, tr_inverse_lerp(src_min, src_max, v));
}

TrColor tr_rgba(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
	return (TrColor){.r = r, .g = g, .b = b, .a = a};
}

TrColor tr_rgb(uint8_t r, uint8_t g, uint8_t b)
{
	return (TrColor){.r = r, .g = g, .b = b, .a = 255};
}

TrColor tr_hex_rgba(int32_t hex)
{
	return (TrColor){
		.r = (hex >> 24) & 0xFF,
		.g = (hex >> 16) & 0xFF,
		.b = (hex >> 8) & 0xFF,
		.a = hex & 0xFF,
	};
}
