package stgfx3d

import hm "core:container/handle_map"

@(private)
global: struct {
	models:      hm.Static_Handle_Map(1024, Model_Data, Model),
	model_cache: map[string]Model,
}
