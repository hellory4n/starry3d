package stmodel

// Returns a cuboid mesh with the selected size. The returned mesh has no material.
gen_cube_mesh :: proc(size: [3]f32, allocator := context.allocator) -> (mesh: Mesh)
{
	width := size.x
	height := size.y
	length := size.z
	
	// odinfmt: disable
	vertices := [?]f32{
		-width/2, -height/2, length/2,
		width/2, -height/2, length/2,
		width/2, height/2, length/2,
		-width/2, height/2, length/2,
		-width/2, -height/2, -length/2,
		-width/2, height/2, -length/2,
		width/2, height/2, -length/2,
		width/2, -height/2, -length/2,
		-width/2, height/2, -length/2,
		-width/2, height/2, length/2,
		width/2, height/2, length/2,
		width/2, height/2, -length/2,
		-width/2, -height/2, -length/2,
		width/2, -height/2, -length/2,
		width/2, -height/2, length/2,
		-width/2, -height/2, length/2,
		width/2, -height/2, -length/2,
		width/2, height/2, -length/2,
		width/2, height/2, length/2,
		width/2, -height/2, length/2,
		-width/2, -height/2, -length/2,
		-width/2, -height/2, length/2,
		-width/2, height/2, length/2,
		-width/2, height/2, -length/2
	};

	texcoords := [?]f32{
		0.0, 0.0,
		1.0, 0.0,
		1.0, 1.0,
		0.0, 1.0,
		1.0, 0.0,
		1.0, 1.0,
		0.0, 1.0,
		0.0, 0.0,
		0.0, 1.0,
		0.0, 0.0,
		1.0, 0.0,
		1.0, 1.0,
		1.0, 1.0,
		0.0, 1.0,
		0.0, 0.0,
		1.0, 0.0,
		1.0, 0.0,
		1.0, 1.0,
		0.0, 1.0,
		0.0, 0.0,
		0.0, 0.0,
		1.0, 0.0,
		1.0, 1.0,
		0.0, 1.0
	};

	normals := [?]f32{
		0.0, 0.0, 1.0,
		0.0, 0.0, 1.0,
		0.0, 0.0, 1.0,
		0.0, 0.0, 1.0,
		0.0, 0.0,-1.0,
		0.0, 0.0,-1.0,
		0.0, 0.0,-1.0,
		0.0, 0.0,-1.0,
		0.0, 1.0, 0.0,
		0.0, 1.0, 0.0,
		0.0, 1.0, 0.0,
		0.0, 1.0, 0.0,
		0.0,-1.0, 0.0,
		0.0,-1.0, 0.0,
		0.0,-1.0, 0.0,
		0.0,-1.0, 0.0,
		1.0, 0.0, 0.0,
		1.0, 0.0, 0.0,
		1.0, 0.0, 0.0,
		1.0, 0.0, 0.0,
		-1.0, 0.0, 0.0,
		-1.0, 0.0, 0.0,
		-1.0, 0.0, 0.0,
		-1.0, 0.0, 0.0
	};
	// odinfmt: enable

	mesh.vertices = make([dynamic]Vertex, 24, allocator)
	for i in 0 ..< 24 {
		mesh.vertices[i] = Vertex {
			position = vertices[i * 3],
			normal   = normals[i * 3],
			uv       = texcoords[i * 2],
		}
	}

	mesh.indices = make([dynamic]u32, 36, allocator)
	k: u32 = 0
	for i := 0; i < 36; i += 6 {
		mesh.indices[i] = 4 * k
		mesh.indices[i + 1] = 4 * k + 1
		mesh.indices[i + 2] = 4 * k + 2
		mesh.indices[i + 3] = 4 * k
		mesh.indices[i + 4] = 4 * k + 2
		mesh.indices[i + 5] = 4 * k + 3

		k += 1
	}

	return mesh
}
