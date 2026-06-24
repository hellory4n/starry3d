#version 460 core

layout(location = 0) in vec2 vs_pos;
layout(location = 1) in vec3 vs_normal;
layout(location = 2) in vec2 vs_uv;

layout(location = 0) out vec3 fs_pos;
layout(location = 1) out vec3 fs_normal;
layout(location = 2) out vec2 fs_uv;
layout(location = 3) flat out int fs_object_index;

struct Object {
	mat4 transform;
	vec4 material_params[16];
};

layout(std140, binding = 0) uniform world {
	mat4 u_vp;
	vec2 u_resolution;
	float u_time;
	float u_delta_time;
};

layout(std430, binding = 0) buffer objects {
	Object u_objects[];
};

// user code
void material_vertex(vec3 vert_position, vec3 vert_normal, vec2 vert_uv, out vec3 position);

void main() {
	vec3 world_pos;
	material_vertex(vs_pos, vs_normal, vs_uv, world_pos);

	Object object = u_objects[0]; // TODO
	gl_Position = u_vp * u_object.transform * vec4(world_pos, 1.0)

	fs_pos = vs_pos;
	fs_normal = vs_normal;
	fs_uv = vs_uv;
}
