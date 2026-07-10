package starry

import "core:encoding/json"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"

Config :: struct {
	name: string,
	main: string,
}

load_app_config :: proc()
{
	init_alloc := vmem.arena_allocator(&global.init_arena)

	config_bytes, ferr := read_from_exe_dir("app.json", init_alloc)
	if ferr != nil {
		fmt.panicf("couldn't read app.json: %s", os.error_string(ferr))
	}

	jerr := json.unmarshal(config_bytes, &global.config, .JSON5, init_alloc)
	if jerr != nil {
		fmt.panicf("error parsing app.json: %s", jerr)
	}
}

init_app :: proc()
{
	main_script, ferr := read_from_exe_dir_as_cstring(
		global.config.main,
		context.temp_allocator,
	)
	if ferr != nil {
		fmt.panicf("couldn't read %q: %s", global.config.main, os.error_string(ferr))
	}

	L := global.lua
	lua_run(L, cstring(raw_data(main_script)))
	call_lua_function(L, "app_init")
}
