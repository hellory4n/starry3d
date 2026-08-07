/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

subset.odin - Types and functions for (mostry OpenType) font subsetting.

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
author: Maurizio M. Gavioli, 2024-10-11

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-subset.h
		https://harfbuzz.github.io/harfbuzz-hb-subset.html
*/

package	harfbuzz_subset

import 	"core:c"
//import cm "./common"
import hrfb ".."

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "../windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

HB_EXPERIMENTAL_API :: #config(HB_EXPERIMENTAL_API, false)

/*
hb-subset — Subsets font files.

Subsetting reduces the codepoint coverage of font files and removes all data that is no longer needed. A subset input
describes the desired subset. The input is provided along with a font to the subsetting operation. Output is a new font
file containing only the data specified in the input.

Currently most outline and bitmap tables are supported: glyf, CFF, CFF2, sbix, COLR, and CBDT/CBLC. This also includes
fonts with variable outlines via OpenType variations. Notably EBDT/EBLC and SVG are not supported. Layout subsetting is
supported only for OpenType Layout tables (GSUB, GPOS, GDEF). Notably subsetting of graphite or AAT tables is not yet
supported.

Fonts with graphite or AAT tables may still be subsetted but will likely need to use the retain glyph ids option and
configure the subset to pass through the layout tables untouched.
*/

//******************
// TYPES
//******************

/*
enum hb_subset_flags_t

List of boolean properties that can be configured on the subset input.

Since: 2.9.0
*/
subset_flags_t :: enum
{
	SUBSET_FLAGS_DEFAULT					= 0x00000000,	// all flags at their default value of false.
	SUBSET_FLAGS_NO_HINTING					= 0x00000001,	// If set hinting instructions will be dropped in the produced subset. Otherwise hinting instructions will be retained.
	SUBSET_FLAGS_RETAIN_GIDS				= 0x00000002,	// If set glyph indices will not be modified in the produced subset. If glyphs are dropped their indices will be retained as an empty glyph.
	SUBSET_FLAGS_DESUBROUTINIZE				= 0x00000004,	// If set and subsetting a CFF font the subsetter will attempt to remove subroutines from the CFF glyphs.
	SUBSET_FLAGS_NAME_LEGACY				= 0x00000008,	// If set non-unicode name records will be retained in the subset.
	SUBSET_FLAGS_SET_OVERLAPS_FLAG			= 0x00000010,	// If set the subsetter will set the OVERLAP_SIMPLE flag on each simple glyph.
	SUBSET_FLAGS_PASSTHROUGH_UNRECOGNIZED	= 0x00000020,	// If set the subsetter will not drop unrecognized tables and instead pass them through untouched.
	SUBSET_FLAGS_NOTDEF_OUTLINE				= 0x00000040,	// If set the notdef glyph outline will be retained in the final subset.
	SUBSET_FLAGS_GLYPH_NAMES				= 0x00000080,	// If set the PS glyph names will be retained in the final subset.
	SUBSET_FLAGS_NO_PRUNE_UNICODE_RANGES	= 0x00000100,	// If set then the unicode ranges in OS/2 will not be recalculated.
	SUBSET_FLAGS_NO_LAYOUT_CLOSURE			= 0x00000200,	// If set don't perform glyph closure on layout substitution rules (GSUB). Since: 7.2.0.
	SUBSET_FLAGS_OPTIMIZE_IUP_DELTAS		= 0x00000400,	// If set perform IUP delta optimization on the remaining gvar table's deltas. Since: 8.5.0
//#ifdef HB_EXPERIMENTAL_API
	SUBSET_FLAGS_IFTB_REQUIREMENTS  	    = 0x00000800,	// If set enforce requirements on the output subset to allow it to be used with incremental font transfer IFTB patches. Primarily, this forces all outline data to use long (32 bit) offsets. Since: EXPERIMENTAL
//#endif
}

/*
typedef struct hb_subset_input_t hb_subset_input_t;

Things that change based on the input. Characters to keep, etc.
*/
subset_input_t :: struct	{}			// opaque structure

/*
enum hb_subset_sets_t

List of sets that can be configured on the subset input.

Since: 2.9.1
*/
subset_sets_t :: enum
{
	SUBSET_SETS_GLYPH_INDEX = 0,		// the set of glyph indexes to retain in the subset.
	SUBSET_SETS_UNICODE,				// the set of unicode codepoints to retain in the subset.
	SUBSET_SETS_NO_SUBSET_TABLE_TAG,	// the set of table tags which specifies tables that should not be subsetted.
	SUBSET_SETS_DROP_TABLE_TAG,			// the set of table tags which specifies tables which will be dropped in the subset.
	SUBSET_SETS_NAME_ID,				// the set of name ids that will be retained.
	SUBSET_SETS_NAME_LANG_ID,			// the set of name lang ids that will be retained.
	SUBSET_SETS_LAYOUT_FEATURE_TAG,		// the set of layout feature tags that will be retained in the subset.
	SUBSET_SETS_LAYOUT_SCRIPT_TAG,		// the set of layout script tags that will be retained in the subset. Defaults to all tags. Since: 5.0.0
}

/*
typedef struct hb_subset_plan_t hb_subset_plan_t;

Contains information about how the subset operation will be executed. Such as mappings from the old glyph ids to the
new ones in the subset.
*/
subset_plan_t :: struct	{}				// opaque structure

/*
typedef struct
{
	unsigned int width;
	unsigned int position;
	unsigned int objidx;
} hb_subset_serialize_link_t;

Represents a link between two objects in the object graph to be serialized.

Members:
unsigned int width;		offsetSize in bytes
unsigned int position;	position of the offset field in bytes from beginning of subtable
unsigned int objidx;	index of subtable

Since: 10.2.0
*/
subset_serialize_link_t :: struct
{
	width:		c.uint,
	position:	c.uint,
	objidx:		c.uint
};

/*
typedef struct
{
char *head;
	char *tail;
	unsigned int num_real_links;
	hb_subset_serialize_link_t *real_links;
	unsigned int num_virtual_links;
	hb_subset_serialize_link_t *virtual_links;
} hb_subset_serialize_object_t;

Represents an object in the object graph to be serialized.

Members:
char *head;										start of object data
- char *tail;									end of object data
- unsigned int num_real_links;					number of offset field in the object
- hb_subset_serialize_link_t *real_links;		array of offset info
- unsigned int num_virtual_links;				number of objects that must be packed after current object in the final serialized order
- hb_subset_serialize_link_t *virtual_links;	array of virtual link info

Since: 10.2.0
*/
subset_serialize_object_t :: struct
{
	head:				^cstring,
	tail:				^cstring,
	num_real_links:		c.uint,
	real_links: 		^subset_serialize_link_t,
	num_virtual_links:	c.uint,
	virtual_links:		^subset_serialize_link_t
};

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

//******************
// FUNCTIONS
//******************

/*
hb_subset_input_t * hb_subset_input_create_or_fail (void);

Creates a new subset input object.

Returns:
- New subset input, or NULL if failed. Destroy with hb_subset_input_destroy(). [transfer full]

Since: 1.8.0
*/
subset_input_create_or_fail ::proc ()	-> ^subset_input_t ---

/*
hb_subset_input_t * hb_subset_input_reference (hb_subset_input_t *input);

Increases the reference count on input.

Inputs:
- input:	a hb_subset_input_t object.
Returns:
- input.

Since: 1.8.0
*/
subset_input_reference :: proc (input: ^subset_input_t)	-> ^subset_input_t ---

/*
void hb_subset_input_destroy (hb_subset_input_t *input);

Decreases the reference count on input , and if it reaches zero, destroys input , freeing all memory.

Inputs:
- input:	a hb_subset_input_t object.

Since: 1.8.0
*/
subset_input_destroy ::proc (input: ^subset_input_t)	---

/*
hb_bool_t hb_subset_input_set_user_data (hb_subset_input_t *input, hb_user_data_key_t *key, void *data,
	hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the given subset input object.

Inputs:
- input:	a hb_subset_input_t object.
- key:		The user-data key to set
- data:		A pointer to the user data
- destroy:	A callback to call when data is not needed anymore. [nullable]
- replace:	Whether to replace an existing data with the same key
Returns:
- true if success, false otherwise

Since: 2.9.0
*/
subset_input_set_user_data :: proc (input: ^subset_input_t, key: ^hrfb.user_data_key_t, data: rawptr,
	destroy: hrfb.destroy_func_t, replace: hrfb.bool_t)	-> hrfb.bool_t ---

/*
void * hb_subset_input_get_user_data (const hb_subset_input_t *input, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified subset input object.

Inputs:
- input:	a hb_subset_input_t object.
- key:		The user-data key to query
Returns:
- A pointer to the user data. [transfer none]

Since: 2.9.0
*/
subset_input_get_user_data :: proc (input: /*const*/ ^subset_input_t, key: ^hrfb.user_data_key_t)	-> rawptr ---

/*
void hb_subset_input_keep_everything (hb_subset_input_t *input);

Configure input object to keep everything in the font face. That is, all Unicodes, glyphs, names, layout items, glyph names, etc.

The input can be tailored afterwards by the caller.

Inputs:
- input:	a hb_subset_input_t object

Since: 7.0.0
*/
subset_input_keep_everything ::proc (input: ^subset_input_t)	---

/*
void hb_subset_input_set_flags (hb_subset_input_t *input, unsigned  value);

Sets all of the flags in the input object to the values specified by the bit field.

Inputs:
- input:	a hb_subset_input_t object.
- value:	bit field of flags
Since: 2.9.0
*/
subset_input_set_flags :: proc (input: ^subset_input_t, value: c.uint) ---

/*
hb_subset_flags_t hb_subset_input_get_flags (hb_subset_input_t *input);

Gets all of the subsetting flags in the input object.

Inputs:
- input:	a hb_subset_input_t object.
Returns:
- the subsetting flags bit field.

Since: 2.9.0
*/
subset_input_get_flags :: proc (input: subset_input_t)	-> subset_flags_t ---

/*
hb_set_t * hb_subset_input_unicode_set (hb_subset_input_t *input);

Gets the set of Unicode code points to retain, the caller should modify the set as needed.

Inputs:
- input:	a hb_subset_input_t object.
Returns:
- pointer to the hb_set_t of Unicode code points. [transfer none]

Since: 1.8.0
*/
subset_input_unicode_set :: proc (input: ^subset_input_t)	-> ^hrfb.set_t ---

/*
hb_set_t * hb_subset_input_glyph_set (hb_subset_input_t *input);

Gets the set of glyph IDs to retain, the caller should modify the set as needed.

Inputs:
- input:	a hb_subset_input_t object.
Returns:
- pointer to the hb_set_t of glyph IDs. [transfer none]

Since: 1.8.0
*/
subset_input_glyph_set ::proc (input: ^subset_input_t)	-> ^hrfb.set_t ---

/*
hb_set_t * hb_subset_input_set (hb_subset_input_t *input, hb_subset_sets_t set_type);

Gets the set of the specified type.

Inputs:
- input:	a hb_subset_input_t object.
- set_type:	a hb_subset_sets_t set type.
Returns:
- pointer to the hb_set_t of the specified type. [transfer none]

Since: 2.9.1
*/
subset_input_set :: proc (input: ^subset_input_t, set_type: subset_sets_t)	-> ^hrfb.set_t ---

/*
hb_map_t * hb_subset_input_old_to_new_glyph_mapping (hb_subset_input_t *input);

Returns a map which can be used to provide an explicit mapping from old to new glyph id's in the produced subset.
The caller should populate the map as desired. If this map is left empty then glyph ids will be automatically mapped to
new values by the subsetter. If populated, the mapping must be unique. That is no two original glyph ids can be mapped
to the same new id. Additionally, if a mapping is provided then the retain gids option cannot be enabled.

Any glyphs that are retained in the subset which are not specified in this mapping will be assigned glyph ids after the
highest glyph id in the mapping.

Note: this will accept and apply non-monotonic mappings, however this may result in unsorted Coverage tables. Such fonts
may not work for all use cases (for example ots will reject unsorted coverage tables). So it's recommended, if possible,
to supply a monotonic mapping.

Inputs:
- input:	a hb_subset_input_t object.
Returns:
- pointer to the hb_map_t of the custom glyphs ID map. [transfer none]

Since: 7.3.0
*/
subset_input_old_to_new_glyph_mapping :: proc (input: ^subset_input_t)	-> ^hrfb.map_t ---

/*
hb_bool_t hb_subset_input_pin_all_axes_to_default (hb_subset_input_t *input, hb_face_t *face);

Pin all axes to default locations in the given subset input object.

All axes in a font must be pinned. Additionally, CFF2 table, if present, will be de-subroutinized.

Inputs:
- input:	a hb_subset_input_t object.
- face:		a hb_face_t object.
Returns:
- true if success, false otherwise

Since: 8.3.1
*/
subset_input_pin_all_axes_to_default :: proc (input: ^subset_input_t, face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_subset_input_pin_axis_location (hb_subset_input_t *input, hb_face_t *face, hb_tag_t axis_tag, float axis_value);

Pin an axis to a fixed location in the given subset input object.

All axes in a font must be pinned. Additionally, CFF2 table, if present, will be de-subroutinized.

Inputs:
- input:		a hb_subset_input_t object.
- face:			a hb_face_t object.
- axis_tag:		Tag of the axis to be pinned
- axis_value:	Location on the axis to be pinned at
Returns:
- true if success, false otherwise

Since: 6.0.0
*/
subset_input_pin_axis_location :: proc (input: ^subset_input_t, face: ^hrfb.face_t, axis_tag: hrfb.tag_t, axis_value: c.float)	-> hrfb.bool_t ---

/*
hb_bool_t hb_subset_input_pin_axis_to_default (hb_subset_input_t *input, hb_face_t *face, hb_tag_t axis_tag);

Pin an axis to its default location in the given subset input object.

All axes in a font must be pinned. Additionally, CFF2 table, if present, will be de-subroutinized.

Inputs:
- input:	a hb_subset_input_t object.
- face:		a hb_face_t object.
- axis_tag:	Tag of the axis to be pinned
Returns:
- true if success, false otherwise

Since: 6.0.0
*/
subset_input_pin_axis_to_default :: proc (input: ^subset_input_t, face: ^hrfb.face_t, axis_tag: hrfb.tag_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_subset_input_get_axis_range (hb_subset_input_t *input, hb_tag_t axis_tag, float *axis_min_value,
	float *axis_max_value, float *axis_def_value);

Gets the axis range assigned by previous calls to hb_subset_input_set_axis_range.

Inputs:
- input:			a hb_subset_input_t object.
- axis_tag:			Tag of the axis
- axis_min_value:	Set to the previously configured minimum value of the axis variation range.
- axis_max_value:	Set to the previously configured maximum value of the axis variation range.
- axis_def_value:	Set to the previously configured default value of the axis variation range.
Returns:
- true if a range has been set for this axis tag, false otherwise.

Since: 8.5.0
*/
subset_input_get_axis_range :: proc (input: ^subset_input_t, axis_tag: hrfb.tag_t, axis_min_value: ^c.float,
	axis_max_value: c.float, axis_def_value: c.float)	-> hrfb.bool_t ---

/*
hb_bool_t hb_subset_input_set_axis_range (hb_subset_input_t *input, hb_face_t *face, hb_tag_t axis_tag, float axis_min_value,
	float axis_max_value, float axis_def_value);

Restricting the range of variation on an axis in the given subset input object. New min/default/max values will be
clamped if they're not within the fvar axis range.

If the fvar axis default value is not within the new range, the new default value will be changed to the new min or max
value, whichever is closer to the fvar axis default.

Note: input min value can not be bigger than input max value. If the input default value is not within the new min/max
range, it'll be clamped. Note: currently it supports gvar and cvar tables only.

Inputs:
- input:			a hb_subset_input_t object.
- face:				a hb_face_t object.
- axis_tag:			Tag of the axis
- axis_min_value: 	Minimum value of the axis variation range to set, if NaN the existing min will be used.
- axis_max_value:	Maximum value of the axis variation range to set if NaN the existing max will be used.
- axis_def_value:	Default value of the axis variation range to set, if NaN the existing default will be used.
Returns:
- true if success, false otherwise

Since: 8.5.0
*/
subset_input_set_axis_range :: proc (input: ^subset_input_t, face: ^hrfb.face_t, axis_tag: hrfb.tag_t, axis_min_value: ^c.float,
	axis_max_value: c.float, axis_def_value: c.float)	-> hrfb.bool_t ---

/*
hb_face_t * hb_subset_or_fail (hb_face_t *source, const hb_subset_input_t *input);

Subsets a font according to provided input. Returns nullptr if the subset operation fails or the face has no glyphs.

Inputs:
- source:	font face data to be subset.
- input:	input to use for the subsetting.

Since: 2.9.0
*/
subset_or_fail :: proc (source: ^hrfb.face_t, input: /*const*/ ^subset_input_t)	-> ^hrfb.face_t ---

/*
hb_subset_plan_t * hb_subset_plan_create_or_fail (hb_face_t *face, const hb_subset_input_t *input);

Computes a plan for subsetting the supplied face according to a provided input. The plan describes which tables and
glyphs should be retained.

Inputs:
- face:		font face to create the plan for.
- input:	a hb_subset_input_t input.
Returns:
- New subset plan. Destroy with hb_subset_plan_destroy(). If there is a failure creating the plan nullptr will be returned. [transfer full]

Since: 4.0.0
*/
subset_plan_create_or_fail :: proc (face: ^hrfb.face_t, input: /*const*/ ^subset_input_t)	-> ^subset_plan_t ---

/*
hb_subset_plan_t * hb_subset_plan_reference (hb_subset_plan_t *plan);

Increases the reference count on plan .

Inputs:
- plan:	a hb_subset_plan_t object.
Returns:
- plan.

Since: 4.0.0
*/
subset_plan_reference :: proc (plan: ^subset_plan_t)	-> ^subset_plan_t ---

/*
void hb_subset_plan_destroy (hb_subset_plan_t *plan);

Decreases the reference count on plan , and if it reaches zero, destroys plan , freeing all memory.

Inputs:
- plan:	a hb_subset_plan_t

Since: 4.0.0
*/
subset_plan_destroy :: proc (plan: ^subset_plan_t)	---

/*
hb_bool_t hb_subset_plan_set_user_data (hb_subset_plan_t *plan, hb_user_data_key_t *key, void *data,
* 	hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the given subset plan object.

Inputs:
- plan:		a hb_subset_plan_t object.
- key:		The user-data key to set
- data:		A pointer to the user data
- destroy:	A callback to call when data is not needed anymore. [nullable]
- replace:	Whether to replace an existing data with the same key
Returns:
- true if success, false otherwise

Since: 4.0.0
*/
subset_plan_set_user_data :: proc (plan: ^subset_plan_t, key: ^hrfb.user_data_key_t, data: rawptr,
	destroy: hrfb.destroy_func_t, replace: hrfb.bool_t)	-> hrfb.bool_t ---

/*
void * hb_subset_plan_get_user_data (const hb_subset_plan_t *plan, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified subset plan object.

Inputs:
- plan:a hb_subset_plan_t object.
- key:	The user-data key to query
Returns:
- A pointer to the user data. [transfer none]

Since: 4.0.0
*/
subset_plan_get_user_data :: proc (plan: /*const*/ ^subset_plan_t, key: ^hrfb.user_data_key_t)	-> rawptr ---

/*
hb_face_t * hb_subset_plan_execute_or_fail (hb_subset_plan_t *plan);

Executes the provided subsetting plan .

Inputs:
- plan:	a subsetting plan.
Returns:
- on success returns a reference to generated font subset. If the subsetting operation fails returns nullptr.

Since: 4.0.0
*/
subset_plan_execute_or_fail :: proc (plan: ^subset_plan_t)	-> ^hrfb.face_t ---

/*
hb_map_t * hb_subset_plan_unicode_to_old_glyph_mapping (const hb_subset_plan_t *plan);

Returns the mapping between codepoints in the original font and the associated glyph id in the original font.

Inputs:
- plan:	a subsetting plan.
Returns:
- A pointer to the hb_map_t of the mapping. [transfer none]

Since: 4.0.0
*/
subset_plan_unicode_to_old_glyph_mapping :: proc (plan: /*const*/ ^subset_plan_t)	-> ^hrfb.map_t ---

/*
hb_map_t * hb_subset_plan_new_to_old_glyph_mapping (const hb_subset_plan_t *plan);

Returns the mapping between glyphs in the subset that will be produced by plan and the glyph in the original font.

Inputs:
- plan:	a subsetting plan.
Returns:
- A pointer to the hb_map_t of the mapping. [transfer none]

Since: 4.0.0
*/
subset_plan_new_to_old_glyph_mapping :: proc (plan: /*const*/ ^subset_plan_t)	-> ^hrfb.map_t ---

/*
hb_map_t * hb_subset_plan_old_to_new_glyph_mapping (const hb_subset_plan_t *plan);

Returns the mapping between glyphs in the original font to glyphs in the subset that will be produced by plan

Inputs:
- plan:	a subsetting plan.
Returns:
- A pointer to the hb_map_t of the mapping. [transfer none]

Since: 4.0.0
*/
subset_plan_old_to_new_glyph_mapping :: proc (plan: /*const*/ ^subset_plan_t)	-> ^hrfb.map_t ---

/*
hb_face_t * hb_subset_preprocess (hb_face_t *source);

Preprocesses the face and attaches data that will be needed by the subsetter. Future subsetting operations can then use
the precomputed data to speed up the subsetting operation.

See subset-preprocessing for more information.

Note: the preprocessed face may contain sub-blobs that reference the memory backing the source hb_face_t. Therefore in
the case that this memory is not owned by the source face you will need to ensure that memory lives as long as the
returned hb_face_t.

Inputs:
- source:	a hb_face_t object.
Returns:
- a new hb_face_t.

Since: 6.0.0
*/
subset_preprocess :: proc (source: ^hrfb.face_t)	-> ^hrfb.face_t ---

/*
#ifdef HB_EXPERIMENTAL_API
HB_EXTERN hb_bool_t hb_subset_input_override_name_table (hb_subset_input_t *input, hb_ot_name_id_t name_id,
	unsigned platform_id, unsigned encoding_id, unsigned language_id, const char *name_str, int str_len);
#endif
*/

when HB_EXPERIMENTAL_API
{
	subset_input_override_name_table :: proc (input: ^subset_input_t, name_id: ot_name_id_t, platform_id: c.uint,
		encoding_id: c.uint, language_id: c.uint, name_str: cstring, str_len: c.int) -> hrbf.bool_t ---
}

/*
hb_bool_t hb_subset_axis_range_from_string (const char *str, int len, float *axis_min_value,
		float *axis_max_value, float *axis_def_value);

Parses a string into a subset axis range(min, def, max). Axis positions string is in the format
of min:def:max or min:max When parsing axis positions, empty values as meaning the existing
value for that part E.g: :300:500 Specifies min = existing, def = 300, max = 500 In the output
axis_range, if a value should be set to it's default value, then it will be set to NaN

Inputs:
- str:				a string to parse
- len:				length of str , or -1 if str is NULL terminated
- axis_min_value:	the axis min value to initialize with the parsed value. [out]
- axis_max_value:	the axis max value to initialize with the parsed value. [out]
- axis_def_value:	the axis default value to initialize with the parse value. [out]
Returns:
- true if str is successfully parsed, false otherwise

Since: 10.2.0
*/
subset_axis_range_from_string :: proc (str: cstring, len: c.int, axis_min_value: ^c.float,
	axis_max_value: ^c.float, axis_def_value: ^c.float) -> hrfb.bool_t ---

/*
void hb_subset_axis_range_to_string (hb_subset_input_t *input, hb_tag_t axis_tag, char *buf, unsigned  size);

Converts an axis range into a NULL-terminated string in the format understood by
hb_subset_axis_range_from_string(). The client in responsible for allocating big
enough size for buf , 128 bytes is more than enough.

Inputs:
- input:	a hb_subset_input_t object.
- axis_tag:	an axis to convert
- buf:		output string. [array length=size][out caller-allocates]
- size:		the allocated size of buf

Since: 10.2.0
*/
subset_axis_range_to_string :: proc(input: ^subset_input_t, axis_tag: hrfb.tag_t, buf: cstring, size: c.uint) ---

/*
hb_blob_t * hb_subset_serialize_or_fail (hb_tag_t table_tag, hb_subset_serialize_object_t *hb_objects, unsigned  num_hb_objs);

Given the input object graph info, repack a table to eliminate offset overflows and serialize it
into a continuous array of bytes. A nullptr is returned if the serializing attempt fails. Table
specific optimizations (eg. extension promotion in GSUB/GPOS) may be performed. Passing HB_TAG_NONE
will disable table specific optimizations.

Inpyts:
- table_tag:	tag of the table being packed, needed to allow table specific optimizations.
- hb_objects:	raw array of struct hb_subset_serialize_object_t, which provides object graph info
- num_hb_objs:	number of hb_subset_serialize_object_t in the hb_objects array.

Since: 10.2.0
*/
subset_serialize_or_fail :: proc (table_tag: hrfb.tag_t, hb_objects: ^subset_serialize_object_t, num_hb_objs: c.uint) -> ^hrfb.blob_t ---

}
