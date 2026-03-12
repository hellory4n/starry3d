package starrylib

import "core:os"
import "core:testing"

@(test)
t_write_model_to_bmv_file :: proc(t: ^testing.T)
{
	model := create_the_great_upside_down_t_model(t)
	defer free_model(&model)

	oserr := os.make_directory_all("testout")
	if oserr != .Exist {
		testing.expect_value(t, oserr, nil)
	}

	err := write_model_to_bmv_file("testout/model.bmv", &model)
	testing.expect_value(t, err, nil)
}
