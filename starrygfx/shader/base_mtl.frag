#version 460 core

layout(location = 0) in vec2 fs_pos;
layout(location = 1) in vec3 fs_normal;
layout(location = 2) in vec2 fs_uv;
layout(location = 3) flat in int fs_object_index;

layout(location = 0) out vec4 frag_color;

struct Material {
	// TODO dynamic size
	vec4 params[16];
};

struct Object {
	mat4 transform;
	Material material;
};

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
void material_fragment(
	vec4 material[16],
	vec3 vert_position,
	vec3 vert_normal,
	vec2 vert_uv,
	vec2 frag_coord,
	out vec4 out_color
);

void main()
{
	Object obj = u_objects[fs_object_index];
	material_fragment(obj, fs_pos, fs_normal, fs_uv, gl_FragCoord.xy, frag_color);
}
