package starrygfx

import stapp "../starryapp"
import "core:math/linalg"

Camera :: struct {
	transform:   matrix[4, 4]f32,
	projection:  Camera_Projection,
	fov_or_zoom: f32,
	near:        f32,
	far:         f32,
}

Camera_Projection :: enum {
	PERSPECTIVE,
	ORTHOGRAPHIC,
}

// catchy
camera_transform_from_position_rotation :: proc(
	pos: [3]f32,
	rot: quaternion128,
) -> matrix[4, 4]f32
{
	return linalg.matrix4_inverse(
		linalg.matrix4_translate(pos) * linalg.matrix4_from_quaternion(rot),
	)
}

camera_projection_matrix :: proc(cam: Camera) -> matrix[4, 4]f32
{
	if cam.projection == .PERSPECTIVE {
		return linalg.matrix4_perspective(
			fovy = cam.fov_or_zoom,
			aspect = stapp.aspect_ratio(),
			near = cam.near,
			far = cam.far,
		)
	} else {
		left := -cam.fov_or_zoom / 2
		right := cam.fov_or_zoom / 2

		winsize := stapp.framebuffer_sizef()
		height := cam.fov_or_zoom * (winsize.y / winsize.x)
		bottom := -height / 2
		top := height / 2

		return linalg.matrix_ortho3d(
			left = left,
			right = right,
			bottom = bottom,
			top = top,
			near = cam.near,
			far = cam.far,
		)
	}
}

Light :: struct {
	transform: matrix[4, 4]f32,
	color:     [4]f32,
	intensity: f32,
}

Flat_Scene :: struct {
	camera: Camera,
	lights: [dynamic]Light,
}

// A flat scene is intended to be used between Scene_Tree (user-friendly) and Render_Scene
// (renderer-friendly), hence why the allocator defaults to temp_allocator, you never want to
// store Flat_Scene for too long
new_flat_scene :: proc(allocator := context.temp_allocator) -> (scene: Flat_Scene)
{
	// TODO micro-optimization: keep track of how many total items are in Scene_Tree
	// so that this exact amount can be reserved here
	scene.lights = make([dynamic]Light, allocator)
	return
}
