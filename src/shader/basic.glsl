#shader vertex
#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec4 color;
layout (location = 2) in vec2 uv;

out vec4 out_color;
out vec2 out_uv;

void main()
{
	gl_Position = vec4(position, 1.0);
	out_color = color;
	out_uv = uv;
}

#shader fragment
#version 330 core
in vec4 out_color;
in vec2 out_uv;

out vec4 FragColor;

uniform sampler2D u_texture;

void main()
{
	FragColor = texture(u_texture, out_uv) * out_color;
}
