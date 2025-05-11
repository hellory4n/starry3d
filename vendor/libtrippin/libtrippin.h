/*
 * libtrippin v1.2.3
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

#ifndef _TRIPPIN_H
#define _TRIPPIN_H
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

// Idk why I added this
#define TR_VERSION "v1.2.3"

// It initializes libtrippin.
void tr_init(const char* log_file);

// It frees libtrippin.
void tr_free(void);

// arenas

// Kilobytes to bytes
#define TR_KB(b) ((b) * 1024)
// Megabytes to bytes
#define TR_MB(b) (TR_KB((b)) * 1024)
// Gigabytes to bytes
#define TR_GB(b) (TR_MB((b)) * 1024)

typedef struct {
	size_t size;
	size_t alloc_pos;
	void* buffer;
} TrArena;

// Makes a new arena :)
TrArena tr_arena_new(size_t size);

// Frees the arena and everything inside it.
void tr_arena_free(TrArena* arena);

// Allocates space in the arena.
void* tr_arena_alloc(TrArena* arena, size_t size);

// vectors

typedef struct {
	double x;
	double y;
} TrVec2f;

typedef struct {
	int64_t x;
	int64_t y;
} TrVec2i;

typedef struct {
	double x;
	double y;
	double z;
} TrVec3f;

typedef struct {
	int64_t x;
	int64_t y;
	int64_t z;
} TrVec3i;

typedef struct {
	double x;
	double y;
	double z;
	double w;
} TrVec4f;

typedef struct {
	int64_t x;
	int64_t y;
	int64_t z;
	int64_t w;
} TrVec4i;

#define TR_V2_ADD(a, b)  { a.x + b.x, a.y + b.y}
#define TR_V2_SUB(a, b)  { a.x - b.x, a.y - b.y}
#define TR_V2_MUL(a, b)  { a.x * b.x, a.y * b.y}
#define TR_V2_SMUL(a, b) { a.x * b,   a.y * b}
#define TR_V2_DIV(a, b)  { a.x / b.x, a.y / b.y}
#define TR_V2_SDIV(a, b) { a.x / b,   a.y / b}
#define TR_V2_NEG(a, b)  {-a.x,      -a.y}

#define TR_V2_EQ(a, b)   (a.x == b.x && a.y == b.y)
#define TR_V2_NEQ(a, b)  !TR_V2_EQ(a, b)
#define TR_V2_LT(a, b)   (a.x < b.x  && a.y < b.y)
#define TR_V2_LTE(a, b)  (a.x <= b.x && a.y <= b.y)
// shout out to lua
#define TR_V2_GT(a, b)   TR_V2_LT(b, a)
#define TR_V2_GTE(a, b)  TR_V2_LTE(b, a)

#define TR_V3_ADD(a, b)  { a.x + b.x, a.y + b.y, a.z + b.z}
#define TR_V3_SUB(a, b)  { a.x - b.x, a.y - b.y, a.z - b.z}
#define TR_V3_MUL(a, b)  { a.x * b.x, a.y * b.y, a.z * b.z}
#define TR_V3_SMUL(a, b) { a.x * b,   a.y * b,   a.z * b}
#define TR_V3_DIV(a, b)  { a.x / b.x, a.y / b.y, a.z / b.z}
#define TR_V3_SDIV(a, b) { a.x / b,   a.y / b,   a.z / b}
#define TR_V3_NEG(a, b)  {-a.x,      -a.y,      -a.z}

#define TR_V3_EQ(a, b)   (a.x == b.x && a.y == b.y && a.z == b.z)
#define TR_V3_NEQ(a, b)  !TR_V3_EQ(a, b)
#define TR_V3_LT(a, b)   (a.x <  b.x && a.y <  b.y && a.z <  b.z)
#define TR_V3_LTE(a, b)  (a.x <= b.x && a.y <= b.y && a.z <= b.z)
// shout out to lua
#define TR_V3_GT(a, b)   TR_V3_LT(b, a)
#define TR_V3_GTE(a, b)  TR_V3_LTE(b, a)

// idk why you would need those on vec4s but ok
#define TR_V4_ADD(a, b)  { a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w}
#define TR_V4_SUB(a, b)  { a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w}
#define TR_V4_MUL(a, b)  { a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w}
#define TR_V4_SMUL(a, b) { a.x * b,   a.y * b,   a.z * b,   a.w * b}
#define TR_V4_DIV(a, b)  { a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w}
#define TR_V4_SDIV(a, b) { a.x / b,   a.y / b,   a.z / b,   a.w / b}
#define TR_V4_NEG(a, b)  {-a.x,      -a.y,      -a.z,      -a.w}

#define TR_V4_EQ(a, b)   (a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w)
#define TR_V4_NEQ(a, b)  !TR_V4_EQ(a, b)
#define TR_V4_LT(a, b)   (a.x <  b.x && a.y <  b.y && a.z <  b.z && a.w <  b.w)
#define TR_V4_LTE(a, b)  (a.x <= b.x && a.y <= b.y && a.z <= b.z && a.w <= b.w)
// shout out to lua
#define TR_V4_GT(a, b)   TR_V4_LT(b, a)
#define TR_V4_GTE(a, b)  TR_V4_LTE(b, a)

// mate
typedef struct {
	uint8_t r, g, b, a;
} TrColor;

static inline TrColor tr_rgba(uint8_t r, uint8_t g, uint8_t b, uint8_t a)
{
	return (TrColor){.r = r, .g = g, .b = b, .a = a};
}

static inline TrColor tr_rgb(uint8_t r, uint8_t g, uint8_t b)
{
	return (TrColor){.r = r, .g = g, .b = b, .a = 255};
}

// format is 0xRRGGBBAA for red, green, blue, and alpha respectively
static inline TrColor tr_hex_rgba(uint32_t hex)
{
	return (TrColor){
		.r = (hex >> 24) & 0xFF,
		.g = (hex >> 16) & 0xFF,
		.b = (hex >> 8) & 0xFF,
		.a = hex & 0xFF,
	};
}

// format is 0xRRGGBB for red, green, and blue respectively
static inline TrColor tr_hex_rgb(uint32_t hex)
{
	return (TrColor){
		.r = (hex >> 16) & 0xFF,
		.g = (hex >> 8) & 0xFF,
		.b = hex & 0xFF,
		.a = 255,
	};
}

#define TR_WHITE tr_hex_rgb(0xffffff)
#define TR_BLACK tr_hex_rgb(0x000000)
#define TR_TRANSPARENT tr_hex_rgba(0x00000000)

// logging

// TODO colored output doesn't work on windows and i can't be bothered to fix it
#ifndef _WIN32
#define TR_CONSOLE_COLOR_RESET    "\033[0m"
#define TR_CONSOLE_COLOR_LIB_INFO "\033[0;90m"
#define TR_CONSOLE_COLOR_WARN     "\033[0;93m"
#define TR_CONSOLE_COLOR_ERROR    "\033[0;91m"
#else
#define TR_CONSOLE_COLOR_RESET
#define TR_CONSOLE_COLOR_LIB_INFO
#define TR_CONSOLE_COLOR_WARN
#define TR_CONSOLE_COLOR_ERROR
#endif

#if (defined(__GNUC__) || defined(__clang__)) && !defined(_WIN32)
// counting starts at 1 lmao
#define TR_LOG_FUNC(fmt_idx, varargs_idx) __attribute__((format(printf, fmt_idx, varargs_idx)))
#else
#define TR_LOG_FUNC(fmt_idx, varargs_idx)
#endif

// Log.
TR_LOG_FUNC(1, 2) void tr_log(const char* fmt, ...);

// Log but for libraries that use libtrippin so your log isn't flooded with crap.
TR_LOG_FUNC(1, 2) void tr_liblog(const char* fmt, ...);

// Oh nose.
TR_LOG_FUNC(1, 2) void tr_warn(const char* fmt, ...);

// Oh god oh fuck.
TR_LOG_FUNC(1, 2) void tr_error(const char* fmt, ...);

// Formatted assert?!!!??!?!??!?1
TR_LOG_FUNC(2, 3) void tr_assert(bool x, const char* msg, ...);

// uh oh
TR_LOG_FUNC(1, 2) void tr_panic(const char* msg, ...);

// slices

typedef struct {
	size_t length;
	size_t elem_size;
	void* buffer;
} TrSlice;

// Creates a new slice in an arena. The element size is supposed to be used with sizeof,
// e.g. sizeof(int) for a slice of ints.
TrSlice tr_slice_new(TrArena* arena, size_t length, size_t elem_size);

// Gets the element at the specified index. Note this returns a pointer to the element so this is
// also how you change elements.
void* tr_slice_at(TrSlice* slice, size_t idx);

// slice but 2d lmao
typedef struct {
	size_t width;
	size_t height;
	size_t elem_size;
	void* buffer;
} TrSlice2D;

// Creates a new 2D slice in an arena. The element size is supposed to be used with sizeof,
// e.g. sizeof(int) for a slice of ints.
TrSlice2D tr_slice2d_new(TrArena* arena, size_t width, size_t height, size_t elem_size);

// Gets the element at the specified index. Note this returns a pointer to the element so this is
// also how you change elements.
void* tr_slice2d_at(TrSlice2D* slice, size_t x, size_t y);

// these aren't really necessary, it's just for clarity
typedef TrSlice TrSlice_int64;
typedef TrSlice TrSlice_uint64;
typedef TrSlice TrSlice_int32;
typedef TrSlice TrSlice_uint32;
typedef TrSlice TrSlice_int16;
typedef TrSlice TrSlice_uint16;
typedef TrSlice TrSlice_int8;
typedef TrSlice TrSlice_uint8;
typedef TrSlice TrSlice_bool;
typedef TrSlice TrSlice_double;
typedef TrSlice TrSlice_float;
typedef TrSlice TrString;
typedef TrSlice TrSlice_Vec2f;
typedef TrSlice TrSlice_Vec2i;
typedef TrSlice TrSlice_Vec3f;
typedef TrSlice TrSlice_Vec3i;
typedef TrSlice TrSlice_Vec4f;
typedef TrSlice TrSlice_Vec4i;
typedef TrSlice TrSlice_Color;

// idk why you would need 2d slices for anything else
// idk if i'm gonna keep 2d slices lmao
typedef TrSlice2D TrSlice2D_int64;
typedef TrSlice2D TrSlice2D_uint64;
typedef TrSlice2D TrSlice2D_int32;
typedef TrSlice2D TrSlice2D_uint32;
typedef TrSlice2D TrSlice2D_int16;
typedef TrSlice2D TrSlice2D_uint16;
typedef TrSlice2D TrSlice2D_int8;
typedef TrSlice2D TrSlice2D_uint8;
typedef TrSlice2D TrSlice2D_bool;
typedef TrSlice2D TrSlice2D_double;
typedef TrSlice2D TrSlice2D_float;
typedef TrSlice2D TrSlice2D_Color;

// also not really necessary
// it's just that the regular function is quite the mouthful

// apparently doing & and + 0 makes clangd get rid of the inlay hints
// i don't want to disable them entirely
// but i do want to disable them in this case
#define TR_AT(slice, type, idx) ((type*)tr_slice_at(&slice, (idx + 0)))

#define TR_AT2D(slice, type, x, y) ((type*)tr_slice2d_at(&slice, (x + 0), (y + 0)))

#define TR_SET_SLICE(arena, slice, type, ...) do { \
		type tmp[] = {__VA_ARGS__}; \
		(slice)->length = sizeof(tmp) / sizeof(type); \
		*(slice) = tr_slice_new(arena, (slice)->length, sizeof(type)); \
		memcpy((slice)->buffer, tmp, sizeof(tmp)); \
	} while (false)

// rectnagle
typedef struct {
	double x;
	double y;
	double w;
	double h;
} TrRect;

// Returns the area of the rectangle
static inline double tr_rect_area(TrRect r)
{
	return r.w * r.h;
}

// If true, the 2 rects intersect
static inline bool tr_rect_intersects(TrRect a, TrRect b)
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

// If true, the rect, in fact, has that point
static inline bool tr_rect_has_point(TrRect rect, TrVec2f point)
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

// meth

// lo
typedef struct {
	uint64_t s[4];
} TrRand;

// yea
TrRand* tr_default_rand(void);

TrRand tr_rand_new(uint64_t seed);

// Gets a random double in a range :)
double tr_rand_double(TrRand* rand, double min, double max);

// Gets a random uint64 in a range :)
uint64_t tr_rand_u64(TrRand* rand, uint64_t min, uint64_t max);

// Gets a random int64 in a range :)
int64_t tr_rand_i64(TrRand* rand, int64_t min, int64_t max);

#ifndef PI
#define PI 3.141592653589793238463
#endif

// Converts degrees to radians
static inline double tr_deg2rad(double deg)
{
	return deg * (PI / 180.0);
}

// Converts radians to degrees
static inline double tr_rad2deg(double rad)
{
	return rad * (180 / PI);
}

// clamp
static inline double tr_clamp(double val, double min, double max)
{
	if (val < min) return min;
	else if (val > max) return max;
	else return val;
}

// lerp
static inline double tr_lerp(double a, double b, double t)
{
	return (1.0 - t) * a + t * b;
}

// Similar to lerp, but inverse.
static inline double tr_inverse_lerp(double a, double b, double v)
{
	return (v - a) / (b - a);
}

// Converts a number from one scale to another
static inline double tr_remap(double v, double src_min, double src_max, double dst_min, double dst_max)
{
	return tr_lerp(dst_min, dst_max, tr_inverse_lerp(src_min, src_max, v));
}

#ifdef __cplusplus
}
#endif

#endif
