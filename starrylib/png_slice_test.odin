package starrylib

import "core:log"
import os "core:os/os2"
import "core:testing"

@(test)
t_png_slice :: proc(t: ^testing.T)
{
	m := create_the_great_upside_down_t_model(t)
	defer free_model(&m)

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
