//! Does the raytracing stuff and outputs it into a fullscreen quad
@vs vs
layout(location = 0) out vec2 fs_uv;

vec2 positions[6] = vec2[](
    vec2(-1, -1), vec2(-1, 1), vec2(1, 1),
    vec2(-1, -1), vec2(1, -1), vec2(1, 1)
);

vec2 uvs[6] = vec2[](
    vec2(0, 0), vec2(0, 1), vec2(1, 1),
    vec2(0, 0), vec2(1, 0), vec2(1, 1)
);

void main() {
    gl_Position = vec4(positions[gl_VertexIndex], 0.0, 1.0);
    fs_uv = uvs[gl_VertexIndex];
}
@end

@fs fs
struct Ray {
    vec3 origin;
    vec3 dir;
};

layout(location = 0) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform fs_uniform {
    vec3 view_params;
    mat4 view_matrix;
} u;

void main() {
    // flip the Y axis to follow raytracing in one weekend
    // stupid i know
    vec2 uv = vec2(fs_uv.x, -fs_uv.y + 1);

    frag_color = vec4(uv, 0.0, 1.0);
}
@end

@program rt vs fs
