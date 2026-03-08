package starrylib

import "core:log"
import glm "core:math/linalg/glsl"
import "core:mem"

Tag :: u16
Payload :: u32

Prop :: struct {
	tag:     Tag,
	payload: Payload,
}

// color is pretty important so it gets the so very special 0 tag
COLOR_TAG :: 0

@(private)
BRICK_SIZE :: 8
@(private)
BRICK_SIZE_CUBED :: BRICK_SIZE * BRICK_SIZE * BRICK_SIZE
@(private)
BRICK_SIZE_VECI :: [3]i32{BRICK_SIZE, BRICK_SIZE, BRICK_SIZE}

@(private)
Prop_List_Data :: struct {
	payload: Payload,
	set:     bool,
}

@(private)
Prop_List :: struct {
	tag:  Tag,
	data: [BRICK_SIZE][BRICK_SIZE][BRICK_SIZE]Prop_List_Data,
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
	voxel_count:       i32,
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
	model.size_with_padding = model.size

	if glm.any(glm.greaterThanEqual(start, end)) {
		err = .START_MUST_BE_SMALLER_THAN_END
		return
	}

	// padding so simd stuff doesn't have to check for bounds
	if glm.any(glm.notEqual(model.size % BRICK_SIZE_VECI, [3]i32{0, 0, 0})) {
		model.size_with_padding += BRICK_SIZE_VECI
	}

	alloc_error: mem.Allocator_Error
	model.bricks, alloc_error = make(
		[]^Brick,
		model.size_with_padding.x * model.size_with_padding.y * model.size_with_padding.z,
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
		// mate
		if brick == nil {
			continue
		}

		delete(brick.data)
		free(brick, model.allocator)
	}
	delete(model.bricks, model.allocator)
	model^ = {}
}

model_get_brick_pos :: #force_inline proc(model: ^Model, vox_pos: [3]i32) -> [3]i32
{
	return (vox_pos + glm.abs(model.start)) / BRICK_SIZE_VECI
}

model_get_brick_idx :: #force_inline proc(model: ^Model, brick_pos: [3]i32) -> i32
{
	return(
		brick_pos.x * (model.size.y * model.size.z) +
		brick_pos.y * model.size.z +
		brick_pos.z \
	)
}

model_get_brick :: #force_inline proc(model: ^Model, vox_pos: [3]i32) -> ^Brick
{
	return model.bricks[model_get_brick_idx(model, model_get_brick_pos(model, vox_pos))]
}

model_get_brick_ptr :: #force_inline proc(model: ^Model, vox_pos: [3]i32) -> ^^Brick
{
	return &model.bricks[model_get_brick_idx(model, model_get_brick_pos(model, vox_pos))]
}

is_out_of_bounds :: #force_inline proc(model: ^Model, pos: [3]i32) -> bool
{
	return(
		glm.any(glm.lessThan(pos, model.start)) ||
		glm.any(glm.greaterThanEqual(pos, model.end)) \
	)
}

Get_Voxel_Error :: enum {
	OK,
	NO_SUCH_PROP,
	EMPTY_VOXEL,
	OUT_OF_BOUNDS,
}

// returns a prop from a voxel at the specified position. if for whatever reason it's unable to
// get the data (out of bounds, empty voxel, or undefined tag), the default value will be
// returned instead. the returned data may be interpreted any way you'd like (through
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
		return default, false
	}
	brick := model_get_brick(model, pos)
	if brick == nil {
		return default, false
	}
	voxel_idx := glm.abs(pos) % BRICK_SIZE_VECI

	if !brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] {
		return default, false
	}

	// hashing is overkill here i think tbh ong icl fr
	for list in brick.data {
		if list.tag == tag {
			crap := list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z]
			return crap.payload if crap.set else default, true
		}
	}
	return default, true
}

// returns a prop from a voxel at the specified position, reinterpreted as T (must be 32-bits).
// if for whatever reason it's unable to get the data (out of bounds, empty voxel, or
// undefined tag), the default value will be returned instead.
get_voxel_transmute :: proc(
	model: ^Model,
	$T: typeid,
	pos: [3]i32,
	tag: Tag,
	default: T,
) -> (
	payload: T,
	solid: bool,
) where size_of(T) ==
	size_of(Payload)
{
	val: Payload
	val, solid = get_voxel(model, pos, tag, transmute(Payload)default)
	return transmute(T)val, solid
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
	brick := model_get_brick(model, pos)
	if brick == nil {
		alloc_error: mem.Allocator_Error
		brick, alloc_error = new(Brick, model.allocator)
		if alloc_error == .Out_Of_Memory {
			err = .OUT_OF_MEMORY
			return
		}

		brick.data, alloc_error = make([dynamic]Prop_List, model.allocator)
		if alloc_error == .Out_Of_Memory {
			err = .OUT_OF_MEMORY
			return
		}

		model_get_brick_ptr(model, pos)^ = brick
	}

	voxel_idx := glm.abs(pos) % BRICK_SIZE_VECI
	if !brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] {
		brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] = true
		model.voxel_count += 1
	}

	for &list in brick.data {
		if list.tag == tag {
			list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z].payload = transmute(u32)value
			list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z].set = true
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
	list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z].payload = value
	list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z].set = true
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
	brick := model_get_brick(model, pos)
	if brick == nil {
		was_solid = false
		return
	}

	voxel_idx := glm.abs(pos) % BRICK_SIZE_VECI
	if brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] {
		brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] = false
		model.voxel_count -= 1
	}
	return true
}

is_voxel_solid :: proc(model: ^Model, pos: [3]i32) -> bool
{
	if is_out_of_bounds(model, pos) {
		return false
	}
	brick := model_get_brick(model, pos)
	if brick == nil {
		return false
	}

	voxel_idx := glm.abs(pos) % BRICK_SIZE_VECI
	return brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z]
}

is_voxel_empty :: proc(model: ^Model, pos: [3]i32) -> bool
{
	return !is_voxel_solid(model, pos)
}

// returned array must be manually `delete`d
list_voxel_props :: proc(
	model: ^Model,
	pos: [3]i32,
	allocator := context.allocator,
) -> (
	props: []Prop,
	solid: bool,
)
{
	if is_out_of_bounds(model, pos) {
		return
	}
	brick := model_get_brick(model, pos)
	if brick == nil {
		return
	}
	voxel_idx := glm.abs(pos) % BRICK_SIZE_VECI

	if !brick.solid[voxel_idx.x][voxel_idx.y][voxel_idx.z] {
		return
	}
	solid = true

	length := 0
	for list in brick.data {
		if list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z].set {
			length += 1
		}
	}
	props = make([]Prop, length, allocator)

	i := 0
	for list in brick.data {
		crap := list.data[voxel_idx.x][voxel_idx.y][voxel_idx.z]
		if !crap.set {
			continue
		}

		props[i].tag = list.tag
		props[i].payload = crap.payload
		i += 1
	}
	return
}

Model_Iterator :: struct {
	model:        ^Model,
	voxel_index:  int, // 0 .. total_voxels-1
	prop_index:   int, // current prop in current voxel
	total_voxels: int,
}

model_iterator :: proc(model: ^Model) -> Model_Iterator
{
	return Model_Iterator {
		model = model,
		voxel_index = 0,
		prop_index = 0,
		total_voxels = int(model.size.x * model.size.y * model.size.z),
	}
}

model_iterator_next :: proc(
	it: ^Model_Iterator,
) -> (
	pos: [3]i32,
	tag: Tag,
	payload: Payload,
	ok: bool,
)
{
	for it.voxel_index < it.total_voxels {
		pos.x =
			(i32(it.voxel_index) / (it.model.size.y * it.model.size.z)) +
			it.model.start.x
		pos.y =
			((i32(it.voxel_index) / it.model.size.z) % it.model.size.y) +
			it.model.start.y
		pos.z = (i32(it.voxel_index) % it.model.size.z) + it.model.start.z

		brick := model_get_brick(it.model, pos)

		if brick != nil {
			for it.prop_index < len(brick.data) {
				// the transmute is just to flatten the fucking
				p := transmute([BRICK_SIZE_CUBED]Prop_List_Data)brick.data[it.prop_index].data
				it.prop_index += 1

				brick_idx := it.prop_index % BRICK_SIZE_CUBED
				if p[brick_idx].set {
					log.debug(
						"fuh",
						pos,
						brick.data[it.prop_index].tag,
						p[brick_idx].payload,
						true,
					)
					return pos,
						brick.data[it.prop_index].tag,
						p[brick_idx].payload,
						true
				}
			}
		}

		// next voxel
		it.voxel_index += 1
		it.prop_index = 0
	}

	ok = false
	return
}
