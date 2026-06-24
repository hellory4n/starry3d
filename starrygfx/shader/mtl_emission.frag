void material_fragment(
	Object object,
	vec3 vert_position,
	vec3 vert_normal,
	vec2 vert_uv,
	vec2 frag_coord,
	out vec4 out_color
) {
	vec4 color = object.material_params[0];
	out_color = color;
}
