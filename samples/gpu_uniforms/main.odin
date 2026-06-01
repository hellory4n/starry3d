package gpu_uniforms

import stapp "../../starryapp"
import gpu "../../starryapp/gpu"
import "core:math"
import "core:math/linalg"
import "core:mem"

app: struct {
	pipeline:            gpu.Pipeline,
	vertex_buffer:       gpu.Buffer,
	index_buffer:        gpu.Buffer,
	tri_rotation:        f32,
	camera_position:     [3]f32,
	camera_rotation:     quaternion128,
	camera_euler:        [3]f32,
	player_controllable: bool,
}

Vertex :: struct {
	pos:   [2]f32,
	color: [3]f32,
}

@(rodata)
VERTICES := [?]Vertex {
	Vertex{pos = {0.0, 0.5}, color = {1.0, 0.0, 0.0}},
	Vertex{pos = {0.5, -0.5}, color = {0.0, 1.0, 0.0}},
	Vertex{pos = {-0.5, -0.5}, color = {0.0, 0.0, 1.0}},
}

@(rodata)
INDICES := [?]u32{0, 1, 2}

Uniforms :: struct {
	model:  matrix[4, 4]f32 `gpu:"u_model"`,
	view:   matrix[4, 4]f32 `gpu:"u_view"`,
	u_proj: matrix[4, 4]f32, // tag is optional
}

new_app :: proc()
{
	app.camera_position = {0, 0, 5}
	dev := stapp.get_gpu()

	vert := gpu.new_shader(dev, #load("tri.vert"), .VERTEX)
	defer gpu.free_shader(vert)

	frag := gpu.new_shader(dev, #load("tri.frag"), .FRAGMENT)
	defer gpu.free_shader(frag)

	app.pipeline = gpu.new_pipeline(
		dev,
		shaders = gpu.Render_Shaders{vertex = vert, fragment = frag},
		vertex_size = size_of(Vertex),
		vertex_layout = []gpu.Vertex_Attribute {
			gpu.Vertex_Attribute {
				name = "pos",
				type = .VEC2_FLOAT32,
				offset = offset_of(Vertex, pos),
			},
			gpu.Vertex_Attribute {
				name = "color",
				type = .VEC3_FLOAT32,
				offset = offset_of(Vertex, color),
			},
		},
	)

	vert_bytes := mem.slice_to_bytes(VERTICES[:])
	app.vertex_buffer = gpu.new_buffer(dev, .VERTEX, .READ_ONLY, len(vert_bytes), vert_bytes)

	idx_bytes := mem.slice_to_bytes(INDICES[:])
	app.index_buffer = gpu.new_buffer(dev, .INDEX, .READ_ONLY, len(idx_bytes), idx_bytes)
}

free_app :: proc()
{
	gpu.free_buffer(app.index_buffer)
	gpu.free_buffer(app.vertex_buffer)
	gpu.free_pipeline(app.pipeline)
}

render_app :: proc(dt: f32, dev: gpu.Device, swap: gpu.Swapchain)
{
	gpu.begin_render_pass(dev, swap, [4]f32{0, 0, 0, 1})

	gpu.bind_pipeline(dev, app.pipeline)
	gpu.bind_vertex_buffer(dev, app.vertex_buffer)
	gpu.bind_index_buffer(dev, app.index_buffer)

	gpu.set_uniforms(
		dev,
		Uniforms {
			model = linalg.matrix4_rotate(
				math.to_radians(app.tri_rotation),
				[3]f32{0, 1, 0},
			),
			view = camera_view_matrix(),
			u_proj = linalg.matrix4_perspective_f32(
				fovy = math.to_radians_f32(45),
				aspect = stapp.aspect_ratio(),
				near = 0.0001,
				far = 1000,
				flip_z_axis = false,
			),
		},
	)

	gpu.draw_indexed(dev, index_count = 3)
	gpu.end_render_pass(dev)
}

update_app :: proc(dt: f32)
{
	app.tri_rotation += 100 * dt

	if stapp.is_key_just_pressed(.ESCAPE) {
		app.player_controllable = !app.player_controllable
		stapp.lock_mouse(app.player_controllable)
	}

	if app.player_controllable {
		mouse_look(dt)
		move(dt)
	}
}

mouse_look :: #force_inline proc(dt: f32)
{
	MOUSE_SENSITIVITY :: 50
	mouse := stapp.delta_mouse_position()
	app.camera_euler.y -= mouse.x * MOUSE_SENSITIVITY * dt
	app.camera_euler.x -= mouse.y * MOUSE_SENSITIVITY * dt
	// don't break your neck
	app.camera_euler.x = clamp(app.camera_euler.x, -89, 89)

	app.camera_rotation = linalg.quaternion_from_euler_angles(
		math.to_radians(app.camera_euler.x),
		math.to_radians(app.camera_euler.y),
		0,
		.XYZ,
	)
}

move :: #force_inline proc(dt: f32)
{
	PLAYER_SPEED :: 5
	dir := [3]f32{}

	if stapp.is_key_held(.W) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y)) * 1
		dir.z += math.cos(math.to_radians(app.camera_euler.y)) * -1
	}
	if stapp.is_key_held(.S) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y)) * -1
		dir.z += math.cos(math.to_radians(app.camera_euler.y)) * 1
	}
	if stapp.is_key_held(.D) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y - 90)) * 1
		dir.z += math.cos(math.to_radians(app.camera_euler.y - 90)) * -1
	}
	if stapp.is_key_held(.A) {
		dir.x += math.sin(math.to_radians(app.camera_euler.y - 90)) * -1
		dir.z += math.cos(math.to_radians(app.camera_euler.y - 90)) * 1
	}
	if stapp.is_key_held(.SPACE) {
		dir.y -= 1
	}
	if stapp.is_key_held(.LEFT_SHIFT) {
		dir.y += 1
	}

	if linalg.length(dir) > 0.0001 {
		dir = linalg.normalize(dir)
		app.camera_position += dir * PLAYER_SPEED * dt
	}
}

camera_view_matrix :: proc() -> matrix[4, 4]f32
{
	mpos := linalg.matrix4_translate(app.camera_position)
	mrot := linalg.matrix4_from_quaternion(app.camera_rotation)
	return mrot * mpos
}

main :: proc()
{
	stapp.run(
		app_name = "gpu uniforms",
		app_version = {0, 1, 0},
		asset_dir = "samples/gpu_uniforms",
		init_proc = new_app,
		free_proc = free_app,
		render_proc = render_app,
		update_proc = update_app,
	)
}
