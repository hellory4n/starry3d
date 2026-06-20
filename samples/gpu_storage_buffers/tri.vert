#version 430 core

const vec2 POSITIONS[3] = vec2[3](
	vec2( 0.0,  0.5),
	vec2( 0.5, -0.5),
	vec2(-0.5, -0.5)
);

layout(location = 0) out vec4 fs_color;

struct Triangle {
	mat4 transform;
	vec4 color;
};

layout(std430, binding = 0) buffer triangles {
	Triangle u_triangles[];
};

void main()
{
	Triangle tri = u_triangles[gl_InstanceID];
	gl_Position = tri.transform * vec4(POSITIONS[gl_VertexID], 0.0, 1.0);
	fs_color = tri.color;
}
