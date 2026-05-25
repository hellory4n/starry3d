package stvoxel

import st "../starrylib"
import strt "../starryrt"
import "../starryrt/gpu"
import "core:math"
import "core:math/linalg"

init_renderer :: proc(dev: gpu.Device)
{
	// to avoid a mysterious black screen
	if global.camera.fov_radians == 0 do global.camera.fov_radians = math.to_radians(f32(70))
	if global.camera.rotation == 0 do global.camera.rotation = 1

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
	Uniforms :: struct {
		aspect_ratio: f32 `gpu:"u_aspect_ratio"`,
		cam_pos:      [3]f32 `gpu:"u_cam_pos"`,
		cam_rot:      [4]f32 `gpu:"u_cam_rot"`,
		fov:          f32 `gpu:"u_fov"`,
	}
	gpu.set_uniforms(
		dev,
		Uniforms {
			aspect_ratio = strt.aspect_ratio(),
			cam_pos = camera().position,
			cam_rot = st.quat_to_vec4(camera().rotation),
			fov = camera().fov_radians,
		},
	)

	gpu.draw(dev, vertex_count = 6)
	gpu.end_render_pass(dev)
}
