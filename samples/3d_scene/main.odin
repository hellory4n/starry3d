package a3dscene

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import gfx "../../starrygfx"
import st "../../starrylib"

app: struct {
	scene: gfx.Flat_Scene,
}

new_app :: proc()
{
	app.scene = gfx.new_flat_scene()
	app.scene.camera = {
		transform   = gfx.camera_transform_from_position_rotation(
			pos = {1, 2, 3},
			rot = 1,
		),
		projection  = .PERSPECTIVE,
		fov_or_zoom = 45,
		near        = 0.001,
		far         = 1000,
	}
}

free_app :: proc()
{
}

update_app :: proc(dt: f32)
{
	// TODO
}

render_app :: proc(dt: f32, dev: gpu.Device)
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
