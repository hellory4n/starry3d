package stvoxel

Camera :: struct {
	position:    [3]f32,
	rotation:    quaternion128,
	fov_radians: f32,
	// TODO orthographic projection
}

// Returns the active camera
camera :: proc() -> Camera
{
	return global.camera
}

// Sets the current camera
set_camera :: proc(camera: Camera)
{
	global.camera = camera
}
