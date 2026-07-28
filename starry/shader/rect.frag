#version 430 core

layout(location = 0) in vec4 fs_color;
layout(location = 1) in vec2 fs_uv;
layout(location = 2) in flat uint fs_has_texture;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform sampler2D u_texture;

void main()
{
	if (bool(fs_has_texture)) {
		frag_color = texture(u_texture, fs_uv) * fs_color;
	} else {
		frag_color = fs_color;
	}
}
