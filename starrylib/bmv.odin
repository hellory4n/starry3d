package starrylib

import glm "core:math/linalg/glsl"
import "core:os"

BMV_MAGIC :: "\x00bmvoxel"
BMV_MAJOR_VERSION :: u8(0)
BMV_MINOR_VERSION :: u8(3)

// usage not recommended unless you need extensions
Bmv_Raw_Metadata :: map[[4]byte][]byte

Bmv_Metadata :: union #no_nil {
	Bmv_Standard_Metadata,
	Bmv_Raw_Metadata,
}

Bmv_Standard_Metadata :: struct {
	compression_algorithm: Bmv_Compression,
}

Bmv_Compression :: enum u16 {
	NONE = 0,
	LZ4  = 1,
}

@(rodata)
BMV_SIZE_METATAG := [4]byte{'s', 'i', 'z', 'e'}
@(rodata)
BMV_COMPRESSION_METATAG := [4]byte{'c', 'm', 'p', 's'}

Bmv_Write_Error :: enum {
	OK,
	INVALID_SIZE,
	MISSING_SIZE_META_ATTRIBUTE,
}

Bmv_Error :: union #shared_nil {
	os.Error,
	Bmv_Write_Error,
}

// writes the model to a Big Massive Voxels file, the most massive most superior format of all time.
write_model_to_bmv_file :: proc(
	path: string,
	model: ^Model,
	metadata: Bmv_Metadata = {},
	allocator := context.allocator,
) -> (
	err: Bmv_Error,
)
{
	file := os.open(path, {.Write, .Create}) or_return
	defer os.close(file)

	// header
	os.write_string(file, BMV_MAGIC) or_return
	write_int_to_file(file, BMV_MAJOR_VERSION) or_return
	write_int_to_file(file, BMV_MINOR_VERSION) or_return

	// metadata section
	os.write_string(file, "metadata") or_return

	switch md in metadata {
	case Bmv_Standard_Metadata:
		count := 1
		if md.compression_algorithm != .NONE {
			count += 1
		}
		write_int_to_file(file, u32le(count))

		// size attr
		if glm.any(glm.lessThanEqual(model.size, [3]i32{0, 0, 0})) {
			return .INVALID_SIZE
		}
		os.write(file, BMV_SIZE_METATAG[:]) or_return
		write_int_to_file(file, u32le(12)) or_return // len
		write_int_to_file(file, u32le(model.size.x)) or_return
		write_int_to_file(file, u32le(model.size.y)) or_return
		write_int_to_file(file, u32le(model.size.z)) or_return

		// compression attr
		if md.compression_algorithm != .NONE {
			os.write(file, BMV_COMPRESSION_METATAG[:]) or_return
			write_int_to_file(file, u32le(2)) or_return // len
			write_int_to_file(file, u16le(md.compression_algorithm))
		}

	case Bmv_Raw_Metadata:
		if BMV_SIZE_METATAG not_in md {
			return .MISSING_SIZE_META_ATTRIBUTE
		}

		write_int_to_file(file, u32le(len(md))) or_return
		for tag, val in md {
			tag := tag
			os.write(file, tag[:]) or_return
			write_int_to_file(file, u32le(len(val))) or_return
			os.write(file, val) or_return
		}
	}

	compression: Bmv_Compression
	switch md in metadata {
	case Bmv_Standard_Metadata:
		compression = md.compression_algorithm
	case Bmv_Raw_Metadata:
		compression = Bmv_Compression(
			(cast([^]u16le)raw_data(md[BMV_COMPRESSION_METATAG]))[0],
		)
	}

	// solid mask section
	os.write_string(file, "solidmsk") or_return
	// it's very convenient when you're the one that designed the format
	// TODO compression
	os.write_slice(file, model.solid) or_return

	// attribute data sections
	for tag, payloads in model.data {
		tag := tag

		os.write_string(file, "attrdata") or_return
		os.write(file, tag[:]) or_return

		// TODO compression
		os.write_slice(file, payloads) or_return
	}

	return
}
