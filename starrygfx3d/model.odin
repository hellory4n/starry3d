package stgfx3d

import gpu "../starryapp/gpu"
import hm "core:container/handle_map"
import "core:log"
import "core:strings"
import gltf "vendor:cgltf"

Model :: distinct hm.Handle32

Model_Data :: struct {
	gltf_model: ^gltf.data,
	meshes:     []Mesh,
}

// Pure uncut mesh data. Probably use a model instead
Mesh :: struct {
	vertices: []Vertex,
	indices:  []Triangle,
}

// TODO consider not forcing the exact same format for every model that has ever existed
// this could be done by having these be in separate arrays, then the renderer chooses
// a pipeline with the correct data format + material combination
// but that sounds obnoxious
Vertex :: struct {
	pos:    [3]f32,
	normal: [3]f32,
	color:  [4]f32,
	uv:     [2]f32,
}

Triangle :: distinct [3]u32

// Forces a model to be reloaded, ignoring if it's already in texture cache
reload_model :: proc(path: string) -> (model: Model, ok: bool) #optional_ok
{
	data: Model_Data
	if strings.ends_with(path, ".gltf") {
		data, ok = import_gltf(path)
		if !ok do return
	} else {
		log.errorf("unsupported model format: %s", path)
		return
	}

	model, ok = hm.add(&global.models, data)
	if !ok do return

	global.model_cache[path] = model
	return
}

// Unloads a model from the cache.
unload_model :: proc(model: Model)
{
	m, ok := hm.get(&global.models, model)
	assert(ok)

	if m.gltf_model != nil {
		defer gltf.free(m.gltf_model)
	}

	hm.remove(&global.models, model)
}

// Fetches a model from the cache, and loads it if it's not in there yet. This means that it'll
// only be loaded once throughout the entire app's lifecycle. The engine will handle freeing the
// model automatically.
fetch_model :: proc(path: string) -> (model: Model, ok: bool) #optional_ok
{
	model, ok = global.model_cache[path]
	if !ok {
		return reload_model(path)
	}

	if !hm.is_valid(global.models, model) {
		return reload_model(path)
	}

	return model, true
}

@(private)
import_gltf :: proc(path: string) -> (model: Model_Data, ok: bool) #optional_ok
{
	cpath := strings.clone_to_cstring(path, context.temp_allocator)
	tfm, res := gltf.parse_file({}, cpath)
	if res != .success {
		log.errorf("couldn't load %q: %s", path, res)
		return model, false
	}
	model.gltf_model = tfm

	res = gltf.load_buffers({}, tfm, cpath)
	if res != .success {
		log.errorf("couldn't load internal buffers for %q: %s", path, res)
		return model, false
	}

	return model, true
}
