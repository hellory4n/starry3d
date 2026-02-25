struct Vert_Input {
	@builtin(vertex_index) vert_id: u32,
}

struct Vert_Output {
	@builtin(position) pos: vec4f,
	@location(0) color: vec4f,
}

struct Frag_Input {
	@location(0) color: vec4f,
}

struct Frag_Output {
	@location(0) color: vec4f,
}

const VERTICES = array(
	vec2f( 0.0, 0.5),
	vec2f(-0.5, -0.5),
	vec2f( 0.5, -0.5),
);

const COLORS = array(
	vec3f(1, 0, 0),
	vec3f(0, 1, 0),
	vec3f(0, 0, 1),
);

@vertex
fn main_vert(in: Vert_Input) -> Vert_Output {
	var out = Vert_Output();
	out.pos = vec4f(VERTICES[in.vert_id], 0, 1);
	out.color = vec4f(COLORS[in.vert_id], 1);
	return out;
}

@fragment
fn main_frag(in: Frag_Input) -> Frag_Output {
	var out = Frag_Output();
	out.color = in.color;
	return out;
}
