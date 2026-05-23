package stvoxel

Camera :: struct {
	position: [3]f32,
	rotation: quaternion128,
	// TODO orthographic projection
	fov:      f32, // radians
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
