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
    vec3 direction;
};

vec3 rayAt(Ray ray, float t) {
    return ray.origin + t * ray.direction;
}

vec4 rayColor(Ray r) {
    vec3 unit_direction = normalize(r.direction);
    float a = 0.5 * (unit_direction.y + 1.0);
    return vec4((1.0 - a) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0), 1.0);
}

layout(location = 0) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform fs_uniform {
    float image_width;
    float image_height;
    float aspect_ratio;
} u;

// TODO make this come from the cpu
const float focal_length = 1;
const vec3 camera_position = vec3(0, 0, 0);

void main() {
    float viewport_height = 2.0;
    float viewport_width = viewport_height * u.aspect_ratio;
    vec3 viewport_u = vec3(viewport_width, 0, 0);
    vec3 viewport_v = vec3(0, viewport_height, 0);

    // no idea what this is but i think it's important
    vec3 pixel_delta_u = viewport_u / u.image_width;
    vec3 pixel_delta_v = viewport_v / u.image_height;

    // wheres my top left pixel in world space i thought it was here
    vec3 viewport_upper_left =
        camera_position - vec3(0, 0, focal_length) - viewport_u / 2 - viewport_v / 2;
    vec3 pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);
    vec3 pixel_center =
        pixel00_loc + (gl_FragCoord.x * pixel_delta_u) + (gl_FragCoord.y * pixel_delta_v);

    Ray ray;
    ray.direction = pixel_center - camera_position;
    ray.origin = camera_position;
    frag_color = rayColor(ray);
}
@end

@program rt vs fs
