package starrylib

import "core:testing"

@(test)
test_get_set_remove_voxels :: proc(t: ^testing.T)
{
	// TODO segregate into multiple tests but i can't be bothered rn
	model, init_err := new_empty_model(start = {-16, -4, -16}, end = {16, 4, 16})
	testing.expect_value(t, init_err, Init_Model_Error.OK)
	defer free_model(&model)

	colorof, get_err := get_voxel(&model, {1, 2, 3}, COLOR_TAG)
	testing.expect_value(t, get_err, Get_Voxel_Error.EMPTY_VOXEL)
	testing.expect(t, !is_voxel_solid(&model, {1, 2, 3}))

	MYSTERY_TAG :: 61
	set_err := set_voxel(&model, {1, 2, 3}, MYSTERY_TAG, u32(76816425))
	testing.expect_value(t, set_err, Set_Voxel_Error.OK)
	testing.expect(t, !is_out_of_bounds(&model, {1, 2, 3}))
	testing.expect(t, is_voxel_solid(&model, {1, 2, 3}))

	_, get_err = get_voxel(&model, {1, 2, 3}, COLOR_TAG)
	testing.expect_value(t, get_err, Get_Voxel_Error.NO_SUCH_PROP)

	was_solid := remove_voxel(&model, {1, 2, 3})
	testing.expect_value(t, was_solid, true)
	testing.expect(t, !is_voxel_solid(&model, {1, 2, 3}))

	set_err = set_voxel(&model, {1, 2, 3}, COLOR_TAG, u32(0xff0000ff))
	colorof, get_err = get_voxel(&model, {1, 2, 3}, COLOR_TAG)
	testing.expect_value(t, get_err, Get_Voxel_Error.OK)
	testing.expect_value(t, colorof, 0xff0000ff)

	_, get_err = get_voxel(&model, {-1, -2, -3}, COLOR_TAG)
	testing.expect_value(t, get_err, Get_Voxel_Error.EMPTY_VOXEL)

	set_err = set_voxel(&model, {-1, -2, -3}, COLOR_TAG, u32(0x00ff00ff))
	colorof, get_err = get_voxel(&model, {-1, -2, -3}, COLOR_TAG)
	testing.expect_value(t, get_err, Get_Voxel_Error.OK)
	testing.expect_value(t, colorof, 0x00ff00ff)

	colorof, get_err = get_voxel(&model, {1, 2, 3}, COLOR_TAG)
	testing.expect_value(t, get_err, Get_Voxel_Error.OK)
	testing.expect_value(t, colorof, 0xff0000ff)

	set_err = set_voxel(&model, {1, 2, 4}, COLOR_TAG, u32(0x0000ffff))
	colorof, get_err = get_voxel(&model, {1, 2, 4}, COLOR_TAG)
	testing.expect_value(t, get_err, Get_Voxel_Error.OK)
	testing.expect_value(t, colorof, 0x0000ffff)
}
