package gfx2d

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import stgfx "../../starrygfx"
import st "../../starrylib"

global: struct {
	texture: stapp.Asset_Ref,
}

new_app :: proc()
{
	stgfx.init_gfx()
	global.texture = stapp.load(st.strid("texture"), "fish.png")
}

free_app :: proc()
{
	stgfx.free_gfx()
}

render_app :: proc(dt: f32, dev: gpu.Device)
{
	stgfx.clear_screen(dev)

	stgfx.draw_texture_rect(
		pos = {200, 300},
		size = {200, 200},
		texture = global.texture,
		modulate = {0.3, 1, 0.3, 1},
	)
	stgfx.draw_texture_rect(
		pos = {256, 256},
		size = {200, 200},
		texture = global.texture,
		modulate = {1, 1, 1, 0.5},
	)

	stgfx.draw_colored_rect(pos = {0, 0}, size = {50, 10}, color = {1, 1, 1, 1})
	stgfx.draw_colored_rect(
		pos = stapp.mouse_position(),
		size = {20, 20},
		color = {1, 0, 0, 1},
	)

	stgfx.render_2d(dev)
}

main :: proc()
{
	ctx := st.init_better_context()
	defer st.free_better_context(&ctx)
	context = ctx.ctx

	stapp.run(
		app_name = "gfx2D",
		app_version = {0, 1, 0},
		asset_dir = "samples/gfx2d",
		init_proc = new_app,
		free_proc = free_app,
		render_proc = render_app,
	)
}
