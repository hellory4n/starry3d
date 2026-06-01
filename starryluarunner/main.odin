package starryluarunner

import stapp "../starryapp"
import gpu "../starryapp/gpu"
import "core:fmt"
import lua "vendor:lua/5.4"

global: struct {
	L:    ^lua.State,
	conf: Game_Conf,
}

main :: proc()
{
	// TODO there should be a logger setup at this point?
	// (usually the engine inits it, but the engine isn't initialized yet)

	L := lua.L_newstate()
	if L == nil {
		fmt.panicf("starryluarunner: couldn't initialize lua state")
	}
	defer lua.close(L)
	global.L = L

	// TODO how much of the lua standard library should be replaced by our functions?
	lua.L_openlibs(L)

	global.conf = load_game_conf(L)

	stapp.run(
		app_name = global.conf.name,
		init_proc = init_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
		app_version = cast([3]i32)global.conf.version,
		graphics_profile = global.conf.graphics_profile,
	)
}

init_app :: proc()
{
	L := global.L
	// TODO load bindings here

	lua_run_file_from_path(L, global.conf.main)
	lua_call(L, "app_init")
}

free_app :: proc()
{
	// man
}

update_app :: proc(dt: f32)
{
	L := global.L
	lua_call(L, "app_update", dt)
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	// TODO
}
