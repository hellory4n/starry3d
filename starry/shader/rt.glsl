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
    float plane_width;
    float plane_height;
    float near_clip_plane;
    vec3 camera_position;
    mat4 view_matrix;
} u;

void main() {
    // screen to world coords
    vec3 view_point_local = vec3(fs_uv - 0.5, 1) *
        vec3(u.plane_width, u.plane_height, u.near_clip_plane);
    vec3 view_point = (u.view_matrix * vec4(view_point_local, 1)).xyz;

    Ray ray;
    ray.origin = u.camera_position;
    ray.dir = normalize(view_point - ray.origin);
    frag_color = vec4(ray.dir, 1);
}
@end

@program rt vs fs
