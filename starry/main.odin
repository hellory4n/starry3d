package starryexe

import "core:dynlib"
import "core:fmt"
import vmem "core:mem/virtual"
import "core:os"

DLL_EXTENSION :: ".dll" when ODIN_OS == .Windows else ".so"

App :: struct {
	init:     proc "c" (api: Api) -> rawptr,
	free:     proc "c" (api: Api, mem: rawptr),
	memory:   rawptr,
	dll_path: string,
	dll:      dynlib.Library,
}

load_app_dll :: proc() -> (app: App)
{
	// find DLL
	// TODO this would be better loaded from a game config (app.json5)
	files, ferr := os.read_directory_by_path(
		global.exe_dir,
		n = 0,
		allocator = context.temp_allocator,
	)
	if ferr != nil {
		fmt.eprintfln(
			"starry: couldn't list files from exe dir %q: %s",
			global.exe_dir,
			os.error_string(ferr),
		)
	}

	found_dll: bool
	for fi in files {
		if os.ext(fi.fullpath) != DLL_EXTENSION {
			continue
		}

		ok := try_load_dll(fi.fullpath, &app)
		if ok {
			found_dll = true
			break
		}
	}

	if !found_dll {
		panic("starry: no game dll to load or all dlls failed, aborting")
	}

	return
}

try_load_dll :: proc(src_path: string, app: ^App) -> (ok: bool)
{
	// OS locks the dll, which is bad if you want to reload it
	// TODO don't do this on release? it'll become slow as shit as the game grows
	app.dll_path = fmt.tprintf("%s/.tmpapp%s", global.exe_dir, DLL_EXTENSION)
	_, ferr := os.create(app.dll_path)
	if ferr != nil {
		fmt.eprintfln(
			"starry: couldn't create %q: %s",
			app.dll_path,
			os.error_string(ferr),
		)
		return false
	}

	ferr = os.copy_file(app.dll_path, src_path)
	if ferr != nil {
		fmt.eprintfln(
			"starry: couldn't copy %q to %q: %s",
			src_path,
			app.dll_path,
			os.error_string(ferr),
		)
		return false
	}

	app.dll, ok = dynlib.load_library(app.dll_path)
	if !ok {
		fmt.eprintln(dynlib.last_error())
		return false
	}

	app.init = cast(proc "c" (api: Api) -> rawptr)(dynlib.symbol_address(
			app.dll,
			"st_init",
		) or_else nil)
	app.free = cast(proc "c" (api: Api, mem: rawptr))(dynlib.symbol_address(
			app.dll,
			"st_free",
		) or_else nil)

	// st_init is the bare minimum
	if app.init == nil {
		fmt.eprintfln("starry: %q missing `st_init`, not a valid app dll", src_path)
	}

	return true
}

unload_app_dll :: proc(app: ^App) -> (ok: bool)
{
	if app.dll != nil {
		dynlib.unload_library(app.dll) or_return
	}
	return true
}

main :: proc()
{
	defer free_all(context.temp_allocator)

	aerr := vmem.arena_init_growing(&global.init_arena)
	assert(aerr == .None)
	defer vmem.arena_destroy(&global.init_arena)

	ferr: os.Error
	global.exe_dir, ferr = os.get_executable_directory(
		vmem.arena_allocator(&global.init_arena),
	)
	if ferr != nil {
		panic(fmt.tprintf("starry: couldn't get exe dir: %s", os.error_string(ferr)))
	}

	global.app = load_app_dll()
	if ferr != nil {
		panic(
			fmt.tprintf(
				"starry: couldn't load app %q: %s",
				global.app.dll_path,
				os.error_string(ferr),
			),
		)
	}
	defer unload_app_dll(&global.app)

	// TODO do something useful
	global.app.memory = global.app.init(DEFAULT_API)
	defer global.app.free(DEFAULT_API, global.app.memory)
}
