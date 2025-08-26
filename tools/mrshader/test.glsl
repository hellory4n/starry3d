#version 330 core

#pragma mrshader vertex
layout(location = 0) in vec3 vs_pos;
layout(location = 1) in vec3 vs_color;

out vec3 fs_color;

void main()
{
	gl_Position = vec4(vs_pos, 1.0);
	fs_color = vs_color;
}

#pragma mrshader fragment
out vec4 frag_color;
in vec3 fs_color;

void main()
{
	frag_color = vec4(fs_color, 1.0);
}
