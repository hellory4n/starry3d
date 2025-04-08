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

#ifndef TRIPPIN_H
#define TRIPPIN_H
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

// Idk why I added this
#define TR_VERSION "v1.0.2"

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
void tr_arena_free(TrArena arena);

// Allocates space in the arena.
void* tr_arena_alloc(TrArena arena, size_t size);

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

#define TR_V2_ADD(a, b)  {a.x + b.x, a.y + b.y}
#define TR_V2_SUB(a, b)  {a.x - b.x, a.y - b.y}
#define TR_V2_MUL(a, b)  {a.x * b.x, a.y * b.y}
#define TR_V2_SMUL(a, b) {a.x * b,   a.y * b}
#define TR_V2_DIV(a, b)  {a.x / b.x, a.y / b.y}
#define TR_V2_SDIV(a, b) {a.x / b,   a.y / b}

#define TR_V2_EQ(a, b)   (a.x == b.x && a.y == b.y)
#define TR_V2_NEQ(a, b)  (a.x != b.x && a.y != b.y)
#define TR_V2_LT(a, b)   (a.x < b.x  && a.y < b.y)
#define TR_V2_LTE(a, b)  (a.x <= b.x && a.y <= b.y)
// shout out to lua
#define TR_V2_GT(a, b)   TR_V2_LT(b, a)
#define TR_V2_GTE(a, b)  TR_V2_LTE(b, a)

#define TR_V3_ADD(a, b)  {a.x + b.x, a.y + b.y, a.z + b.z}
#define TR_V3_SUB(a, b)  {a.x - b.x, a.y - b.y, a.z - b.z}
#define TR_V3_MUL(a, b)  {a.x * b.x, a.y * b.y, a.z * b.z}
#define TR_V3_SMUL(a, b) {a.x * b,   a.y * b,   a.z * b}
#define TR_V3_DIV(a, b)  {a.x / b.x, a.y / b.y, a.z / b.z}
#define TR_V3_SDIV(a, b) {a.x / b,   a.y / b,   a.z / b}

#define TR_V3_EQ(a, b)   (a.x == b.x && a.y == b.y && a.z == b.z)
#define TR_V3_NEQ(a, b)  (a.x != b.x && a.y != b.y && a.z != b.z)
#define TR_V3_LT(a, b)   (a.x < b.x  && a.y < b.y  && a.z <  b.z)
#define TR_V3_LTE(a, b)  (a.x <= b.x && a.y <= b.y && a.z <= b.z)
// shout out to lua
#define TR_V3_GT(a, b)   TR_V3_LT(b, a)
#define TR_V3_GTE(a, b)  TR_V3_LTE(b, a)

// logging

#define TR_CONSOLE_COLOR_RESET    "\033[0m"
#define TR_CONSOLE_COLOR_LIB_INFO "\033[0;90m"
#define TR_CONSOLE_COLOR_WARN     "\033[0;93m"
#define TR_CONSOLE_COLOR_ERROR    "\033[0;91m"

typedef enum {
	// literally just for use with raylib
	TR_LOG_LIB_INFO,
	TR_LOG_INFO,
	TR_LOG_WARNING,
	TR_LOG_ERROR,
} TrLogLevel;

// Log.
void tr_log(TrLogLevel level, const char* fmt, ...);

// Formatted assert?!!!??!?!??!?1
void tr_assert(bool x, const char* msg, ...);

// uh oh
void tr_panic(const char* msg, ...);

// slices

typedef struct {
	size_t length;
	size_t elem_size;
	void* buffer;
} TrSlice;

// Creates a new slice in an arena. The element size is supposed to be used with sizeof,
// e.g. sizeof(int) for a slice of ints.
TrSlice tr_slice_new(TrArena arena, size_t length, size_t elem_size);

// Gets the element at the specified index. Note this returns a pointer to the element so this is also
// how you change elements.
void* tr_slice_at(TrSlice slice, size_t idx);

// slice but 2d lmao
typedef struct {
	size_t width;
	size_t height;
	size_t elem_size;
	void* buffer;
} TrSlice2D;

// Creates a new 2D slice in an arena. The element size is supposed to be used with sizeof,
// e.g. sizeof(int) for a slice of ints.
TrSlice2D tr_slice2d_new(TrArena arena, size_t width, size_t height, size_t elem_size);

// Gets the element at the specified index. Note this returns a pointer to the element so this is also
// how you change elements.
void* tr_slice2d_at(TrSlice2D slice, size_t x, size_t y);

// rectnagle

typedef struct {
	double x;
	double y;
	double w;
	double h;
} TrRect;

// Returns the area of the rectangle
double tr_rect_area(TrRect r);

/// If true, the 2 rects intersect
bool tr_rect_intersects(TrRect a, TrRect b);

/// If true, the rect, in fact, has that point
bool tr_rect_has_point(TrRect rect, TrVec2f point);

// mate
typedef struct {
	uint8_t r, g, b, a;
} TrColor;

TrColor tr_rgba(uint8_t r, uint8_t g, uint8_t b, uint8_t a);

TrColor tr_rgb(uint8_t r, uint8_t g, uint8_t b);

// format is 0xRRGGBBAA for red, green, blue, and alpha respectively
TrColor tr_hex_rgba(int32_t hex);

#define TR_WHITE tr_hex_rgba(0xffffffff)
#define TR_BLACK tr_hex_rgba(0x000000ff)
#define TR_TRANSPARENT tr_hex_rgba(0x00000000)

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
double tr_deg2rad(double deg);

// Converts radians to degrees
double tr_rad2deg(double rad);

// clamp
double tr_clamp(double val, double min, double max);

// lerp
double tr_lerp(double a, double b, double t);

// Similar to lerp, but inverse.
double tr_inverse_lerp(double a, double b, double v);

// Converts a number from one scale to another
double tr_remap(double v, double src_min, double src_max, double dst_min, double dst_max);

#ifdef __cplusplus
}
#endif

#endif
