package vox

import glm "core:math/linalg/glsl"
import "core:os"
import model ".."
import st "../.."

// NOTE: .vox doesn't specify endianness, assuming little endian
Int :: i32le
Char :: u8

Limitation_Error :: enum {
	OK,
	SIZE_MUST_BE_SMALLER_THAN_256X256X256,
}

Write_Error :: union #shared_nil {
	os.Error,
	Limitation_Error,
}

// writes a model to a MagicaVoxel .vox file. note that .vox is quite a limited format. this means that:
// - model size must be smaller than 256x256x256
// - semi-transparent voxels will be fully opaque
// - 24-bit color will be quantized to a palette of 255 colors
write_to_file :: proc(
	path: string,
	m: ^model.Model,
	color_tag: st.Tag = model.RGBA_TAG,
) -> (
	err: Write_Error,
)
{
	if glm.any(glm.greaterThanEqual(m.size, [3]i32{256, 256, 256})) {
		return .SIZE_MUST_BE_SMALLER_THAN_256X256X256
	}

	file := os.open(path, {.Write, .Create}) or_return
	defer os.close(file)

	// header
	os.write_string(file, "VOX ") or_return
	st.write_int_to_file(file, Int(150)) or_return

	// main chunk
	os.write_string(file, "MAIN") or_return
	st.write_int_to_file(file, Int(0)) or_return
	file_size_position := st.file_position(file) or_return // set later
	st.write_int_to_file(file, Int(0)) or_return

	// size chunk
	os.write_string(file, "SIZE") or_return
	st.write_int_to_file(file, Int(size_of(Int) * 3)) // chunk size
	st.write_int_to_file(file, Int(0)) // children chunk size
	st.write_int_to_file(file, Int(m.size.x))
	st.write_int_to_file(file, Int(m.size.y))
	st.write_int_to_file(file, Int(m.size.z))

	// xyzi chunk
	os.write_string(file, "XYZI") or_return

	st.write_int_to_file(file, Int(m.voxel_count * 4)) // chunk size
	st.write_int_to_file(file, Int(0)) // children chunk size
	st.write_int_to_file(file, Int(m.voxel_count))

	// world's worst quantization algorithm
	distance_sq :: #force_inline proc(c1, c2: [3]u8) -> u32
	{
		dr := i32(c1.r) - i32(c2.r)
		dg := i32(c1.g) - i32(c2.g)
		db := i32(c1.b) - i32(c2.b)
		return u32(dr * dr + dg * dg + db * db)
	}

	closest_color_idx :: #force_inline proc(src: u32) -> (idx: int)
	{
		best_distance: u32 = 4294967295
		best_idx := 0

		for pal_color, i in DEFAULT_PALETTE {
			distance := distance_sq(
				st.unpack_rgba_from_u32(src).rgb,
				st.unpack_argb_from_u32(pal_color).bgr,
			)
			if distance < best_distance {
				best_distance = distance
				best_idx = i
			}
		}

		return best_idx
	}

	// destruction
	for z in m.start.z ..< m.end.z {
		for y in m.start.y ..< m.end.y {
			for x in m.start.x ..< m.end.x {
				val, solid := model.get_voxel(m, {x, y, z}, color_tag)
				if !solid {
					continue
				}

				// +Y up in starry, +Z up in magicavoxel
				st.write_int_to_file(file, Char(x - m.start.x))
				st.write_int_to_file(file, Char(z - m.start.z))
				st.write_int_to_file(file, Char(y - m.start.y))
				st.write_int_to_file(file, Char(closest_color_idx(val)))
			}
		}
	}

	// "from BMV" chunk, to show .bmv's superiority
	// any decent reader should be able to ignore this
	os.write_string(file, "fBMV") or_return
	st.write_int_to_file(file, Int(0)) // chunk size
	st.write_int_to_file(file, Int(0)) // children chunk size

	// now we know the size of the rest of the file
	main_chunk_children_size := (st.file_position(file) or_return) - file_size_position
	os.seek(file, file_size_position, .Start)
	st.write_int_to_file(file, Int(main_chunk_children_size)) or_return

	return
}
