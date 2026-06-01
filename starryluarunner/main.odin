package starryluarunner

import stapp "../starryapp"
import gpu "../starryapp/gpu"
import "core:c"
import "core:fmt"
import "core:strings"
import lua "vendor:lua/5.4"

// I LOVE GLOBAL STATE!!!!!!!!!!!!!
L: ^lua.State

main :: proc()
{
	game_ini := load_game_ini()

	L := lua.L_newstate()
	if L == nil {
		fmt.panicf("starryluarunner: couldn't initialize lua state")
	}
	defer lua.close(L)

	// TODO how much of the lua standard library should be replaced by our functions?
	lua.L_openlibs(L)

	main_cstr := strings.clone_to_cstring(game_ini.main, context.temp_allocator)
	if lua.L_dofile(L, main_cstr) != c.int(lua.OK) {
		fmt.printfln("%s", lua.tostring(L, -1))
		lua.pop(L, 1)
		return
	}

	stapp.run(
		app_name = game_ini.name,
		init_proc = init_app,
		free_proc = free_app,
		update_proc = update_app,
		render_proc = render_app,
		app_version = cast([3]i32)game_ini.version,
		graphics_profile = game_ini.graphics_profile,
	)
}

init_app :: proc()
{
	// TODO load bindings here

	lua_call(L, "app_init")
}

free_app :: proc()
{
	// man
}

update_app :: proc(dt: f32)
{
	lua_call(L, "app_update", dt)
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	// TODO
}
