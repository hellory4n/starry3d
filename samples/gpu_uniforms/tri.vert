#version 450 core

layout(location = 0) in vec2 vs_pos;
layout(location = 1) in vec3 vs_color;

layout(location = 0) out vec3 fs_color;

uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_proj;

void main()
{
	gl_Position = u_proj * u_view * u_model * vec4(vs_pos, 0.0, 1.0);
	fs_color = vs_color;
}
