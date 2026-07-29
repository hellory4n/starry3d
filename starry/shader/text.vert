#version 430 core

const vec2 POSITIONS[6] = vec2[6](
	vec2(1.0, 1.0),
	vec2(1.0, 0.0),
	vec2(0.0, 1.0),
	vec2(1.0, 0.0),
	vec2(0.0, 0.0),
	vec2(0.0, 1.0)
);

const vec2 UVS[6] = vec2[6](
	vec2(1.0, 1.0),
	vec2(1.0, 0.0),
	vec2(0.0, 1.0),
	vec2(1.0, 0.0),
	vec2(0.0, 0.0),
	vec2(0.0, 1.0)
);

layout(location = 0) out vec4 fs_color;
layout(location = 1) out vec2 fs_uv;

layout(std140, binding = 0) uniform world {
	vec4 u_color;
	vec2 u_resolution;
	vec2 u_xy0;
	vec2 u_xy1;
	vec2 u_uv0;
	vec2 u_uv1;
};

void main()
{
	fs_color = u_color;
	fs_uv = u_uv0 + u_uv1 * UVS[gl_VertexID];
	vec2 base_pos = u_xy0 + u_xy1 * POSITIONS[gl_VertexID];
	vec2 ndc = vec2(
		2.0 * base_pos.x / u_resolution.x - 1.0,
		1.0 - 2.0 * base_pos.y / u_resolution.y
	);
	gl_Position = vec4(ndc, 0, 1);
}
