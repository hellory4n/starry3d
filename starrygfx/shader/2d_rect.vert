#version 430 core

const vec2 POSITIONS[6] = vec2[6](
	vec2(1.0, 1.0),
	vec2(1.0, 0.0),
	vec2(0.0, 1.0),
	vec2(1.0, 0.0),
	vec2(0.0, 0.0),
	vec2(0.0, 1.0)
);

layout(location = 0) out vec4 fs_color;

layout(std140, binding = 0) uniform world {
	vec4 u_color;
	vec2 u_resolution;
	vec2 u_pos;
	vec2 u_size;
};

void main()
{
	vec2 base_pos = POSITIONS[gl_VertexID] * u_size;
	vec2 ndc = vec2(
		2.0 * (u_pos.x + base_pos.x) / u_resolution.x - 1.0,
		1.0 - 2.0 * (u_pos.y + base_pos.y) / u_resolution.y
	);
	gl_Position = vec4(ndc, 0, 1);
	fs_color = u_color;
}
