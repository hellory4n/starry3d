package starrylib

import "core:log"
import os "core:os/os2"
import "core:testing"

@(test)
t_png_slice :: proc(t: ^testing.T)
{
	m, merr := new_empty_model(start = {-4, -2, -4}, end = {4, 2, 4})
	testing.expect_value(t, merr, Init_Model_Error.OK)
	defer free_model(&m)

	// H somewhere in the middle-ish
	testing.expect_value(
		t,
		set_voxel(&m, {0, 0, 0}, COLOR_TAG, u32(0x0000ffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, 0, 1}, COLOR_TAG, u32(0x0000ccff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, 0, 2}, COLOR_TAG, u32(0x0000aaff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, 0, 3}, COLOR_TAG, u32(0x000066ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {0, 0, 4}, COLOR_TAG, u32(0x000033ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {2, 0, 0}, COLOR_TAG, u32(0x0000ffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {2, 0, 1}, COLOR_TAG, u32(0x0000ccff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {2, 0, 2}, COLOR_TAG, u32(0x0000aaff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {2, 0, 3}, COLOR_TAG, u32(0x000066ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {2, 0, 4}, COLOR_TAG, u32(0x000033ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {1, 0, 2}, COLOR_TAG, u32(0x0000aaff)),
		Set_Voxel_Error.OK,
	)

	// corners
	testing.expect_value(
		t,
		set_voxel(&m, {-4, -2, -4}, COLOR_TAG, u32(0xffffffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-4, -2, 4}, COLOR_TAG, u32(0xffffffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {4, -2, -4}, COLOR_TAG, u32(0xffffffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {4, -2, 4}, COLOR_TAG, u32(0xffffffff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-4, 2, -4}, COLOR_TAG, u32(0xff0000ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {-4, 2, 4}, COLOR_TAG, u32(0xff0000ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {4, 2, -4}, COLOR_TAG, u32(0xff0000ff)),
		Set_Voxel_Error.OK,
	)
	testing.expect_value(
		t,
		set_voxel(&m, {4, 2, 4}, COLOR_TAG, u32(0xff0000ff)),
		Set_Voxel_Error.OK,
	)

	oserr := os.make_directory_all("testout")
	if oserr != .Exist {
		testing.expect_value(t, oserr, nil)
	}

	oserr = write_model_to_png_file("testout/slice.png", &m)
	testing.expect_value(t, oserr, nil)

	log.warn(
		"TODO can't be bothered to automatically check the image just check it yourself lmao",
	)
}
