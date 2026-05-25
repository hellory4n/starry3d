package stvoxel

import "../starryrt/gpu"
import "core:math"
import "core:math/linalg"

init_renderer :: proc(dev: gpu.Device)
{
	// to avoid a mysterious black screen
	if global.camera.fov_radians == 0 do global.camera.fov_radians = math.to_radians(f32(70))
	if global.camera.rotation == 0 do global.camera.rotation = 0

	vert := gpu.new_shader(dev, #load("shader/voxel.vert"), .VERTEX)
	defer gpu.free_shader(vert)

	frag := gpu.new_shader(dev, #load("shader/voxel.frag"), .FRAGMENT)
	defer gpu.free_shader(frag)

	global.pipeline = gpu.new_pipeline(
		dev,
		shaders = gpu.Render_Shaders{vertex = vert, fragment = frag},
	)
}

free_renderer :: proc(dev: gpu.Device)
{
	gpu.free_pipeline(global.pipeline)
}

render :: proc(dev: gpu.Device, swap: gpu.Swapchain)
{
	gpu.begin_render_pass(dev, swap)
	gpu.bind_pipeline(dev, global.pipeline)

	gpu.draw(dev, vertex_count = 6)
	gpu.end_render_pass(dev)
}
