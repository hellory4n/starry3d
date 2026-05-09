package starryrt

import "base:runtime"
import hm "core:container/handle_map"
import "gpu"

// all the engine's global state goes here (or at least the state from this package)
@(private)
engine: struct {
	// window/app lifetime
	ctx:           runtime.Context, // for callbacks
	windows:       [dynamic]^Window,
	device:        gpu.Device,
	swapchain:     gpu.Swapchain,
	start_time:    f64,
	current_time:  f64,
	prev_time:     f64,
	running:       bool,

	// asset systems
	textures:      hm.Static_Handle_Map(1024, Texture_Data, Texture),
	texture_cache: map[string]Texture,
}
