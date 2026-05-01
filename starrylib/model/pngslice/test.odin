package pngslice

import "core:log"
import "core:os"
import "core:testing"
import model ".."

@(test)
t_png_slice :: proc(t: ^testing.T)
{
	m := model.make_testing_model(t)
	defer model.free_model(&m)

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
