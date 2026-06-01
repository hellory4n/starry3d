package starryluarunner

import stapp "../starryapp"
import "core:encoding/ini"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Game_Ini :: struct {
	name:             string,
	main:             string,
	version:          [3]int,
	graphics_profile: stapp.Graphics_Profile,
}

// crashes on error (fuck you)
game_ini_path :: proc() -> (path: string)
{
	// from current working directory
	path = "game.ini"
	if os.exists(path) {
		return path
	}

	// relative to the exe
	exe_dir, err := os.get_executable_path(context.temp_allocator)
	if err != nil {
		fmt.printfln("couldn't get exe path: %s", os.error_string(err))
	}
	path = strings.join({exe_dir, "game.ini"}, sep = "/", allocator = context.temp_allocator)
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
		"couldn't find game.ini, can't start app\ntip: you can specify one yourself: %s /path/to/game.ini",
		os.args[0],
	)
}

// crashes on error (fuck you)
load_game_ini :: proc() -> Game_Ini
{
	src, ferr := os.read_entire_file(game_ini_path(), context.temp_allocator)
	if ferr != nil {
		fmt.panicf("couldn't load game.ini: %s", os.error_string(ferr))
	}

	ini_src, err := ini.load_map_from_string(string(src), context.temp_allocator)
	if err != nil || ini_src == nil {
		fmt.panicf("couldn't parse game.ini")
	}

	return parse_game_ini(ini_src)
}

// crashes on error (fuck you)
parse_game_ini :: proc(src: ini.Map) -> (conf: Game_Ini)
{
	ok: bool
	conf.name, ok = src["project"]["name"]
	ensure(ok, "game.ini: project name is missing")

	conf.main, ok = src["project"]["main"]
	ensure(ok, "game.ini: main script is missing")

	version_str := src["project"]["version"]
	if version_str != "" {
		version_elems := strings.split(
			version_str,
			sep = ".",
			allocator = context.temp_allocator,
		)
		ensure(
			len(version_elems) == 3,
			"game.ini: version should have 3 numbers (major, minor, patch)",
		)

		conf.version[0], ok = strconv.parse_int(version_elems[0])
		ensure(ok, "game.ini: couldn't parse version number")
		conf.version[1], ok = strconv.parse_int(version_elems[1])
		ensure(ok, "game.ini: couldn't parse version number")
		conf.version[2], ok = strconv.parse_int(version_elems[2])
		ensure(ok, "game.ini: couldn't parse version number")
	}

	graphics_profile_str := src["target"]["graphics_profile"]
	if graphics_profile_str != "" {
		switch graphics_profile_str {
		case "compatibility":
			conf.graphics_profile = .COMPATIBILITY
		case "modern":
			conf.graphics_profile = .MODERN
		case:
			ensure(false, "game.ini: invalid graphics profile")
		}
	}

	return conf
}
