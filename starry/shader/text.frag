#version 430 core

layout(location = 0) in vec4 fs_color;
layout(location = 1) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform sampler2D u_texture;

void main()
{
	frag_color = vec4(fs_uv, 0, 1);
	// frag_color = vec4(1, 0, 0, 1);
	// frag_color = texture(u_texture, fs_uv).rrrr * fs_color;
}
