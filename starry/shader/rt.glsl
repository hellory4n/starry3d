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
vec3 rotateByQuat(vec3 vec, vec4 quat) {
    vec3 t = 2.0 * cross(quat.xyz, vec);
    return vec + quat.w * t + cross(quat.xyz, t);
}

struct Ray {
    vec3 origin;
    vec3 direction;
};

bool hitSphere(vec3 center, float radius, Ray r) {
    vec3 oc = center - r.origin;
    float a = dot(r.direction, r.direction);
    float b = -2.0 * dot(r.direction, oc);
    float c = dot(oc, oc) - radius * radius;
    float discriminant = b * b - 4 * a * c;
    return (discriminant >= 0);
}

vec3 rayAt(Ray ray, float t) {
    return ray.origin + t * ray.direction;
}

vec4 rayColor(Ray r) {
    if (hitSphere(vec3(0,0,-1), 0.5, r))
        return vec4(1, 0, 0, 1);

    vec3 unit_direction = normalize(r.direction);
    float a = 0.5 * (unit_direction.y + 1.0);
    return vec4((1.0 - a) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0), 1.0);
}

layout(location = 0) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform fs_uniform {
    float u_image_width;
    float u_image_height;
    float u_aspect_ratio;
    float u_fovy; // radians
    vec3 u_camera_position;
    vec4 u_camera_rotation; // quaternion
};

const float focal_length = 1;
const vec3 vup = vec3(0, 1, 0);

void main() {
    // viewport stuff
    float theta = u_fovy;
    float h = tan(theta / 2);
    float viewport_height = 2 * h * focal_length;
    float viewport_width = viewport_height * u_aspect_ratio;

    vec3 w = -rotateByQuat(vec3(0, 0, -1), u_camera_rotation);
    vec3 u = rotateByQuat(vec3(1, 0, 0), u_camera_rotation);
    vec3 v = rotateByQuat(vec3(0, 1, 0), -u_camera_rotation);

    vec3 viewport_u = viewport_width * u;
    vec3 viewport_v = viewport_height * v;

    vec3 pixel_delta_u = viewport_u / u_image_width;
    vec3 pixel_delta_v = viewport_v / u_image_height;

    vec3 viewport_upper_left =
        u_camera_position - (focal_length * w) - viewport_u / 2 - viewport_v / 2;
    vec3 pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);
    vec3 pixel_center = pixel00_loc + (gl_FragCoord.x * pixel_delta_u) + (gl_FragCoord.y * pixel_delta_v);

    Ray ray;
    ray.direction = pixel_center - u_camera_position;
    ray.origin = u_camera_position;
    frag_color = rayColor(ray);
}
@end

@program rt vs fs
