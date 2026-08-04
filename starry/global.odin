package starry

import ft "../thirdparty/freetype"
import lua "../thirdparty/luajit"
import "base:runtime"
import hm "core:container/handle_map"
import vmem "core:mem/virtual"
import "gpu"

global: struct {
	// pre-init
	ctx:          runtime.Context,
	args:         Args,
	init_arena:   vmem.Arena,
	exe_dir:      string,
	exe_name:     string,

	// app
	lua:          ^lua.State,
	config:       Config,
	config_flags: ConfigFlags,

	// window
	windows:      [dynamic]^Window,
	start_time:   f64,
	current_time: f64,
	prev_time:    f64,
	delta_time:   f64,
	running:      bool,

	// graphics
	device:       gpu.Device,
	textures:     hm.Dynamic_Handle_Map(TextureData, hm.Handle32),
	fonts:        hm.Dynamic_Handle_Map(FontData, hm.Handle32),
	samplers:     [gpu.Texture_Filter]gpu.Sampler,
	ft:           ft.Library,
	gfx2d:        struct {
		commands:      [dynamic]DrawCommand2D,
		rect_pipeline: gpu.Pipeline,
		rect_uniforms: gpu.Buffer,
		text_pipeline: gpu.Pipeline,
		text_uniforms: gpu.Buffer,
	},

	// string ids
	strdb:        struct {
		arena:       vmem.Arena,
		str_to_id:   map[string]StringId,
		id_to_str:   map[StringId]string,
		initialized: bool,
	},
}
