package starrygfx

import "../starryapp/gpu"
import hm "core:container/handle_map"

@(private)
global: struct {
	// assets
	textures: hm.Dynamic_Handle_Map(Texture_Data, hm.Handle32),

	// renderers
	gfx2d:    struct {
		pipelines:      [Command_2D_Type]gpu.Pipeline,
		uniform_buffer: gpu.Buffer,
		commands:       [dynamic]Command_2D,
	},
}
