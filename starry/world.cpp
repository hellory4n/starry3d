/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/world.cpp
 * The API for the voxel world and stuff.
 *
 * Copyright (c) 2025 hellory4n <hellory4n@gmail.com>
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 */

#include "starry/world.h"

#include <trippin/math.h>

#include "starry/app.h"
#include "starry/internal.h"

tr::Matrix4x4 st::Camera::view_matrix() const
{
	auto pos = tr::Matrix4x4::translate(-position.x, -position.y, -position.z);

	auto rot = tr::Matrix4x4::identity();
	rot = rot * rot.rotate_x(tr::deg2rad(rotation.x));
	rot = rot * rot.rotate_y(tr::deg2rad(rotation.y));
	rot = rot * rot.rotate_z(tr::deg2rad(rotation.z));

	return rot * pos;
}

tr::Matrix4x4 st::Camera::projection_matrix() const
{
	tr::Vec2<uint32> winsize = st::window_size();

	if (projection == CameraProjection::PERSPECTIVE) {
		return tr::Matrix4x4::perspective(
			tr::deg2rad(fov), float32(winsize.x) / float32(winsize.y), near, far
		);
	}

	// TODO this may be fucked im not sure
	float32 left = -zoom / 2.0f;
	float32 right = zoom / 2.0f;

	float32 height = zoom * (float32(winsize.y) / float32(winsize.x));
	float32 bottom = -height / 2.0f;
	float32 top = height / 2.0f;

	return tr::Matrix4x4::orthographic(left, right, bottom, top, near, far);
}

st::Camera& st::Camera::current()
{
	return _st->camera;
}
