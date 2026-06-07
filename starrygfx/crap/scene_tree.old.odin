package stgfx3d

import stapp "../starryapp"
import "core:fmt"
import "core:math"
import "core:math/linalg"

Object_Type :: enum {
	// don't use, only exists to find corrupted objects
	NIL,
	SCENE,
	CAMERA,
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
}

new_blank_scene :: proc(allocator := context.allocator) -> (obj: ^Scene_Object)
{
	obj = new(Scene_Object, allocator)
	obj.type = .SCENE
	obj.rotation = 1
	obj.scale = 1

	obj.children = make(map[string]^Object, allocator)
	return
}

free_scene :: proc(obj: ^Scene_Object, allocator := context.allocator)
{
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
		fmt.printf("\n%s = %#v", name, child)
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
		"- %s: type=%d, pos=%v, rot=%v, scale=%v, flags=%w",
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

	case .CAMERA:
		cam := cast(^Camera_Object)obj
		fmt.printf(
			", fov or zoom=%f, near=%f, far=%f, projection=%s",
			cam.fov_or_zoom,
			cam.near,
			cam.far,
			cam.projection,
		)

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
object_transform :: proc(obj: ^Object) -> matrix[4, 4]f32
{
	base :=
		linalg.matrix4_translate(obj.position) *
		linalg.matrix4_from_quaternion(obj.rotation) *
		linalg.matrix4_scale(obj.scale)

	parent := object_transform(obj.parent) if obj.parent != nil else 1
	return parent * base
}

Camera_Projection :: enum {
	PERSPECTIVE,
	ORTHOGRAPHIC,
}

Camera_Object :: struct {
	using _:     Object,
	// FOV in radians
	fov_or_zoom: f32,
	near:        f32,
	far:         f32,
	projection:  Camera_Projection,
}

new_camera :: proc(
	projection := Camera_Projection.PERSPECTIVE,
	allocator := context.allocator,
) -> (
	obj: ^Camera_Object,
)
{
	obj = new(Camera_Object, allocator)
	obj.type = .CAMERA
	obj.rotation = 1
	obj.scale = 1
	obj.projection = projection
	obj.near = 0.001
	obj.far = 1000
	obj.fov_or_zoom = math.to_radians(f32(45)) if projection == .PERSPECTIVE else 10

	return
}

free_camera :: proc(obj: ^Camera_Object, allocator := context.allocator)
{
	free(obj, allocator)
}

camera_projection_matrix :: proc(obj: ^Camera_Object) -> matrix[4, 4]f32
{
	if obj.projection == .PERSPECTIVE {
		return linalg.matrix4_perspective_f32(
			fovy = obj.fov_or_zoom,
			aspect = stapp.aspect_ratio(),
			near = obj.near,
			far = obj.far,
		)
	} else {
		left := -obj.fov_or_zoom / 2
		right := obj.fov_or_zoom / 2

		winsize := stapp.framebuffer_sizef()
		height := obj.fov_or_zoom * (winsize.y / winsize.x)
		bottom := -height / 2
		top := height / 2

		return linalg.matrix_ortho3d_f32(
			left = left,
			right = right,
			bottom = bottom,
			top = top,
			near = obj.near,
			far = obj.far,
		)
	}
}
