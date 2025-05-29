#vertex
#version 330 core

// glsl doesnt have a byte type
layout (location = 0) in uint low;
layout (location = 1) in uint high;

uniform mat4 u_view;
uniform mat4 u_proj;
uniform ivec3 u_chunk_pos;
uniform vec2 u_limits; // x is voxel size, y is chunk size

flat out uint out_facing;
flat out uint out_color;

void main()
{
	float voxel_size = u_limits.x;
	float chunk_size = u_limits.y;

	// glsl doesn't have a byte type
	// so we have to do evil bit fuckery to get our crap back
	ivec3 model = ivec3(
		(low >>  0u) & 0xFFu,
		(low >>  8u) & 0xFFu,
		(low >> 16u) & 0xFFu
	);
	ivec3 block = ivec3(
		(low  >> 24u) & 0xFFu,
		(high >>  0u) & 0xFFu,
		(high >>  8u) & 0xFFu
	);
	uint facing = (high >> 16u) & 0xFFu;
	uint color  = (high >> 24u) & 0xFFu;

	vec3 pos = (vec3(model) / voxel_size) + vec3(block) + (vec3(block) / chunk_size);
	gl_Position = u_proj * u_view * vec4(pos, 1.0);

	out_facing = facing;
	out_color = color;
}

#fragment
#version 330 core

flat in uint out_facing;
flat in uint out_color;

out vec4 FragColor;

uniform vec3 u_ambient;
uniform vec3 u_sun_color;
uniform vec3 u_sun_dir;

layout(std140) uniform palette_block {
	vec4 u_palette[256];
};

void main()
{
	vec4 obj_color = u_palette[out_color];

	vec3 normals[6] = vec3[6](
		vec3(-1,  0,  0),
		vec3( 1,  0,  0),
		vec3( 0,  0, -1),
		vec3( 0,  0,  1),
		vec3( 0,  1,  0),
		vec3( 0, -1,  0)
	);
	vec3 normal = normals[out_facing];
	vec3 sundir = normalize(u_sun_dir);

	float diff = max(dot(normal, sundir), 0.0);
	FragColor = vec4(
		obj_color.rgb * ((u_ambient * u_sun_color) + diff * (1.0 - u_ambient * u_sun_color)),
		obj_color.a
	);
}
