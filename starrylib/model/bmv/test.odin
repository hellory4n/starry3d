package bmv

import "core:mem"
import "core:os"
import "core:testing"
import model ".."
import st "../.."

@(test)
t_read_write :: proc(t: ^testing.T)
{
	src := model.new_testing_model(t)
	defer model.free_model(&src)

	oserr := os.make_directory_all("testout")
	if oserr != .Exist {
		testing.expect_value(t, oserr, nil)
	}

	err := write_to_file(
		"testout/model.bmv",
		&src,
		Standard_Metadata{compression_algorithm = .NONE},
	)
	testing.expect_value(t, err, nil)

	// TODO test writer separately
	// but how do you know the writer works if you don't know whether the reader works
	// a chicken or egg esque conundrum
	// (read the file and manually check all of the bytes i guess?)

	meta, err2 := load_metadata_from_file("testout/model.bmv")
	testing.expect_value(t, err2, nil)
	defer free_metadata_from_file(meta)

	testing.expect(t, SIZE_METATAG in meta)
	testing.expect(t, STARRY_BOUNDS_METATAG in meta)
	// testing.expect(t, BMV_COMPRESSION_METATAG in meta)
	// TODO don't feel like copy pasting the byte fucking to test the data

	dst, err3 := load_from_file("testout/model.bmv")
	defer model.free_model(&dst)
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
	testing.expect(t, model.RGBA_TAG in dst.data)
	testing.expect(t, st.tag("Di?h") in dst.data)
	testing.expect(
		t,
		mem.compare(
			mem.slice_to_bytes(dst.data[model.RGBA_TAG]),
			mem.slice_to_bytes(src.data[model.RGBA_TAG]),
		) ==
		0,
	)
	testing.expect(
		t,
		mem.compare(
			mem.slice_to_bytes(dst.data[st.tag("Di?h")]),
			mem.slice_to_bytes(src.data[st.tag("Di?h")]),
		) ==
		0,
	)
}
