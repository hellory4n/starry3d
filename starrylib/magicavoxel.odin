package starrylib

import glm "core:math/linalg/glsl"
import os "core:os/os2"

// NOTE: .vox doesn't specify endianness, assuming little endian
Magica_Int :: i32le
Magica_Char :: u8

Magica_Limitation_Error :: enum {
	OK,
	SIZE_MUST_BE_SMALLER_THAN_256X256X256,
}

Magica_Error :: union #shared_nil {
	os.Error,
	Magica_Limitation_Error,
}

// writes a model to a MagicaVoxel .vox file. note that .vox is quite a limited format. this means that:
// - model size must be smaller than 256x256x256
// - semi-transparent voxels will be fully opaque
// - 24-bit color will be quantized to a palette of 255 colors
write_model_to_magicavoxel_file :: proc(
	path: string,
	model: ^Model,
	color_tag: Tag = COLOR_TAG,
) -> (
	err: Magica_Error,
)
{
	if glm.any(glm.greaterThanEqual(model.size, [3]i32{256, 256, 256})) {
		return .SIZE_MUST_BE_SMALLER_THAN_256X256X256
	}

	file := os.open(path, {.Write, .Create}) or_return
	defer os.close(file)

	// header
	os.write_string(file, "VOX ") or_return
	write_int_to_file(file, Magica_Int(150)) or_return

	// main chunk
	os.write_string(file, "MAIN") or_return
	write_int_to_file(file, Magica_Int(0)) or_return
	file_size_position := file_tell(file) or_return // set later
	write_int_to_file(file, Magica_Int(0)) or_return

	// size chunk
	os.write_string(file, "SIZE") or_return
	write_int_to_file(file, Magica_Int(size_of(Magica_Int) * 3)) // chunk size
	write_int_to_file(file, Magica_Int(0)) // children chunk size
	write_int_to_file(file, Magica_Int(model.size.x))
	write_int_to_file(file, Magica_Int(model.size.y))
	write_int_to_file(file, Magica_Int(model.size.z))

	// xyzi chunk
	os.write_string(file, "XYZI") or_return

	write_int_to_file(file, Magica_Int(model.voxel_count * 4)) // chunk size
	write_int_to_file(file, Magica_Int(0)) // children chunk size
	write_int_to_file(file, Magica_Int(model.voxel_count))

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

		for pal_color, i in MAGICA_DEFAULT_PALETTE {
			distance := distance_sq(
				unpack_rgba_from_u32(src).rgb,
				unpack_argb_from_u32(pal_color).bgr,
			)
			if distance < best_distance {
				best_distance = distance
				best_idx = i
			}
		}

		return best_idx
	}

	// destruction
	for z in model.start.z ..< model.end.z {
		for y in model.start.y ..< model.end.y {
			for x in model.start.x ..< model.end.x {
				val, solid := get_voxel(
					model,
					{x, y, z},
					color_tag,
					default = 0x000000ff,
				)
				if !solid {
					continue
				}

				// +Y up in starry, +Z up in magicavoxel
				write_int_to_file(file, Magica_Char(x - model.start.x))
				write_int_to_file(file, Magica_Char(z - model.start.z))
				write_int_to_file(file, Magica_Char(y - model.start.y))
				write_int_to_file(file, Magica_Char(closest_color_idx(val)))
			}
		}
	}

	// "from BMV" chunk, to show .bmv's superiority
	// any decent reader should be able to ignore this
	os.write_string(file, "fBMV") or_return
	write_int_to_file(file, Magica_Int(0)) // chunk size
	write_int_to_file(file, Magica_Int(0)) // children chunk size

	// now we know the size of the rest of the file
	main_chunk_children_size := (file_tell(file) or_return) - file_size_position
	os.seek(file, file_size_position, .Start)
	write_int_to_file(file, Magica_Int(main_chunk_children_size)) or_return

	return
}

// note: argb instead of rgba
@(rodata)
MAGICA_DEFAULT_PALETTE := [?]u32 {
	0x00000000,
	0xffffffff,
	0xffccffff,
	0xff99ffff,
	0xff66ffff,
	0xff33ffff,
	0xff00ffff,
	0xffffccff,
	0xffccccff,
	0xff99ccff,
	0xff66ccff,
	0xff33ccff,
	0xff00ccff,
	0xffff99ff,
	0xffcc99ff,
	0xff9999ff,
	0xff6699ff,
	0xff3399ff,
	0xff0099ff,
	0xffff66ff,
	0xffcc66ff,
	0xff9966ff,
	0xff6666ff,
	0xff3366ff,
	0xff0066ff,
	0xffff33ff,
	0xffcc33ff,
	0xff9933ff,
	0xff6633ff,
	0xff3333ff,
	0xff0033ff,
	0xffff00ff,
	0xffcc00ff,
	0xff9900ff,
	0xff6600ff,
	0xff3300ff,
	0xff0000ff,
	0xffffffcc,
	0xffccffcc,
	0xff99ffcc,
	0xff66ffcc,
	0xff33ffcc,
	0xff00ffcc,
	0xffffcccc,
	0xffcccccc,
	0xff99cccc,
	0xff66cccc,
	0xff33cccc,
	0xff00cccc,
	0xffff99cc,
	0xffcc99cc,
	0xff9999cc,
	0xff6699cc,
	0xff3399cc,
	0xff0099cc,
	0xffff66cc,
	0xffcc66cc,
	0xff9966cc,
	0xff6666cc,
	0xff3366cc,
	0xff0066cc,
	0xffff33cc,
	0xffcc33cc,
	0xff9933cc,
	0xff6633cc,
	0xff3333cc,
	0xff0033cc,
	0xffff00cc,
	0xffcc00cc,
	0xff9900cc,
	0xff6600cc,
	0xff3300cc,
	0xff0000cc,
	0xffffff99,
	0xffccff99,
	0xff99ff99,
	0xff66ff99,
	0xff33ff99,
	0xff00ff99,
	0xffffcc99,
	0xffcccc99,
	0xff99cc99,
	0xff66cc99,
	0xff33cc99,
	0xff00cc99,
	0xffff9999,
	0xffcc9999,
	0xff999999,
	0xff669999,
	0xff339999,
	0xff009999,
	0xffff6699,
	0xffcc6699,
	0xff996699,
	0xff666699,
	0xff336699,
	0xff006699,
	0xffff3399,
	0xffcc3399,
	0xff993399,
	0xff663399,
	0xff333399,
	0xff003399,
	0xffff0099,
	0xffcc0099,
	0xff990099,
	0xff660099,
	0xff330099,
	0xff000099,
	0xffffff66,
	0xffccff66,
	0xff99ff66,
	0xff66ff66,
	0xff33ff66,
	0xff00ff66,
	0xffffcc66,
	0xffcccc66,
	0xff99cc66,
	0xff66cc66,
	0xff33cc66,
	0xff00cc66,
	0xffff9966,
	0xffcc9966,
	0xff999966,
	0xff669966,
	0xff339966,
	0xff009966,
	0xffff6666,
	0xffcc6666,
	0xff996666,
	0xff666666,
	0xff336666,
	0xff006666,
	0xffff3366,
	0xffcc3366,
	0xff993366,
	0xff663366,
	0xff333366,
	0xff003366,
	0xffff0066,
	0xffcc0066,
	0xff990066,
	0xff660066,
	0xff330066,
	0xff000066,
	0xffffff33,
	0xffccff33,
	0xff99ff33,
	0xff66ff33,
	0xff33ff33,
	0xff00ff33,
	0xffffcc33,
	0xffcccc33,
	0xff99cc33,
	0xff66cc33,
	0xff33cc33,
	0xff00cc33,
	0xffff9933,
	0xffcc9933,
	0xff999933,
	0xff669933,
	0xff339933,
	0xff009933,
	0xffff6633,
	0xffcc6633,
	0xff996633,
	0xff666633,
	0xff336633,
	0xff006633,
	0xffff3333,
	0xffcc3333,
	0xff993333,
	0xff663333,
	0xff333333,
	0xff003333,
	0xffff0033,
	0xffcc0033,
	0xff990033,
	0xff660033,
	0xff330033,
	0xff000033,
	0xffffff00,
	0xffccff00,
	0xff99ff00,
	0xff66ff00,
	0xff33ff00,
	0xff00ff00,
	0xffffcc00,
	0xffcccc00,
	0xff99cc00,
	0xff66cc00,
	0xff33cc00,
	0xff00cc00,
	0xffff9900,
	0xffcc9900,
	0xff999900,
	0xff669900,
	0xff339900,
	0xff009900,
	0xffff6600,
	0xffcc6600,
	0xff996600,
	0xff666600,
	0xff336600,
	0xff006600,
	0xffff3300,
	0xffcc3300,
	0xff993300,
	0xff663300,
	0xff333300,
	0xff003300,
	0xffff0000,
	0xffcc0000,
	0xff990000,
	0xff660000,
	0xff330000,
	0xff0000ee,
	0xff0000dd,
	0xff0000bb,
	0xff0000aa,
	0xff000088,
	0xff000077,
	0xff000055,
	0xff000044,
	0xff000022,
	0xff000011,
	0xff00ee00,
	0xff00dd00,
	0xff00bb00,
	0xff00aa00,
	0xff008800,
	0xff007700,
	0xff005500,
	0xff004400,
	0xff002200,
	0xff001100,
	0xffee0000,
	0xffdd0000,
	0xffbb0000,
	0xffaa0000,
	0xff880000,
	0xff770000,
	0xff550000,
	0xff440000,
	0xff220000,
	0xff110000,
	0xffeeeeee,
	0xffdddddd,
	0xffbbbbbb,
	0xffaaaaaa,
	0xff888888,
	0xff777777,
	0xff555555,
	0xff444444,
	0xff222222,
	0xff111111,
}
