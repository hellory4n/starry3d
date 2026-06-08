package a3dscene

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import gfx3d "../../starrygfx3d"
import st "../../starrylib"
import "core:log"
import "core:math/linalg"

app: struct {
	scene: ^gfx3d.Scene_Object,
}

new_app :: proc()
{
	app.scene = gfx3d.new_blank_scene()
	ricardo := gfx3d.new_blank_scene()
	roberto := gfx3d.new_blank_scene()
	ricardo_roberto := gfx3d.new_blank_scene()
	camera := gfx3d.new_camera()
	ensure(camera.type == .CAMERA)

	defer gfx3d.free_scene(app.scene)
	defer gfx3d.free_scene(ricardo)
	defer gfx3d.free_scene(roberto)
	defer gfx3d.free_scene(ricardo_roberto)
	defer gfx3d.free_camera(camera)

	gfx3d.add_child_to_scene(app.scene, "ricardo roberto", ricardo_roberto)
	gfx3d.add_child_to_scene(ricardo_roberto, "ricardo", ricardo)
	gfx3d.add_child_to_scene(ricardo_roberto, "roberto", roberto)
	gfx3d.add_child_to_scene(ricardo, "camera", camera)
	ensure(camera.type == .CAMERA)

	camera.rotation = linalg.quaternion_from_euler_angle_x(f32(3))
	ricardo.position = {-1, 41, 3}
	ricardo_roberto.scale = 4

	ensure(camera.type == .CAMERA)
	gfx3d.dump_scene(app.scene, "la scene au chocolat")
	log.debugf("%#v", gfx3d.camera_projection_matrix(camera) * gfx3d.object_transform(camera))
	ensure(camera.type == .CAMERA)
}

free_app :: proc()
{
}

update_app :: proc(dt: f32)
{
	// TODO
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	// TODO
}

main :: proc()
{
	ctx := st.init_better_context()
	defer st.free_better_context(&ctx)
	context = ctx.ctx

	stapp.run(
		app_name = "3D scene",
		app_version = {0, 1, 0},
		asset_dir = "samples/3d_scene",
		init_proc = new_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
	)
}
