#version 430 core

layout(location = 0) in vec2 vs_pos;
layout(location = 1) in vec3 vs_color;

layout(location = 0) out vec3 fs_color;

layout(std140, binding = 0) uniform data {
	mat4 u_model;
	mat4 u_view;
	mat4 u_proj;
};

void main()
{
	gl_Position = u_proj * u_view * u_model * vec4(vs_pos, 0.0, 1.0);
	fs_color = vs_color;
}
