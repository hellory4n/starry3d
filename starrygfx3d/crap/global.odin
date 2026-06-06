package stgfx3d

import hm "core:container/handle_map"

@(private)
global: struct {
	models:      hm.Static_Handle_Map(1024, Model_Data, Model),
	model_cache: map[string]Model,
	objects:     hm.Dynamic_Handle_Map(Any_Object, Object),
}

init_renderer :: proc()
{
	hm.dynamic_init(&global.objects, context.allocator)
}

free_renderer :: proc()
{
	iter := hm.iterator_make(&global.objects)
	for obj, _ in hm.iterate(&iter) {
		#partial switch v in obj.v {
		case Group_Object:
			delete(v.children)
		case Level_Object:
			delete(v.children)
		}
	}
	hm.dynamic_destroy(&global.objects)
}
