#ifndef _SB_CAMERA_H
#define _SB_CAMERA_H
#include <math.h>
#include <libtrippin.h>
#include <starry3d.h>

#define SB_SENSITIVITY 0.1
#define SB_SPEED 5.0
static double sb_cam_rot_x;
static double sb_cam_rot_y;
static TrVec3f sb_cam_pos = {0, 0, 8};
static TrVec2f sb_prev_mouse;

static inline void sb_camera_update(void)
{
	double dt = st_delta_time();

	TrVec2f mpos = st_mouse_position();
	TrVec2f dmouse = TR_V2_SUB(mpos, sb_prev_mouse);
	sb_prev_mouse = mpos;
	sb_cam_rot_y += dmouse.x * SB_SENSITIVITY;
	sb_cam_rot_x += dmouse.y * SB_SENSITIVITY;
	if (sb_cam_rot_x > 89) sb_cam_rot_x = 89;
	if (sb_cam_rot_x < -89) sb_cam_rot_x = -89;

	TrVec3f in = {0,0,0};
	if (st_is_key_held(ST_KEY_W))          in.z += 1;
	if (st_is_key_held(ST_KEY_S))          in.z -= 1;
	if (st_is_key_held(ST_KEY_A))          in.x -= 1;
	if (st_is_key_held(ST_KEY_D))          in.x += 1;
	if (st_is_key_held(ST_KEY_SPACE))      in.y += 1;
	if (st_is_key_held(ST_KEY_LEFT_SHIFT)) in.y -= 1;

	double yaw = tr_deg2rad(sb_cam_rot_y);
	TrVec3f forward = {sin(yaw), 0, -cos(yaw)};
	TrVec3f right = {cos(yaw), 0, sin(yaw)};

	float len_xz = sqrtf(in.x * in.x + in.z * in.z);
	if (len_xz > 0.0001f) {
		in.x /= len_xz;
		in.z /= len_xz;
	}

	TrVec3f move = {
		right.x * in.x + forward.x * in.z,
		in.y,
		right.z * in.x + forward.z * in.z
	};

	sb_cam_pos.x += move.x * SB_SPEED * dt;
	sb_cam_pos.y += move.y * SB_SPEED * dt;
	sb_cam_pos.z += move.z * SB_SPEED * dt;

	st_set_camera((StCamera){
		.position = sb_cam_pos,
		.rotation = {sb_cam_rot_x, sb_cam_rot_y, 0},
		.view = 90,
		.near = 0.001,
		.far = 1000,
		.perspective = true,
	});
}

#endif