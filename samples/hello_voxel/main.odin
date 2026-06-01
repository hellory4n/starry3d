package hello

import stapp "../../starryapp"
import "../../starryapp/gpu"
import stvx "../../voxel"
import "core:log"
import "core:math"
import "core:math/linalg"

app: struct {
	player_controllable: bool,
	camera_euler:        [3]f32,
}

new_app :: proc()
{
	stvx.init_renderer(stapp.get_gpu())

	stvx.set_camera({fov_radians = math.to_radians(f32(90))})
}

free_app :: proc()
{
	stvx.free_renderer(stapp.get_gpu())
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	stvx.render(dev, swap)
}

update_app :: proc(dt: f32)
{
	if stapp.is_key_just_pressed(.ESCAPE) {
		app.player_controllable = !app.player_controllable
		stapp.lock_mouse(app.player_controllable)
	}

	if app.player_controllable {
		cam := stvx.camera()
		mouse_look(&cam, dt)
		move(&cam, dt)
		stvx.set_camera(cam)
	}
}

mouse_look :: #force_inline proc(camera: ^stvx.Camera, dt: f32)
{
	MOUSE_SENSITIVITY :: 50
	mouse := stapp.delta_mouse_position()
	app.camera_euler.y -= mouse.x * MOUSE_SENSITIVITY * dt
	app.camera_euler.x -= mouse.y * MOUSE_SENSITIVITY * dt
	// don't break your neck
	app.camera_euler.x = clamp(app.camera_euler.x, -89, 89)

	camera.rotation = linalg.quaternion_from_euler_angles(
		math.to_radians(app.camera_euler.x),
		math.to_radians(app.camera_euler.y),
		0,
		.XYZ,
	)
}

move :: #force_inline proc(camera: ^stvx.Camera, dt: f32)
{
	PLAYER_SPEED :: 5
	dir := [3]f32{}

	if stapp.is_key_held(.W) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y)) * 1
		dir.z += math.cos(math.to_radians(app.camera_euler.y)) * -1
	}
	if stapp.is_key_held(.S) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y)) * -1
		dir.z += math.cos(math.to_radians(app.camera_euler.y)) * 1
	}
	if stapp.is_key_held(.D) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y - 90)) * 1
		dir.z += math.cos(math.to_radians(app.camera_euler.y - 90)) * -1
	}
	if stapp.is_key_held(.A) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y - 90)) * -1
		dir.z += math.cos(math.to_radians(app.camera_euler.y - 90)) * 1
	}
	if stapp.is_key_held(.SPACE) {
		dir += 1
	}
	if stapp.is_key_held(.LEFT_SHIFT) {
		dir -= 1
	}

	if linalg.length(dir) > 0.0001 {
		dir = linalg.normalize(dir)
		camera.position += dir * PLAYER_SPEED * dt
	}
}

main :: proc()
{
	stapp.run(
		app_name = "hello voxel",
		app_version = {0, 1, 0},
		asset_dir = "samples/hello_voxel",
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
	)
}
