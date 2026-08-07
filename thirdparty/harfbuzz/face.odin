/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

face.odin - Types and functions for managing typefaces.

The HarfBuzz API itself is copyright of HarfBuzz copyright holders
Copyright for binding coding of (c) 2024, Maurizio M. Gavioli and contributors

LICENSING ("2-Clause BSD License a.k.a. Simplified BSD License a.k.a. FreeBSD License")

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1) Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2) Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(c) 2024-2026, Maurizio M. Gavioli and contributors
author: Maurizio M. Gavioli, 2024-07-26

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-face.h
		https://harfbuzz.github.io/harfbuzz-hb-face.html
*/

/*
hb-face — Font face objects

A font face is an object that represents a single face from within a font family.

More precisely, a font face represents a single face in a binary font file. Font faces are typically built from a binary
blob and a face index. Font faces are used to create fonts.

A font face can be created from a binary blob using hb_face_create(). The face index is used to select a face from a
binary blob that contains multiple faces. For example, a binary blob that contains both a regular and a bold face can
be used to create two font faces, one for each face index.
*/

package harfbuzz

import "core:c"
//import cm "./common"

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

//******************
// TYPES
//******************

/*
typedef struct hb_face_t hb_face_t;

Data type for holding font faces.
*/
face_t :: struct {}							// opaque structure


/**
 * typedef hb_blob_t * (*hb_reference_table_func_t)  (hb_face_t *face, hb_tag_t tag, void *user_data);
 * 
 * Callback function for hb_face_create_for_tables().
 * -face		an hb_face_t to reference table for
 * -tag			the tag of the table to reference
 * -user_data	User data pointer passed by the caller
 * -Returns		(transfer full): A pointer to the tag table within face
 *
 * Since: 0.9.2
 */
reference_table_func_t	:: #type proc "c" (face: ^face_t, tag: tag_t, user_data: rawptr)	-> ^blob_t

//******************
// VERSION 10
//******************

/*
unsigned int (*hb_get_table_tags_func_t) (const hb_face_t *face, unsigned int start_offset,
	unsigned int *table_count, hb_tag_t *table_tags, void *user_data);

Callback function for hb_face_get_table_tags().

Inputs:
- face:			A face object
- start_offset:	The index of first table tag to retrieve
- table_count:	Input = the maximum number of table tags to return; Output = the actual number of table tags returned (may be zero). [inout]
- table_tags:	The array of table tags found. [out][array length=table_count]
- user_data:	User data pointer passed by the caller
Returns:
- Total number of tables, or zero if it is not possible to list

Since: 10.0.0
*/
get_table_tags_func_t :: #type proc "c" (face: /*const*/ ^face_t, start_offset: c.uint,
	table_count: ^c.uint, table_tags: [^]tag_t, user_data: rawptr)	-> c.uint

//******************
// FUNCTIONS
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
unsigned int hb_face_count (hb_blob_t *blob);

Fetches the number of faces in a blob.
- blob		a blob.
- Returns	Number of faces in blob

Since: 1.7.7
*/
face_count	:: proc(blob: ^blob_t) -> c.int ---

/*
hb_face_t * hb_face_create (hb_blob_t *blob, unsigned int index);

Constructs a new face object from the specified blob and a face index into that blob.

The face index is used for blobs of file formats such as TTC and DFont that can contain more than one face. Face indices
within such collections are zero-based.

Note: If the blob font format is not a collection, index is ignored. Otherwise, only the lower 16-bits of index are used.
The unmodified index can be accessed via hb_face_get_index().

Note: The high 16-bits of index, if non-zero, are used by hb_font_create() to load named-instances in variable fonts.
See hb_font_create() for details.
- blob		hb_blob_t to work upon
- index		The index of the face within blob
- Returns	The new face object. [transfer full]

Since: 0.9.2
*/
face_create	:: proc(blob: ^blob_t, index: c.uint)	-> ^face_t ---

/*
hb_face_t * hb_face_create_for_tables (hb_reference_table_func_t reference_table_func, void *user_data, hb_destroy_func_t destroy);

Variant of hb_face_create(), built for those cases where it is more convenient to provide data for individual tables
instead of the whole font data. With the caveat that hb_face_get_table_tags() does not currently work with faces
created this way.

Creates a new face object from the specified user_data and reference_table_func, with the destroy callback.

- reference_table_func	Table-referencing function. [closure user_data][destroy destroy][scope notified]
- user_data				A pointer to the user data
- destroy				A callback to call when data is not needed anymore. [nullable]
- Returns				The new face object. [transfer full]

Since: 0.9.2
*/
face_create_for_tables	:: proc(reference_table_func: reference_table_func_t, user_data: rawptr, destroy: destroy_func_t)	-> ^face_t ---

/*
hb_face_t * hb_face_get_empty (void);

Fetches the singleton empty face object.

- Returns	The empty face object. [transfer full]

Since: 0.9.2
*/
face_get_empty	::proc()	-> ^face_t ---

/*
hb_face_t * hb_face_reference (hb_face_t *face);

Increases the reference count on a face object.

- face		A face object
- Returns	The face object

Since: 0.9.2
*/
face_reference	:: proc(face: ^face_t)	-> ^face_t ---

/*
void hb_face_destroy (hb_face_t *face);

Decreases the reference count on a face object. When the reference count reaches zero, the face is destroyed, freeing all memory.

- face		A face object

Since: 0.9.2
*/
face_destroy	:: proc(face: ^face_t)	---

/*
hb_bool_t hb_face_set_user_data (hb_face_t *face, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the given face object.

- face		A face object
- key		The user-data key to set
- data		A pointer to the user data
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 0.9.2
*/
face_set_user_data	:: proc(face: ^face_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_face_get_user_data (const hb_face_t *face, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified face object.

- face		A face object
- key		The user-data key to query
- Returns	A pointer to the user data. [transfer none]

Since: 0.9.2
*/
face_get_user_data	:: proc(face: /*const*/ ^face_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_face_make_immutable (hb_face_t *face);

Makes the given face object immutable.

- face		A face object

Since: 0.9.2
*/
face_make_immutable	:: proc(face: ^face_t)	---

/*
hb_bool_t hb_face_is_immutable (const hb_face_t *face);

Tests whether the given face object is immutable.

- face		A face object
- Returns	true is face is immutable, false otherwise

Since: 0.9.2
*/
face_is_immutable	:: proc(face: /*const*/ ^face_t)	-> bool_t ---

/*
unsigned int hb_face_get_table_tags (const hb_face_t *face, unsigned int start_offset, unsigned int *table_count, hb_tag_t *table_tags);

Fetches a list of all table tags for a face, if possible. The list returned will begin at the offset provided

- face			A face object
- start_offset	The index of first table tag to retrieve
- table_count	Input = the maximum number of table tags to return; Output = the actual number of table tags returned (may be zero). [inout]
- table_tags	The array of table tags found. [out][array length=table_count]
- Returns		Total number of tables, or zero if it is not possible to list

Since: 1.6.0
*/
face_get_table_tags	:: proc(face: /*const*/ ^face_t, start_offset: c.uint, table_count: ^c.uint, table_tags: [^]tag_t)	-> c.uint ---

/*
void hb_face_set_glyph_count (hb_face_t *face, unsigned int glyph_count);

Sets the glyph count for a face object to the specified value. This API is used in rare circumstances.

- face			A face object
- glyph_count	The glyph-count value to assign

Since: 0.9.7
*/
face_set_glyph_count	:: proc(face: ^face_t, glyph_count: c.uint)	---

/*
unsigned int hb_face_get_glyph_count (const hb_face_t *face);

Fetches the glyph-count value of the specified face object.

- face		A face object
- Returns	The glyph-count value of face

Since: 0.9.7
*/
face_get_glyph_count	:: proc(face: /*const*/ ^face_t)	-> c.uint ---

/*
void hb_face_set_index (hb_face_t *face, unsigned int index);

Assigns the specified face-index to face . Fails if the face is immutable.
Note: changing the index has no effect on the face itself This only changes the value returned by hb_face_get_index().

- face		A face object
- index		The index to assign

Since: 0.9.2
*/
face_set_index	:: proc(face: ^face_t, index: c.uint)	---

/*
unsigned int hb_face_get_index (const hb_face_t *face);

Fetches the face-index corresponding to the given face.
Note: face indices within a collection are zero-based.

- face		A face object
- Returns	The index of face.

Since: 0.9.2
*/
face_get_index	:: proc(face: /*const*/ ^face_t)	-> c.uint ---

/*
void hb_face_set_upem (hb_face_t *face, unsigned int upem);

Sets the units-per-em (upem) for a face object to the specified value. This API is used in rare circumstances.

- face		A face object
- upem		The units-per-em value to assign

Since: 0.9.2
*/
face_set_upem	:: proc(face: ^face_t, upem: c.uint)	---

/*
unsigned int hb_face_get_upem (const hb_face_t *face);

Fetches the units-per-em (UPEM) value of the specified face object.

Typical UPEM values for fonts are 1000, or 2048, but any value in between 16 and 16,384 is allowed for OpenType fonts.

- face		A face object
- Returns	The upem value of face

Since: 0.9.2
*/
face_get_upem	:: proc(face: /*const*/ ^face_t)	-> c.uint ---

/*
hb_blob_t * hb_face_reference_blob (hb_face_t *face);

Fetches a pointer to the binary blob that contains the specified face. Returns an empty blob if referencing face data is not possible.

- face		A face object
- Returns	A pointer to the blob for face. [transfer full]

Since: 0.9.2
*/
face_reference_blob	:: proc(face: ^face_t)	-> ^blob_t ---

/*
hb_blob_t * hb_face_reference_table (const hb_face_t *face, hb_tag_t tag);

Fetches a reference to the specified table within the specified face.

Inputs:
- face		A face object
- tag		The hb_tag_t of the table to query
Returns:
A pointer to the tag table within face. [transfer full]

Since: 0.9.2
*/
face_reference_table	:: proc(face: /*const*/ ^face_t, tag: tag_t)	-> ^blob_t ---

/*
void hb_face_collect_unicodes (hb_face_t *face, hb_set_t *out);

Collects all of the Unicode characters covered by face and adds them to the hb_set_t set out .

- face		A face object
- out		The set to add Unicode characters to. [out]

Since: 1.9.0
*/
face_collect_unicodes	:: proc(face: ^face_t, out: ^set_t)	---

/*
void hb_face_collect_nominal_glyph_mapping (hb_face_t *face, hb_map_t *mapping, hb_set_t *unicodes);

Collects the mapping from Unicode characters to nominal glyphs of the face , and optionally all of the Unicode characters covered by face.

- face		A face object
- mapping	The map to add Unicode-to-glyph mapping to. [out]
- unicodes	The set to add Unicode characters to, or NULL. [nullable][out]

Since: 7.0.0
*/
face_collect_nominal_glyph_mapping	:: proc(face: ^face_t, mapping: ^map_t, unicodes: ^set_t)	---

/*
void hb_face_collect_variation_selectors (hb_face_t *face, hb_set_t *out);

Collects all Unicode "Variation Selector" characters covered by face and adds them to the hb_set_t set out.

- face		A face object
- out		The set to add Variation Selector characters to. [out]

Since: 1.9.0
*/
face_collect_variation_selectors	:: proc(face: ^face_t, out: ^set_t)	---

/*
void hb_face_collect_variation_unicodes (hb_face_t *face, hb_codepoint_t variation_selector, hb_set_t *out);

Collects all Unicode characters for variation_selector covered by face and adds them to the hb_set_t set out.

- face					A face object
- variation_selector	The Variation Selector to query
- out					The set to add Unicode characters to. [out]

Since: 1.9.0
*/
face_collect_variation_unicodes	:: proc(face: ^face_t, variation_selector: codepoint_t, out: ^set_t)	---

/*
hb_face_t * hb_face_builder_create (void);

Creates a hb_face_t that can be used with hb_face_builder_add_table(). After tables are added to the face, it can be
compiled to a binary font file by calling hb_face_reference_blob().

- Returns	New face. [transfer full]

Since: 1.9.0
*/
face_builder_create	:: proc()	-> ^face_t ---

/*
hb_bool_t hb_face_builder_add_table (hb_face_t *face, hb_tag_t tag, hb_blob_t *blob);

Add table for tag with data provided by blob to the face. face must be created using hb_face_builder_create().

- face		A face object created with hb_face_builder_create()
- tag		The hb_tag_t of the table to add
- blob		The blob containing the table data to add

Since: 1.9.0
*/
face_builder_add_table	:: proc(face: ^face_t, tag: tag_t, blob: ^blob_t)	-> bool_t ---

/*
void hb_face_builder_sort_tables (hb_face_t *face, const hb_tag_t *tags);

Set the ordering of tables for serialization. Any tables not specified in the tags list will be ordered after the tables
in tags, ordered by the default sort ordering.

- face		A face object created with hb_face_builder_create()
- tags		ordered list of table tags terminated by HB_TAG_NONE. [array zero-terminated=1]

Since: 5.3.0
*/
face_builder_sort_tables	:: proc(face: ^face_t, tags: /*const*/ [^]tag_t)	---

//******************
// VERSION 10
//******************

/*
void hb_face_set_get_table_tags_func (hb_face_t *face, hb_get_table_tags_func_t func, void *user_data,
	hb_destroy_func_t destroy);

Sets the table-tag-fetching function for the specified face object.

Inputs:
- face:			A face object
- func:			The table-tag-fetching function. [closure user_data][destroy destroy][scope notified]
- user_data:	A pointer to the user data, to be destroyed by destroy when not needed anymore
- destroy:		A callback to call when func is not needed anymore. [nullable]

Since: 10.0.0
*/
face_set_get_table_tags_func :: proc (face: ^face_t, func: get_table_tags_func_t, user_data: rawptr,
	destroy: destroy_func_t)	---

/*
hb_face_t * hb_face_create_or_fail (hb_blob_t *blob, unsigned int index);

Like hb_face_create(), but returns NULL if the blob data contains no usable font face at the specified index.

Inputs:
- blob		hb_blob_t to work upon
- index		The index of the face within blob
Returns:
- The new face object, or NULL if no face is found at the specified index. [transfer full]

Since: 10.1.0
*/
face_create_or_fail :: proc (blob: ^blob_t, index: c.uint)	-> ^face_t ---

/*
hb_face_t * hb_face_create_from_file_or_fail (const char *file_name, unsigned int index);

A thin wrapper around hb_blob_create_from_file_or_fail() followed by hb_face_create_or_fail().

Inputs:
- file_name:	A font filename
- index:		The index of the face within the file
Returns:
- The new face object, or NULL if no face is found at the specified index or the file cannot be read. [transfer full]

Since: 10.1.0
*/
face_create_from_file_or_fail :: proc (file_name: cstring, index: c.uint)	-> ^face_t ---

/*
hb_face_t * hb_face_create_from_file_or_fail_using (const char *file_name, unsigned int index, const char *loader_name);

A thin wrapper around the face loader functions registered with HarfBuzz. If loader_name is NULL or the empty string,
the first available loader is used.

For example, the FreeType ("ft") loader might be able to load WOFF and WOFF2 files if FreeType is built with those
features, whereas the OpenType ("ot") loader will not.

Inputs:
- file_name:	A font filename
- index:		The index of the face within the file
- loader_name:	The name of the loader to use, or NULL. [nullable]
Returns:
- The new face object, or NULL if the file cannot be read or the loader fails to load the face. [transfer full]

Since: 11.0.0
*/

face_create_from_file_or_fail_using :: proc (file_name: cstring, index: c.uint, loader_name: cstring) -> ^face_t ---

/*
hb_face_t * hb_face_create_or_fail_using (hb_blob_t *blob, unsigned int index, const char *loader_name);

A thin wrapper around the face loader functions registered with HarfBuzz. If loader_name is NULL or
the empty string, the first available loader is used.

For example, the FreeType ("ft") loader might be able to load WOFF and WOFF2 files if FreeType is
built with those features, whereas the OpenType ("ot") loader will not.

Inputs:
- blob:			hb_blob_t to work upon
- index:		The index of the face within blob
- loader_name:	The name of the loader to use, or NULL. [nullable]
Returns:
- The new face object, or NULL if the loader fails to load the face. [transfer full]

Since: 11.0.0
*/
face_create_or_fail_using :: proc (blob: ^blob_t, index: c.uint, loader_name: cstring) -> ^face_t ---

/*
const char ** hb_face_list_loaders (void);

Retrieves the list of face loaders supported by HarfBuzz.

Returns:
- a NULL-terminated array of supported face loaders constant strings. The returned array is owned
		by HarfBuzz and should not be modified or freed. [transfer none][array zero-terminated=1]

Since: 11.0.0
*/
face_list_loaders :: proc()	-> [^]cstring ---

}
