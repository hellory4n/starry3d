#version 430 core

layout(location = 0) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

uniform float u_aspect_ratio;
uniform vec3 u_cam_pos;
uniform vec4 u_cam_rot; // quaternion
uniform float u_fov;

vec3 quat_rotate(vec4 q, vec3 v)
{
	vec3 qvec = q.xyz;
	vec3 t = cross(qvec, v) * 2.0;
	return v + q.w * t + cross(qvec, t);
}

vec3 get_ray_dir()
{
	vec2 ndc = fs_uv * 2.0 - 1.0;
	float tan_hf = tan(u_fov * 0.5);

	vec3 dir = vec3(ndc.x * u_aspect_ratio * tan_hf,
	                ndc.y * tan_hf,
	                -1.0);

	return normalize(quat_rotate(u_cam_rot, dir));
}

void main()
{
	frag_color = vec4(get_ray_dir(), 1);
}
