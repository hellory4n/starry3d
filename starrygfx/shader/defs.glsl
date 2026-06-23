#version 430 core

#define MATERIAL_TYPE_FLOAT 0
#define MATERIAL_TYPE_INT 1
#define MATERIAL_TYPE_VEC2 2
#define MATERIAL_TYPE_VEC3 3
#define MATERIAL_TYPE_VEC4 4
#define MATERIAL_TYPE_IVEC2 5
#define MATERIAL_TYPE_IVEC3 6
#define MATERIAL_TYPE_IVEC4 7

struct Material_Entry {
	// union
	ivec4 data;
	ivec2 tag;
};

#define MATERIAL_TYPE_BLINN_PHONG 0

struct Material {
	Material_Entry entries[16];
	int type;
};

Material_Entry material_get(Material material, ivec2 tag)
{
	for (int i = 0; i < material.entries.length(); i++) {
		Material_Entry entry = material.entries[i];
		if (entry.tag == tag) {
			return entry;
		}
	}
	return Material_Entry();
}
