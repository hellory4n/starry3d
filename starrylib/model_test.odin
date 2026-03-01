package starrylib

import "core:testing"

@(test)
t_model_start_must_be_smaller_than_end :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {5, 5, 5}, end = {2, 2, 2})
	testing.expect(t, err == .START_MUST_BE_SMALLER_THAN_END)
	testing.expect(t, m.bricks == nil)
}

@(test)
t_init_small_model :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-4, -4, -4}, end = {4, 4, 4})
	defer free_model(&m)
	testing.expect(t, err == .OK)
	testing.expect(t, m.start == {-4, -4, -4})
	testing.expect(t, m.end == {5, 5, 5})
	testing.expect(t, m.size == {9, 9, 9}) // inclusive
}

@(test)
t_init_model_with_negative_coords :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-12, -12, -12}, end = {11, 11, 11})
	defer free_model(&m)
	testing.expect(t, err == .OK)
	testing.expect(t, m.start == {-12, -12, -12})
	testing.expect(t, m.end == {12, 12, 12})
	// size inclusive -> 24 voxels per axis
	testing.expect(t, m.size.x == 24)
	testing.expect(t, m.size.y == 24)
	testing.expect(t, m.size.z == 24)
}

@(test)
t_model_out_of_bounds :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-8, -8, -8}, end = {7, 7, 7})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	outside := [][3]i32 {
		{-9, 0, 0},
		{8, 0, 0},
		{0, -9, 0},
		{0, 8, 0},
		{0, 0, -9},
		{0, 0, 8},
		{-8, -8, -9},
		{7, 7, 8},
	}

	for pos in outside {
		testing.expect(t, is_out_of_bounds(&m, pos))
		_, solid := get_voxel(&m, pos, tag = 0, default = 0xDEADDEAD)
		testing.expect(t, !solid)
		_, solid = get_voxel_transmute(&m, u32, pos, tag = 0, default = 0xDEADDEAD)
		testing.expect(t, !solid)
	}

	inside := [][3]i32{{-7, 0, 0}, {7, 0, 0}, {0, -7, 0}, {0, 7, 0}, {0, 0, -7}, {0, 0, 7}}
	for pos in inside {
		testing.expect(t, !is_out_of_bounds(&m, pos))
	}
}

@(test)
t_model_empty_voxel :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-8, -8, -8}, end = {7, 7, 7})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	pos := [3]i32{3, 4, -2}
	testing.expect(t, !is_voxel_solid(&m, pos))

	v, solidv := get_voxel(&m, pos, COLOR_TAG, default = 0x11223344)
	testing.expect(t, v == 0x11223344)
	testing.expect(t, !solidv)

	Color :: distinct u32
	c, solidc := get_voxel_transmute(&m, Color, pos, tag = 61, default = Color(0xFF00AA11))
	testing.expect(t, c == 0xFF00AA11)
	testing.expect(t, !solidc)
}

@(test)
t_model_get_set :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-32, -32, -32}, end = {31, 31, 31})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	pos := [3]i32{-17, 9, 22}

	set_err := set_voxel(&m, pos, COLOR_TAG, u32(0xFF336699))
	testing.expect(t, set_err == .OK)

	col, solidcol := get_voxel(&m, pos, COLOR_TAG, default = 0)
	testing.expect(t, col == 0xFF336699)
	testing.expect(t, solidcol)

	// neighbor in same brick, tag now exists but not explicitly set
	neighbor := [3]i32{-20, 9, 22}
	n_col, _ := get_voxel(&m, neighbor, COLOR_TAG, default = 0xFFFFFFFF)
	testing.expect(t, n_col == 0xFFFFFFFF)

	// different tag still gives default
	crap, solidcrap := get_voxel(&m, pos, tag = 99, default = 12345)
	testing.expect(t, crap == 12345)
	testing.expect(t, solidcrap)

	// still solid without color tag
	set_voxel(&m, {1, 0, 0}, tag = 61, value = u32(123456))
	testing.expect(t, is_voxel_solid(&m, pos))
}

@(test)
t_model_remove :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-16, -16, -16}, end = {15, 15, 15})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	pos := [3]i32{4, -3, 10}
	set_voxel(&m, pos, COLOR_TAG, u32(0xFF4488FF))
	set_voxel(&m, pos, tag = 77, value = u32(0xBEEFBEEF))

	testing.expect(t, is_voxel_solid(&m, pos))

	was_solid := remove_voxel(&m, pos)
	testing.expect(t, was_solid)
	testing.expect(t, !is_voxel_solid(&m, pos))

	col, _ := get_voxel(&m, pos, COLOR_TAG, default = 123)
	testing.expect(t, col == 123)

	v77, _ := get_voxel(&m, pos, tag = 77, default = 456)
	testing.expect(t, v77 == 456)

	// neighbor still gets default for both tags
	n := [3]i32{5, -3, 10}
	testing.expect(t, !is_voxel_solid(&m, n))
}
