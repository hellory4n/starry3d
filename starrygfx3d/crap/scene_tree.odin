package stgfx3d

import stapp "../starryapp"
import hm "core:container/handle_map"
import "core:fmt"
import "core:math"
import "core:math/linalg"

// Opaque handle to an object. Get its data with `object_data()`
Object :: distinct hm.Handle32

Object_Flag :: enum u8 {
	HIDDEN,
}
Object_Flags :: bit_set[Object_Flag]

// Base for all objects.
Base_Object :: struct {
	// DON'T MODIFY!!!! USE rename_object !!!!
	name:     string,
	handle:   Object,
	parent:   Object,
	position: [3]f32,
	scale:    [3]f32,
	rotation: quaternion128,
	flags:    Object_Flags,
}

Group_Object :: struct {
	using _:  Base_Object,
	// key is both the name and how you access objects
	children: map[string]Object,
}

Level_Object :: struct {
	using _: Group_Object,
	camera:  Object,
}

Camera_Projection :: enum {
	PERSPECTIVE,
	ORTHOGRAPHIC,
}

Camera_Object :: struct {
	using _:     Base_Object,
	// FOV in radians
	fov_or_zoom: f32,
	near:        f32,
	far:         f32,
	projection:  Camera_Projection,
}

Any_Object :: struct {
	handle: Object,
	// there's no inheritance so we can be greedy
	v:      union {
		Base_Object,
		Group_Object,
		Level_Object,
		Camera_Object,
	},
}

object_data :: proc(obj: Object) -> ^Any_Object
{
	return hm.get(&global.objects, obj)
}

object_is_nil :: proc(obj: Object) -> bool
{
	return !hm.is_valid(&global.objects, obj)
}

object_is_valid :: proc(obj: Object) -> bool
{
	return hm.is_valid(&global.objects, obj)
}

new_blank_level :: proc(name: string) -> Object
{
	data := Any_Object {
		v = Level_Object {
			name = name,
			children = make(map[string]Object),
			rotation = 1,
			scale = 1,
		},
	}
	obj, err := hm.add(&global.objects, data)
	return 
}

new_group_object :: proc(name: string) -> Object

new_camera_object :: proc(name: string) -> Object

add_child :: proc(parent: Object, child: Object)

// Returns true if the object existed before being deleted
remove_child :: proc(parent: Object, child: Object) -> (existed: bool)

rename_child :: proc(obj: Object, new_name: string)

// Gets an immediate child of an object
get_child :: proc(parent: Object, name: string) -> (obj: Object, ok: bool)

// TODO all the other fucking functions piece of shit
// - init and free renderer
//
// - new group
// - new level
// - new camera
//
// - add child to scene
// - remove child
// - get child
// - get child with path
//
// - object transform
// - camera view matrix
//
// - dump scene
