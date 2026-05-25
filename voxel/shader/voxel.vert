#version 430 core

layout(location = 0) out vec2 fs_uv;

vec2 POSITIONS[6] = vec2[](
	vec2(-1, -1), vec2(-1, 1), vec2(1, 1),
	vec2(-1, -1), vec2(1, -1), vec2(1, 1)
);

vec2 UVS[6] = vec2[](
	vec2(0, 0), vec2(0, 1), vec2(1, 1),
	vec2(0, 0), vec2(1, 0), vec2(1, 1)
);

void main() {
	gl_Position = vec4(POSITIONS[gl_VertexID], 0.0, 1.0);
	fs_uv = UVS[gl_VertexID];
}
