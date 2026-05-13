#version 430 core

layout(location = 0) in vec2 vs_pos;
layout(location = 1) in vec2 vs_uv;
layout(location = 2) in int vs_char;

layout(location = 0) out vec2 fs_base_uv;
layout(location = 1) flat out int fs_char;

void main()
{
	gl_Position = vec4(vs_pos, 0, 1);
	fs_base_uv = vs_uv;
	fs_char = vs_char;
}
