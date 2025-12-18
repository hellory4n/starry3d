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
mat3 yawPitchRoll(float yaw, float pitch, float roll)
{
    mat3 r = mat3(vec3(cos(yaw), sin(yaw), 0.0), vec3(-sin(yaw), cos(yaw), 0.0), vec3(0.0, 0.0, 1.0));
    mat3 s = mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, cos(pitch), sin(pitch)), vec3(0.0, -sin(pitch), cos(pitch)));
    mat3 t = mat3(vec3(cos(roll), 0.0, sin(roll)), vec3(0.0, 1.0, 0.0), vec3(-sin(roll), 0.0, cos(roll)));

    return r * s * t;
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
    // no depth stuff fuck you
    if (hitSphere(vec3(0, 0, -1), 0.5, r)) {
        return vec4(1, 0, 0, 1);
    }
    if (hitSphere(vec3(1.5, 0, -1), 0.5, r)) {
        return vec4(0, 0, 1, 1);
    }
    if (hitSphere(vec3(0, 1.5, -1), 0.3, r)) {
        return vec4(1, 1, 1, 1);
    }
    if (hitSphere(vec3(0, 0, -2.5), 0.3, r)) {
        return vec4(0, 1, 0, 1);
    }

    vec3 unit_direction = normalize(r.direction);
    float a = 0.5 * (unit_direction.y + 1.0);
    return vec4((a - 1.0) * vec3(1.0, 1.0, 1.0) + a * vec3(0.5, 0.7, 1.0), 1.0);
}

layout(location = 0) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

layout(binding = 0) uniform fs_uniform {
    float u_image_width;
    float u_image_height;
    float u_aspect_ratio;
    float u_fovy; // radians
    vec3 u_camera_position;
    vec3 u_camera_rotation; // euler radians
};

void main() {
    // pixel-position mapping
    vec2 I = (2.0 * gl_FragCoord.xy - vec2(u_image_width, u_image_height)) / u_image_height / u_aspect_ratio;

    mat3 rot_mat = yawPitchRoll(u_camera_rotation.y, u_camera_rotation.x, u_camera_rotation.z);
    Ray ray;
    ray.origin = rot_mat * u_camera_position;
    ray.direction = rot_mat * vec3(I.x, I.y, 2.0);

    // something has gone wrong in the middle of the code thievery
    ray.origin = -ray.origin.xyz;
    ray.direction = -ray.direction.xyz;

    frag_color = rayColor(ray);
}
@end

@program rt vs fs
