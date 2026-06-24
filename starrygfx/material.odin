package starrygfx

import stapp "../starryapp"
import gpu "../starryapp/gpu"
import st "../starrylib"
import model "../starrylib/model"
import "core:strings"

Material :: model.Material

MATERIAL_EMISSIVE := st.tag64("emissive")
MATERIAL_SOLID := st.tag64("solidobj")
MATERIAL_REFLECTIVE := st.tag64("reflectv")

new_material_type :: proc(
	tag: st.Tag64,
	vertex_shader_code: string,
	fragment_shader_code: string,
) -> (
	ok: bool,
)
{
	context.allocator = stapp.get_engine_allocator()
	dev := stapp.get_gpu()
	BASE_MATERIAL_VERT :: #load("shader/base_mtl.vert", string)
	BASE_MATERIAL_FRAG :: #load("shader/base_mtl.frag", string)

	full_vert_code := strings.concatenate(
		{BASE_MATERIAL_VERT, vertex_shader_code},
		context.temp_allocator,
	)
	vert_shader := gpu.new_shader(dev, transmute([]byte)full_vert_code, .VERTEX) or_return
	defer gpu.free_shader(vert_shader)

	full_frag_code := strings.concatenate(
		{BASE_MATERIAL_FRAG, fragment_shader_code},
		context.temp_allocator,
	)
	frag_shader := gpu.new_shader(dev, transmute([]byte)full_frag_code, .FRAGMENT) or_return
	defer gpu.free_shader(frag_shader)

	pipeline := gpu.new_pipeline(
		dev,
		gpu.Render_Shaders{vertex = vert_shader, fragment = frag_shader},
		topology = .TRIANGLE_LIST,
		// TODO culling should be global
		// but then either it's set once, or all pipelines have to be recreated if you
		// ever change it?
		vertex_layout = {
			gpu.Vertex_Attribute {
				name = "position",
				offset = offset_of(Vertex, position),
				type = .VEC3_FLOAT32,
			},
			gpu.Vertex_Attribute {
				name = "normal",
				offset = offset_of(Vertex, normal),
				type = .VEC3_FLOAT32,
			},
			gpu.Vertex_Attribute {
				name = "uv",
				offset = offset_of(Vertex, uv),
				type = .VEC2_FLOAT32,
			},
		},
		vertex_size = size_of(Vertex),
	) or_return

	global.material_types[tag] = Internal_Material {
		pipeline = pipeline,
	}

	return true
}

@(private)
Internal_Material :: struct {
	pipeline: gpu.Pipeline,
}
