#include <math.h>
#include "fast_voxel_raycast.h"

// ported from https://github.com/fenomas/fast-voxel-raycast/blob/master/index.js

static bool jk_raycast_impl(jk_vox_should_block_func get_voxel, double px, double py, double pz,
	double dx, double dy, double dz, double max_d, TrVec3f* out_hit_pos, TrVec3f* out_hit_norm)
{
	double t = 0.0;

	double ix = floor(px);
	double iy = floor(py);
	double iz = floor(pz);

	double stepx = (dx > 0) ? 1 : -1;
	double stepy = (dy > 0) ? 1 : -1;
	double stepz = (dz > 0) ? 1 : -1;

	// dx, dy, dz are already normalized
	double tx_delta = fabs(1 / dx);
	double ty_delta = fabs(1 / dy);
	double tz_delta = fabs(1 / dz);

	double xdist = (stepx > 0) ? (ix + 1 - px) : (px - ix);
	double ydist = (stepy > 0) ? (iy + 1 - py) : (py - iy);
	double zdist = (stepz > 0) ? (iz + 1 - pz) : (pz - iz);

	// location of nearest voxel boundary, in units of t
	double tx_max = (tx_delta < INFINITY) ? tx_delta * xdist : INFINITY;
	double ty_max = (ty_delta < INFINITY) ? ty_delta * ydist : INFINITY;
	double tz_max = (tz_delta < INFINITY) ? tz_delta * zdist : INFINITY;

	double stepped_index = -1;

	// main loop along raycast vector
	while (t <= max_d) {
		bool b = get_voxel(ix, iy, iz);
		if (b) {
			if (out_hit_pos != NULL) {
				out_hit_pos->x = px + t * dx;
				out_hit_pos->y = py + t * dy;
				out_hit_pos->z = pz + t * dz;
			}
			if (out_hit_norm != NULL) {
				out_hit_norm->x = out_hit_norm->y = out_hit_norm->z = 0;
				if (stepped_index == 0) out_hit_norm->x = -stepx;
				if (stepped_index == 1) out_hit_norm->y = -stepy;
				if (stepped_index == 2) out_hit_norm->z = -stepz;
			}
			return b;
		}

		// advance t to next nearest voxel boundary
		if (tx_max < ty_max) {
			if (tx_max < tz_max) {
				ix += stepx;
				t = tx_max;
				tx_max += tx_delta;
				stepped_index = 0;
			}
			else {
				iz += stepz;
				t = tz_max;
				tz_max += tz_delta;
				stepped_index = 2;
			}
		}
		else {
			if (ty_max < tz_max) {
				iy += stepy;
				t = ty_max;
				ty_max += ty_delta;
				stepped_index = 1;
			} else {
				iz += stepz;
				t = tz_max;
				tz_max += tz_delta;
				stepped_index = 2;
			}
		}
	}

	// no voxel hit found
	if (out_hit_pos != NULL) {
		out_hit_pos->x = px + t * dx;
		out_hit_pos->y = py + t * dy;
		out_hit_pos->z = pz + t * dz;
	}
	if (out_hit_norm != NULL) {
		out_hit_norm->x = out_hit_norm->y = out_hit_norm->z = 0;
	}

	return false;
}

bool jk_raycast(jk_vox_should_block_func get_voxel, TrVec3f start, TrVec3f dir, double raylen,
	TrVec3f* out_hit_pos, TrVec3f* out_hit_norm)
{
	double px = +start.x;
	double py = +start.y;
	double pz = +start.x;
	double dx = +dir.x;
	double dy = +dir.y;
	double dz = +dir.z;
	double ds = sqrt(dx * dx + dy * dy + dz * dz);

	if (ds == 0) {
		tr_panic("Can't raycast along a zero vector");
	}

	dx /= ds;
	dy /= ds;
	dz /= ds;
	if (raylen < 0.1) {
		raylen = 64;
	}
	else {
		raylen = +raylen;
	}

	return jk_raycast_impl(get_voxel, px, py, pz, dx, dy, dz, raylen, out_hit_pos, out_hit_norm);
}
