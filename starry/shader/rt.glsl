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
layout(location = 0) in vec2 fs_uv;

layout(location = 0) out vec4 frag_color;

struct Ray {
    vec3 origin;
    vec3 dir;
};

bool hitSphere(vec3 center, float radius, Ray r) {
    vec3 oc = center - r.origin;
    float a = dot(r.dir, r.dir);
    float b = -2.0 * dot(r.dir, oc);
    float c = dot(oc, oc) - radius * radius;
    float discriminant = b * b - 4.0 * a * c;
    return (discriminant >= 0.0);
}

vec4 rayColor(Ray r) {
    // no depth stuff fuck you
    if (hitSphere(vec3(0,0,-1), 0.5, r)) {
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

    vec3 unit_direction = normalize(r.dir);
    float a = 0.5*(unit_direction.y + 1.0);
    return vec4((1.0-a)*vec3(1.0, 1.0, 1.0) + a*vec3(0.5, 0.7, 1.0),1);
}

vec3 unproject(vec3 pos, mat4 inv_mat, vec4 viewport) {
    vec4 vec = vec4(
        2.0 * (pos.x - viewport.x) / viewport.z - 1.0,
        2.0 * (pos.y - viewport.y) / viewport.w - 1.0,
        2.0 * pos.z - 1.0,
        1.0
    );
    vec = inv_mat * vec;
    vec *= 1.0 / vec.w;
    return vec.xyz;
}

layout(binding = 0) uniform fs_uniform {
    mat4 u_inv_view_proj_mat;
    vec4 u_viewport; // z/w = image size
    vec3 u_camera_pos;
};

void main() {
    vec2 pixel = gl_FragCoord.xy;
    vec2 image_size = u_viewport.zw;

    vec3 win_near = vec3(pixel, 0);
    vec3 win_far = vec3(pixel, 1);

    vec3 world_near = unproject(win_near, u_inv_view_proj_mat, u_viewport);
    vec3 world_far = unproject(win_far, u_inv_view_proj_mat, u_viewport);

    Ray ray;
    ray.origin = u_camera_pos;
    ray.dir = normalize(world_far - world_near);

    frag_color = rayColor(ray);
}
@end

@program rt vs fs
