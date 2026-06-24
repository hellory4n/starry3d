void material_fragment(
	vec4 material[16],
	vec3 vert_position,
	vec3 vert_normal,
	vec2 vert_uv,
	vec2 frag_coord,
	out vec4 out_color
) {
	vec4 color = material[0];
	out_color = color;
}
