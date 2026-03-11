package starrylib

import "core:testing"

@(test)
t_model_start_must_be_smaller_than_end :: proc(t: ^testing.T)
{
	_, err := new_empty_model(start = {5, 5, 5}, end = {2, 2, 2})
	testing.expect(t, err == .START_MUST_BE_SMALLER_THAN_END)
}

@(test)
t_init_small_model :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-4, -4, -4}, end = {4, 4, 4})
	defer free_model(&m)
	testing.expect(t, err == .OK)
	testing.expect(t, m.start == {-4, -4, -4})
	testing.expect(t, m.end == {4, 4, 4})
	testing.expect(t, m.size == {8, 8, 8}) // inclusive
}

@(test)
t_init_model_with_negative_coords :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-12, -12, -12}, end = {12, 12, 12})
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
	m, err := new_empty_model(start = {-8, -8, -8}, end = {8, 8, 8})
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
		_, solid := get_voxel(&m, pos, tag = 0)
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
	m, err := new_empty_model(start = {-8, -8, -8}, end = {8, 8, 8})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	pos := [3]i32{3, 4, -2}
	testing.expect(t, !is_voxel_solid(&m, pos))

	_, solid := get_voxel(&m, pos, RGBA_TAG)
	testing.expect(t, !solid)

	_, solid = get_voxel(&m, pos, tag = 61)
	testing.expect(t, !solid)
}

@(test)
t_model_get_set :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-32, -32, -32}, end = {32, 32, 32})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	pos := [3]i32{-17, 9, 22}

	set_err := set_voxel(&m, pos, RGBA_TAG, 0xFF336699)
	testing.expect(t, set_err == .OK)

	col, solidcol := get_voxel(&m, pos, RGBA_TAG)
	testing.expect(t, col == 0xFF336699)
	testing.expect(t, solidcol)

	// still solid without color tag
	set_voxel(&m, {1, 0, 0}, tag = 61, value = 123456)
	testing.expect(t, is_voxel_solid(&m, pos))
}

@(test)
t_model_remove :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-16, -16, -16}, end = {16, 16, 16})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	pos := [3]i32{4, -3, 10}
	set_voxel(&m, pos, RGBA_TAG, 0xFF4488FF)
	set_voxel(&m, pos, tag = 77, value = 0xBEEFBEEF)

	testing.expect(t, is_voxel_solid(&m, pos))

	was_solid := remove_voxel(&m, pos)
	testing.expect(t, was_solid)
	testing.expect(t, !is_voxel_solid(&m, pos))
}

@(test)
t_model_iterator_empty :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {0, 0, 0}, end = {8, 8, 8})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	iter := model_iterator(&m)
	_, _, _, ok := model_iterator_next(&iter)
	testing.expect(t, !ok, "empty model should have no items")
}

@(test)
t_model_iterator_no_solid_voxels :: proc(t: ^testing.T)
{
	m, err := new_empty_model(start = {-8, -8, -8}, end = {8, 8, 8})
	defer free_model(&m)
	testing.expect(t, err == .OK)

	pos := [3]i32{1, 1, -1}
	// first set_voxel should allocate
	set_voxel(&m, pos, RGBA_TAG, value = 0xFF112233)
	set_voxel(&m, pos, tag = 99, value = 777)
	// memory still reserved but now without anything
	remove_voxel(&m, pos)

	iter := model_iterator(&m)
	_, _, _, ok := model_iterator_next(&iter)
	testing.expect(t, !ok, "should not yield anything when no solid voxel")
}

@(test)
t_model_iterator_negative_and_boundaries :: proc(t: ^testing.T)
{
	m, _ := new_empty_model(start = {-12, -12, -12}, end = {-5, -5, -5})
	defer free_model(&m)

	positions := [][3]i32{{-12, -12, -12}, {-8, -8, -8}, {-6, -6, -6}}

	for p, i in positions {
		set_voxel(&m, p, RGBA_TAG, value = 1000 + u32(i))
	}

	seen: map[[3]i32]int
	defer delete(seen)

	iter := model_iterator(&m)
	for pos, _, _ in model_iterator_next(&iter) {
		seen[pos] += 1
	}

	testing.expect_value(t, len(seen), 3)
	for p in positions {
		testing.expect_value(t, seen[p], 1)
	}
}

@(test)
t_model_iterator_one_voxel_one_prop :: proc(t: ^testing.T)
{
	m, _ := new_empty_model(start = {-16, -16, -16}, end = {16, 16, 16})
	defer free_model(&m)

	target := [3]i32{5, -7, 12}
	set_voxel(&m, target, RGBA_TAG, 0xFF00FF00)

	iter := model_iterator(&m)
	pos, tag, payload, ok := model_iterator_next(&iter)
	testing.expect(t, ok)
	testing.expect_value(t, pos, target)
	testing.expect_value(t, tag, RGBA_TAG)
	testing.expect_value(t, payload, 0xFF00FF00)

	_, _, _, ok = model_iterator_next(&iter)
	testing.expect(t, !ok, "should only have one item")
}

@(test)
t_model_iterator_one_voxel_multiple_props :: proc(t: ^testing.T)
{
	m, _ := new_empty_model(start = {0, 0, 0}, end = {15, 15, 15})
	defer free_model(&m)

	pos := [3]i32{4, 4, 4}
	set_voxel(&m, pos, RGBA_TAG, 0xFF336699)
	set_voxel(&m, pos, 10, 0xCAFE0000)
	set_voxel(&m, pos, 77, 12345678)

	Collected_Crap :: struct {
		tag:     Tag,
		payload: Payload,
	}
	collected: [dynamic]Collected_Crap
	defer delete(collected)

	iter := model_iterator(&m)
	for p, tag, payload in model_iterator_next(&iter) {
		testing.expect(t, p == pos)
		append(&collected, Collected_Crap{tag, payload})
	}

	testing.expect(t, len(collected) == 3)

	found_tags: map[Tag]Payload
	defer delete(found_tags)
	for item in collected {
		found_tags[item.tag] = item.payload
	}

	testing.expect(t, found_tags[RGBA_TAG] == 0xFF336699)
	testing.expect(t, found_tags[10] == 0xCAFE0000)
	testing.expect(t, found_tags[77] == 12345678)
}

// world's worst test model
@(private)
create_the_great_upside_down_t_model :: proc(t: ^testing.T) -> Model
{
	m, err := new_empty_model(start = {-8, -8, -8}, end = {8, 8, 8})
	testing.expect_value(t, err, Init_Model_Error.OK)

	// upside-down T
	testing.expect_value(
		t,
		set_voxel(&m, {0, -2, 0}, RGBA_TAG, 0xf9c440ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-1, -2, 0}, RGBA_TAG, 0xf9c440ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {1, -2, 0}, RGBA_TAG, 0xf9c440ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, -1, 0}, RGBA_TAG, 0xf9c440ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(t, set_voxel(&m, {0, 0, 0}, RGBA_TAG, 0xf9c440ff), Set_Voxel_Error.OK)
	testing.expect_value(t, set_voxel(&m, {0, 1, 0}, RGBA_TAG, 0xf9c440ff), Set_Voxel_Error.OK)
	testing.expect_value(t, set_voxel(&m, {0, 2, 0}, RGBA_TAG, 0xffffffff), Set_Voxel_Error.OK)

	// corners
	testing.expect_value(
		t,
		set_voxel(&m, {-8, 7, -8}, RGBA_TAG, 0xff0000ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-8, 7, 7}, RGBA_TAG, 0x00ff00ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {7, 7, -8}, RGBA_TAG, 0x0000ffff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(t, set_voxel(&m, {7, 7, 7}, RGBA_TAG, 0xffff00ff), Set_Voxel_Error.OK)
	testing.expect_value(
		t,
		set_voxel(&m, {-8, -8, -8}, RGBA_TAG, 0xff0000ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-8, -8, 7}, RGBA_TAG, 0x00ff00ff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {7, -8, -8}, RGBA_TAG, 0x0000ffff),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {7, -8, 7}, RGBA_TAG, 0xffff00ff),
		Set_Voxel_Error.OK,
	)

	return m
}
