package starrylib

import "core:log"
import os "core:os/os2"
import "core:testing"

@(test)
t_write_to_magicavoxel :: proc(t: ^testing.T)
{
	m, merr := new_empty_model(start = {-8, -8, -8}, end = {8, 8, 8})
	testing.expect_value(t, merr, Init_Model_Error.OK)
	defer free_model(&m)

	// upside-down T
	testing.expect_value(
		t,
		set_voxel(&m, {0, -2, 0}, COLOR_TAG, u32(0xf9c440ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-1, -2, 0}, COLOR_TAG, u32(0xf9c440ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {1, -2, 0}, COLOR_TAG, u32(0xf9c440ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, -1, 0}, COLOR_TAG, u32(0xf9c440ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, 0, 0}, COLOR_TAG, u32(0xf9c440ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, 1, 0}, COLOR_TAG, u32(0xf9c440ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, 2, 0}, COLOR_TAG, u32(0xffffffff)),
		Set_Voxel_Error.OK,
	)

	// corners
	testing.expect_value(
		t,
		set_voxel(&m, {-8, 7, -8}, COLOR_TAG, u32(0xff0000ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-8, 7, 7}, COLOR_TAG, u32(0x00ff00ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {7, 7, -8}, COLOR_TAG, u32(0x0000ffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {7, 7, 7}, COLOR_TAG, u32(0xffff00ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-8, -8, -8}, COLOR_TAG, u32(0xff0000ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-8, -8, 7}, COLOR_TAG, u32(0x00ff00ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {7, -8, -8}, COLOR_TAG, u32(0x0000ffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {7, -8, 7}, COLOR_TAG, u32(0xffff00ff)),
		Set_Voxel_Error.OK,
	)

	oserr := os.make_directory_all("testout")
	if oserr != .Exist {
		testing.expect_value(t, oserr, nil)
	}

	mverr := write_model_to_magicavoxel("testout/model.vox", &m)
	testing.expect_value(t, mverr, nil)

	log.warn(
		"TODO can't be bothered to automatically check the .vox just check it yourself lmao",
	)
}
