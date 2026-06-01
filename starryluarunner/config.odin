package starryluarunner

import stapp "../starryapp"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import lua "vendor:lua/5.4"

Game_Conf :: struct {
	name:             string,
	main:             string,
	version:          [3]int,
	graphics_profile: stapp.Graphics_Profile,
}

// crashes on error (fuck you)
game_conf_path :: proc() -> (path: string)
{
	// from current working directory
	path = "config.lua"
	if os.exists(path) {
		return path
	}

	// relative to the exe
	exe_dir, err := os.get_executable_path(context.temp_allocator)
	if err != nil {
		fmt.printfln("couldn't get exe path: %s", os.error_string(err))
	}
	path = strings.join({exe_dir, "config.lua"}, sep = "/", allocator = context.temp_allocator)
	if os.exists(path) {
		return path
	}

	// from args
	if len(os.args) > 1 {
		path = os.args[1]
		if os.exists(path) {
			return path
		}
	}

	// tough shit
	fmt.panicf(
		"couldn't find config.lua, can't start app\ntip: you can specify one yourself: %s /path/to/config.lua",
		os.args[0],
	)
}

// crashes on error (fuck you)
load_game_conf :: proc(L: ^lua.State) -> (conf: Game_Conf)
{
	path := game_conf_path()
	ensure(lua_run_file_from_path(L, path), "couldn't load config.lua, game can't start")

	if !lua.istable(L, -1) {
		fmt.panicf("config.lua should return a table")
	}

	lua.pushnil(L) // i guess
	KEY_IDX :: -2
	VALUE_IDX :: -1
	for lua.next(L, KEY_IDX) != 0 {
		key := string(lua.tostring(L, KEY_IDX))

		switch key {
		case "name":
			conf.name = string(lua.tostring(L, VALUE_IDX))
		case "main":
			conf.main = string(lua.tostring(L, VALUE_IDX))

		case "version":
			version_str := string(lua.tostring(L, VALUE_IDX))
			version_elems := strings.split(
				version_str,
				sep = ".",
				allocator = context.temp_allocator,
			)
			ensure(
				len(version_elems) == 3,
				"config.lua: version should have 3 numbers (major, minor, patch)",
			)

			ok: bool
			conf.version[0], ok = strconv.parse_int(version_elems[0])
			ensure(ok, "config.lua: couldn't parse version number")
			conf.version[1], ok = strconv.parse_int(version_elems[1])
			ensure(ok, "config.lua: couldn't parse version number")
			conf.version[2], ok = strconv.parse_int(version_elems[2])
			ensure(ok, "config.lua: couldn't parse version number")

		case "graphics_profile":
			profile_str := string(lua.tostring(L, VALUE_IDX))

			switch profile_str {
			case "compatibility":
				conf.graphics_profile = .COMPATIBILITY
			case "modern":
				conf.graphics_profile = .MODERN
			case:
				fmt.printfln(
					"warning: unexpected graphics profile %q (perhaps a typo?)",
					profile_str,
				)
			}

		case:
			fmt.printfln("warning: unexpected key %q (perhaps a typo?)", key)
		}

		lua.pop(L, 1) // remove value, keep key for next iteration
	}

	return conf
}
