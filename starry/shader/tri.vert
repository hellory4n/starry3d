#version 450 core

const vec2 positions[3] = vec2[](
    vec2(0.0, 0.5),
    vec2(0.5, -0.5),
    vec2(-0.5, -0.5)
);
const vec3 colors[3] = vec3[](
    vec3(1.0, 0.0, 0.0),
    vec3(0.0, 1.0, 0.0),
    vec3(0.0, 0.0, 1.0)
);

layout(location = 0) out vec3 fs_color;

uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_proj;

void main() {
    gl_Position = u_proj * u_view * u_model * vec4(positions[gl_VertexID], 0.0, 1.0);
    fs_color = colors[gl_VertexID];
}
