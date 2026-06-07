package starrygfx

import "core:math"

@(private)
global: struct {
	camera: Camera_3D,
}

init_system :: proc()
{
	global.camera.rotation = 1
	global.camera.fov = math.to_radians_f32(45)
	global.camera.zoom = 10
	global.camera.near = 0.001
	global.camera.far = 1000
}

free_system :: proc()
{
}
