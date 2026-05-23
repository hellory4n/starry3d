#version 430 core

const vec2 POSITIONS[3] = vec2[3](
	vec2( 0.0,  0.5),
	vec2( 0.5, -0.5),
	vec2(-0.5, -0.5)
);

const vec3 COLORS[3] = vec3[3](
	vec3(1.0, 0.0, 0.0),
	vec3(0.0, 1.0, 0.0),
	vec3(0.0, 0.0, 1.0)
);

layout(location = 0) out vec3 fs_color;

void main()
{
	gl_Position = vec4(POSITIONS[gl_VertexID], 0.0, 1.0);
	fs_color = COLORS[gl_VertexID];
}
