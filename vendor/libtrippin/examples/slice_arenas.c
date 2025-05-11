#include <stdint.h>
#include "libtrippin.h"

int main(void) {
	tr_init("log.txt");

	// slices require an arena
	TrArena arena = tr_arena_new(TR_MB(1));

	TrSlice slicema = tr_slice_new(&arena, 4, sizeof(int32_t));

	// set items
	*TR_AT(slicema, int32_t, 0) = 11;
	*TR_AT(slicema, int32_t, 1) = 22;
	*TR_AT(slicema, int32_t, 2) = 33;
	*TR_AT(slicema, int32_t, 3) = 44;

	// or use the shorthand
	slicema = (TrSlice){0};
	TR_SET_SLICE(&arena, &slicema, int32_t, 12, 23, 34, 45);
	tr_log("%zu", slicema.length);
	/*
	{
	int32_t tmp[] = {12, 23, 34, 45};
	memcpy(&slicema->buffer, tmp, sizeof(tmp));
	&slicema->length = sizeof(tmp) / sizeof(int32_t);
	}*/

	// iterate
	for (size_t i = 0; i < slicema.length; i++) {
		tr_log("%i", *TR_AT(slicema, int32_t, i));
	}
	// will panic without mysteriously dying
	tr_log("%i\n", *TR_AT(slicema, int32_t, 842852357635735));

	// 2d slice
	TrSlice2D slicema2d = tr_slice2d_new(&arena, 4, 4, sizeof(int32_t));

	// set items
	*TR_AT2D(slicema2d, int32_t, 0, 0) = 11;
	*TR_AT2D(slicema2d, int32_t, 1, 1) = 22;
	*TR_AT2D(slicema2d, int32_t, 2, 2) = 33;
	*TR_AT2D(slicema2d, int32_t, 3, 3) = 44;

	// iterate
	for (size_t y = 0; y < slicema2d.height; y++) {
		for (size_t x = 0; x < slicema2d.width; x++) {
			tr_log("%i", *TR_AT2D(slicema2d, int32_t, x, y));
		}
	}
	// will panic without mysteriously dying
	tr_log("%i\n", *TR_AT2D(slicema2d, int32_t, 6396903, 26464262));

	// you free the entire arena at once
	tr_arena_free(&arena);

	tr_free();
}
