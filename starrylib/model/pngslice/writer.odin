package pngslice

import "base:runtime"
import "core:c"
import "core:os"
import model ".."
import stbi "vendor:stb/image"
import st "../.."

// flattens the model into an image of 8-bit red, green, blue, and alpha quadruplets. assumes
// the model is valid. you must `delete()` the returned buffer yourself.
flatten_model :: proc(
	m: ^model.Model,
	color_tag: st.Tag = model.RGBA_TAG,
	allocator := context.allocator,
) -> (
	buffer: []u8,
	dimensions: [2]i32,
)
{
	dimensions = [2]i32{m.size.x * m.size.y, m.size.z}
	buffer = make([]u8, dimensions.x * dimensions.y * 4, allocator)

	i := 0
	for z in m.start.z ..< m.end.z {
		for y in m.start.y ..< m.end.y {
			for x in m.start.x ..< m.end.x {
				defer i += 4

				val, solid := model.get_voxel(m, {x, y, z}, color_tag)
				if !solid {
					continue
				}

				color := st.unpack_rgba_from_u32(val)
				buffer[i] = color.r
				buffer[i + 1] = color.g
				buffer[i + 2] = color.b
				buffer[i + 3] = color.a
			}
		}
	}

	return
}

// assumes model is valid
write_to_file :: proc(
	path: string,
	m: ^model.Model,
	color_tag: st.Tag = model.RGBA_TAG,
	allocator := context.allocator,
) -> (
	err: os.Error,
)
{
	file := os.open(path, {.Write, .Create}) or_return
	defer os.close(file)

	img, size := flatten_model(m, color_tag, allocator)
	defer delete(img)

	Write_Context :: struct {
		ctx:        runtime.Context,
		file:       ^os.File,
		last_error: os.Error,
	}

	write_func :: proc "c" (ctx: rawptr, data: rawptr, size: c.int)
	{
		crap := cast(^Write_Context)ctx
		context = crap.ctx

		// inconveniently we can't tell stb to stop writing
		_, crap.last_error = os.write_ptr(crap.file, data, int(size))
	}

	crap := Write_Context {
		file = file,
		ctx  = context,
	}
	stbi.write_png_to_func(write_func, &crap, size.x, size.y, 4, raw_data(img), 0)

	return
}
