#include <linmath.h>
#include <libtrippin.h>
#include <st3d.h>
#include <st3d_render.h>
#include <st3d_ui.h>
#include <st3d_voxel.h>
#include "fast_voxel_raycast.h"

// why the fuck would you need a 3d array
#define ST3D_AT3D(slice, type, sizey, sizez, x, y, z) TR_AT(slice, type, x * (sizey * sizez) + y * sizez + z)

static void camera_shitfuck(void);
static void the_placer_5001(void);

typedef enum {
	JK_DIRECTION_NORTH,
	JK_DIRECTION_NORTH_EAST,
	JK_DIRECTION_EAST,
	JK_DIRECTION_SOUTH_EAST,
	JK_DIRECTION_SOUTH,
	JK_DIRECTION_SOUTH_WEST,
	JK_DIRECTION_WEST,
	JK_DIRECTION_NORTH_WEST,
} JkDirection;

static JkDirection get_facing_direction(void);

static St3dMesh jk_el_cubo;
static TrSlice_uint8 jk_cubes;

int main(void)
{
	st3d_init("sandbox", "assets", 800, 600);
	TrArena arena = tr_arena_new(TR_MB(1));
	jk_cubes = tr_slice_new(&arena, 16 * 16 * 16, sizeof(uint8_t));
	st3d_set_palette("app:default.stpal");

	// ttriangel
	TrSlice_float vertices;
	// dear god
	TR_SET_SLICE(&arena, &vertices, float,
		-0.5f, -0.5f, +0.5f,   0, 0, 1,    0.0f, 0.0f,
		+0.5f, -0.5f, +0.5f,   0, 0, 1,    1.0f, 0.0f,
		+0.5f, +0.5f, +0.5f,   0, 0, 1,    1.0f, 1.0f,
		-0.5f, +0.5f, +0.5f,   0, 0, 1,    0.0f, 1.0f,

		+0.5f, -0.5f, -0.5f,   0, 0,-1,    0.0f, 0.0f,
		-0.5f, -0.5f, -0.5f,   0, 0,-1,    1.0f, 0.0f,
		-0.5f, +0.5f, -0.5f,   0, 0,-1,    1.0f, 1.0f,
		+0.5f, +0.5f, -0.5f,   0, 0,-1,    0.0f, 1.0f,

		-0.5f, -0.5f, -0.5f,  -1, 0, 0,    0.0f, 0.0f,
		-0.5f, -0.5f, +0.5f,  -1, 0, 0,    1.0f, 0.0f,
		-0.5f, +0.5f, +0.5f,  -1, 0, 0,    1.0f, 1.0f,
		-0.5f, +0.5f, -0.5f,  -1, 0, 0,    0.0f, 1.0f,

		+0.5f, -0.5f, +0.5f,   1, 0, 0,    0.0f, 0.0f,
		+0.5f, -0.5f, -0.5f,   1, 0, 0,    1.0f, 0.0f,
		+0.5f, +0.5f, -0.5f,   1, 0, 0,    1.0f, 1.0f,
		+0.5f, +0.5f, +0.5f,   1, 0, 0,    0.0f, 1.0f,

		-0.5f, +0.5f, +0.5f,   0, 1, 0,    0.0f, 0.0f,
		+0.5f, +0.5f, +0.5f,   0, 1, 0,    1.0f, 0.0f,
		+0.5f, +0.5f, -0.5f,   0, 1, 0,    1.0f, 1.0f,
		-0.5f, +0.5f, -0.5f,   0, 1, 0,    0.0f, 1.0f,

		-0.5f, -0.5f, -0.5f,   0,-1, 0,    0.0f, 0.0f,
		+0.5f, -0.5f, -0.5f,   0,-1, 0,    1.0f, 0.0f,
		+0.5f, -0.5f, +0.5f,   0,-1, 0,    1.0f, 1.0f,
		-0.5f, -0.5f, +0.5f,   0,-1, 0,    0.0f, 1.0f,
	);

	TrSlice_uint32 indices;
	TR_SET_SLICE(&arena, &indices, uint32_t,
		0, 2, 1, 0, 3, 2,
		4, 6, 5, 4, 7, 6,
		8, 10, 9, 8, 11, 10,
		12, 14, 13, 12, 15, 14,
		16, 18, 17, 16, 19, 18,
		20, 22, 21, 20, 23, 22,
	);

	jk_el_cubo = st3d_mesh_new(&vertices, &indices, true);
	*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, 8, 1, 8) = ST3D_COLOR_WHITE_1;

	st3d_ui_new("app:figtree/Figtree-Medium.ttf", 16);
	bool ui = false;
	st3d_set_mouse_enabled(false);

	st3d_set_environment((St3dEnvironment){
		.sky_color = tr_hex_rgb(0x03A9F4),
		.ambient_color = tr_hex_rgb(0xaaaaaa),
		.sun = {
			.direction = {-0.5, 1.0, 0.75},
			.color = TR_WHITE,
		},
	});

	while (!st3d_is_closing()) {
		st3d_begin_drawing();

		// i'm sorry... i'm sorry... i'm sorry...
		for (size_t x = 0; x < 16; x++) {
			for (size_t y = 0; y < 16; y++) {
				for (size_t z = 0; z < 16; z++) {
					uint8_t lecolourindexè = *ST3D_AT3D(jk_cubes, uint8_t, 16, 16, x, y, z);
					TrColor lecolour = st3d_get_color(lecolourindexè);
					if (lecolour.a == 0) {
						continue;
					}

					jk_el_cubo.material.color = lecolour;
					st3d_mesh_draw_3d(jk_el_cubo, (TrVec3f){x, y, z}, (TrVec3f){0, 0, 0});
				}
			}
		}

		if (st3d_is_key_just_pressed(ST3D_KEY_ESCAPE)) {
			ui = !ui;
			st3d_set_mouse_enabled(ui);
		}

		// nuklear calls go inside here
		if (ui) {
			st3d_ui_begin();
			st3d_ui_end();
		}
		else {
			camera_shitfuck();
			the_placer_5001();
		}

		st3d_end_drawing();
		st3d_poll_events();
	}

	st3d_ui_free();

	st3d_mesh_free(jk_el_cubo);
	st3d_free();
}

const double jk_sensitivity = 0.1;
const double jk_speed = 5;
static double jk_cam_rot_x;
static double jk_cam_rot_y;
static TrVec3f jk_cam_pos = {0, 0, 8};
static TrVec2f jk_prev_mouse;

static void camera_shitfuck(void)
{
	// why did this take so long
	double dt = st3d_delta_time();

	TrVec2f mpos = st3d_mouse_position();
	TrVec2f dmouse = TR_V2_SUB(mpos, jk_prev_mouse);
	jk_prev_mouse = mpos;
	jk_cam_rot_y += dmouse.x * jk_sensitivity;
	jk_cam_rot_x += dmouse.y * jk_sensitivity;
	if (jk_cam_rot_x > 89) jk_cam_rot_x = 89;
	if (jk_cam_rot_x < -89) jk_cam_rot_x = -89;

	TrVec3f in = {0,0,0};
	if (st3d_is_key_held(ST3D_KEY_W))       in.z += 1;
	if (st3d_is_key_held(ST3D_KEY_S))       in.z -= 1;
	if (st3d_is_key_held(ST3D_KEY_A))       in.x -= 1;
	if (st3d_is_key_held(ST3D_KEY_D))       in.x += 1;
	if (st3d_is_key_held(ST3D_KEY_SPACE))   in.y += 1;
	if (st3d_is_key_held(ST3D_KEY_LEFT_SHIFT)) in.y -= 1;

	double yawRad = jk_cam_rot_y * (PI/180.0);
	vec3 forward = { sin(yawRad), 0, -cos(yawRad) };
	vec3 right   = { cos(yawRad), 0,  sin(yawRad) };

	float len_xz = sqrtf(in.x*in.x + in.z*in.z);
	if (len_xz > 0.0001f) {
		in.x /= len_xz;
		in.z /= len_xz;
	}

	TrVec3f mv = {
		right[0]*in.x + forward[0]*in.z,
		in.y,
		right[2]*in.x + forward[2]*in.z
	};

	jk_cam_pos.x += mv.x * jk_speed * dt;
	jk_cam_pos.y += mv.y * jk_speed * dt;
	jk_cam_pos.z += mv.z * jk_speed * dt;

	st3d_set_camera((St3dCamera){
		.position    = jk_cam_pos,
		.rotation    = { jk_cam_rot_x, jk_cam_rot_y, 0 },
		.view        = 90,
		.near        = 0.001,
		.far         = 1000,
		.perspective = true,
	});

	// tr_log("yaw %f", jk_cam_rot_y);
}

static bool get_voxel(int64_t x, int64_t y, int64_t z)
{
	// the array isnt infinite
	if (x < 0) return true;
	if (x > 15) return true;
	if (y < 0) return true;
	if (y > 15) return true;
	if (z < 0) return true;
	if (z > 15) return true;

	return *ST3D_AT3D(jk_cubes, uint8_t, 16, 16, x, y, z) != ST3D_COLOR_TRANSPARENT;
}

static void the_placer_5001(void)
{
	TrVec2f mousepos = st3d_mouse_position();
	TrVec3f bldjhdjrt = st3d_screen_to_world_pos(mousepos);
	TrVec3f dir;
	switch (get_facing_direction()) {
		case JK_DIRECTION_NORTH:      dir = (TrVec3f){ 0, 0, -1}; break;
		case JK_DIRECTION_NORTH_EAST: dir = (TrVec3f){-1, 0, -1}; break;
		case JK_DIRECTION_EAST:       dir = (TrVec3f){-1, 0,  0}; break;
		case JK_DIRECTION_SOUTH_EAST: dir = (TrVec3f){-1, 0,  1}; break;
		case JK_DIRECTION_SOUTH:      dir = (TrVec3f){ 0, 0,  1}; break;
		case JK_DIRECTION_SOUTH_WEST: dir = (TrVec3f){ 1, 0,  1}; break;
		case JK_DIRECTION_WEST:       dir = (TrVec3f){ 1, 0,  0}; break;
		case JK_DIRECTION_NORTH_WEST: dir = (TrVec3f){ 1, 0, -1}; break;
	}
	if (jk_cam_rot_x > 45) dir.y += 1;
	if (jk_cam_rot_x < -45) dir.y -= 1;

	TrVec3f hitpos;
	TrVec3f hitnorm;
	bool hit = jk_raycast(get_voxel, bldjhdjrt, dir, 8, &hitpos, &hitnorm);
	if (hit) {
		tr_log("hit!");
		tr_log("pos: %f %f %f", hitpos.x, hitpos.y, hitpos.z);
		tr_log("norm: %f %f %f", hitnorm.x, hitnorm.y, hitnorm.z);
	}

	// preview mtae
	st3d_set_wireframe(true);
	jk_el_cubo.material.color = TR_BLACK;
	st3d_mesh_draw_3d(jk_el_cubo, hitpos, (TrVec3f){0, 0, 0});
	// TODO go back to selected color
	jk_el_cubo.material.color = TR_WHITE;
	st3d_set_wireframe(false);

	if (st3d_is_mouse_just_pressed(ST3D_MOUSE_BUTTON_RIGHT)) {
		*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, hitpos.x, hitpos.y, hitpos.z) = ST3D_COLOR_WHITE_1;
	}

	if (st3d_is_mouse_just_pressed(ST3D_MOUSE_BUTTON_LEFT)) {
		*ST3D_AT3D(jk_cubes, uint8_t, 16, 16, hitpos.x, hitpos.y, hitpos.z) = ST3D_COLOR_TRANSPARENT;
	}
}

static JkDirection get_facing_direction(void)
{
	float yaw = jk_cam_rot_y;
	if (yaw < 0) yaw += 360;
    yaw = fmod(yaw, 360.0);

	if (yaw >= 337.5 || yaw < 22.5)   return JK_DIRECTION_NORTH;
    if (yaw >= 22.5  && yaw < 67.5)   return JK_DIRECTION_NORTH_EAST;
    if (yaw >= 67.5  && yaw < 112.5)  return JK_DIRECTION_EAST;
    if (yaw >= 112.5 && yaw < 157.5)  return JK_DIRECTION_SOUTH_EAST;
    if (yaw >= 157.5 && yaw < 202.5)  return JK_DIRECTION_SOUTH;
    if (yaw >= 202.5 && yaw < 247.5)  return JK_DIRECTION_SOUTH_WEST;
    if (yaw >= 247.5 && yaw < 292.5)  return JK_DIRECTION_WEST;
    if (yaw >= 292.5 && yaw < 337.5)  return JK_DIRECTION_NORTH_WEST;
	return JK_DIRECTION_NORTH;
}
