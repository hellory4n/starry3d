package starryluarunner

import "core:c"
import "core:fmt"
import "core:log"
import "core:strings"
import lua "vendor:lua/5.4"

lua_run_file_from_c_path :: proc(L: ^lua.State, path: cstring) -> (ok: bool)
{
	if lua.L_dofile(L, path) != c.int(lua.OK) {
		fmt.printfln("in %s", lua.tostring(L, -1))
		return false
	}
	return true
}

lua_run_file_from_odin_path :: proc(L: ^lua.State, path: string) -> (ok: bool)
{
	return lua_run_file_from_c_path(L, strings.clone_to_cstring(path, context.temp_allocator))
}

lua_run_file_from_path :: proc {
	lua_run_file_from_c_path,
	lua_run_file_from_odin_path,
}

lua_call :: proc(L: ^lua.State, name: cstring, args: ..any) -> (ok: bool)
{
	lua.getglobal(L, name)
	if !lua.isfunction(L, -1) {
		log.errorf("Lua function '%s' not found", name)
		lua.pop(L, 1)
		return false
	}

	for arg in args {
		lua_push_value(L, arg)
	}
	nargs := i32(len(args))

	if lua.pcall(L, nargs, 0, 0) != c.int(lua.OK) {
		log.error("in %s(): %s", name, lua.tostring(L, -1))
		lua.pop(L, 1)
		return false
	}

	return true
}

lua_push_value :: proc(L: ^lua.State, v: any)
{
	// despair
	switch val in v {
	case bool:
		lua.pushboolean(L, b32(val))
	case b8:
		lua.pushboolean(L, b32(val))
	case b16:
		lua.pushboolean(L, b32(val))
	case b32:
		lua.pushboolean(L, val)
	case int:
		lua.pushinteger(L, lua.Integer(val))
	case uint:
		lua.pushinteger(L, lua.Integer(val))
	case i8:
		lua.pushinteger(L, lua.Integer(val))
	case i16:
		lua.pushinteger(L, lua.Integer(val))
	case i32:
		lua.pushinteger(L, lua.Integer(val))
	case i64:
		lua.pushinteger(L, lua.Integer(val))
	case u8:
		lua.pushinteger(L, lua.Integer(val))
	case u16:
		lua.pushinteger(L, lua.Integer(val))
	case u32:
		lua.pushinteger(L, lua.Integer(val))
	case u64:
		lua.pushinteger(L, lua.Integer(val))
	case f32:
		lua.pushnumber(L, lua.Number(val))
	case f64:
		lua.pushnumber(L, lua.Number(val))
	case string:
		lua.pushlstring(L, cstring(raw_data(transmute([]byte)val)), c.size_t(len(val)))
	case:
		log.warnf("unsupported by lua_push_value: %v", val)
		lua.pushnil(L)
	}
}
