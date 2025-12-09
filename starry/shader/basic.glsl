@vs vs
layout(location = 0) out vec3 fs_color;

vec2 positions[3] = vec2[](
    vec2(0.0, -0.5),
    vec2(0.5, 0.5),
    vec2(-0.5, 0.5)
);

vec3 colors[3] = vec3[](
    vec3(1.0, 0.0, 0.0),
    vec3(0.0, 1.0, 0.0),
    vec3(0.0, 0.0, 1.0)
);

void main() {
    gl_Position = vec4(positions[gl_VertexIndex], 0.0, 1.0);
    fs_color = colors[gl_VertexIndex];
}
@end

@fs fs
layout(location = 0) in vec3 fs_color;

layout(location = 0) out vec4 frag_color;

void main() {
    frag_color = vec4(fs_color, 1.0);
}
@end

@program basic vs fs
