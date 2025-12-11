@vs vs
layout(location = 0) out vec2 fs_screencoord;

vec2 positions[6] = vec2[](
    vec2(-1, -1), vec2(-1, 1), vec2(1, 1),
    vec2(-1, -1), vec2(1, -1), vec2(1, 1)
);

void main() {
    gl_Position = vec4(positions[gl_VertexIndex], 0.0, 1.0);
    fs_screencoord = positions[gl_VertexIndex];
}
@end

@fs fs
layout(location = 0) in vec2 fs_screencoord;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform fs_uniform {
    float plane_width;
    float plane_height;
    float near_clip_plane;
    vec3 camera_position;
    mat4 view_matrix;
} u;

void main() {
    frag_color = vec4(u.plane_width, 0, 0, 1);
}
@end

@program rt vs fs
