#version 330 core

const vec2 positions[6] = vec2[](
    vec2(-1, -1),
    vec2(-1, 1),
    vec2(1, 1),
    vec2(-1, -1),
    vec2(1, -1),
    vec2(1, 1)
);
const vec2 uvs[6] = vec2[](
    vec2(0, 1),
    vec2(0, 0),
    vec2(1, 0),
    vec2(0, 1),
    vec2(1, 1),
    vec2(1, 0)
);

out vec2 fs_uv;

void main() {
    gl_Position = vec4(positions[gl_VertexID], 0.0, 1.0);
    fs_uv = uvs[gl_VertexID];
}
