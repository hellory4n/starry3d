package starry

import "core:fmt"
import "core:hash"
import "core:io"
import "core:log"
import vmem "core:mem/virtual"
import "core:strings"

// TODO this is used nowhere

StringId :: distinct u64

// Initializes the String ID database.
init_string_ids :: proc()
{
	if global.strdb.initialized {
		log.warn("string ID database already initialized")
		return
	}

	aerr := vmem.arena_init_growing(&global.strdb.arena)
	if aerr != .None {
		fmt.panicf("couldn't allocate string ID arena: %s", aerr)
	}
	context.allocator = vmem.arena_allocator(&global.strdb.arena)

	global.strdb.str_to_id = make(map[string]StringId)
	global.strdb.id_to_str = make(map[StringId]string)

	global.strdb.initialized = true
}

// Frees the String ID database, and all strings associated with it.
free_string_ids :: proc()
{
	if !global.strdb.initialized {
		return
	}

	delete(global.strdb.str_to_id)
	delete(global.strdb.id_to_str)
	vmem.arena_destroy(&global.strdb.arena)
}

// Returns a string ID from a string. Identical strings are guaranteed to have the same ID.
strid :: proc(str: string) -> StringId
{
	assert(global.strdb.initialized)
	id, ok := global.strdb.str_to_id[str]
	if ok {
		return id
	}

	context.allocator = vmem.arena_allocator(&global.strdb.arena)
	our_str := strings.clone(str)
	// comically low chance of coliliding considering there'll be far less
	// than 1000 unique items
	id = StringId(hash.fnv64a(transmute([]byte)str))

	global.strdb.str_to_id[our_str] = id
	global.strdb.id_to_str[id] = our_str
	return id
}

// Returns the string from which a string ID is created.
readable_strid :: proc(id: StringId) -> string
{
	assert(
		global.strdb.initialized,
		"st.init_string_ids() must be called before using String IDs",
	)
	return global.strdb.id_to_str[id] or_else "(BAD STRING ID)"
}

String_Id_Formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> (ok: bool)
{
	sid := (cast(^StringId)arg.data)^
	switch verb {
	case 'v', 's':
		_, err := io.write_string(fi.writer, readable_strid(sid))
		if err != nil do return false
	case 'q':
		_, err := io.write_rune(fi.writer, '"')
		if err != nil do return false
		_, err = io.write_string(fi.writer, readable_strid(sid))
		if err != nil do return false
		_, err = io.write_rune(fi.writer, '"')
		if err != nil do return false
	case 'w':
		_, err := io.write_string(fi.writer, "st.strid(\"")
		if err != nil do return false
		_, err = io.write_string(fi.writer, readable_strid(sid))
		if err != nil do return false
		_, err = io.write_string(fi.writer, "\")")
		if err != nil do return false
	case 'd', 'i':
		_, err := io.write_u64(fi.writer, u64(sid))
		if err != nil do return false
	case:
		return false
	}
	return true
}
