#include "app.h"

#include <trippin/common.h>
#include <trippin/log.h>
#include <trippin/math.h>
#include <trippin/memory.h>

#include <starry/app.h>
#include <starry/gpu.h>
#include <starry/shader/terrain.glsl.h>
#include <starry/world.h>

#include "debug_mode.h"
#include "starry/render.h"
#include "world.h"

struct Vertex
{
	st::PackedModelVertex packed;
};

sbox::Sandbox::Sandbox()
{
	st::Camera& cam = st::Camera::current();
	cam.position = {0, 0, 1};
	cam.fov = 90;
	cam.projection = st::CameraProjection::PERSPECTIVE;
	st::set_mouse_enabled(_ui_enabled);

	auto vert_shader = st::VertexShader(ST_TERRAIN_SHADER_VERTEX);
	auto frag_shader = st::FragmentShader(ST_TERRAIN_SHADER_FRAGMENT);
	TR_DEFER(vert_shader.free());
	TR_DEFER(frag_shader.free());

	program = st::ShaderProgram();
	program.attach(vert_shader);
	program.attach(frag_shader);
	program.link();
	program.use();
	program.set_uniform(ST_TERRAIN_SHADER_U_MODEL, tr::Matrix4x4::identity());
	program.set_uniform(ST_TERRAIN_SHADER_U_VIEW, tr::Matrix4x4::identity());
	program.set_uniform(ST_TERRAIN_SHADER_U_PROJECTION, tr::Matrix4x4::identity());

	tr::Array<st::VertexAttribute> attrs = {
		{"packed", st::VertexAttributeType::VEC2_UINT32, offsetof(Vertex, packed)},
	};

	tr::Array<Vertex> vertices = {
		{st::PackedModelVertex{st::ModelVertex{
			.position = {0, 0, 0},
			.corner = st::ModelVertex::QuadCorner::BOTTOM_LEFT,
			.using_texture = true,
			.texture_id = Texture::GRASS_SIDE,
		}}},
		{st::PackedModelVertex{st::ModelVertex{
			.position = {2, 0, 0},
			.corner = st::ModelVertex::QuadCorner::BOTTOM_RIGHT,
			.using_texture = true,
			.texture_id = Texture::GRASS_SIDE,
		}}},
		{st::PackedModelVertex{st::ModelVertex{
			.position = {0, 2, 0},
			.corner = st::ModelVertex::QuadCorner::TOP_LEFT,
			.using_texture = true,
			.texture_id = Texture::GRASS_SIDE,
		}}},
		{st::PackedModelVertex{st::ModelVertex{
			.position = {2, 2, 0},
			.corner = st::ModelVertex::QuadCorner::TOP_RIGHT,
			.using_texture = true,
			.texture_id = Texture::GRASS_SIDE,
		}}},
	};

	tr::Array<st::Triangle> triangles = {
		{2, 1, 0},
		{2, 3, 1},
	};

	mesh = st::Mesh(attrs, vertices, triangles, true);

	st::TextureAtlas atlasma = sbox::setup_world();
	program.set_uniform(ST_TERRAIN_SHADER_U_ATLAS_SIZE, atlasma.size());
	program.set_uniform(ST_TERRAIN_SHADER_U_CHUNK, tr::Vec3<uint32>{});

	ssbo = st::StorageBuffer(ST_TERRAIN_SHADER_SSBO_ATLAS);
	tr::Array<tr::Rect<uint32>> ssbo_data{arena, st::MAX_ATLAS_TEXTURES};
	for (auto [id, rect] : atlasma._textures) {
		ssbo_data[id] = rect;
	}
	ssbo.update(*ssbo_data, ssbo_data.len() * sizeof(tr::Rect<uint32>));

	tr::log("initialized sandbox :)");
}

void sbox::Sandbox::update(float64 dt)
{
	// hlep
	if (st::is_key_just_pressed(st::Key::ESCAPE)) {
		_ui_enabled = !_ui_enabled;
		st::set_mouse_enabled(_ui_enabled);
	}
	if (st::is_key_just_pressed(st::Key::F1)) {
		st::set_wireframe_mode(true);
	}

	player_controller(dt);
}

void sbox::Sandbox::draw()
{
	st::clear_screen(tr::Color::rgb(0x009ccf)); // weezer blue
	program.set_uniform(ST_TERRAIN_SHADER_U_VIEW, st::Camera::current().view_matrix());
	program.set_uniform(
		ST_TERRAIN_SHADER_U_PROJECTION, st::Camera::current().projection_matrix()
	);
	mesh.draw();
}

void sbox::Sandbox::gui()
{
	sbox::debug_mode();
}

void sbox::Sandbox::free()
{
	program.free();
	mesh.free();
	ssbo.free();
	arena.free();

	tr::log("freed sandbox :)");
}

void sbox::Sandbox::player_controller(float64 dt) const
{
	if (_ui_enabled) {
		return;
	}

	st::Camera& cam = st::Camera::current();
	tr::Vec2<float64> mouse = st::delta_mouse_position();
	cam.rotation.y += float32(mouse.x * MOUSE_SENSITIVITY);
	cam.rotation.x += float32(mouse.y * MOUSE_SENSITIVITY);
	// don't break your neck
	cam.rotation.x = tr::clamp(cam.rotation.x, -89.0f, 89.0f);

	tr::Vec3<float32> move = {};
	if (st::is_key_held(st::Key::W)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y)) * 1, 0,
			 cosf(tr::deg2rad(cam.rotation.y)) * -1};
	}
	if (st::is_key_held(st::Key::S)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y)) * -1, 0,
			 cosf(tr::deg2rad(cam.rotation.y)) * 1};
	}
	if (st::is_key_held(st::Key::A)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y - 90)) * 1, 0,
			 cosf(tr::deg2rad(cam.rotation.y - 90)) * -1};
	}
	if (st::is_key_held(st::Key::D)) {
		move +=
			{sinf(tr::deg2rad(cam.rotation.y - 90)) * -1, 0,
			 cosf(tr::deg2rad(cam.rotation.y - 90)) * 1};
	}
	if (st::is_key_held(st::Key::SPACE)) {
		move.y += 1;
	}
	if (st::is_key_held(st::Key::LEFT_SHIFT)) {
		move.y -= 1;
	}

	if (move.length() > 0.0f) {
		cam.position += move.normalize() * PLAYER_SPEED * float32(dt);
	}
}
