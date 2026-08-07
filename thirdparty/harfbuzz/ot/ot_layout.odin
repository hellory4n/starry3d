/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

ot_layout.odin - Types and functions for OpenType compatibility - Mathematics layout data.

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

(c) 2024-26, Maurizio M. Gavioli and contributors
author: Maurizio M. Gavioli, 2024-09-24

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-layout.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-layout.html
*/

package	harfbuzz_ot

import 	"core:c"
//import cm "./common"
import hrfb ".."

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb_ot "../windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb_ot "system:harfbuzz"	}

/*******************
hb-ot-layout — OpenType Layout

Functions for querying OpenType Layout features in the font face. See the OpenType specification for details.
*******************/

//******************
// TYPES
//******************

// #define HB_OT_MAX_TAGS_PER_LANGUAGE 3u
// Since: 2.0.0
MAX_TAGS_PER_LANGUAGE	: u32	: 3	// Maximum number of OpenType tags that can correspond to a give hb_language_t.

// #define HB_OT_MAX_TAGS_PER_SCRIPT 3u
// Since: 2.0.0
MAX_TAGS_PER_SCRIPT		: u32	: 3	// Maximum number of OpenType tags that can correspond to a give hb_script_t.

// #define HB_OT_TAG_DEFAULT_LANGUAGE HB_TAG ('d', 'f', 'l', 't')
TAG_DEFAULT_LANGUAGE	: hrfb.tag_t	: ('d' << 24) | ('f' << 16) | ('l' << 8) | 't' // dflt OpenType language tag, dflt. Not a valid language tag, but some fonts mistakenly use it.

// #define HB_OT_TAG_DEFAULT_SCRIPT HB_TAG ('D', 'F', 'L', 'T')
TAG_DEFAULT_SCRIPT	: hrfb.tag_t	: ('D' << 24) | ('F' << 16) | ('L' << 8) | 'T' // DFLT OpenType script tag, DFLT, for features that are not script-specific.

//#define HB_OT_LAYOUT_DEFAULT_LANGUAGE_INDEX 0xFFFFu
LAYOUT_DEFAULT_LANGUAGE_INDEX	: u32	: 0xFFFF				// Special value for language index indicating default or unsupported language.

//#define HB_OT_LAYOUT_NO_FEATURE_INDEX		0xFFFFu
LAYOUT_NO_FEATURE_INDEX			: u32	: 0xFFFF				// Special value for feature index indicating unsupported feature.

// #define HB_OT_LAYOUT_NO_SCRIPT_INDEX		0xFFFFu
LAYOUT_NO_SCRIPT_INDEX			: u32	: 0xFFFF				// Special value for script index indicating unsupported script.

// #define HB_OT_LAYOUT_NO_VARIATIONS_INDEX 0xFFFFFFFFu
LAYOUT_NO_VARIATIONS_INDEX		: u32	:  0xFFFFFFFF			// Special value for variations index indicating unsupported variation.

// #define HB_OT_TAG_BASE HB_TAG('B','A','S','E')
TAG_BASE	: hrfb.tag_t	: ('B' << 24) | ('A' << 16) | ('S' << 8) | 'E' // BASE OpenType Baseline Table.

// #define HB_OT_TAG_GDEF HB_TAG('G','D','E','F')
TAG_GDEF	: hrfb.tag_t	: ('G' << 24) | ('D' << 16) | ('E' << 8) | 'F' // GDEF OpenType Glyph Definition Table.

// #define HB_OT_TAG_GPOS HB_TAG('G','P','O','S')
TAG_GPOS	: hrfb.tag_t	: ('G' << 24) | ('P' << 16) | ('O' << 8) | 'S' // GPOS OpenType Glyph Positioning Table.

// #define HB_OT_TAG_GSUB HB_TAG('G','S','U','B')
TAG_GSUB	: hrfb.tag_t	: ('G' << 24) | ('S' << 16) | ('U' << 8) | 'B' // GSUB OpenType Glyph Substitution Table.

// #define HB_OT_TAG_JSTF HB_TAG('J','S','T','F')
TAG_JSTF	: hrfb.tag_t	: ('J' << 24) | ('S' << 16) | ('T' << 8) | 'F' // JSTF OpenType Justification Table.


/*
enum hb_ot_layout_baseline_tag_t

Baseline tags from Baseline Tags registry.
Since: 2.6.0

*/
layout_baseline_tag_t :: enum (hrfb.tag_t)
{
	LAYOUT_BASELINE_TAG_ROMAN						= ('r' << 24) | ('o' << 16) | ('m' << 8) | 'n', // romn The baseline used by alphabetic scripts such as Latin, Cyrillic and Greek. In vertical writing mode, the alphabetic baseline for characters rotated 90 degrees clockwise. (This would not apply to alphabetic characters that remain upright in vertical writing mode, since these characters are not rotated.)
	LAYOUT_BASELINE_TAG_HANGING						= ('h' << 24) | ('a' << 16) | ('n' << 8) | 'g', // hang The hanging baseline. In horizontal direction, this is the horizontal line from which syllables seem, to hang in Tibetan and other similar scripts. In vertical writing mode, for Tibetan (or some other similar script) characters rotated 90 degrees clockwise.
	LAYOUT_BASELINE_TAG_IDEO_FACE_BOTTOM_OR_LEFT	= ('i' << 24) | ('c' << 16) | ('f' << 8) | 'b', // icfb Ideographic character face bottom or left edge, if the direction is horizontal or vertical, respectively.
	LAYOUT_BASELINE_TAG_IDEO_FACE_TOP_OR_RIGHT		= ('i' << 24) | ('c' << 16) | ('f' << 8) | 't', // icft Ideographic character face top or right edge, if the direction is horizontal or vertical, respectively.
	LAYOUT_BASELINE_TAG_IDEO_FACE_CENTRAL			= ('I' << 24) | ('c' << 16) | ('f' << 8) | 'c', // Icfc The center of the ideographic character face. Since: 4.0.0
	LAYOUT_BASELINE_TAG_IDEO_EMBOX_BOTTOM_OR_LEFT	= ('i' << 24) | ('d' << 16) | ('e' << 8) | 'o', // ideo Ideographic em-box bottom or left edge, if the direction is horizontal or vertical, respectively.
	LAYOUT_BASELINE_TAG_IDEO_EMBOX_TOP_OR_RIGHT		= ('i' << 24) | ('d' << 16) | ('t' << 8) | 'p', // idtp Ideographic em-box top or right edge baseline.
	LAYOUT_BASELINE_TAG_IDEO_EMBOX_CENTRAL			= ('I' << 24) | ('d' << 16) | ('c' << 8) | 'e', // Idce The center of the ideographic em-box. Since: 4.0.0 if the direction is horizontal or vertical, respectively.
	LAYOUT_BASELINE_TAG_MATH						= ('m' << 24) | ('a' << 16) | ('t' << 8) | 'h', // math The baseline about which mathematical characters are centered. In vertical writing mode when mathematical characters rotated 90 degrees clockwise, are centered.
  /*< private >*/
	LAYOUT_BASELINE_TAG_MAX_VALUE					= hrfb.TAG_MAX_SIGNED
}

/*
enum hb_ot_layout_glyph_class_t

The GDEF classes defined for glyphs.
*/
layout_glyph_class_t :: enum
{
	LAYOUT_GLYPH_CLASS_UNCLASSIFIED	= 0,	// Glyphs not matching the other classifications
	LAYOUT_GLYPH_CLASS_BASE_GLYPH	= 1,	// Spacing, single characters, capable of accepting marks
	LAYOUT_GLYPH_CLASS_LIGATURE		= 2,	// Glyphs that represent ligation of multiple characters
	LAYOUT_GLYPH_CLASS_MARK			= 3,	// Non-spacing, combining glyphs that represent marks
	LAYOUT_GLYPH_CLASS_COMPONENT	= 4,	// Spacing glyphs that represent part of a single character
}

//******************
// FUNCTIONS
//******************

@(default_calling_convention = "c", link_prefix = "hb_ot_") foreign hb_ot
{

/*
hb_language_t hb_ot_tag_to_language (hb_tag_t tag);

Converts a language tag to an hb_language_t.

Inputs:
- tag:	an language tag
Returns:
- The hb_language_t corresponding to tag. [transfer none][nullable]

Since: 0.9.2
*/
tag_to_language :: proc (tag: hrfb.tag_t)	-> hrfb.language_t ---

/*
hb_script_t hb_ot_tag_to_script (hb_tag_t tag);

Converts a script tag to an hb_script_t.

Inputs:
- tag:	a script tag
Returns:
- The hb_script_t corresponding to tag.
*/
tag_to_script ::proc (tag: hrfb.tag_t)	-> hrfb.script_t ---

/*
void hb_ot_tags_from_script_and_language (hb_script_t script,  hb_language_t language, unsigned int *script_count,
	hb_tag_t *script_tags, unsigned int *language_count, hb_tag_t *language_tags);

Converts an hb_script_t and an hb_language_t to script and language tags.

Inputs:
- script:			an hb_script_t to convert.
- language:			an hb_language_t to convert. 	[nullable]
- script_count:		maximum number of script tags to retrieve (IN) and actual number of script tags retrieved (OUT). [inout][optional]
- script_tags:		array of size at least script_count to store the script tag results. [out][optional]
- language_count:	maximum number of language tags to retrieve (IN) and actual number of language tags retrieved (OUT). [inout][optional]
- language_tags:	array of size at least language_count to store the language tag results. [out][optional]

Since: 2.0.0
*/
tags_from_script_and_language :: proc (script: hrfb.script_t, language: hrfb.language_t, script_count: ^c.uint, script_tags: [^]hrfb.tag_t,
	language_count: ^c.uint, language_tags: [^]hrfb.tag_t)	---

/*
void hb_ot_tags_to_script_and_language (hb_tag_t script_tag, hb_tag_t language_tag, hb_script_t *script, hb_language_t *language);

Converts a script tag and a language tag to an hb_script_t and an hb_language_t.

Inputs:
- script_tag:	a script tag
- language_tag:	a language tag
- script:		the hb_script_t corresponding to script_tag. [out][optional]
- language:		the hb_language_t corresponding to script_tag and language_tag. [out][optional]

Since: 2.0.0
*/
tags_to_script_and_language :: proc (script_tag: hrfb.tag_t, language_tag: hrfb.tag_t, script: ^hrfb.script_t, language: ^hrfb.language_t)	---

/*
void hb_ot_layout_collect_lookups (hb_face_t *face, hb_tag_t table_tag, const hb_tag_t *scripts, const hb_tag_t *languages,
	const hb_tag_t *features, hb_set_t *lookup_indexes);

Fetches a list of all feature-lookup indexes in the specified face's GSUB table or GPOS table, underneath the specified
scripts, languages, and features. If no list of scripts is provided, all scripts will be queried. If no list of
languages is provided, all languages will be queried. If no list of features is provided, all features will be queried.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- scripts:			The array of scripts to collect lookups for, terminated by HB_TAG_NONE. [nullable][array zero-terminated=1]
- languages:		The array of languages to collect lookups for, terminated by HB_TAG_NONE. [nullable][array zero-terminated=1]
- features:			The array of features to collect lookups for, terminated by HB_TAG_NONE. [nullable][array zero-terminated=1]
- lookup_indexes:	The array of lookup indexes found for the query. [out]

Since: 0.9.8
*/
layout_collect_lookups :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, scripts: /*const*/ [^]hrfb.tag_t, languages: /*const*/ [^]hrfb.tag_t,
	features: /*const*/ [^]hrfb.tag_t, lookup_indexes: [^]hrfb.set_t)	---

/*
void hb_ot_layout_collect_features (hb_face_t *face, hb_tag_t table_tag, const hb_tag_t *scripts, const hb_tag_t *languages,
	const hb_tag_t *features, hb_set_t *feature_indexes);

Fetches a list of all feature indexes in the specified face's GSUB table or GPOS table, underneath the specified scripts,
languages, and features. If no list of scripts is provided, all scripts will be queried. If no list of languages is
provided, all languages will be queried. If no list of features is provided, all features will be queried.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- scripts:			The array of scripts to collect features for, terminated by HB_TAG_NONE. [nullable][array zero-terminated=1]
- languages:		The array of languages to collect features for, terminated by HB_TAG_NONE. [nullable][array zero-terminated=1]
- features:			The array of features to collect, terminated by HB_TAG_NONE. [nullable][array zero-terminated=1]
- feature_indexes:	The set of feature indexes found for the query. [out]

Since: 1.8.5
*/
layout_collect_features :: proc (face: hrfb.face_t, table_tag: hrfb.tag_t, scripts: /*const*/ [^]hrfb.tag_t, languages: /*const*/ [^]hrfb.tag_t,
	features: /*const*/ [^]hrfb.tag_t,  feature_indexes: /*const*/ [^]hrfb.set_t)	---

/*
void hb_ot_layout_collect_features_map (hb_face_t *face, hb_tag_t table_tag, unsigned  script_index,
	unsigned language_index, hb_map_t *feature_map);

Fetches the mapping from feature tags to feature indexes for the specified script and language.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_index:	The index of the requested language tag
- feature_map:		The map of feature tag to feature index. [out]

Since: 8.1.0
*/
layout_collect_features_map :: proc (face: hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_index: c.uint, feature_map: ^hrfb.map_t)	---

/*
unsigned int hb_ot_layout_feature_get_characters (hb_face_t *face, hb_tag_t table_tag, unsigned int feature_index,
	unsigned int start_offset, unsigned int *char_count, hb_codepoint_t *characters);

Fetches a list of the characters defined as having a variant under the specified "Character Variant" ("cvXX") feature tag.

Inputs:
- face:				hb_face_t to work upon
: table_tag:		table tag to query, "GSUB" or "GPOS".
- feature_index:	index of feature to query.
- start_offset:		offset of the first character to retrieve
- char_count:		Input = the maximum number of characters to return; Output = the actual number of characters returned (may be zero). [inout][optional]
- characters:		A buffer pointer. The Unicode codepoints of the characters for which this feature provides glyph variants. [out caller-allocates][array length=char_count]
Returns:
- Number of total sample characters in the cvXX feature.

Since: 2.0.0
*/
layout_feature_get_characters :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, feature_index: c.uint, start_offset: c.uint,
	char_count: ^c.uint, characters: [^]hrfb.codepoint_t)	-> c.uint ---

/*
unsigned int hb_ot_layout_feature_get_lookups (hb_face_t *face, hb_tag_t table_tag, unsigned int feature_index,
	unsigned int start_offset, unsigned int *lookup_count, unsigned int *lookup_indexes);

Fetches a list of all lookups enumerated for the specified feature, in the specified face's GSUB table or GPOS table.
The list returned will begin at the offset provided.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- feature_index:	The index of the requested feature
- start_offset:		offset of the first lookup to retrieve
- lookup_count:		Input = the maximum number of lookups to return; Output = the actual number of lookups returned (may be zero). [inout][optional]
- lookup_indexes:	The array of lookup indexes found for the query. [out][array length=lookup_count]
Returns:
- Total number of lookups.

Since: 0.9.7
*/
layout_feature_get_lookups :: proc (face: hrfb.face_t, table_tag: hrfb.tag_t, feature_index: c.uint, start_offset: c.uint,
	lookup_count: ^c.uint, lookup_indexes: [^]c.uint)	-> c.uint ---

/*
hb_bool_t hb_ot_layout_feature_get_name_ids (hb_face_t *face, hb_tag_t table_tag, unsigned int feature_index,
	hb_ot_name_id_t *label_id, hb_ot_name_id_t *tooltip_id, hb_ot_name_id_t *sample_id,
	unsigned int *num_named_parameters, hb_ot_name_id_t *first_param_id);

Fetches name indices from feature parameters for "Stylistic Set" ('ssXX') or "Character Variant" ('cvXX') features.

Inputs:
- face:					hb_face_t to work upon
- table_tag:			table tag to query, "GSUB" or "GPOS".
- feature_index:		index of feature to query.
- label_id:				The ‘name’ table name ID that specifies a string for a user-interface label for this feature. (May be NULL.). [out][optional]
- tooltip_id:			The ‘name’ table name ID that specifies a string that an application can use for tooltip text for this feature. (May be NULL.). [out][optional]
- sample_id:			The ‘name’ table name ID that specifies sample text that illustrates the effect of this feature. (May be NULL.). [out][optional]
- num_named_parameters:	Number of named parameters. (May be zero.). [out][optional]
- first_param_id:		The first ‘name’ table name ID used to specify strings for user-interface labels for the feature parameters. (Must be zero if numParameters is zero.). [out][optional]
Returns:
- true if data found, false otherwise

Since: 2.0.0
*/
layout_feature_get_name_ids :: proc (face: hrfb.face_t, table_tag: hrfb.tag_t, feature_index: c.uint, label_id: ^name_id_t,
	tooltip_id: ^name_id_t, sample_id: ^name_id_t, num_named_parameters: ^c.uint, first_param_id: ^name_id_t)	-> hrfb.bool_t ---

/*
unsigned int hb_ot_layout_feature_with_variations_get_lookups (hb_face_t *face, hb_tag_t table_tag,
	unsigned int feature_index, unsigned int variations_index, unsigned int start_offset,
	unsigned int *lookup_count, unsigned int *lookup_indexes);

Fetches a list of all lookups enumerated for the specified feature, in the specified face's GSUB table or GPOS table,
enabled at the specified variations index. The list returned will begin at the offset provided.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- feature_index:	The index of the feature to query
- variations_index:	The index of the feature variation to query
- start_offset:		offset of the first lookup to retrieve
- lookup_count:		Input = the maximum number of lookups to return; Output = the actual number of lookups returned (may be zero). [inout][optional]
- lookup_indexes:	The array of lookups found for the query. [out][array length=lookup_count]
Returns:
- Total number of lookups.

Since: 1.4.0
*/
layout_feature_with_variations_get_lookups :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, feature_index: c.uint,
	variations_index: c.uint, start_offset: c.uint, lookup_count: ^c.uint, lookup_indexes: [^]c.uint)	-> c.uint ---

/*
unsigned int hb_ot_layout_get_attach_points (hb_face_t *face, hb_codepoint_t glyph, unsigned int start_offset,
	unsigned int *point_count, unsigned int *point_array);

Fetches a list of all attachment points for the specified glyph in the GDEF table of the face. The list returned will
begin at the offset provided.

Useful if the client program wishes to cache the list.

Inputs:
- face:			The hb_face_t to work on
- glyph:		The hb_codepoint_t code point to query
- start_offset:	offset of the first attachment point to retrieve
- point_count:	Input = the maximum number of attachment points to return; Output = the actual number of attachment points returned (may be zero). [inout][optional]
- point_array:	The array of attachment points found for the query. [out][array length=point_count]
Returns:
- Total number of attachment points for glyph.
*/
layout_get_attach_points :: proc (face: ^hrfb.face_t, glyph: hrfb.codepoint_t, start_offset: c.uint, point_count: ^c.uint, point_array: [^]c.uint)	-> c.uint ---

/*
hb_bool_t hb_ot_layout_get_font_extents (hb_font_t *font, hb_direction_t direction, hb_tag_t script_tag,
	hb_tag_t language_tag, hb_font_extents_t *extents);

Fetches script/language-specific font extents. These values are looked up in the BASE table's MinMax records.

If no such extents are found, the default extents for the font are fetched. As such, the return value of this function
can for the most part be ignored. Note that the per-script/language extents do not have a line-gap value, and the
line-gap is set to zero in that case.

Inputs:
- font:			a font
- direction:	text direction.
- script_tag:	script tag.
- language_tag:	language tag.
- extents:		font extents if found. [out][nullable]
Returns:
- true if found script/language-specific font extents.

Since: 8.0.0
*/
layout_get_font_extents :: proc (font: ^hrfb.font_t, direction: hrfb.direction_t, script_tag: hrfb.tag_t, language_tag: hrfb.tag_t,
	extents: ^hrfb.font_extents_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_get_font_extents2 (hb_font_t *font, hb_direction_t direction, hb_script_t script, hb_language_t language, hb_font_extents_t *extents);

Fetches script/language-specific font extents. These values are looked up in the BASE table's MinMax records.

If no such extents are found, the default extents for the font are fetched. As such, the return value of this function
can for the most part be ignored. Note that the per-script/language extents do not have a line-gap value, and the
line-gap is set to zero in that case.

This function is like hb_ot_layout_get_font_extents() but takes hb_script_t and hb_language_t instead of OpenType hb_tag_t.

Inputs:
- font:			a font
- direction:	text direction.
- script:		script.
- language:		language. [nullable]
- extents:		font extents if found. [out][nullable]
Returns:
- true if found script/language-specific font extents.

Since: 8.0.0
*/
layout_get_font_extents2 :: proc (font: ^hrfb.font_t, direction: hrfb.direction_t, script: hrfb.script_t, language: hrfb.language_t,
	extents: ^hrfb.font_extents_t)	-> hrfb.bool_t ---

/*
hb_ot_layout_baseline_tag_t hb_ot_layout_get_horizontal_baseline_tag_for_script (hb_script_t script);

Fetches the dominant horizontal baseline tag used by script .

Inputs:
- script:	a script tag.
Returns:
- dominant baseline tag for the script .

Since: 4.0.0
*/
layout_get_horizontal_baseline_tag_for_script :: proc (script: hrfb.script_t)	-> layout_baseline_tag_t ---

/*
hb_bool_t hb_ot_layout_get_baseline (hb_font_t *font, hb_ot_layout_baseline_tag_t baseline_tag, hb_direction_t direction,
	hb_tag_t script_tag, hb_tag_t language_tag, hb_position_t *coord);

Fetches a baseline value from the face.

Inputs:
- font:			a font
- baseline_tag:	a baseline tag
- direction:	text direction.
- script_tag:	script tag.
- language_tag:	language tag, currently unused.
- coord:		baseline value if found. [out][nullable]
Returns:
- true if found baseline value in the font.

Since: 2.6.0
*/
layout_get_baseline :: proc (font: ^hrfb.font_t, baseline_tag: layout_baseline_tag_t, direction: hrfb.direction_t,
	script_tag: hrfb.tag_t, language_tag: hrfb.tag_t, coord: ^hrfb.position_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_get_baseline2 (hb_font_t *font, hb_ot_layout_baseline_tag_t baseline_tag, hb_direction_t direction,
	hb_script_t script, hb_position_t *coord);

Fetches a baseline value from the face.

This function is like hb_ot_layout_get_baseline() but takes hb_script_t and hb_language_t instead of OpenType hb_tag_t.

- font:			a font
- baseline_tag:	a baseline tag
- direction:	text direction.
- script:		script.
- language:		language, currently unused. [nullable]
- coord:		baseline value if found. [out][nullable]
Returns:
- true if found baseline value in the font.

Since: 8.0.0
*/
layout_get_baseline2 :: proc (font: ^hrfb.font_t, baseline_tag: layout_baseline_tag_t, direction: hrfb.direction_t,
	script: hrfb.script_t, coord: ^hrfb.position_t)	-> hrfb.bool_t ---

/*
void hb_ot_layout_get_baseline_with_fallback (hb_font_t *font, hb_ot_layout_baseline_tag_t baseline_tag, hb_direction_t direction,
	hb_tag_t script_tag,hb_tag_t language_tag, hb_position_t *coord);

Fetches a baseline value from the face, and synthesizes it if the font does not have it.

Inputs:
- font:			a font
- baseline_tag:	a baseline tag
 direction:		text direction.
- script_tag:	script tag.
- language_tag:	language tag, currently unused.
- coord:		baseline value if found. [out]

Since: 4.0.0
*/
layout_get_baseline_with_fallback :: proc (font: hrfb.font_t, baseline_tag: layout_baseline_tag_t, direction: hrfb.direction_t,
	script_tag: hrfb.tag_t, language_tag: hrfb.tag_t, coord: ^hrfb.position_t)	---

/*
void hb_ot_layout_get_baseline_with_fallback2 (hb_font_t *font, hb_ot_layout_baseline_tag_t baseline_tag,
	hb_direction_t direction, hb_script_t script, hb_language_t language, hb_position_t *coord);

Fetches a baseline value from the face, and synthesizes it if the font does not have it.

This function is like hb_ot_layout_get_baseline_with_fallback() but takes hb_script_t and hb_language_t instead of
OpenType hb_tag_t.

Inputs:
- font:			a font
- baseline_tag:	a baseline tag
- direction:	text direction.
- script:		script.
- language:		language, currently unused. [nullable]
- coord:		baseline value if found. [out]

Since: 8.0.0
*/
layout_get_baseline_with_fallback2 ::proc (font: ^hrfb.font_t,  baseline_tag: layout_baseline_tag_t,
	direction: hrfb.direction_t, script: hrfb.script_t, language: hrfb.language_t, coord: ^hrfb.position_t)	---

/*
hb_ot_layout_glyph_class_t hb_ot_layout_get_glyph_class (hb_face_t *face, hb_codepoint_t glyph);

Fetches the GDEF class of the requested glyph in the specified face.

Inputs:
- face:		The hb_face_t to work on
- glyph:	The hb_codepoint_t code point to query
Returns:
- The hb_ot_layout_glyph_class_t glyph class of the given code point in the GDEF table of the face.

Since: 0.9.7
*/
layout_get_glyph_class :: proc (face: ^hrfb.face_t, glyph: hrfb.codepoint_t)	-> layout_glyph_class_t ---

/*
void hb_ot_layout_get_glyphs_in_class (hb_face_t *face, hb_ot_layout_glyph_class_t klass, hb_set_t *glyphs);

Retrieves the set of all glyphs from the face that belong to the requested glyph class in the face's GDEF table.

Inputs:
- face:		The hb_face_t to work on
- klass:	The hb_ot_layout_glyph_class_t GDEF class to retrieve
- glyphs:	The hb_set_t set of all glyphs belonging to the requested class. [out]

Since: 0.9.7
*/
layout_get_glyphs_in_class :: proc (face: ^hrfb.face_t, klass: layout_glyph_class_t, glyphs: ^hrfb.set_t)	---

/*
unsigned int hb_ot_layout_get_ligature_carets (hb_font_t *font, hb_direction_t direction, hb_codepoint_t glyph,
	unsigned int start_offset, unsigned int *caret_count, hb_position_t *caret_array);

Fetches a list of the caret positions defined for a ligature glyph in the GDEF table of the font. The list returned will
begin at the offset provided.

Note that a ligature that is formed from n characters will have n-1 caret positions. The first character is not
represented in the array, since its caret position is the glyph position.

The positions returned by this function are 'unshaped', and will have to be fixed up for kerning that may be applied to
the ligature glyph.

Inputs:
- font:			The hb_font_t to work on
- direction:	The hb_direction_t text direction to use
- glyph:		The hb_codepoint_t code point to query
- start_offset:	offset of the first caret position to retrieve
- caret_count:	Input = the maximum number of caret positions to return; Output = the actual number of caret positions returned (may be zero). [inout][optional]
- caret_array:	The array of caret positions found for the query. [out][array length=caret_count]
Returns:
- otal number of ligature caret positions for glyph.
*/
layout_get_ligature_carets :: proc (font: ^hrfb.font_t, direction: hrfb.direction_t, glyph: hrfb.codepoint_t,
	start_offset: c.uint, caret_count: ^c.uint, caret_array: [^]hrfb.position_t)	-> c.uint ---

/*
hb_bool_t hb_ot_layout_get_size_params (hb_face_t *face, unsigned int *design_size, unsigned int *subfamily_id,
	hb_ot_name_id_t *subfamily_name_id, unsigned int *range_start, unsigned int *range_end);

Fetches optical-size feature data (i.e., the size feature from GPOS). Note that the subfamily_id and the subfamily name
string (accessible via the subfamily_name_id) as used here are defined as pertaining only to fonts within a font family
that differ specifically in their respective size ranges; other ways to differentiate fonts within a subfamily are not
covered by the size feature.

For more information on this distinction, see the size feature documentation.

Inputs:
- face:					hb_face_t to work upon
- design_size:			The design size of the face. [out]
- subfamily_id:			The identifier of the face within the font subfamily. [out]
- subfamily_name_id:	The ‘name’ table name ID of the face within the font subfamily. [out]
- range_start:			The minimum size of the recommended size range for the face. [out]
- range_end:			The maximum size of the recommended size range for the face. [out]
Returns:
- true if data found, false otherwise

Since: 0.9.10
*/
layout_get_size_params :: proc (face: ^hrfb.face_t, design_size: ^c.uint, subfamily_id: ^c.uint,
	subfamily_name_id: name_id_t, range_start: ^c.uint, range_end: ^c.uint)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_has_glyph_classes (hb_face_t *face);

Tests whether a face has any glyph classes defined in its GDEF table.

Inputs:
- face:	hb_face_t to work upon
Returns:
- true if data found, false otherwise
*/
layout_has_glyph_classes :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_has_positioning (hb_face_t *face);

Tests whether the specified face includes any GPOS positioning.

Inputs:
- face:	hb_face_t to work upon
Returns:
- rue if the face has GPOS data, false otherwise
*/
layout_has_positioning :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_has_substitution (hb_face_t *face);

Tests whether the specified face includes any GSUB substitutions.

Inputs:
- face:	hb_face_t to work upon
Returns:
- true if data found, false otherwise

Since: 0.6.0
*/
layout_has_substitution :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_language_find_feature (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int language_index, hb_tag_t feature_tag, unsigned int *feature_index);

Fetches the index of a given feature tag in the specified face's GSUB table or GPOS table, underneath the specified
script and language.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_index:	The index of the requested language tag
- feature_tag:		hb_tag_t of the feature tag requested
- feature_index:	The index of the requested feature. [out]
Returns:
- true if the feature is found, false otherwise

Since: 0.6.0
*/
layout_language_find_feature :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_index: c.uint, feature_tag: hrfb.tag_t, feature_index: ^hrfb.tag_t)	-> hrfb.bool_t ---

/*
unsigned int hb_ot_layout_language_get_feature_indexes (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int language_index, unsigned int start_offset, unsigned int *feature_count, unsigned int *feature_indexes);

Fetches a list of all features in the specified face's GSUB table or GPOS table, underneath the specified script and
language. The list returned will begin at the offset provided.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_index:	The index of the requested language tag
- start_offset:		offset of the first feature tag to retrieve
- feature_count:	Input = the maximum number of feature tags to return; Output: the actual number of feature tags returned (may be zero). [inout][optional]
- feature_indexes:	The array of feature indexes found for the query. [out][array length=feature_count]
Returns:
- Total number of features.

Since: 0.6.0
*/
layout_language_get_feature_indexes :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_index: c.uint, start_offset: c.uint, feature_count: ^c.uint, feature_indexes: [^] c.uint)	-> c.uint ---

/*
unsigned int hb_ot_layout_language_get_feature_tags (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int language_index, unsigned int start_offset, unsigned int *feature_count, hb_tag_t *feature_tags);

Fetches a list of all features in the specified face's GSUB table or GPOS table, underneath the specified script and
language. The list returned will begin at the offset provided.

Inputs:
- face:				b_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_index:	The index of the requested language tag
- start_offset:		offset of the first feature tag to retrieve
- feature_count:	Input = the maximum number of feature tags to return; Output = the actual number of feature tags returned (may be zero). [inout][optional]
- feature_tags:		The array of hb_tag_t feature tags found for the query. [out][array length=feature_count]
Returns:
- Total number of feature tags.

Since: 0.6.0
*/
layout_language_get_feature_tags :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_index: c.uint, start_offset: c.uint, feature_count: ^c.uint, feature_tags: [^] hrfb.tag_t)	-> c.uint ---

/*
hb_bool_t hb_ot_layout_language_get_required_feature (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int language_index, unsigned int *feature_index, hb_tag_t *feature_tag);

Fetches the tag of a requested feature index in the given face's GSUB or GPOS table, underneath the specified script and language.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_index:	The index of the requested language tag
- feature_index:	The index of the requested feature. [out]
- feature_tag:		The hb_tag_t of the requested feature. [out]
Returns:
- true if the feature is found, false otherwise

Since: 0.9.30
*/
layout_language_get_required_feature :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_index: c.uint, feature_index: ^c.uint, feature_tag: [^] hrfb.tag_t)	-> hrfb.bool_t ---

/*
void hb_ot_layout_lookup_collect_glyphs (hb_face_t *face, hb_tag_t table_tag, unsigned int lookup_index,
	hb_set_t *glyphs_before, hb_set_t *glyphs_input, hb_set_t *glyphs_after, hb_set_t *glyphs_output);

Fetches a list of all glyphs affected by the specified lookup in the specified face's GSUB table or GPOS table.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- lookup_index:		The index of the feature lookup to query
- glyphs_before:	Array of glyphs preceding the substitution range. [out]
- glyphs_input:		Array of input glyphs that would be substituted by the lookup. [out]
- glyphs_after:		Array of glyphs following the substitution range. [out]
- glyphs_output:	Array of glyphs that would be the substituted output of the lookup. [out]

Since: 0.9.7
*/
layout_lookup_collect_glyphs :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, lookup_index: c.uint,
	glyphs_before: [^]hrfb.set_t, glyphs_input: [^]hrfb.set_t, glyphs_after: [^]hrfb.set_t, glyphs_output: [^]hrfb.set_t)	---

/*
unsigned hb_ot_layout_lookup_get_glyph_alternates (hb_face_t *face, unsigned  lookup_index, hb_codepoint_t glyph,
 	unsigned  start_offset, unsigned *alternate_count, hb_codepoint_t *alternate_glyphs);

Fetches alternates of a glyph from a given GSUB lookup index.

Inputs:
- face:				a face.
- lookup_index:		index of the feature lookup to query.
- glyph:			a glyph id.
- start_offset:		starting offset.
- alternate_count:	Input = the maximum number of alternate glyphs to return; Output = the actual number of alternate glyphs returned (may be zero). [inout][optional]
- alternate_glyphs:	A glyphs buffer. Alternate glyphs associated with the glyph id. [out caller-allocates][array length=alternate_count]
Returns:
- Total number of alternates found in the specific lookup index for the given glyph id.

Since: 2.6.8
*/
layout_lookup_get_glyph_alternates :: proc (face: ^hrfb.face_t,  lookup_index: c.uint, glyph: hrfb.codepoint_t,
	 start_offset: c.uint, alternate_count: ^c.uint, alternate_glyphs: [^] hrfb.codepoint_t)	-> c.uint ---

/*
hb_position_t hb_ot_layout_lookup_get_optical_bound (hb_font_t *font, unsigned  lookup_index, hb_direction_t direction,
	hb_codepoint_t glyph);

Fetches the optical bound of a glyph positioned at the margin of text. The direction identifies which edge of the glyph to query.

Inputs:
- font:			a font.
- lookup_index:	index of the feature lookup to query.
- direction:	edge of the glyph to query.
- glyph:		a glyph id.
Returns:
- Adjustment value. Negative values mean the glyph will stick out of the margin.

Since: 5.3.0
*/
layout_lookup_get_optical_bound :: proc (font: ^hrfb.font_t, lookup_index: c.uint, direction: hrfb.direction_t,
	glyph: hrfb.codepoint_t)	-> hrfb.position_t ---

/*
void hb_ot_layout_lookup_substitute_closure (hb_face_t *face, unsigned int lookup_index, hb_set_t *glyphs);

Compute the transitive closure of glyphs needed for a specified lookup.

Inputs:
- face:			hb_face_t to work upon
- lookup_index:	index of the feature lookup to query
- glyphs:		Array of glyphs comprising the transitive closure of the lookup. [out]

Since: 0.9.7
*/
layout_lookup_substitute_closure :: proc (face: ^hrfb.face_t, lookup_index: c.uint, glyphs: [^]hrfb.set_t)	---

/*
void hb_ot_layout_lookups_substitute_closure (hb_face_t *face, const hb_set_t *lookups, hb_set_t *glyphs);

Compute the transitive closure of glyphs needed for all of the provided lookups.

Inputs:
- face:		hb_face_t to work upon
- lookups:	The set of lookups to query
- glyphs:	Array of glyphs comprising the transitive closure of the lookups. [out]

Since: 1.8.1
*/
layout_lookups_substitute_closure :: proc (face: ^hrfb.face_t, lookups: /*const*/ ^hrfb.set_t, glyphs: [^]hrfb.set_t)	---

/*
hb_bool_t hb_ot_layout_lookup_would_substitute (hb_face_t *face, unsigned int lookup_index, const hb_codepoint_t *glyphs,
	unsigned int glyphs_length, hb_bool_t zero_context);

Tests whether a specified lookup in the specified face would trigger a substitution on the given glyph sequence.

Inputs:
- face:				hb_face_t to work upon
- lookup_index:		The index of the lookup to query
- glyphs:			The sequence of glyphs to query for substitution
- glyphs_length:	The length of the glyph sequence
- zero_context:		hb_bool_t indicating whether pre-/post-context are disallowed in substitutions
Returns:
- true if a substitution would be triggered, false otherwise

Since: 0.9.7
*/
layout_lookup_would_substitute :: proc (face: ^hrfb.face_t, lookup_index: c.uint, glyphs: /*const*/ ^hrfb.codepoint_t,
	glyphs_length: c.uint, zero_context: hrfb.bool_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_script_find_language (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	hb_tag_t language_tag, unsigned int *language_index);

hb_ot_layout_script_find_language has been deprecated since version 2.0.0 and should not be used in newly-written code.

Fetches the index of a given language tag in the specified face's GSUB table or GPOS table, underneath the specified script tag.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_tag:		The hb_tag_t of the requested language
- language_index:	The index of the requested language
Returns:
- true if the language tag is found, false otherwise

Since: 0.6.0
*/
@(deprecated="'layout_script_find_language()' deprecated")
layout_script_find_language :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_tag: hrfb.tag_t, language_index: ^c.uint)	-> hrfb.bool_t ---

/*
unsigned int hb_ot_layout_script_get_language_tags (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int start_offset, unsigned int *language_count, hb_tag_t *language_tags);

Fetches a list of language tags in the given face's GSUB or GPOS table, underneath the specified script index. The list
returned will begin at the offset provided.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- start_offset:		offset of the first language tag to retrieve
- language_count:	Input = the maximum number of language tags to return; Output = the actual number of language tags returned (may be zero). [inout][optional]
- language_tags:	Array of language tags found in the table. [out][array length=language_count]
Returns:
- Total number of language tags.

Since: 0.6.0
*/
layout_script_get_language_tags :: proc (face:^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	start_offset: c.uint, language_count: ^c.uint, language_tags: [^]hrfb.tag_t)	-> c.uint ---

/*
hb_bool_t hb_ot_layout_script_select_language (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int language_count, const hb_tag_t *language_tags, unsigned int *language_index);

Fetches the index of the first language tag fom language_tags that is present in the specified face's GSUB or GPOS table,
underneath the specified script index.

If none of the given language tags is found, false is returned and language_index is set to the default language index.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_count:	The number of languages in the specified script
- language_tags:	The array of language tags
- language_index:	The index of the requested language. [out]
Returns:
- true if one of the given language tags is found, false otherwise

Since: 2.0.0
*/
layout_script_select_language :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_count: c.uint, language_tags: /*const*/ [^]hrfb.tag_t, language_index: ^c.uint)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_script_select_language2 (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int language_count, const hb_tag_t *language_tags, unsigned int *language_index, hb_tag_t *chosen_language);

Fetches the index of the first language tag fom language_tags that is present in the specified face's GSUB or GPOS
table, underneath the specified script index.

If none of the given language tags is found, false is returned and language_index is set to
HB_OT_LAYOUT_DEFAULT_LANGUAGE_INDEX and chosen_language is set to HB_TAG_NONE.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_count:	The number of languages in the specified script
- language_tags:	The array of language tags
- language_index:	The index of the chosen language. [out]
- chosen_language:	hb_tag_t of the chosen language. [out]
Returns:
- true if one of the given language tags is found, false otherwise

Since: 7.0.0
*/
layout_script_select_language2 :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint, language_count: c.uint,
	language_tags: /*const*/ [^]hrfb.tag_t, language_index: ^c.uint, chosen_language: ^hrfb.tag_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_layout_table_find_feature_variations (hb_face_t *face, hb_tag_t table_tag, const int *coords,
	unsigned int num_coords, unsigned int *variations_index);

Fetches a list of feature variations in the specified face's GSUB table or GPOS table, at the specified variation coordinates.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- coords:			The variation coordinates to query
- num_coords:		The number of variation coordinates
- variations_index:	The array of feature variations found for the query. [out]
Returns:
- true if feature variations were found, false otherwise.

Since: 1.4.0
*/
layout_table_find_feature_variations :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, coords: /*const*/ [^]c.int,
	num_coords: c.uint, variations_index: [^]c.uint)	-> hrfb.bool_t ---

/*
unsigned int hb_ot_layout_table_get_feature_tags (hb_face_t *face, hb_tag_t table_tag, unsigned int start_offset,
	unsigned int *feature_count, hb_tag_t *feature_tags);

Fetches a list of all feature tags in the given face's GSUB or GPOS table. Note that there might be duplicate feature
tags, belonging to different script/language-system pairs of the table.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- start_offset:		offset of the first feature tag to retrieve
- feature_count:	Input = the maximum number of feature tags to return; Output = the actual number of feature tags returned (may be zero). [inout][optional]
- feature_tags:		Array of feature tags found in the table. [out][array length=feature_count]
Returns:
- Total number of feature tags.

Since: 0.6.0
*/
layout_table_get_feature_tags :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, start_offset: c.uint,
	feature_count: ^c.uint, feature_tags: [^]hrfb.tag_t)	-> c.uint ---

/*
unsigned int hb_ot_layout_table_get_script_tags (hb_face_t *face, hb_tag_t table_tag, unsigned int start_offset,
	unsigned int *script_count, hb_tag_t *script_tags);

Fetches a list of all scripts enumerated in the specified face's GSUB table or GPOS table. The list returned will begin
t the offset provided.

Inputs:
- face:			hb_face_t to work upon
- table_tag:	HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- start_offset:	offset of the first script tag to retrieve
- script_count:	Input = the maximum number of script tags to return; Output = the actual number of script tags returned (may be zero). [inout][optional]
- script_tags:	The array of hb_tag_t script tags found for the query. [out][array length=script_count]
Returns:
- Total number of script tags.
*/
layout_table_get_script_tags :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, start_offset: c.uint,
	script_count: ^c.uint, script_tags: [^]hrfb.tag_t)	-> c.uint ---

/*
unsigned int hb_ot_layout_table_get_lookup_count (hb_face_t *face, hb_tag_t table_tag);

Fetches the total number of lookups enumerated in the specified face's GSUB table or GPOS table.

Inputs:
- face:			hb_face_t to work upon
- table_tag:	HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
Returns:
- Total number of lookups.

Since: 0.9.22
*/
layout_table_get_lookup_count :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t)	-> c.uint ---

/*
hb_bool_t hb_ot_layout_table_select_script (hb_face_t *face, hb_tag_t table_tag, unsigned int script_count,
	const hb_tag_t *script_tags, unsigned int *script_index, hb_tag_t *chosen_script);

Selects an OpenType script for table_tag from the script_tags array.

If the table does not have any of the requested scripts, then DFLT, dflt, and latn tags are tried in that order. If the
table still does not have any of these scripts, script_index is set to HB_OT_LAYOUT_NO_SCRIPT_INDEX and chosen_script
is set to HB_TAG_NONE.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_count:		Number of script tags in the array
- script_tags:		Array of hb_tag_t script tags
- script_index:		The index of the requested script. [out][optional]
- chosen_script:	hb_tag_t of the requested script. [out][optional]
Returns:
- true if one of the requested scripts is selected, false if a fallback script is selected or if no scripts are selected.

Since: 2.0.0
*/
layout_table_select_script :: proc(face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_count: c.uint,
	script_tags: /*const*/ [^]hrfb.tag_t, script_index: ^c.uint, chosen_script: ^hrfb.tag_t)	-> hrfb.bool_t ---

/*
void hb_ot_shape_plan_collect_lookups (hb_shape_plan_t *shape_plan, hb_tag_t table_tag, hb_set_t *lookup_indexes);

Computes the complete set of GSUB or GPOS lookups that are applicable under a given shape_plan.

Inputs:
- shape_plan:		hb_shape_plan_t to query
- table_tag:		GSUB or GPOS
- lookup_indexes:	The hb_set_t set of lookups returned. [out]

Since: 0.9.7
*/
shape_plan_collect_lookups :: proc (shape_plan: ^hrfb.shape_plan_t,  table_tag: hrfb.tag_t, lookup_indexes: ^hrfb.set_t)	---

/*
hb_bool_t hb_ot_layout_language_get_required_feature_index (hb_face_t *face, hb_tag_t table_tag, unsigned int script_index,
	unsigned int language_index, unsigned int *feature_index);

Fetches the index of a requested feature in the given face's GSUB or GPOS table, underneath the specified script and language.

Inputs:
- face:				hb_face_t to work upon
- table_tag:		HB_OT_TAG_GSUB or HB_OT_TAG_GPOS
- script_index:		The index of the requested script tag
- language_index:	The index of the requested language tag
- feature_index:	The index of the requested feature. [out]
Returns:
- true if the feature is found, false otherwise

Since: 0.6.0
*/
layout_language_get_required_feature_index :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t, script_index: c.uint,
	language_index: c.uint, feature_index: ^c.uint)	-> hrfb.bool_t ---

// NOT IN API?
// HB_EXTERN hb_bool_t hb_ot_layout_table_find_script (hb_face_t *face, hb_tag_t table_tag, hb_tag_t script_tag, unsigned int *script_index /* OUT */);
layout_table_find_script :: proc (face: ^hrfb.face_t, table_tag: hrfb.tag_t,
	script_tag: hrfb.tag_t, script_index: ^c.uint /* OUT */)	-> hrfb.bool_t ---

/*
unsigned int hb_ot_shape_plan_get_feature_tags (hb_shape_plan_t *shape_plan,
	unsigned int start_offset, unsigned int *tag_count, hb_tag_t *tags);

Fetches the list of OpenType feature tags enabled for a shaping plan, if possible.

Inputs:
- shape_plan:	A shaping plan
- start_offset:	The index of first feature to retrieve
- tag_count:	Input = the maximum number of features to return; Output = the actual number of features returned (may be zero). [inout]
- tags:			The array of enabled feature. [out][array length=tag_count]
Returns:
- Total number of feature tags.

Since: 10.3.0
*/
ot_shape_plan_get_feature_tags :: proc (shape_plan: ^hrfb.shape_plan_t, start_offset: c.uint,
	tag_count: ^c.uint, tags: ^hrfb.tag_t) -> c.uint ---

/*
hb_bool_t hb_ot_layout_lookup_collect_glyph_alternates(hb_face_t *face, unsigned  lookup_index,
	hb_map_t *alternate_count, hb_map_t *alternate_glyphs);

Collects alternates of glyphs from a given GSUB lookup index.

For one-to-one GSUB glyph substitutions, this function collects the substituted glyph.

For lookups that assign multiple alternates to a glyph, all alternate glyphs are collected.

For other lookup types, nothing is performed and false is returned.

The alternate_count mapping will contain the number of alternates for each glyph id. Upon entry, this mapping should contain the glyph ids as keys, and the number of alternates currently known for each glyph id as values.

The alternate_glyphs mapping will contain the alternate glyph ids for each glyph id. The mapping is encoded in the following way, upon entry and after processing: If G is the glyph id, and A0, A1, ..., A(n-1) are the alternate glyph ids, the mapping will contain the following entries: (G + (i << 24)) -> A(i) for i = 0, 1, ..., n-1 where n is the number of alternates for G as per alternate_count.

Inputs:
- face:				a face.
- lookup_index:		index of the feature lookup to query.
- alternate_count:	mapping from glyph index to number of alternates for that glyph. [inout]
- alternate_glyphs:	mapping from encoded glyph index and alternate index, to alternate glyph ids. [inout]
Returns:
- true if alternates were collected, false otherwise.

Since: 12.1.0*/
ot_layout_lookup_collect_glyph_alternates :: proc (face: ^hrfb.face_t, lookup_index: c.uint,
	alternate_count: ^hrfb.map_t, alternate_glyphs: ^hrfb.map_t) -> hrfb.bool_t ---

}
