package stgfx3d

import "core:fmt"
import "core:log"
import "core:math/linalg"
import vmem "core:mem/virtual"

Object_Type :: enum {
	// don't use, only exists to find corrupted objects
	NIL,
	SCENE,
}

Object_Flag :: enum u8 {
	HIDDEN,
}
Object_Flags :: bit_set[Object_Flag]

// Base for all objects.
Object :: struct {
	parent:   ^Object,
	position: [3]f32,
	scale:    [3]f32,
	rotation: quaternion128,
	type:     Object_Type,
	flags:    Object_Flags,
}

// Used for grouping objects and stacking transforms (position, rotation, scale)
Group_Object :: struct {
	using _: Object,
}

Scene_Object :: struct {
	using _:  Group_Object,
	// key is both the name and how you access objects
	children: map[string]^Object,
	arena:    vmem.Arena,
}

new_blank_scene :: proc(allocator := context.allocator) -> (obj: ^Scene_Object)
{
	obj = new(Scene_Object, allocator)
	obj.type = .SCENE

	err := vmem.arena_init_growing(&obj.arena)
	if err != nil {
		log.errorf("couldn't create blank scene: %s", err)
	}

	obj.children = make(map[string]^Object, vmem.arena_allocator(&obj.arena))
	return
}

free_scene :: proc(obj: ^Scene_Object, allocator := context.allocator)
{
	alloc := vmem.arena_allocator(&obj.arena)
	free_all(alloc)
	free(obj, allocator)
}

// Prints the whole scene tree into the console for debugging purposes.
dump_scene :: proc(obj: ^Scene_Object, scene_name: string = "scene")
{
	print_obj(obj, scene_name, 0)
	dump_scene_recursive(obj, scene_name, level = 1)
}

@(private)
dump_scene_recursive :: proc(obj: ^Scene_Object, scene_name: string, level: int)
{
	for name, child in obj.children {
		print_obj(obj, name, level)
		if child.type == .SCENE {
			dump_scene_recursive(cast(^Scene_Object)child, name, level + 1)
		}
	}
}

@(private)
print_obj :: proc(obj: ^Object, name: string, level: int)
{
	// fuckass padding wont pad
	for _ in 0 ..< level {
		fmt.print("    ")
	}

	fmt.printf(
		"- %s: type=%s, pos=%v, rot=%v, scale=%v, flags=%w",
		name,
		obj.type,
		obj.position,
		obj.rotation,
		obj.scale,
		obj.flags,
	)

	switch obj.type {
	case .NIL:
		fmt.printf(" (CORRUPTED)")

	case .SCENE: // not gonna make the switch partial for this
	}

	fmt.print("\n")
}

add_child_to_scene :: proc(parent: ^Scene_Object, name: string, child: ^Object)
{
	// TODO this WILL cause some goofy bug because it got out of sync or some shit
	child.parent = parent
	parent.children[name] = child
}

// Returns true if the object existed
remove_child :: proc(parent: ^Scene_Object, name: string) -> (ok: bool)
{
	ok = name in parent.children
	delete_key(&parent.children, name)
	return ok
}

// Returned object may be nil
get_child_object :: proc(parent: ^Scene_Object, child_name: string) -> ^Object
{
	return parent.children[child_name]
}

// Returned object may be nil
get_child_and_cast :: proc($T: typeid, parent: ^Scene_Object, child_name: string) -> ^T
{
	return cast(^T)parent.children[child_name]
}

get_child :: proc {
	get_child_object,
	get_child_and_cast,
}

// Returns the model matrix for the object
object_transform :: proc(obj: Object) -> matrix[4, 4]f32
{
	// i hope this is the right order lmao
	return(
		linalg.matrix4_scale(obj.scale) *
		linalg.matrix4_from_quaternion(obj.rotation) *
		linalg.matrix4_translate(obj.position) \
	)
}
