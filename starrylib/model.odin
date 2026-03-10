package starrylib

import glm "core:math/linalg/glsl"
import "core:mem"

Tag :: [4]u8
Payload :: u32

Vox_Attr :: struct {
	tag:     Tag,
	payload: Payload,
}

// the standard color tag
RGBA_TAG :: Tag{'r', 'g', 'b', 'a'}

Model :: struct {
	allocator:   mem.Allocator,
	data:        map[Tag][]Payload,
	solid:       []bool,
	start:       [3]i32,
	end:         [3]i32,
	size:        [3]i32,
	voxel_count: i32,
}

Init_Model_Error :: enum {
	OK,
	OUT_OF_MEMORY,
	START_MUST_BE_SMALLER_THAN_END,
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
	model.size = glm.abs(end - start)

	if glm.any(glm.greaterThanEqual(start, end)) {
		err = .START_MUST_BE_SMALLER_THAN_END
		return
	}
	// can't fit more than that into 64-bit morton indexes
	if glm.any(glm.greaterThanEqual(model.size, [3]i32{2097152, 2097152, 2097152})) {
		err = .OUT_OF_MEMORY
		return
	}

	// TODO for the padding stuff just allocate a bigger buffer than necessary,
	// make a smaller slice from that buffer, and then disable bounds checks
	alerr: mem.Allocator_Error

	model.solid, alerr = make([]bool, area(model.size), allocator)
	if alerr == .Out_Of_Memory {
		err = .OUT_OF_MEMORY
		return
	}

	model.data = make(map[Tag][]Payload, allocator)
	return
}

free_model :: proc(model: ^Model)
{
	delete(model.solid, model.allocator)
	for _, payload in model.data {
		delete(payload, model.allocator)
	}
	delete(model.data)
	model^ = {}
}

is_out_of_bounds :: #force_inline proc(model: ^Model, pos: [3]i32) -> bool
{
	return(
		glm.any(glm.lessThan(pos, model.start)) ||
		glm.any(glm.greaterThanEqual(pos, model.end)) \
	)
}

// returns a attribute from a voxel at the specified position. if for whatever reason it's
// unable to get the data (out of bounds, empty voxel, or undefined tag), the default value
// will be returned instead. the returned data may be interpreted any way you'd like (through
// `transmute`) as long as it fits in 32 bits.
get_voxel :: proc(
	model: ^Model,
	pos: [3]i32,
	tag: Tag,
	default: Payload,
) -> (
	payload: Payload,
	solid: bool,
)
{
	if is_out_of_bounds(model, pos) {
		solid = false
		return
	}
	solid = model.solid[flatten_3d_idx(model.size, pos - model.start)]

	attr_list, ok := model.data[tag]
	payload = attr_list[flatten_3d_idx(model.size, pos - model.start)] if ok else default
	return
}

Set_Voxel_Error :: enum {
	OK,
	OUT_OF_MEMORY,
	OUT_OF_BOUNDS,
}

// sets a voxel's attribute to a value (must be 32 bits), may allocate
set_voxel :: proc(model: ^Model, pos: [3]i32, tag: Tag, value: Payload) -> (err: Set_Voxel_Error)
{
	if is_out_of_bounds(model, pos) {
		err = .OUT_OF_BOUNDS
		return
	}

	if !model.solid[flatten_3d_idx(model.size, pos - model.start)] {
		model.solid[flatten_3d_idx(model.size, pos - model.start)] = true
		model.voxel_count += 1
	}

	attr_list, ok := model.data[tag]
	if !ok {
		alerr: mem.Allocator_Error
		model.data[tag], alerr = make([]Payload, area(model.size), model.allocator)
		if alerr == .Out_Of_Memory {
			err = .OUT_OF_MEMORY
			return
		}

		attr_list = model.data[tag]
	}

	attr_list[flatten_3d_idx(model.size, pos - model.start)] = value
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

	was_solid = model.solid[flatten_3d_idx(model.size, pos - model.start)]
	if !was_solid {
		model.solid[flatten_3d_idx(model.size, pos - model.start)] = false
		model.voxel_count -= 1
	}
	return
}

is_voxel_solid :: proc(model: ^Model, pos: [3]i32) -> bool
{
	if is_out_of_bounds(model, pos) {
		return false
	}
	return model.solid[flatten_3d_idx(model.size, pos - model.start)]
}

is_voxel_empty :: proc(model: ^Model, pos: [3]i32) -> bool
{
	return !is_voxel_solid(model, pos)
}
