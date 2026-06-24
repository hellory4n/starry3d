/*
3D model API and loader, with an API inspired by `core:image`
*/
package stmodel

import st ".."
import "core:fmt"
import "core:mem"
import "core:strings"

Vertex :: struct {
	position: [3]f32,
	normal:   [3]f32,
	uv:       [2]f32,
}

Mesh :: struct {
	vertices: [dynamic]Vertex,
	indices:  [dynamic]u32, // must be triangles
	material: Material,
}

Material :: struct {
	tag:    st.Tag64,
	params: [16][4]f32,
}

Model :: struct {
	meshes: [dynamic]Mesh,
}

Error :: union {}

Loader_Proc :: #type proc(data: []byte, allocator: mem.Allocator) -> (model: Model, err: Error)

@(private)
_internal_loaders: [File_Type]Loader_Proc

register :: proc "contextless" (kind: File_Type, loader: Loader_Proc)
{
	assert_contextless(loader != nil)
	_internal_loaders[kind] = loader
}

File_Type :: enum {
	UNKNOWN,
	BIG_MASSIVE_MODELS, // .bmm
	BLENDER, // .blend
	FBX, // .fbx
	GLTF, // .gltf, .glb
	WAVEFRONT_OBJ, // .obj
	STL, // .stl
	COLLADA_DAE, // .dae
	UNIVERSAL_SCENE_DESCRIPTION, // .usd
	STANFORD_PLY, // .ply
	ALEMBIC, // .abc
}

// there's too many text-based formats to detect it from just a magic number (it's possible
// but very annoying)
which_format_from_path :: proc(path: string) -> File_Type
{
	if strings.ends_with(path, ".bmm") {
		return .BIG_MASSIVE_MODELS
	} else if strings.ends_with(path, ".blend") {
		return .BLENDER
	} else if strings.ends_with(path, ".fbx") {
		return .FBX
	} else if strings.ends_with(path, ".gltf") || strings.ends_with(path, ".glb") {
		return .GLTF
	} else if strings.ends_with(path, ".obj") {
		return .WAVEFRONT_OBJ
	} else if strings.ends_with(path, ".stl") {
		return .STL
	} else if strings.ends_with(path, ".dae") {
		return .COLLADA_DAE
	} else if strings.ends_with(path, ".usd") {
		return .UNIVERSAL_SCENE_DESCRIPTION
	} else if strings.ends_with(path, ".ply") {
		return .STANFORD_PLY
	} else if strings.ends_with(path, ".abc") {
		return .ALEMBIC
	}
	return .UNKNOWN
}

load_from_bytes :: proc(
	data: []byte,
	format: File_Type,
	allocator := context.allocator,
) -> (
	model: Model,
	err: Error,
)
{
	loader := _internal_loaders[format]
	if loader == nil {
		errstrb: strings.Builder
		strings.builder_init(&errstrb, context.temp_allocator)

		errstr := fmt.sbprintf(
			&errstrb,
			"no loader for %s found. add one with model.register()",
			format,
		)
		panic(errstr)
	}

	return loader(data, allocator)
}

destroy :: proc(model: ^Model)
{
	delete(model.meshes)
	model^ = {}
}
