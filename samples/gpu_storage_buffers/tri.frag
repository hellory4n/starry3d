#version 430 core

layout(location = 0) in vec4 fs_color;

layout(location = 0) out vec4 frag_color;

void main()
{
	frag_color = fs_color;
}
