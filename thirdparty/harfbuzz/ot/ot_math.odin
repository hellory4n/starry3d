/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

ot_math.odin - Types and functions for OpenType compatibility - Mathematics layout data.

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

(c) 2024, Maurizio M. Gavioli and contributors
author: Maurizio M. Gavioli, 2024-09-23

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-math.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-math.html
*/

package	harfbuzz_ot

import 	"core:c"
//import cm "./common"
import hrfb ".."

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb_ot "../windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb_ot "system:harfbuzz"	}

/*******************
hb-ot-math — OpenType Math information

Functions for fetching mathematics layout data from OpenType fonts.

HarfBuzz itself does not implement a math layout solution. The functions and types provided can be used by client programs to access the font data necessary for typesetting OpenType Math layout.
*******************/

//******************
// TYPES
//******************

/*
#define HB_OT_TAG_MATH HB_TAG('M','A','T','H')

OpenType Mathematical Typesetting Table.

Since: 1.3.3
**/
TAG_MATH	: int : ('M' << 24) | ('A' << 16) | ('T' << 8) | 'H' // MATH

/*
#define HB_OT_TAG_MATH_SCRIPT HB_TAG('m','a','t','h')

OpenType script tag, math, for features specific to math shaping.
HB_OT_TAG_MATH_SCRIPT is not a valid hb_script_t and should only be used with functions that accept raw OpenType script
tags, such as hb_ot_layout_collect_features. In other cases, HB_SCRIPT_MATH should be used instead.

Since: 3.4.0
*/
TAG_MATH_SCRIPT : int : ('m' << 24) | ('a' << 16) | ('t' << 8) | 'h' // math

/*
enum hb_ot_math_constant_t

The 'MATH' table constants, refer to OpenType documentation For more explanations.

Since: 1.3.3
*/
math_constant_t :: enum
{
	MATH_CONSTANT_SCRIPT_PERCENT_SCALE_DOWN						= 0,
	MATH_CONSTANT_SCRIPT_SCRIPT_PERCENT_SCALE_DOWN				= 1,
	MATH_CONSTANT_DELIMITED_SUB_FORMULA_MIN_HEIGHT				= 2,
	MATH_CONSTANT_DISPLAY_OPERATOR_MIN_HEIGHT					= 3,
	MATH_CONSTANT_MATH_LEADING									= 4,
	MATH_CONSTANT_AXIS_HEIGHT									= 5,
	MATH_CONSTANT_ACCENT_BASE_HEIGHT							= 6,
	MATH_CONSTANT_FLATTENED_ACCENT_BASE_HEIGHT					= 7,
	MATH_CONSTANT_SUBSCRIPT_SHIFT_DOWN							= 8,
	MATH_CONSTANT_SUBSCRIPT_TOP_MAX								= 9,
	MATH_CONSTANT_SUBSCRIPT_BASELINE_DROP_MIN					= 10,
	MATH_CONSTANT_SUPERSCRIPT_SHIFT_UP							= 11,
	MATH_CONSTANT_SUPERSCRIPT_SHIFT_UP_CRAMPED					= 12,
	MATH_CONSTANT_SUPERSCRIPT_BOTTOM_MIN						= 13,
	MATH_CONSTANT_SUPERSCRIPT_BASELINE_DROP_MAX					= 14,
	MATH_CONSTANT_SUB_SUPERSCRIPT_GAP_MIN						= 15,
	MATH_CONSTANT_SUPERSCRIPT_BOTTOM_MAX_WITH_SUBSCRIPT			= 16,
	MATH_CONSTANT_SPACE_AFTER_SCRIPT							= 17,
	MATH_CONSTANT_UPPER_LIMIT_GAP_MIN							= 18,
	MATH_CONSTANT_UPPER_LIMIT_BASELINE_RISE_MIN					= 19,
	MATH_CONSTANT_LOWER_LIMIT_GAP_MIN							= 20,
	MATH_CONSTANT_LOWER_LIMIT_BASELINE_DROP_MIN					= 21,
	MATH_CONSTANT_STACK_TOP_SHIFT_UP							= 22,
	MATH_CONSTANT_STACK_TOP_DISPLAY_STYLE_SHIFT_UP				= 23,
	MATH_CONSTANT_STACK_BOTTOM_SHIFT_DOWN						= 24,
	MATH_CONSTANT_STACK_BOTTOM_DISPLAY_STYLE_SHIFT_DOWN			= 25,
	MATH_CONSTANT_STACK_GAP_MIN									= 26,
	MATH_CONSTANT_STACK_DISPLAY_STYLE_GAP_MIN					= 27,
	MATH_CONSTANT_STRETCH_STACK_TOP_SHIFT_UP					= 28,
	MATH_CONSTANT_STRETCH_STACK_BOTTOM_SHIFT_DOWN				= 29,
	MATH_CONSTANT_STRETCH_STACK_GAP_ABOVE_MIN					= 30,
	MATH_CONSTANT_STRETCH_STACK_GAP_BELOW_MIN					= 31,
	MATH_CONSTANT_FRACTION_NUMERATOR_SHIFT_UP					= 32,
	MATH_CONSTANT_FRACTION_NUMERATOR_DISPLAY_STYLE_SHIFT_UP		= 33,
	MATH_CONSTANT_FRACTION_DENOMINATOR_SHIFT_DOWN				= 34,
	MATH_CONSTANT_FRACTION_DENOMINATOR_DISPLAY_STYLE_SHIFT_DOWN	= 35,
	MATH_CONSTANT_FRACTION_NUMERATOR_GAP_MIN					= 36,
	MATH_CONSTANT_FRACTION_NUM_DISPLAY_STYLE_GAP_MIN			= 37,
	MATH_CONSTANT_FRACTION_RULE_THICKNESS						= 38,
	MATH_CONSTANT_FRACTION_DENOMINATOR_GAP_MIN					= 39,
	MATH_CONSTANT_FRACTION_DENOM_DISPLAY_STYLE_GAP_MIN			= 40,
	MATH_CONSTANT_SKEWED_FRACTION_HORIZONTAL_GAP				= 41,
	MATH_CONSTANT_SKEWED_FRACTION_VERTICAL_GAP					= 42,
	MATH_CONSTANT_OVERBAR_VERTICAL_GAP							= 43,
	MATH_CONSTANT_OVERBAR_RULE_THICKNESS						= 44,
	MATH_CONSTANT_OVERBAR_EXTRA_ASCENDER						= 45,
	MATH_CONSTANT_UNDERBAR_VERTICAL_GAP							= 46,
	MATH_CONSTANT_UNDERBAR_RULE_THICKNESS						= 47,
	MATH_CONSTANT_UNDERBAR_EXTRA_DESCENDER						= 48,
	MATH_CONSTANT_RADICAL_VERTICAL_GAP							= 49,
	MATH_CONSTANT_RADICAL_DISPLAY_STYLE_VERTICAL_GAP			= 50,
	MATH_CONSTANT_RADICAL_RULE_THICKNESS						= 51,
	MATH_CONSTANT_RADICAL_EXTRA_ASCENDER						= 52,
	MATH_CONSTANT_RADICAL_KERN_BEFORE_DEGREE					= 53,
	MATH_CONSTANT_RADICAL_KERN_AFTER_DEGREE						= 54,
	MATH_CONSTANT_RADICAL_DEGREE_BOTTOM_RAISE_PERCENT			= 55
}

/*
enum hb_ot_math_kern_t

The math kerning-table types defined for the four corners of a glyph.

Since: 1.3.3
*/
math_kern_t :: enum
{
HB_OT_MATH_KERN_TOP_RIGHT	= 0,	// The top right corner of the glyph.
HB_OT_MATH_KERN_TOP_LEFT	= 1,	// The top left corner of the glyph.
HB_OT_MATH_KERN_BOTTOM_RIGHT= 2,	// The bottom right corner of the glyph.
HB_OT_MATH_KERN_BOTTOM_LEFT	= 3,	// The bottom left corner of the glyph.
}

/*
typedef struct hb_ot_math_kern_entry_t

Data type to hold math kerning (cut-in) information for a glyph.

Since: 3.4.0
*/
math_kern_entry_t :: struct #packed
{
	max_correction_height	: hrfb.position_t,	// The maximum height at which this entry should be used
	kern_value				: hrfb.position_t,	// The kern value of the entry
}

/*
typedef struct {
  hb_codepoint_t glyph;
  hb_position_t advance;
} hb_ot_math_glyph_variant_t;

Data type to hold math-variant information for a glyph.

Since: 1.3.3
*/
math_glyph_variant_t :: struct #packed
{
  glyph		: hrfb.codepoint_t,	// The glyph index of the variant
  advance	: hrfb.position_t,	// The advance width of the variant
}

/*
enum hb_ot_math_glyph_part_flags_t

Flags for math glyph parts.

Since: 1.3.3
*/
math_glyph_part_flags_t :: enum (uint)
{
	MATH_GLYPH_PART_FLAG_EXTENDER	= 0x00000001  // This is an extender glyph part that can be repeated to reach the desired length.
}

/*
typedef struct hb_ot_math_glyph_part_t

Data type to hold information for a "part" component of a math-variant glyph. Large variants for stretchable math glyphs (such as parentheses) can be constructed on the fly from parts.

Since: 1.3.3
*/
math_glyph_part_t :: struct #packed
{
	glyph					: hrfb.codepoint_t,	// The glyph index of the variant part
	start_connector_length	: hrfb.position_t,	// The length of the connector on the starting side of the variant part
	end_connector_length	: hrfb.position_t,	// The length of the connector on the ending side of the variant part
	full_advance			: hrfb.position_t,	// The total advance of the part
	flags					: math_glyph_part_flags_t,	// hb_ot_math_glyph_part_flags_t flags for the part
}

//******************
// FUNCTIONS
//******************

@(default_calling_convention = "c", link_prefix = "hb_ot_") foreign hb_ot
{

/*
hb_bool_t hb_ot_math_has_data (hb_face_t *face);

Tests whether a face has a MATH table.

Inputs:
- face:	hb_face_t to test
Returns:
- true if the table is found, false otherwise

Since: 1.3.3
*/
math_has_data :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_position_t hb_ot_math_get_constant (hb_font_t *font, hb_ot_math_constant_t constant);

Fetches the specified math constant. For most constants, the value returned is an hb_position_t.

However, if the requested constant is HB_OT_MATH_CONSTANT_SCRIPT_PERCENT_SCALE_DOWN, HB_OT_MATH_CONSTANT_SCRIPT_SCRIPT_PERCENT_SCALE_DOWN
or HB_OT_MATH_CONSTANT_RADICAL_DEGREE_BOTTOM_RAISE_PERCENT, then the return value is an integer between 0 and 100 representing that percentage.

Inputs:
- font:		hb_font_t to work upon
- constant:	hb_ot_math_constant_t the constant to retrieve
Returns:
- the requested constant or zero

Since: 1.3.3
*/
math_get_constant :: proc (font: ^hrfb.font_t, constant: math_constant_t)	-> hrfb.position_t ---

/*
hb_position_t hb_ot_math_get_glyph_italics_correction (hb_font_t *font, hb_codepoint_t glyph);

Fetches an italics-correction value (if one exists) for the specified glyph index.

Inputs:
- font:		hb_font_t to work upon
- glyph:	The glyph index from which to retrieve the value
Returns:
- the italics correction of the glyph or zero

Since: 1.3.3
*/
math_get_glyph_italics_correction :: proc (font: ^hrfb.font_t, glyph: hrfb.codepoint_t)	-> hrfb.position_t ---

/*
hb_position_t hb_ot_math_get_glyph_top_accent_attachment (hb_font_t *font, hb_codepoint_t glyph);

Fetches a top-accent-attachment value (if one exists) for the specified glyph index.

For any glyph that does not have a top-accent-attachment value - that is, a glyph not covered by the MathTopAccentAttachment
table (or, when font has no MathTopAccentAttachment table or no MATH table, any glyph) - the function synthesizes a value,
returning the position at one-half the glyph's advance width.

Inputs:
- font:		hb_font_t to work upon
- glyph:	The glyph index from which to retrieve the value
Returns:
- the top accent attachment of the glyph or 0.5 * the advance width of glyph

Since: 1.3.3
*/
math_get_glyph_top_accent_attachment :: proc (font: ^hrfb.font_t, glyph: hrfb.codepoint_t)	-> hrfb.position_t ---

/*
hb_position_t hb_ot_math_get_glyph_kerning (hb_font_t *font, hb_codepoint_t glyph, hb_ot_math_kern_t kern, hb_position_t correction_height);

Fetches the math kerning (cut-ins) value for the specified font, glyph index, and kern.

If the MathKern table is found, the function examines it to find a height value that is greater or equal to correction_height.
If such a height value is found, corresponding kerning value from the table is returned. If no such height value is found,
the last kerning value is returned.

Inputs:
- font:					hb_font_t to work upon
- glyph:				The glyph index from which to retrieve the value
- kern:					The hb_ot_math_kern_t from which to retrieve the value
- correction_height:	the correction height to use to determine the kerning.
Returns:
- requested kerning value or zero

Since: 1.3.3
*/
math_get_glyph_kerning :: proc (font: ^hrfb.font_t, glyph: hrfb.codepoint_t, kern: math_kern_t,
	correction_height: hrfb.position_t)	-> hrfb.position_t ---

/*
unsigned int hb_ot_math_get_glyph_kernings (hb_font_t *font, hb_codepoint_t glyph, hb_ot_math_kern_t kern,
	unsigned int start_offset, unsigned int *entries_count, hb_ot_math_kern_entry_t *kern_entries);

Fetches the raw MathKern (cut-in) data for the specified font, glyph index, and kern . The corresponding list of kern
values and correction heights is returned as a list of hb_ot_math_kern_entry_t structs.

See also hb_ot_math_get_glyph_kerning, which handles selecting the appropriate kern value for a given correction height.
For a glyph with n defined kern values (where n > 0), there are only n−1 defined correction heights, as each correction
height defines a boundary past which the next kern value should be selected. Therefore, only the
hb_ot_math_kern_entry_t.kern_value of the uppermost hb_ot_math_kern_entry_t actually comes from the font; its
corresponding hb_ot_math_kern_entry_t.max_correction_height is always set to INT32_MAX.

Inputs:
- font:				hb_font_t to work upon
- glyph:			The glyph index from which to retrieve the kernings
- kern:				The hb_ot_math_kern_t from which to retrieve the kernings
- start_offset:		offset of the first kern entry to retrieve
- entries_count:	Input = the maximum number of kern entries to return; Output = the actual number of kern entries returned. [inout][optional]
- kern_entries:		array of kern entries returned. [out caller-allocates][array length=entries_count]
Returns:
- the total number of kern values available or zero

Since: 3.4.0
*/
math_get_glyph_kernings :: proc (font: ^hrfb.font_t, glyph: hrfb.codepoint_t, kern: math_kern_t, start_offset: c.uint,
	entries_count: ^c.uint, kern_entries: [^]math_kern_entry_t)	-> c.uint ---

/*
hb_bool_t hb_ot_math_is_glyph_extended_shape (hb_face_t *face, hb_codepoint_t glyph);

Tests whether the given glyph index is an extended shape in the face.

Inputs:
- face:		hb_face_t to work upon
- glyph:	The glyph index to test
Returns:
- true if the glyph is an extended shape, false otherwise

Since: 1.3.3
*/
math_is_glyph_extended_shape :: proc (face: ^hrfb.face_t, glyph: hrfb.codepoint_t)	-> hrfb.bool_t ---

/*
unsigned int hb_ot_math_get_glyph_variants (hb_font_t *font, hb_codepoint_t glyph, hb_direction_t direction,
	unsigned int start_offset, unsigned int *variants_count, hb_ot_math_glyph_variant_t *variants);

Fetches the MathGlyphConstruction for the specified font, glyph index, and direction. The corresponding list of size
variants is returned as a list of hb_ot_math_glyph_variant_t structs.

The direction parameter is only used to select between horizontal or vertical directions for the construction. Even though
all hb_direction_t values are accepted, only the result of HB_DIRECTION_IS_HORIZONTAL is considered.

Inputs:
- font:				hb_font_t to work upon
- glyph:			The index of the glyph to stretch
- direction:		The direction of the stretching (horizontal or vertical)
- start_offset:		offset of the first variant to retrieve
- variants_count:	Input = the maximum number of variants to return; Output = the actual number of variants returned. [inout]
- variants:			array of variants returned. [out][array length=variants_count]
Returns:
- the total number of size variants available or zero

Since: 1.3.3
*/
math_get_glyph_variants :: proc (font: ^hrfb.font_t, glyph: hrfb.codepoint_t, direction: hrfb.direction_t,
	start_offset: c.uint, variants_count: ^c.uint, variants: [^]math_glyph_variant_t)	-> c.uint ---

/*
hb_position_t hb_ot_math_get_min_connector_overlap (hb_font_t *font, hb_direction_t direction);

Fetches the MathVariants table for the specified font and returns the minimum overlap of connecting glyphs that are
required to draw a glyph assembly in the specified direction.
The direction parameter is only used to select between horizontal or vertical directions for the construction. Even
though all hb_direction_t values are accepted, only the result of HB_DIRECTION_IS_HORIZONTAL is considered.

Inputs:
- font:			hb_font_t to work upon
- direction:	direction of the stretching (horizontal or vertical)
Returns:
- requested minimum connector overlap or zero

Since: 1.3.3
*/
math_get_min_connector_overlap :: proc (font: ^hrfb.font_t, direction: hrfb.direction_t)	-> hrfb.position_t ---

/*
unsigned int hb_ot_math_get_glyph_assembly (hb_font_t *font, hb_codepoint_t glyph, hb_direction_t direction,
	unsigned int start_offset, unsigned int *parts_count, hb_ot_math_glyph_part_t *parts,
	hb_position_t *italics_correction);

Fetches the GlyphAssembly for the specified font, glyph index, and direction. Returned are a list of hb_ot_math_glyph_part_t
glyph parts that can be used to draw the glyph and an italics-correction value (if one is defined in the font).
The direction parameter is only used to select between horizontal or vertical directions for the construction. Even though
all hb_direction_t values are accepted, only the result of HB_DIRECTION_IS_HORIZONTAL is considered.

Inputs:
- font:					hb_font_t to work upon
- glyph:				The index of the glyph to stretch
- direction:			direction of the stretching (horizontal or vertical)
- start_offset:			offset of the first glyph part to retrieve
- parts_count:			Input = maximum number of glyph parts to return; Output = actual number of parts returned. [inout]
- parts:				the glyph parts returned. [out][array length=parts_count]
- italics_correction:	italics correction of the glyph assembly. [out]
Returns:
- the total number of parts in the glyph assembly

Since: 1.3.3
*/
math_get_glyph_assembly :: proc (font: ^hrfb.font_t, glyph: hrfb.codepoint_t, direction: hrfb.direction_t, start_offset: c.uint,
	parts_count: ^c.uint, parts: [^]math_glyph_part_t, italics_correction: ^hrfb.position_t)	-> c.uint ---

}
