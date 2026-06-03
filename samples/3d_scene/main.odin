package a3dscene

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import gfx3d "../../starrygfx3d"

app: struct {
	scene: ^gfx3d.Scene_Object,
}

new_app :: proc()
{
	app.scene = gfx3d.new_blank_scene()
	ricardo := gfx3d.new_blank_scene()
	roberto := gfx3d.new_blank_scene()
	ricardo_roberto := gfx3d.new_blank_scene()

	defer gfx3d.free_scene(app.scene)
	defer gfx3d.free_scene(ricardo)
	defer gfx3d.free_scene(roberto)
	defer gfx3d.free_scene(ricardo_roberto)

	gfx3d.add_child_to_scene(app.scene, "ricardo roberto", ricardo_roberto)
	gfx3d.add_child_to_scene(ricardo_roberto, "ricardo", ricardo)
	gfx3d.add_child_to_scene(ricardo_roberto, "roberto", roberto)

	gfx3d.dump_scene(app.scene, "la scene au chocolat")
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
