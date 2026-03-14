package starrylib

import "core:mem"
import "core:os"
import "core:testing"

@(test)
t_read_write_bmv :: proc(t: ^testing.T)
{
	src := create_the_great_upside_down_t_model(t)
	defer free_model(&src)

	oserr := os.make_directory_all("testout")
	if oserr != .Exist {
		testing.expect_value(t, oserr, nil)
	}

	err := write_model_to_bmv_file(
		"testout/model.bmv",
		&src,
		Bmv_Standard_Metadata{compression_algorithm = .NONE},
	)
	testing.expect_value(t, err, nil)

	// TODO test writer separately
	// but how do you know the writer works if you don't know whether the reader works
	// a chicken or egg esque conundrum
	// (read the file and manually check all of the bytes i guess?)

	meta, err2 := load_metadata_from_bmv_file("testout/model.bmv")
	testing.expect_value(t, err2, nil)
	defer free_metadata_loaded_from_bmv_file(meta)

	testing.expect(t, BMV_SIZE_METATAG in meta)
	testing.expect(t, BMV_STARRY_BOUNDS_METATAG in meta)
	// testing.expect(t, BMV_COMPRESSION_METATAG in meta)
	// TODO don't feel like copy pasting the byte fucking to test the data

	dst, err3 := new_model_from_bmv_file("testout/model.bmv")
	defer free_model(&dst)
	testing.expect_value(t, err3, nil)

	testing.expect_value(t, dst.start, src.start)
	testing.expect_value(t, dst.end, src.end)
	testing.expect_value(t, dst.size, src.size)
	testing.expect_value(t, dst.voxel_count, src.voxel_count)

	testing.expect_value(t, len(dst.solid), len(src.solid))
	testing.expect(
		t,
		mem.compare(mem.slice_to_bytes(dst.solid), mem.slice_to_bytes(src.solid)) == 0,
	)

	testing.expect_value(t, len(dst.data), len(src.data))
	testing.expect(t, RGBA_TAG in dst.data)
	testing.expect(t, ([4]byte{'D', 'i', '?', 'h'}) in dst.data)
	testing.expect(
		t,
		mem.compare(
			mem.slice_to_bytes(dst.data[RGBA_TAG]),
			mem.slice_to_bytes(src.data[RGBA_TAG]),
		) ==
		0,
	)
	testing.expect(
		t,
		mem.compare(
			mem.slice_to_bytes(dst.data[[4]byte{'D', 'i', '?', 'h'}]),
			mem.slice_to_bytes(src.data[[4]byte{'D', 'i', '?', 'h'}]),
		) ==
		0,
	)
}
