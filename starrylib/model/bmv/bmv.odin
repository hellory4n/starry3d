/*
The reference implementation for the BMV file format. Incomplete!
*/
package bmv

import "core:c"
import glm "core:math/linalg/glsl"
import "core:mem"
import "core:os"
import "vendor:compress/lz4"
import model ".."
import st "../.."

// TODO this might be a shitty reference implementation because it heavily depends
// on model.Model working the way it works

MAGIC :: "\x00bmvoxel"
MAJOR_VERSION :: u8(0)
MINOR_VERSION :: u8(6)

// usage not recommended unless you need extensions
Raw_Metadata :: map[st.Tag][]byte

Metadata :: union #no_nil {
	Standard_Metadata,
	Raw_Metadata,
}

Standard_Metadata :: struct {
	compression_algorithm: Compression,
}

Compression :: enum u8 {
	LZ4  = 0,
	NONE = 255,
}

SIZE_METATAG := st.tag("size")
COMPRESSION_METATAG := st.tag("cmps")
STARRY_BOUNDS_METATAG := st.tag("stBn")

Write_Error :: enum {
	OK,
	INVALID_SIZE,
	// only applies if using raw metadata
	MISSING_SIZE_META_ATTRIBUTE,
	COMPRESSION_FAILED,
}

Read_Error :: enum {
	OK,
	UNSUPPORTED_VERSION,
	CORRUPTED_FILE,
	MISSING_SIZE_META_ATTRIBUTE,
	DECOMPRESSION_FAILED,
}

Error :: union #shared_nil {
	os.Error,
	Write_Error,
	Read_Error,
	model.Init_Error,
	model.Set_Voxel_Error,
}

// writes the model to a Big Massive Voxels file, the most massive most superior format of all time.
write_to_file :: proc(
	path: string,
	model: ^model.Model,
	metadata: Metadata = {},
) -> (
	err: Error,
)
{
	file := os.open(path, {.Write, .Create}) or_return
	defer os.close(file)

	// header
	os.write_string(file, MAGIC) or_return
	st.write_int_to_file(file, MAJOR_VERSION) or_return
	st.write_int_to_file(file, MINOR_VERSION) or_return

	// metadata section
	os.write_string(file, "metadata") or_return

	switch md in metadata {
	case Standard_Metadata:
		count := 2
		if md.compression_algorithm != .NONE {
			count += 1
		}
		st.write_int_to_file(file, u32le(count))

		// size attr
		if glm.any(glm.lessThanEqual(model.size, [3]i32{0, 0, 0})) {
			return .INVALID_SIZE
		}
		os.write(file, SIZE_METATAG[:]) or_return
		st.write_int_to_file(file, u32le(12)) or_return // len
		st.write_int_to_file(file, u32le(model.size.x)) or_return
		st.write_int_to_file(file, u32le(model.size.y)) or_return
		st.write_int_to_file(file, u32le(model.size.z)) or_return

		// starry bounds attribute
		os.write(file, STARRY_BOUNDS_METATAG[:]) or_return
		st.write_int_to_file(file, u32le(24)) or_return // len
		st.write_int_to_file(file, u32le(model.start.x)) or_return
		st.write_int_to_file(file, u32le(model.start.y)) or_return
		st.write_int_to_file(file, u32le(model.start.z)) or_return
		st.write_int_to_file(file, u32le(model.end.x)) or_return
		st.write_int_to_file(file, u32le(model.end.y)) or_return
		st.write_int_to_file(file, u32le(model.end.z)) or_return

		// compression attr
		if md.compression_algorithm != .NONE {
			os.write(file, COMPRESSION_METATAG[:]) or_return
			st.write_int_to_file(file, u32le(1)) or_return // len
			st.write_int_to_file(file, u8(md.compression_algorithm))
		}

	case Raw_Metadata:
		if SIZE_METATAG not_in md {
			return Write_Error.MISSING_SIZE_META_ATTRIBUTE
		}

		st.write_int_to_file(file, u32le(len(md))) or_return
		for tag, val in md {
			tag := tag
			os.write(file, tag[:]) or_return
			st.write_int_to_file(file, u32le(len(val))) or_return
			os.write(file, val) or_return
		}
	}

	compression: Compression
	switch md in metadata {
	case Standard_Metadata:
		compression = md.compression_algorithm
	case Raw_Metadata:
		compression = Compression(
			(cast([^]u16le)raw_data(md[COMPRESSION_METATAG]))[0],
		)
	}

	// solid mask section
	os.write_string(file, "solidmsk") or_return

	switch compression {
	case .NONE:
		// it's very convenient when you're the one that designed the format
		st.write_int_to_file(file, u32le(st.area(model.size))) or_return
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
		st.write_int_to_file(file, u32le(compressed_size)) or_return
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
			st.write_int_to_file(file, u32le(st.area(model.size) * size_of(u32))) or_return
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
			st.write_int_to_file(file, u32le(compressed_size)) or_return
			os.write(file, compressed) or_return
		}
	}

	return
}

// reads a model from a Big Massive Voxels file, the most massive most superior format of all time.
load_from_file :: proc(
	path: string,
	allocator := context.allocator,
) -> (
	m: model.Model,
	err: Error,
)
{
	file := os.open(path, {.Read}) or_return
	defer os.close(file)

	meta := read_header_and_meta(file, context.temp_allocator) or_return
	if SIZE_METATAG not_in meta {
		err = Read_Error.MISSING_SIZE_META_ATTRIBUTE
		return
	}

	// a twinge of bit fuckery to get the meta attr values
	src_size_slice := (cast([^]i32le)raw_data(meta[SIZE_METATAG]))[:3]
	src_size := [3]i32{i32(src_size_slice[0]), i32(src_size_slice[1]), i32(src_size_slice[2])}

	// the stBn meta attr lets us define custom start/end coords
	start := [3]i32{0, 0, 0}
	end := src_size
	if STARRY_BOUNDS_METATAG in meta {
		start_end_slice := (cast([^]i32le)raw_data(meta[STARRY_BOUNDS_METATAG]))[:6]
		start = {i32(start_end_slice[0]), i32(start_end_slice[1]), i32(start_end_slice[2])}
		end = {i32(start_end_slice[3]), i32(start_end_slice[4]), i32(start_end_slice[5])}
	}

	// compression is pretty important innit
	compression := Compression.NONE
	if COMPRESSION_METATAG in meta {
		compression = Compression(meta[COMPRESSION_METATAG][0])
	}

	// chukabanga! we have a model
	m = model.new_empty(start, end, allocator) or_return

	// solidmsk section
	magic: [8]byte
	os.read(file, magic[:]) or_return
	if mem.compare(magic[:], transmute([]byte)string("solidmsk")) != 0 {
		err = .CORRUPTED_FILE
	}

	raw_solid_mask_len := st.read_int_from_file(file, u32le) or_return
	raw_solid_mask := make([]byte, raw_solid_mask_len, context.temp_allocator)
	os.read(file, raw_solid_mask) or_return

	switch compression {
	case .NONE:
		copy(m.solid, transmute([]b8)raw_solid_mask)

	case .LZ4:
		decompressed_size := lz4.decompress_safe(
			raw_data(raw_solid_mask),
			cast([^]byte)raw_data(m.solid),
			c.int(len(raw_solid_mask)),
			c.int(len(m.solid)),
		)
		if decompressed_size <= 0 {
			err = .DECOMPRESSION_FAILED
			return
		}
	}

	// attrdata sections
	for !(st.is_file_at_eof(file) or_return) {
		os.read(file, magic[:]) or_return
		if mem.compare(magic[:], transmute([]byte)string("attrdata")) != 0 {
			err = .CORRUPTED_FILE
		}

		tag: st.Tag
		os.read(file, tag[:]) or_return
		raw_data_len := st.read_int_from_file(file, u32le) or_return
		raw_attr_data := make([]byte, raw_data_len, context.temp_allocator)
		os.read(file, raw_attr_data) or_return

		model.reserve_tag(&m, tag) or_return

		when ODIN_ENDIAN != .Little {
			#panic("TODO")
		}

		switch compression {
		case .NONE:
			copy(mem.slice_to_bytes(m.data[tag]), raw_attr_data)

		case .LZ4:
			decompressed_size := lz4.decompress_safe(
				raw_data(raw_attr_data),
				cast([^]byte)raw_data(m.data[tag]),
				c.int(len(raw_attr_data)),
				c.int(len(m.data[tag])),
			)
			if decompressed_size <= 0 {
				err = .DECOMPRESSION_FAILED
				return
			}
		}
	}

	// bmv doesn't include voxel count
	for solid in m.solid {
		if solid {
			m.voxel_count += 1
		}
	}

	return
}

// loads a Big Massive Voxels file and returns its raw metadata. the returned data must be
// freed with `free_metadata_loaded_from_bmv_file`
load_metadata_from_file :: proc(
	path: string,
	allocator := context.allocator,
) -> (
	meta: Raw_Metadata,
	err: Error,
)
{
	file := os.open(path, {.Read}) or_return
	defer os.close(file)

	meta = read_header_and_meta(file, allocator) or_return
	return
}

// catchy
free_metadata_from_file :: proc(meta: Raw_Metadata, allocator := context.allocator)
{
	for _, payload in meta {
		delete(payload, allocator)
	}
	delete(meta)
}

// `meta` must be freed by the caller
@(private)
read_header_and_meta :: proc(
	file: ^os.File,
	allocator := context.allocator,
) -> (
	meta: Raw_Metadata,
	err: Error,
)
{
	// header
	magic: [8]byte
	os.read(file, magic[:]) or_return
	if mem.compare(magic[:], transmute([]byte)string(MAGIC)) != 0 {
		err = .CORRUPTED_FILE
		return
	}

	ver: [2]byte
	os.read(file, ver[:]) or_return
	if ver[0] != MAJOR_VERSION {
		err = .UNSUPPORTED_VERSION
		return
	}

	// metadata section
	os.read(file, magic[:]) or_return
	if mem.compare(magic[:], transmute([]byte)string("metadata")) != 0 {
		err = .CORRUPTED_FILE
		return
	}

	meta_attr_count := st.read_int_from_file(file, u32le) or_return
	meta = make(Raw_Metadata, allocator)
	reserve(&meta, meta_attr_count)

	for _ in 0 ..< meta_attr_count {
		tag: st.Tag
		os.read(file, tag[:]) or_return
		length := st.read_int_from_file(file, u32le) or_return

		payload := make([]byte, length, allocator)
		os.read(file, payload) or_return
		meta[tag] = payload
	}

	return
}
