/*
 * starry3d: C++ voxel engine
 * https://github.com/hellory4n/starry3d
 *
 * starry/shader/basic.glsl
 * Just some test faffery :)
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

// compile with: ./sokol-shdc -i starry/shader/basic.glsl -o starry/shader/basic.glsl.h -l glsl430

@ctype mat4 tr::Matrix4x4
@ctype vec2 tr::Vec2<float32>
@ctype vec3 tr::Vec3<float32>
@ctype vec4 tr::Vec4<float32>

@vs vs
in vec3 vs_position;
in vec4 vs_color;

out vec4 fs_color;

layout(binding = 0) uniform vs_params {
	mat4 u_model;
	mat4 u_view;
	mat4 u_projection;
};

void main()
{
	gl_Position = u_projection * u_view * u_model * vec4(vs_position, 1.0);
	fs_color = vs_color;
}
@end

@fs fs
in vec4 fs_color;
out vec4 frag_color;

void main()
{
	frag_color = fs_color;
}
@end

@program basic vs fs
