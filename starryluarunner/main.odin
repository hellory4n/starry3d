package starryluarunner

import stapp "../starryapp"
import gpu "../starryapp/gpu"
import st "../starrylib"
import "core:fmt"
import "core:os"
import lua "vendor:lua/5.4"

global: struct {
	L:    ^lua.State,
	conf: Game_Conf,
}

main :: proc()
{
	// we have command parsing at home
	if len(os.args) > 1 {
		cmd := os.args[1]
		switch cmd {
		case "--version", "-v":
			fmt.printfln("starryluarunner %s", st.VERSION_STR)
			return

		case "--help", "-h":
			fmt.println("starryluarunner")
			fmt.printfln("usage: %s [config.lua]", os.args[0])
			fmt.println()
			fmt.println("Options:")
			fmt.println(
				"    --dump-symbols: prints all the engine symbols as a JSON to stdout",
			)
			fmt.println("    --version, -v: prints version and exits")
			fmt.println("    --help, -h: prints this and exits")
			return

		// TODO strip on release mode?
		case "--dump-symbols":
			dump_symbols()
			return
		}
	}

	// TODO there should be a logger setup at this point
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
	lua_run_string(L, #load("builtin.lua", cstring))

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
