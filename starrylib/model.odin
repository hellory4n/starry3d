package starrylib

import glm "core:math/linalg/glsl"
import "core:mem"

Tag :: u16
Payload :: u32

// color is pretty important so it gets the so very special 0 tag
COLOR_TAG :: 0

@(private)
BRICK_SIZE :: 8
@(private)
BRICK_SIZE_VECI :: [3]i32{BRICK_SIZE, BRICK_SIZE, BRICK_SIZE}

@(private)
Prop_List :: struct {
	tag:  Tag,
	data: [BRICK_SIZE][BRICK_SIZE][BRICK_SIZE]Payload,
}

@(private)
Brick :: struct {
	solid: [BRICK_SIZE][BRICK_SIZE][BRICK_SIZE]bool,
	data:  [dynamic]Prop_List,
}

Init_Model_Error :: enum {
	OK,
	OUT_OF_MEMORY,
	START_MUST_BE_SMALLER_THAN_END,
}

Model :: struct {
	allocator:         mem.Allocator,
	// may be null so that it can be lazily allocated
	bricks:            []^Brick,
	start:             [3]i32,
	end:               [3]i32,
	size:              [3]i32,
	size_with_padding: [3]i32,
}

new_empty_model :: proc(
	start: [3]i32,
	end: [3]i32,
	allocator := context.allocator,
) -> (
	model: Model,
	err: Init_Model_Error,
)
{
	model.allocator = allocator
	model.start = start
	model.end = end
	model.size = glm.abs(start) + glm.abs(end)

	if glm.any(glm.greaterThanEqual(start, end)) {
		err = .START_MUST_BE_SMALLER_THAN_END
		return
	}

	// padding so simd stuff doesn't have to check for bounds
	if glm.any(glm.notEqual(model.size % BRICK_SIZE_VECI, [3]i32{0, 0, 0})) {
		model.size_with_padding = model.size + BRICK_SIZE_VECI
	}

	alloc_error: mem.Allocator_Error
	model.bricks, alloc_error = make(
		[]^Brick,
		model.size.x * model.size.y * model.size.z,
		allocator,
	)
	if alloc_error == .Out_Of_Memory {
		err = .OUT_OF_MEMORY
		return
	}

	return
}

free_model :: proc(model: ^Model)
{
	for brick in model.bricks {
		free(brick, model.allocator)
	}
	delete(model.bricks, model.allocator)
	model^ = {}
}

@(private)
_get_brick_pos :: #force_inline proc(model: ^Model, pos: [3]i32) -> [3]i32
{
	return (pos + glm.abs(model.start)) / BRICK_SIZE_VECI
}

@(private)
_get_brick_idx :: #force_inline proc(model: ^Model, pos: [3]i32) -> i32
{
	return pos.x * (model.size.y * model.size.z) + pos.y * model.size.z + pos.z
}

@(private)
_get_brick :: #force_inline proc(model: ^Model, pos: [3]i32) -> ^Brick
{
	return model.bricks[_get_brick_idx(model, _get_brick_pos(model, pos))]
}

@(private)
_get_brick_ptr :: #force_inline proc(model: ^Model, pos: [3]i32) -> ^^Brick
{
	return &model.bricks[_get_brick_idx(model, _get_brick_pos(model, pos))]
}

is_out_of_bounds :: #force_inline proc(model: ^Model, pos: [3]i32) -> bool
{
	return(
		glm.any(glm.lessThanEqual(pos, model.start)) ||
		glm.any(glm.greaterThanEqual(pos, model.end)) \
	)
}

Get_Voxel_Error :: enum {
	OK,
	NO_SUCH_PROP,
	EMPTY_VOXEL,
	OUT_OF_BOUNDS,
}

// returns a prop from a voxel at the specified position. the returned data may be interpreted any
// way you'd like (through `transmute`) as long as it fits in 32 bits.
get_voxel_raw :: proc(
	model: ^Model,
	pos: [3]i32,
	tag: Tag,
) -> (
	payload: Payload,
	err: Get_Voxel_Error,
)
{
	if is_out_of_bounds(model, pos) {
		err = .OUT_OF_BOUNDS
		return
	}
	brick := _get_brick(model, pos)
	if brick == nil {
		err = .EMPTY_VOXEL
		return
	}
	voxel_idx := pos % BRICK_SIZE_VECI

	if (!brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z]) {
		err = .EMPTY_VOXEL
		return
	}

	// hashing is overkill here i think tbh ong icl fr
	for list in brick.data {
		if list.tag == tag {
			payload = list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z]
			return
		}
	}

	err = .NO_SUCH_PROP
	return
}

// returns a prop from a voxel at the specified position, or, a default value if it's not
// available. the returned data may be interpreted any way you'd like (through `transmute`)
// as long as it fits in 32 bits.
get_voxel_raw_orelse :: proc(model: ^Model, pos: [3]i32, tag: Tag, default: Payload) -> Payload
{
	val, err := get_voxel_raw(model, pos, tag)
	return val if err == .OK else default
}

// returns a prop from a voxel at the specified position, reinterpreted as T (must be 32-bits).
get_voxel_transmute :: proc(
	model: ^Model,
	pos: [3]i32,
	tag: Tag,
	$T: typeid,
) -> (
	payload: T,
	err: Get_Voxel_Error,
) where size_of(T) ==
	size_of(Payload)
{
	raw: u32
	raw, err = get_voxel_raw(model, pos, tag)
	payload = transmute(T)raw
	return
}

get_voxel_transmute_orelse :: proc(
	model: ^Model,
	pos: [3]i32,
	tag: Tag,
	$T: typeid,
	default: T,
) -> T where size_of(T) ==
	size_of(Payload)
{
	val, err := get_voxel_transmute(model, pos, tag, T)
	return val if err == .OK else default
}

get_voxel :: proc {
	get_voxel_raw,
	get_voxel_raw_orelse,
	get_voxel_transmute,
	get_voxel_transmute_orelse,
}

Set_Voxel_Error :: enum {
	OK,
	OUT_OF_MEMORY,
	OUT_OF_BOUNDS,
}

// sets a voxel's prop to a value (must be 32 bits), may allocate
set_voxel :: proc(
	model: ^Model,
	pos: [3]i32,
	tag: Tag,
	value: $T,
) -> (
	err: Set_Voxel_Error,
) where size_of(T) ==
	size_of(Payload)
{
	if is_out_of_bounds(model, pos) {
		err = .OUT_OF_BOUNDS
		return
	}
	brick := _get_brick(model, pos)
	if brick == nil {
		alloc_error: mem.Allocator_Error
		brick, alloc_error = new(Brick, model.allocator)
		if alloc_error == .Out_Of_Memory {
			err = .OUT_OF_MEMORY
			return
		}
		_get_brick_ptr(model, pos)^ = brick
	}

	voxel_idx := pos % BRICK_SIZE_VECI
	brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] = true

	for &list in brick.data {
		if list.tag == tag {
			list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z] = transmute(u32)value
		}
	}

	// no list, add one
	// this also means that bricks only store the props they use(d), which is nice
	_, alloc_err := append(&brick.data, Prop_List{tag = tag})
	if alloc_err == .Out_Of_Memory {
		err = .OUT_OF_MEMORY
		return
	}

	list := &brick.data[len(brick.data) - 1]
	list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z] = value
	return
}

// brutally murders the voxel in cold blood. poor voxel. returns true if the voxel was actually
// deleted instead of just being empty/out of bounds.
remove_voxel :: proc(model: ^Model, pos: [3]i32) -> (was_solid: bool)
{
	if is_out_of_bounds(model, pos) {
		was_solid = false
		return
	}
	brick := _get_brick(model, pos)
	if brick == nil {
		was_solid = false
		return
	}

	voxel_idx := pos % BRICK_SIZE_VECI
	brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] = false
	return true
}

is_voxel_solid :: proc(model: ^Model, pos: [3]i32) -> bool
{
	_, err := get_voxel(model, pos, 0)
	switch err {
	case .OK:
	case .NO_SUCH_PROP:
		return true
	case .EMPTY_VOXEL:
	case .OUT_OF_BOUNDS:
		return false
	}
	unreachable()
}
