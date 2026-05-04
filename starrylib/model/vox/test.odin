package vox

import "core:log"
import "core:os"
import "core:testing"
import model ".."

@(test)
t_write :: proc(t: ^testing.T)
{
	m := model.new_testing_model(t)
	defer model.free_model(&m)

	oserr := os.make_directory_all("testout")
	if oserr != .Exist {
		testing.expect_value(t, oserr, nil)
	}

	mverr := write_to_file("testout/model.vox", &m)
	testing.expect_value(t, mverr, nil)

	log.warn(
		"TODO can't be bothered to automatically check the .vox just check it yourself lmao",
	)
}
