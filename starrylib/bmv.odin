package starrylib

import "core:c"
import glm "core:math/linalg/glsl"
import "core:mem"
import "core:os"
import "vendor:compress/lz4"

BMV_MAGIC :: "\x00bmvoxel"
BMV_MAJOR_VERSION :: u8(0)
BMV_MINOR_VERSION :: u8(5)

// usage not recommended unless you need extensions
Bmv_Raw_Metadata :: map[[4]byte][]byte

Bmv_Metadata :: union #no_nil {
	Bmv_Standard_Metadata,
	Bmv_Raw_Metadata,
}

Bmv_Standard_Metadata :: struct {
	compression_algorithm: Bmv_Compression,
}

Bmv_Compression :: enum u8 {
	LZ4  = 0,
	NONE = 255,
}

@(rodata)
BMV_SIZE_METATAG := [4]byte{'s', 'i', 'z', 'e'}
@(rodata)
BMV_COMPRESSION_METATAG := [4]byte{'c', 'm', 'p', 's'}

Bmv_Write_Error :: enum {
	OK,
	INVALID_SIZE,
	// only applies if using raw metadata
	MISSING_SIZE_META_ATTRIBUTE,
	COMPRESSION_FAILED,
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
			write_int_to_file(file, u32le(1)) or_return // len
			write_int_to_file(file, u8(md.compression_algorithm))
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

	switch compression {
	case .NONE:
		// it's very convenient when you're the one that designed the format
		os.write_slice(file, model.solid) or_return

	case .LZ4:
		src := mem.slice_to_bytes(model.solid)

		compressed_cap := lz4.compressBound(c.int(len(src)))
		dst := make([]byte, compressed_cap, context.temp_allocator)

		compressed_size := lz4.compress_default(
			raw_data(src),
			raw_data(dst),
			c.int(len(src)),
			compressed_cap,
		)
		if compressed_size <= 0 {
			return .COMPRESSION_FAILED
		}

		compressed := dst[:compressed_size]
		os.write(file, compressed) or_return
	}

	// attribute data sections
	for tag, payloads in model.data {
		tag := tag

		os.write_string(file, "attrdata") or_return
		os.write(file, tag[:]) or_return

		when ODIN_ENDIAN != .Little {
			#panic("TODO")
		}

		switch compression {
		case .NONE:
			os.write_slice(file, payloads) or_return
		case .LZ4:
			src := mem.slice_to_bytes(payloads)

			compressed_cap := lz4.compressBound(c.int(len(src)))
			dst := make([]byte, compressed_cap, context.temp_allocator)

			compressed_size := lz4.compress_default(
				raw_data(src),
				raw_data(dst),
				c.int(len(src)),
				compressed_cap,
			)
			if compressed_size <= 0 {
				return .COMPRESSION_FAILED
			}

			compressed := dst[:compressed_size]
			os.write(file, compressed) or_return
		}
	}

	return
}
