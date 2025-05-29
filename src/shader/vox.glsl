#vertex
#version 330 core

layout (location = 0) in vec3 pos;
layout (location = 1) in uint facing;
layout (location = 2) in uint color;

uniform mat4 u_view;
uniform mat4 u_proj;

flat out uint out_facing;
flat out uint out_color;

void main()
{
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

	vec3 normals[6] = [
		vec3(-1,  0,  0);
		vec3( 1,  0,  0);
		vec3( 0,  0, -1);
		vec3( 0,  0,  1);
		vec3( 0,  1,  0);
		vec3( 0, -1,  0);
	}
	vec3 normal = normals[out_facing];
	vec3 sundir = normalize(u_sun_dir);

	float diff = max(dot(normal, sundir), 0.0);
	FragColor = vec4(obj_color.rgb * ((u_ambient * u_sun_color) + diff * (1.0 - u_ambient * u_sun_color)), obj_color.a);
}
