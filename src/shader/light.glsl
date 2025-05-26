#vertex
#version 330 core

layout (location = 0) in vec3 pos;
layout (location = 1) in vec3 normal;
layout (location = 2) in vec2 texcoord;

out vec3 out_normal;
out vec2 out_texcoord;
out vec3 out_pos;

uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_proj;
uniform vec4 u_tint;

void main()
{
	gl_Position = u_proj * u_view * u_model * vec4(pos, 1.0);
	out_texcoord = texcoord;
	out_normal = normal;
	out_pos = pos;
}

#fragment
#version 330 core

in vec3 out_normal;
in vec2 out_texcoord;
in vec3 out_pos;

out vec4 FragColor;

uniform sampler2D u_texture;
uniform bool u_has_texture;
uniform vec3 u_ambient;
uniform vec4 u_obj_color;
uniform vec3 u_sun_color;
uniform vec3 u_sun_dir;

void main()
{
	vec4 obj_color = u_has_texture
		? texture(u_texture, out_texcoord) * u_obj_color
		: u_obj_color;

	// make sure it's normalized
	vec3 normal = normalize(out_normal);
	vec3 sundir = normalize(u_sun_dir);

	float diff = max(dot(normal, sundir), 0.0);
	FragColor = vec4(obj_color.rgb * ((u_ambient * u_sun_color) + diff * (1.0 - u_ambient * u_sun_color)), obj_color.a);
}
