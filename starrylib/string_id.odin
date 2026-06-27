package starrylib

import "core:fmt"
import "core:hash"
import "core:io"
import "core:log"
import "core:mem"
import vmem "core:mem/virtual"
import "core:strings"

// TODO make this thread-safe

// It looks like an ID, when it's really a string.
String_Id :: distinct u64

// Initializes the String ID database.
init_string_ids :: proc() -> (err: mem.Allocator_Error)
{
	if strdb.initialized {
		log.warn("string ID database already initialized")
		return
	}

	vmem.arena_init_growing(&strdb.arena) or_return
	context.allocator = vmem.arena_allocator(&strdb.arena)

	strdb.str_to_id = make(map[string]String_Id)
	strdb.id_to_str = make(map[String_Id]string)

	strdb.initialized = true
	return nil
}

// Frees the String ID database, and all strings associated with it.
free_string_ids :: proc()
{
	if !strdb.initialized {
		return
	}

	delete(strdb.str_to_id)
	delete(strdb.id_to_str)
	vmem.arena_destroy(&strdb.arena)
}

// Returns a string ID from a string. Identical strings are guaranteed to have the same ID.
strid :: proc(str: string) -> String_Id
{
	assert(strdb.initialized, "st.init_string_ids() must be called before using String IDs")
	id, ok := strdb.str_to_id[str]
	if ok {
		return id
	}

	context.allocator = vmem.arena_allocator(&strdb.arena)
	our_str := strings.clone(str)
	// comically low chance of coliliding considering there'll be far less
	// than 1000 unique items
	id = String_Id(hash.fnv64a(transmute([]byte)str))

	strdb.str_to_id[our_str] = id
	strdb.id_to_str[id] = our_str
	return id
}

// Returns the string from which a string ID is created.
readable_strid :: proc(id: String_Id) -> string
{
	assert(strdb.initialized, "st.init_string_ids() must be called before using String IDs")
	return strdb.id_to_str[id] or_else "(BAD STRING ID)"
}

@(private = "file")
strdb: struct {
	arena:       vmem.Arena,
	str_to_id:   map[string]String_Id,
	id_to_str:   map[String_Id]string,
	initialized: bool,
}

String_Id_Formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> (ok: bool)
{
	sid := (cast(^String_Id)arg.data)^
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
