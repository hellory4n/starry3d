#version 430 core

layout(location = 0) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

uniform sampler2D u_framebuffer;

void main()
{
	vec4 src = texture(u_framebuffer, fs_uv);
	frag_color = vec4(vec3(1.0 - src), 1.0);
}
