package starrylib

// TODO this might be a shitty reference implementation because it heavily depends on Model
// working the way it works

import "core:c"
import glm "core:math/linalg/glsl"
import "core:mem"
import "core:os"
import "vendor:compress/lz4"

BMV_MAGIC :: "\x00bmvoxel"
BMV_MAJOR_VERSION :: u8(0)
BMV_MINOR_VERSION :: u8(6)

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
@(rodata)
BMV_STARRY_BOUNDS_METATAG := [4]byte{'s', 't', 'B', 'n'}

Bmv_Write_Error :: enum {
	OK,
	INVALID_SIZE,
	// only applies if using raw metadata
	MISSING_SIZE_META_ATTRIBUTE,
	COMPRESSION_FAILED,
}

Bmv_Read_Error :: enum {
	OK,
	UNSUPPORTED_VERSION,
	CORRUPTED_FILE,
	MISSING_SIZE_META_ATTRIBUTE,
	DECOMPRESSION_FAILED,
}

Bmv_Error :: union #shared_nil {
	os.Error,
	Bmv_Write_Error,
	Bmv_Read_Error,
	Init_Model_Error,
	Set_Voxel_Error,
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
		count := 2
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

		// starry bounds attribute
		os.write(file, BMV_STARRY_BOUNDS_METATAG[:]) or_return
		write_int_to_file(file, u32le(24)) or_return // len
		write_int_to_file(file, u32le(model.start.x)) or_return
		write_int_to_file(file, u32le(model.start.y)) or_return
		write_int_to_file(file, u32le(model.start.z)) or_return
		write_int_to_file(file, u32le(model.end.x)) or_return
		write_int_to_file(file, u32le(model.end.y)) or_return
		write_int_to_file(file, u32le(model.end.z)) or_return

		// compression attr
		if md.compression_algorithm != .NONE {
			os.write(file, BMV_COMPRESSION_METATAG[:]) or_return
			write_int_to_file(file, u32le(1)) or_return // len
			write_int_to_file(file, u8(md.compression_algorithm))
		}

	case Bmv_Raw_Metadata:
		if BMV_SIZE_METATAG not_in md {
			return Bmv_Write_Error.MISSING_SIZE_META_ATTRIBUTE
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
		write_int_to_file(file, u32le(area(model.size))) or_return
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
		write_int_to_file(file, u32le(compressed_size)) or_return
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
			write_int_to_file(file, u32le(area(model.size) * size_of(u32))) or_return
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
			write_int_to_file(file, u32le(compressed_size)) or_return
			os.write(file, compressed) or_return
		}
	}

	return
}

// reads the model from a Big Massive Voxels file, the most massive most superior format of all time.
new_model_from_bmv_file :: proc(
	path: string,
	allocator := context.allocator,
) -> (
	model: Model,
	err: Bmv_Error,
)
{
	file := os.open(path, {.Read}) or_return
	defer os.close(file)

	meta := read_bmv_header_and_meta(file, context.temp_allocator) or_return
	if BMV_SIZE_METATAG not_in meta {
		err = Bmv_Read_Error.MISSING_SIZE_META_ATTRIBUTE
		return
	}

	// a twinge of bit fuckery to get the meta attr values
	src_size_slice := (cast([^]i32le)raw_data(meta[BMV_SIZE_METATAG]))[:3]
	src_size := [3]i32{i32(src_size_slice[0]), i32(src_size_slice[1]), i32(src_size_slice[2])}

	// the stBn meta attr lets us define custom start/end coords
	start := [3]i32{0, 0, 0}
	end := src_size
	if BMV_STARRY_BOUNDS_METATAG in meta {
		start_end_slice := (cast([^]i32le)raw_data(meta[BMV_STARRY_BOUNDS_METATAG]))[:6]
		start = {i32(start_end_slice[0]), i32(start_end_slice[1]), i32(start_end_slice[2])}
		end = {i32(start_end_slice[3]), i32(start_end_slice[4]), i32(start_end_slice[5])}
	}

	// compression is pretty important innit
	compression := Bmv_Compression.NONE
	if BMV_COMPRESSION_METATAG in meta {
		compression = Bmv_Compression(meta[BMV_COMPRESSION_METATAG][0])
	}

	// chukabanga! we have a model
	model = new_empty_model(start, end, allocator) or_return

	// solidmsk section
	magic: [8]byte
	os.read(file, magic[:]) or_return
	if mem.compare(magic[:], transmute([]byte)string("solidmsk")) != 0 {
		err = .CORRUPTED_FILE
	}

	raw_solid_mask_len := read_int_from_file(file, u32le) or_return
	raw_solid_mask := make([]byte, raw_solid_mask_len, context.temp_allocator)
	os.read(file, raw_solid_mask) or_return

	switch compression {
	case .NONE:
		model.solid = transmute([]b8)raw_solid_mask

	case .LZ4:
		decompressed_size := lz4.decompress_safe(
			raw_data(raw_solid_mask),
			cast([^]byte)raw_data(model.solid),
			c.int(len(raw_solid_mask)),
			c.int(len(model.solid)),
		)
		if decompressed_size <= 0 {
			err = .DECOMPRESSION_FAILED
			return
		}
	}

	// attrdata sections
	for !(file_at_eof(file) or_return) {
		os.read(file, magic[:]) or_return
		if mem.compare(magic[:], transmute([]byte)string("attrdata")) != 0 {
			err = .CORRUPTED_FILE
		}

		tag: [4]byte
		os.read(file, tag[:]) or_return
		raw_data_len := read_int_from_file(file, u32le) or_return
		raw_attr_data := make([]byte, raw_data_len, context.temp_allocator)
		os.read(file, raw_attr_data) or_return

		// make sure it allocates the proper crap
		set_voxel(&model, start, tag, 0) or_return
		remove_voxel(&model, start)

		when ODIN_ENDIAN != .Little {
			#panic("TODO")
		}

		switch compression {
		case .NONE:
			model.data[tag] = mem.slice_data_cast([]u32, raw_attr_data)

		case .LZ4:
			decompressed_size := lz4.decompress_safe(
				raw_data(raw_attr_data),
				cast([^]byte)raw_data(model.data[tag]),
				c.int(len(raw_attr_data)),
				c.int(len(model.data[tag])),
			)
			if decompressed_size <= 0 {
				err = .DECOMPRESSION_FAILED
				return
			}
		}
	}

	// bmv doesn't include voxel count
	for solid in model.solid {
		if solid {
			model.voxel_count += 1
		}
	}

	return
}

// loads a Big Massive Voxels file and returns its raw metadata. the returned data must be
// freed with `free_metadata_loaded_from_bmv_file`
load_metadata_from_bmv_file :: proc(
	path: string,
	allocator := context.allocator,
) -> (
	meta: Bmv_Raw_Metadata,
	err: Bmv_Error,
)
{
	file := os.open(path, {.Read}) or_return
	defer os.close(file)

	meta = read_bmv_header_and_meta(file, allocator) or_return
	return
}

// catchy
free_metadata_loaded_from_bmv_file :: proc(meta: Bmv_Raw_Metadata, allocator := context.allocator)
{
	for _, payload in meta {
		delete(payload, allocator)
	}
	delete(meta)
}

// `meta` must be freed by the caller
@(private)
read_bmv_header_and_meta :: proc(
	file: ^os.File,
	allocator := context.allocator,
) -> (
	meta: Bmv_Raw_Metadata,
	err: Bmv_Error,
)
{
	// header
	magic: [8]byte
	os.read(file, magic[:]) or_return
	if mem.compare(magic[:], transmute([]byte)string(BMV_MAGIC)) != 0 {
		err = .CORRUPTED_FILE
		return
	}

	ver: [2]byte
	os.read(file, ver[:]) or_return
	if ver[0] != BMV_MAJOR_VERSION {
		err = .UNSUPPORTED_VERSION
		return
	}

	// metadata section
	os.read(file, magic[:]) or_return
	if mem.compare(magic[:], transmute([]byte)string("metadata")) != 0 {
		err = .CORRUPTED_FILE
		return
	}

	meta_attr_count := read_int_from_file(file, u32le) or_return
	meta = make(Bmv_Raw_Metadata, allocator)
	reserve(&meta, meta_attr_count)

	for _ in 0 ..< meta_attr_count {
		tag: [4]byte
		os.read(file, tag[:]) or_return
		length := read_int_from_file(file, u32le) or_return

		payload := make([]byte, length, allocator)
		os.read(file, payload) or_return
		meta[tag] = payload
	}

	return
}
