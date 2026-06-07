package starrygfx

import stapp "../starryapp"
import "core:math/linalg"

Camera_Projection :: enum {
	PERSPECTIVE,
	ORTHOGRAPHIC,
}

Camera_3D :: struct {
	position:   [3]f32,
	rotation:   quaternion128,
	fov:        f32,
	zoom:       f32,
	near:       f32,
	far:        f32,
	projection: Camera_Projection,
}

camera_3d :: proc() -> Camera_3D
{
	return global.camera
}

set_camera_3d :: proc(v: Camera_3D)
{
	global.camera = v
}

// Returns the view matrix from the camera's parameters
camera_3d_view_matrix :: proc(cam: Camera_3D) -> matrix[4, 4]f32
{
	return(
		linalg.matrix4_translate(cam.position) *
		linalg.matrix4_from_quaternion(cam.rotation) \
	)
}

// Returns the projection matrix from the camera's parameters
camera_3d_projection_matrix :: proc(cam: Camera_3D) -> matrix[4, 4]f32
{
	if cam.projection == .PERSPECTIVE {
		return linalg.matrix4_perspective_f32(
			fovy = cam.fov,
			aspect = stapp.aspect_ratio(),
			near = cam.near,
			far = cam.far,
		)
	} else {
		left := -cam.zoom / 2
		right := cam.zoom / 2

		winsize := stapp.framebuffer_sizef()
		height := cam.zoom * (winsize.y / winsize.x)
		bottom := -height / 2
		top := height / 2

		return linalg.matrix_ortho3d_f32(
			left = left,
			right = right,
			bottom = bottom,
			top = top,
			near = obj.near,
			far = obj.far,
		)
	}
}
