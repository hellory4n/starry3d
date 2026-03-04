package starrylib

import os "core:os/os2"

Bmv_Write_Error :: enum {
	OK,
}

Bmv_Error :: union #shared_nil {
	os.Error,
	Bmv_Write_Error,
}

BMV_SIZE_METATAG :: u16(0)
BMV_COMPRESSION_METATAG :: u16(1)
BMV_COPYRIGHT_METATAG :: u16(2)

// usage not recommended unless you need extensions
Bmv_Raw_Metadata :: map[u16][]byte

Bmv_Metadata :: union #no_nil {
	Bmv_Standard_Metadata,
	Bmv_Raw_Metadata,
}

Bmv_Standard_Metadata :: struct {
	copyright:             Maybe(Bmv_Copyright),
	compression_algorithm: Bmv_Compression,
}

Bmv_Compression :: enum u16 {
	NONE = 0,
	LZ4  = 1,
}

Bmv_Copyright :: struct {
	name:    string,
	author:  string,
	license: string,
	contact: string,
	year:    u32,
}

BMV_MAGIC :: "\x00bmvoxel"
BMV_MAJOR_VERSION :: u8(1)
BMV_MINOR_VERSION :: u8(1)

when ODIN_ENDIAN != .Little {
	#panic("TODO real big endian support")
}

// TODO there might be a better way to do this
bmv_size_metaprop :: proc(src: [3]i32, allocator := context.allocator) -> []byte
{
	Payload :: struct #packed {
		size_x: u32le,
		size_y: u32le,
		size_z: u32le,
	}
	#assert(size_of(Payload) == 12)
	payload := Payload {
		size_x = u32le(src.x),
		size_y = u32le(src.y),
		size_z = u32le(src.z),
	}
	return ([^]byte)(new_clone(payload, allocator))[:size_of(Payload)]
}

bmv_compression_metaprop :: proc(src: Bmv_Compression, allocator := context.allocator) -> []byte
{
	Payload :: struct #packed {
		algorithm: u16le,
	}
	#assert(size_of(Payload) == 2)
	payload := Payload {
		algorithm = u16le(src),
	}
	return ([^]byte)(new_clone(payload, allocator))[:size_of(Payload)]
}

bmv_copyright_metaprop :: proc(src: Bmv_Copyright, allocator := context.allocator) -> []byte
{
	bytes := make([dynamic]byte, allocator)

	year := u32le(src.year)
	i := ([^]byte)(&year)[:size_of(u32)]
	append(&bytes, ..i)

	strlen := u32le(len(src.name))
	i = ([^]byte)(&strlen)[:size_of(u32)]
	append(&bytes, ..i)
	append(&bytes, src.name)

	strlen = u32le(len(src.author))
	i = ([^]byte)(&strlen)[:size_of(u32)]
	append(&bytes, ..i)
	append(&bytes, src.author)

	strlen = u32le(len(src.license))
	i = ([^]byte)(&strlen)[:size_of(u32)]
	append(&bytes, ..i)
	append(&bytes, src.license)

	strlen = u32le(len(src.contact))
	i = ([^]byte)(&strlen)[:size_of(u32)]
	append(&bytes, ..i)
	append(&bytes, src.contact)

	return bytes[:]
}

// writes the model to a Big Massive Voxels file, the most massive most superior format of all time.
// write_model_to_bmv_file :: proc(
// 	path: string,
// 	model: ^Model,
// 	metadata: Bmv_Metadata = {},
// 	allocator := context.allocator,
// ) -> (
// 	err: Bmv_Error,
// )
// {
// 	// TODO this can be optimized
// 	// TODO consider not allocating every picosecond

// 	// meta my data
// 	raw_meta: Bmv_Raw_Metadata
// 	raw_meta_owned: bool

// 	switch v in metadata {
// 	case Bmv_Raw_Metadata:
// 		raw_meta = v

// 	case Bmv_Standard_Metadata:
// 		raw_meta = make(Bmv_Raw_Metadata, allocator)
// 		raw_meta_owned = true

// 		raw_meta[BMV_SIZE_METATAG] = bmv_size_metaprop(model.size)
// 		if v.compression_algorithm != .NONE {
// 			raw_meta[BMV_COMPRESSION_METATAG] = bmv_compression_metaprop(
// 				v.compression_algorithm,
// 			)
// 		}

// 		if v.copyright != nil {
// 			raw_meta[BMV_COPYRIGHT_METATAG] = bmv_copyright_metaprop(v.copyright.?)
// 		}
// 	}

// 	defer if raw_meta_owned {
// 		for tag, payload in raw_meta {
// 			delete(payload, allocator)
// 		}
// 		delete(raw_meta)
// 	}

// 	file := os.open(path, {.Write, .Create}) or_return
// 	defer os.close(file)

// 	// header
// 	os.write_string(file, "\x00bmvoxel") or_return
// 	write_int_to_file(file, BMV_MAJOR_VERSION) or_return
// 	write_int_to_file(file, BMV_MINOR_VERSION) or_return

// 	// metadata section
// 	os.write_string(file, "metadata") or_return
// 	write_int_to_file(file, u16le(len(raw_meta))) or_return
// 	for tag, payload in raw_meta {
// 		write_int_to_file(file, u16le(tag)) or_return
// 		write_int_to_file(file, u32le(len(payload))) or_return
// 		os.write(file, payload) or_return
// 	}

// 	// data section
// 	os.write_string(file, "propdata") or_return
// 	write_int_to_file(file, u32le(model.voxel_count)) or_return

// 	voxel_data := make([dynamic]byte, allocator)
// 	defer delete(voxel_data)

// 	for z in model.start.z ..< model.end.z {
// 		for y in model.start.y ..< model.end.y {
// 			for x in model.start.x ..< model.end.x {
// 				props, solid := list_voxel_props(model, {x, y, z}, allocator)
// 				if !solid {
// 					continue
// 				}

// 				// todo lmaop
// 				append(&voxel_data)
// 				for prop in props {

// 				}
// 				append(&voxel_data)
// 			}
// 		}
// 	}

// 	return
// }
