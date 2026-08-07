/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

ot.odin - Types and functions for OpenType compatibility.

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
author: Maurizio M. Gavioli, 2024-09-20

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

This file combines the bindings for the following original file of the HarfBuzz OpenType module:

	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-color.h
	https://harfbuzz.github.io/harfbuzz-hb-ot-color.html

	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-font.h
	https://harfbuzz.github.io/harfbuzz-hb-ot-font.html

	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-meta.h
	https://harfbuzz.github.io/harfbuzz-hb-ot-meta.html

	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-metrics.h
	https://harfbuzz.github.io/harfbuzz-hb-ot-metrics.html

	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-name.h
	https://harfbuzz.github.io/harfbuzz-hb-ot-name.html

	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-shape.h
	https://harfbuzz.github.io/harfbuzz-hb-ot-shape.html

	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-var.h
	https://harfbuzz.github.io/harfbuzz-hb-ot-var.html

The `hb_ot_layout` and `hb_ot_math` have their own separate binding files.
*/

package	harfbuzz_ot

import 	"core:c"
//import cm "./common"
import hrfb ".."

when ODIN_OS == .Windows	{	foreign import hb_ot "../windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb_ot "system:harfbuzz"	}

/*******************
hb-ot-color — OpenType Color Fonts

Functions for fetching color-font information from OpenType font faces.
HarfBuzz supports COLR/CPAL, sbix, CBDT, and SVG color fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-color.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-color.html
*******************/

//******************
// TYPES
//******************

/*
HB_COLOR()

#define HB_COLOR(b,g,r,a) ((hb_color_t) HB_TAG ((b),(g),(r),(a)))

Constructs an hb_color_t from four integers.
- b:	blue channel value
- g:	green channel value
- r:	red channel value
- a:	alpha channel value
Since: 2.1.0
*/
/*
typedef uint32_t hb_color_t;

Data type for holding color values. Colors are eight bits per channel RGB plus alpha transparency.

Since: 2.1.0
*/
color_t	::	distinct u32

/*
hb_ot_color_layer_t:
@glyph: the glyph ID of the layer
@color_index: the palette color index of the layer

Pairs of glyph and color index.

A color index of 0xFFFF does not refer to a palette
color, but indicates that the foreground color should
be used.

Since: 2.1.0
*/
color_layer_t :: struct #packed
{
	glyph		: hrfb.codepoint_t,	// the glyph ID of the layer
	color_index	: c.uint,			// the palette color index of the layer
}

/*
hb_ot_color_palette_flags_t
@HB_OT_COLOR_PALETTE_FLAG_DEFAULT: Default indicating that there is nothing special
  to note about a color palette.
@HB_OT_COLOR_PALETTE_FLAG_USABLE_WITH_LIGHT_BACKGROUND: Flag indicating that the color
  palette is appropriate to use when displaying the font on a light background such as white.
@HB_OT_COLOR_PALETTE_FLAG_USABLE_WITH_DARK_BACKGROUND: Flag indicating that the color
  palette is appropriate to use when displaying the font on a dark background such as black.

Flags that describe the properties of color palette.

Since: 2.1.0
*/
color_palette_flags_t :: enum (u32)
{
	COLOR_PALETTE_FLAG_DEFAULT,							// Default indicating that there is nothing special to note about a color palette.
	COLOR_PALETTE_FLAG_USABLE_WITH_LIGHT_BACKGROUND,	// Flag indicating that the color palette is appropriate to use when displaying the font on a light background such as white.
	COLOR_PALETTE_FLAG_USABLE_WITH_DARK_BACKGROUND,		// Flag indicating that the color palette is appropriate to use when displaying the font on a dark background such as black.
}

/*******************
hb-ot-meta — OpenType Metadata

Functions for fetching metadata from fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-meta.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-meta.html
*******************/

/*
typedef enum hb_ot_meta_tag_t

Known metadata tags from https://docs.microsoft.com/en-us/typography/opentype/spec/meta

Since: 2.6.0
*/
meta_tag_t :: enum
{
	// Design languages. Text, using only Basic Latin (ASCII) characters. Indicates languages and/or scripts for the user audiences that the font was primarily designed for.
	HB_OT_META_TAG_DESIGN_LANGUAGES		= ('d' << 24) | ('l' << 16) | ('n' << 8) | 'g',
	// Supported languages. Text, using only Basic Latin (ASCII) characters. Indicates languages and/or scripts that the font is declared to be capable of supporting.
	HB_OT_META_TAG_SUPPORTED_LANGUAGES	= ('s' << 24) | ('l' << 16) | ('n' << 8) | 'g',
}

/*******************
hb-ot-metrics — OpenType Metrics

Functions for fetching metrics from fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-metrics.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-metrics.html
*******************/

/*
typedef enum hb_ot_metrics_tag_t:

Metric tags corresponding to "MVAR Value Tags" (see:
	https://docs.microsoft.com/en-us/typography/opentype/spec/mvar#value-tags)

Since: 2.6.0
*/
metrics_tag_t :: enum (hrfb.tag_t)
{
	METRICS_TAG_HORIZONTAL_ASCENDER			= ('h' << 24) | ('a' << 16) | ('s' << 8) | 'c', // hasc
	METRICS_TAG_HORIZONTAL_DESCENDER		= ('h' << 24) | ('d' << 16) | ('s' << 8) | 'c', // hdsc
	METRICS_TAG_HORIZONTAL_LINE_GAP			= ('h' << 24) | ('l' << 16) | ('g' << 8) | 'p', // hlgp
	METRICS_TAG_HORIZONTAL_CLIPPING_ASCENT	= ('h' << 24) | ('c' << 16) | ('l' << 8) | 'a', // hcla
	METRICS_TAG_HORIZONTAL_CLIPPING_DESCENT	= ('h' << 24) | ('c' << 16) | ('l' << 8) | 'd', // hcld
	METRICS_TAG_VERTICAL_ASCENDER			= ('v' << 24) | ('a' << 16) | ('s' << 8) | 'c', // vasc
	METRICS_TAG_VERTICAL_DESCENDER			= ('v' << 24) | ('d' << 16) | ('s' << 8) | 'c', // vdsc
	METRICS_TAG_VERTICAL_LINE_GAP			= ('v' << 24) | ('l' << 16) | ('g' << 8) | 'p', // vlgp
	METRICS_TAG_HORIZONTAL_CARET_RISE		= ('h' << 24) | ('c' << 16) | ('r' << 8) | 's', // hcrs
	METRICS_TAG_HORIZONTAL_CARET_RUN		= ('h' << 24) | ('c' << 16) | ('r' << 8) | 'n', // hcrn
	METRICS_TAG_HORIZONTAL_CARET_OFFSET		= ('h' << 24) | ('c' << 16) | ('o' << 8) | 'f', // hcof
	METRICS_TAG_VERTICAL_CARET_RISE			= ('v' << 24) | ('c' << 16) | ('r' << 8) | 's', // vcrs
	METRICS_TAG_VERTICAL_CARET_RUN			= ('v' << 24) | ('c' << 16) | ('r' << 8) | 'n', // vcrn
	METRICS_TAG_VERTICAL_CARET_OFFSET		= ('v' << 24) | ('c' << 16) | ('o' << 8) | 'f', // vcof
	METRICS_TAG_X_HEIGHT					= ('x' << 24) | ('h' << 16) | ('g' << 8) | 't', // xhgt
	METRICS_TAG_CAP_HEIGHT					= ('c' << 24) | ('p' << 16) | ('h' << 8) | 't', // cpht
	METRICS_TAG_SUBSCRIPT_EM_X_SIZE			= ('s' << 24) | ('b' << 16) | ('x' << 8) | 's', // sbxs
	METRICS_TAG_SUBSCRIPT_EM_Y_SIZE			= ('s' << 24) | ('b' << 16) | ('y' << 8) | 's', // sbys
	METRICS_TAG_SUBSCRIPT_EM_X_OFFSET		= ('s' << 24) | ('b' << 16) | ('x' << 8) | 'o', // sbxo
	METRICS_TAG_SUBSCRIPT_EM_Y_OFFSET		= ('s' << 24) | ('b' << 16) | ('y' << 8) | 'o', // sbyo
	METRICS_TAG_SUPERSCRIPT_EM_X_SIZE		= ('s' << 24) | ('p' << 16) | ('x' << 8) | 's', // spxs
	METRICS_TAG_SUPERSCRIPT_EM_Y_SIZE		= ('s' << 24) | ('p' << 16) | ('y' << 8) | 's', // spys
	METRICS_TAG_SUPERSCRIPT_EM_X_OFFSET		= ('s' << 24) | ('p' << 16) | ('x' << 8) | 'o', // spxo
	METRICS_TAG_SUPERSCRIPT_EM_Y_OFFSET		= ('s' << 24) | ('p' << 16) | ('y' << 8) | 'o', // spyo
	METRICS_TAG_STRIKEOUT_SIZE				= ('s' << 24) | ('t' << 16) | ('r' << 8) | 's', // strs
	METRICS_TAG_STRIKEOUT_OFFSET			= ('s' << 24) | ('t' << 16) | ('r' << 8) | 'o', // stro
	METRICS_TAG_UNDERLINE_SIZE				= ('u' << 24) | ('n' << 16) | ('d' << 8) | 's', // unds
	METRICS_TAG_UNDERLINE_OFFSET			= ('u' << 24) | ('n' << 16) | ('d' << 8) | 'o', // undo

	/*< private >*/
	METRICS_TAG_MAX_VALUE = hrfb.TAG_MAX_SIGNED /*< skip >*/
}

/*******************
hb-ot-name — OpenType font name information

Functions for fetching name strings from OpenType fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-name.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-name.html
*******************/

/*
typedef unsigned int hb_ot_name_id_t;

An integral type representing an OpenType 'name' table name identifier. There are predefined name IDs, as well as name
IDs return from other API. These can be used to fetch name strings from a font face.

Since: 2.0.0
*/
name_id_t :: distinct c.uint

/*
enum hb_ot_name_id_predefined_t

An enum type representing the pre-defined name IDs.

For more information on these fields, see the OpenType spec.

Since: 7.0.0
*/
name_id_predefined_t :: enum
{
	HB_OT_NAME_ID_COPYRIGHT				=  0,		// Copyright notice
	HB_OT_NAME_ID_FONT_FAMILY			=  1,		// Font Family name
	HB_OT_NAME_ID_FONT_SUBFAMILY		=  2,		// Font Subfamily name
	HB_OT_NAME_ID_UNIQUE_ID				=  3,		// Unique font identifier
	HB_OT_NAME_ID_FULL_NAME				=  4,		// Full font name that reflects all family and relevant subfamily descriptors
	HB_OT_NAME_ID_VERSION_STRING		=  5,		// Version string
	HB_OT_NAME_ID_POSTSCRIPT_NAME		=  6,		// PostScript name for the font
	HB_OT_NAME_ID_TRADEMARK				=  7,		// Trademark
	HB_OT_NAME_ID_MANUFACTURER			=  8,		// Manufacturer Name
	HB_OT_NAME_ID_DESIGNER				=  9,		// Designer
	HB_OT_NAME_ID_DESCRIPTION			= 10,		// Description
	HB_OT_NAME_ID_VENDOR_URL			= 11,		// URL of font vendor
	HB_OT_NAME_ID_DESIGNER_URL			= 12,		// URL of typeface designer
	HB_OT_NAME_ID_LICENSE				= 13,		// License Description
	HB_OT_NAME_ID_LICENSE_URL			= 14,		// URL where additional licensing information can be found
//	HB_OT_NAME_ID_RESERVED				= 15,
	HB_OT_NAME_ID_TYPOGRAPHIC_FAMILY	= 16,		// Typographic Family name
	HB_OT_NAME_ID_TYPOGRAPHIC_SUBFAMILY	= 17,		// Typographic Subfamily name
	HB_OT_NAME_ID_MAC_FULL_NAME			= 18,		// Compatible Full Name for MacOS
	HB_OT_NAME_ID_SAMPLE_TEXT			= 19,		// Sample text
	HB_OT_NAME_ID_CID_FINDFONT_NAME		= 20,		// PostScript CID findfont name
	HB_OT_NAME_ID_WWS_FAMILY			= 21,		// WWS Family Name
	HB_OT_NAME_ID_WWS_SUBFAMILY			= 22,		// WWS Subfamily Name
	HB_OT_NAME_ID_LIGHT_BACKGROUND		= 23,		// Light Background Palette
	HB_OT_NAME_ID_DARK_BACKGROUND		= 24,		// Dark Background Palette
	HB_OT_NAME_ID_VARIATIONS_PS_PREFIX	= 25,		// Variations PostScript Name Prefix
	HB_OT_NAME_ID_INVALID				= 0xffff,	// Value to represent a nonexistent name ID.
}

/*
typedef struct {
  hb_ot_name_id_t name_id;
  hb_language_t   language;
} hb_ot_name_entry_t;

Structure representing a name ID in a particular language.

Since: 2.1.0
*/
name_entry_t :: struct #packed
{
	name_id:	name_id_t,			// name ID
	var:		hrfb.var_int_t,		// PRIVATE!
	language:	hrfb.language_t,	// language
}

/*******************
hb-ot-var — OpenType Font Variations

Functions for fetching information about OpenType Variable Fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-var.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-var.html
*******************/

// HB_OT_TAG_VAR_AXIS_ITALIC
// Registered tag for the roman/italic axis.
TAG_VAR_AXIS_ITALIC : int : ('i' << 24) | ('t' << 16) | ('a' << 8) | 'l' // ital

// HB_OT_TAG_VAR_AXIS_OPTICAL_SIZE
// Registered tag for the optical-size axis.
// Note: The optical-size axis supersedes the OpenType `size` feature.

TAG_VAR_AXIS_OPTICAL_SIZE : int : ('o' << 24) | ('p' << 16) | ('s' << 8) | 'z' // opsz

// HB_OT_TAG_VAR_AXIS_SLANT
// Registered tag for the slant axis
TAG_VAR_AXIS_SLANT : int : ('s' << 24) | ('l' << 16) | ('n' << 8) | 't' // slnt

// HB_OT_TAG_VAR_AXIS_WEIGHT
// Registered tag for the weight axis.
TAG_VAR_AXIS_WEIGHT : int : ('w' << 24) | ('g' << 16) | ('h' << 8) | 't' // wght

// HB_OT_TAG_VAR_AXIS_WIDTH
// Registered tag for the width axis.
TAG_VAR_AXIS_WIDTH : int : ('w' << 24) | ('d' << 16) | ('t' << 8) | 'h' // wdth

// enum hb_ot_var_axis_flags_t
//
// Flags for hb_ot_var_axis_info_t.
//
// Since: 2.2.0
var_axis_flags_t :: enum (hrfb.tag_t)
{
	VAR_AXIS_FLAG_HIDDEN	= 0x00000001,			// The axis should not be exposed directly in user interfaces.
	VAR_AXIS_FLAG_MAX_VALUE	= hrfb.TAG_MAX_SIGNED	// PRIVATE!
}

/*
typedef struct hb_ot_var_axis_info_t;

Data type for holding variation-axis values.

The minimum, default, and maximum values are in un-normalized, user scales.
Note: at present, the only flag defined for flags is HB_OT_VAR_AXIS_FLAG_HIDDEN.

Since: 2.2.0
*/
var_axis_info_t :: struct #packed
{
	axis_index		: c.uint,			// Index of the axis in the variation-axis array.
	tag				: hrfb.tag_t,		// The `tag_t` tag identifying the design variation of the axis.
	name_id			: name_id_t,		// The name table Name ID that provides display names for the axis.
	flags			: var_axis_flags_t,	// The `var_axis_flags_t` flags for the axis.
	min_value		: c.float,			// The minimum value on the variation axis that the font covers.
	default_value	: c.float,			// The position on the variation axis corresponding to the font's defaults.
	max_value		: c.float,			// The maximum value on the variation axis that the font covers.
}


@(default_calling_convention = "c", link_prefix = "hb_ot_") foreign hb_ot
{

//******************
// FUNCTIONS
//******************

//***
// hb-ot-color — OpenType Color Fonts
//***

/*
uint8_t hb_color_get_alpha (hb_color_t color);

Fetches the alpha channel of the given color.

Inputs:
- color:	an hb_color_t we are interested in its channels.
Returns:
- Alpha channel value

Since: 2.1.0
*/
color_get_alpha :: proc (color: color_t) -> u8 ---

/*
uint8_t hb_color_get_blue (hb_color_t color);

Fetches the blue channel of the given color .

Inputs:
- color:	an hb_color_t we are interested in its channels.
Returns:
- Blue channel value

Since: 2.1.0
*/
color_get_blue :: proc (color: color_t)	-> u8 ---

/*
uint8_t hb_color_get_green (hb_color_t color);

Fetches the green channel of the given color.

Inputs:
- color:	an hb_color_t we are interested in its channels.
Returns:
- Green channel value

Since: 2.1.0
*/
color_get_green :: proc (color: color_t)	-> u8 ---

/*
uint8_t hb_color_get_red (hb_color_t color);

Fetches the red channel of the given color.

Inputs:
- color:	an hb_color_t we are interested in its channels.
Returns
- Red channel value

Since: 2.1.0
*/
color_get_red :: proc (color: color_t)	-> u8 ---

/*
hb_bool_t hb_ot_color_has_layers (hb_face_t *face);

Tests whether a face includes a COLR table with data according to COLRv0.

Inputs:
- face:	hb_face_t to work upon
Returns:
- true if data found, false otherwise

Since: 2.1.0
*/
color_has_layers :: proc (face: ^hrfb.face_t)	-> bool ---

/*
unsigned int hb_ot_color_glyph_get_layers (hb_face_t *face, hb_codepoint_t glyph, unsigned int start_offset,
	unsigned int *layer_count, hb_ot_color_layer_t *layers);

Fetches a list of all color layers for the specified glyph index in the specified face. The list returned will begin at the offset provided.

Inputs:
- face:			hb_face_t to work upon
- glyph:		The glyph index to query
- start_offset:	offset of the first layer to retrieve
- layer_count:	Input = the maximum number of layers to return; Output = the actual number of layers returned (may be zero). [inout][optional]
- layers:		The array of layers found. [out][array length=layer_count][nullable]
Returns:
- Total number of layers available for the glyph index queried

Since: 2.1.0
*/
color_glyph_get_layers :: proc (face: ^hrfb.face_t, glyph: hrfb.codepoint_t, start_offset: c.uint,
	layer_count: ^c.uint, layers: [^]color_layer_t) -> c.uint ---

/*
hb_bool_t hb_ot_color_has_palettes (hb_face_t *face);

Tests whether a face includes a CPAL color-palette table.

Inputs:
- face:	hb_face_t to work upon
Returns:
- true if data found, false otherwise

Since: 2.1.0
*/
color_has_palettes :: proc (face: ^hrfb.face_t)	-> bool ---

/*
unsigned int hb_ot_color_palette_get_count (hb_face_t *face);

Fetches the number of color palettes in a face.

Inputs:
- face:	hb_face_t to work upon
Returns:
- the number of palettes found

Since: 2.1.0
*/
color_palette_get_count :: proc(face: ^hrfb.face_t)	-> c.uint ---

/*
unsigned int hb_ot_color_palette_get_colors (hb_face_t *face, unsigned int palette_index, unsigned int start_offset,
	unsigned int *color_count, hb_color_t *colors);

Fetches a list of the colors in a color palette.

After calling this function, colors will be filled with the palette colors. If colors is NULL, the function will just
return the number of total colors without storing any actual colors; this can be used for allocating a buffer of suitable
size before calling hb_ot_color_palette_get_colors() a second time.

The RGBA values in the palette are unpremultiplied. See the OpenType spec CPAL section for details.

Inputs:
- face:				hb_face_t to work upon
- palette_index:	the index of the color palette to query
- start_offset:		offset of the first color to retrieve
- color_count:		Input = the maximum number of colors to return; Output = the actual number of colors returned (may be zero). [inout][optional]
- colors			The array of hb_color_t records found. [out][array length=color_count][nullable]
Returns:
- the total number of colors in the palette

Since: 2.1.0
*/
color_palette_get_colors :: proc (face: ^hrfb.face_t, palette_index: c.uint, start_offset: c.uint,
	color_count: ^c.uint, colors: [^]color_t)	-> c.uint ---

/*
hb_ot_color_palette_flags_t hb_ot_color_palette_get_flags (hb_face_t *face, unsigned int palette_index);

Fetches the flags defined for a color palette.

Inputs:
- face:			hb_face_t to work upon
- palette_index	The index of the color palette
Returns:
- The hb_ot_color_palette_flags_t of the requested color palette

Since: 2.1.0
*/
color_palette_get_flags :: proc (face: ^hrfb.face_t, palette_index: c.uint)	-> color_palette_flags_t ---

/*
hb_ot_name_id_t hb_ot_color_palette_get_name_id (hb_face_t *face, unsigned int palette_index);

Fetches the name table Name ID that provides display names for a CPAL color palette.

Palette display names can be generic (e.g., "Default") or provide specific, themed names (e.g., "Spring", "Summer", "Fall", and "Winter").

Inputs:
- face:				hb_face_t to work upon
- palette_index:	The index of the color palette
Returns:
- the Named ID found for the palette. If the requested palette has no name the result is HB_OT_NAME_ID_INVALID.

Since: 2.1.0
*/
color_palette_get_name_id :: proc (face: ^hrfb.face_t, palette_index: c.uint)	-> name_id_t ---

/*
hb_ot_name_id_t hb_ot_color_palette_color_get_name_id (hb_face_t *face, unsigned int color_index);

Fetches the name table Name ID that provides display names for the specified color in a face's CPAL color palette.

Display names can be generic (e.g., "Background") or specific (e.g., "Eye color").

Inputs:
- face:			hb_face_t to work upon
- color_index:	The index of the color
Returns:
- the Name ID found for the color.

Since: 2.1.0
*/
color_palette_color_get_name_id :: proc (face: ^hrfb.face_t, color_index: c.uint)	-> name_id_t ---

/*
hb_bool_t hb_ot_color_has_paint (hb_face_t *face);

Tests where a face includes a COLR table with data according to COLRv1.

Inputs:
- face:	hb_face_t to work upon
Returns
- true if data found, false otherwise

Since: 7.0.0
*/
color_has_paint :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_color_glyph_has_paint (hb_face_t *face, hb_codepoint_t glyph);

Tests where a face includes COLRv1 paint data for glyph .

Inputs:
- face:	hb_face_t to work upon
- glyph:	The glyph index to query
Returns:
- true if data found, false otherwise

Since: 7.0.0
*/
color_glyph_has_paint :: proc (face: ^hrfb.face_t, glyph: hrfb.codepoint_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_color_has_png (hb_face_t *face);

Tests whether a face has PNG glyph images (either in CBDT or sbix tables).

Inputs:
- face:	hb_face_t to work upon
Returns:
- true if data found, false otherwise

Since: 2.1.0
*/
color_has_png :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_blob_t * hb_ot_color_glyph_reference_png (hb_font_t *font, hb_codepoint_t glyph);

Fetches the PNG image for a glyph. This function takes a font object, not a face object, as input. To get an optimally
sized PNG blob, the PPEM values must be set on the font object. If PPEM is unset, the blob returned will be the largest
PNG available.

If the glyph has no PNG image, the singleton empty blob is returned.

Inputs:
- font:		hb_font_t to work upon
- glyph:	a glyph index
Returns:
- An hb_blob_t containing the PNG image for the glyph, if available. [transfer full]

Since: 2.1.0
*/
color_glyph_reference_png :: proc (font: ^hrfb.font_t, glyph: hrfb.codepoint_t)	-> ^hrfb.blob_t ---

/*
hb_bool_t hb_ot_color_has_svg (hb_face_t *face);

Tests whether a face includes any SVG glyph images.

Inputs:
- face:	hb_face_t to work upon.
Returns:
- true if data found, false otherwise.

Since: 2.1.0
*/
color_has_svg :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_blob_t * hb_ot_color_glyph_reference_svg (hb_face_t *face, hb_codepoint_t glyph);

Fetches the SVG document for a glyph. The blob may be either plain text or gzip-encoded.

If the glyph has no SVG document, the singleton empty blob is returned.

Inputs:
- face:		hb_face_t to work upon
- glyph:	a svg glyph index
Returns:
- An hb_blob_t containing the SVG document of the glyph, if available. [transfer full]

Since: 2.1.0
*/
color_glyph_reference_svg :: proc (face: ^hrfb.face_t, glyph: hrfb.codepoint_t)	-> ^hrfb.blob_t ---

/*
unsigned int hb_ot_color_get_svg_document_count (hb_face_t *face);

Gets the number of SVG documents in the face SVG table.

Inputs:
- face:		hb_face_t to work upon.
Returns:
-number of SVG documents in the face.

Since: 12.1.0
*/
ot_color_get_svg_document_count :: proc (face: ^hrfb.face_t) -> c.uint ---

/*
hb_bool_t hb_ot_color_glyph_get_svg_document_index(hb_face_t *face, hb_codepoint_t glyph, unsigned int *svg_document_index);

Gets the SVG-table document index associated with a glyph.

Inputs:
- face:					hb_face_t to work upon.
- glyph:				glyph ID to query.
- svg_document_index:	output SVG document index. [out][nullable]
Returns:
- true if glyph maps to an SVG document, false otherwise.

Since: 12.1.0
*/
ot_color_glyph_get_svg_document_index :: proc (face: ^hrfb.face_t, glyph: hrfb.codepoint_t,
	svg_document_index: ^c.uint) -> hrfb.bool_t ---

/*******************
hb-ot-font — OpenType font implementation

Functions for using OpenType fonts with hb_shape(). Note that fonts returned by hb_font_create() default to using these functions, so most clients would never need to call these functions directly.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-font.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-font.html
*******************/

/*
void hb_ot_font_set_funcs (hb_font_t *font);

Sets the font functions to use when working with font .

Inputs:
- font:	hb_font_t to work upon

Since: 0.9.28
*/
font_set_funcs :: proc (font: ^hrfb.font_t)	---

/*******************
hb-ot-meta — OpenType Metadata

Functions for fetching metadata from fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-meta.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-meta.html
*******************/

/*
unsigned int hb_ot_meta_get_entry_tags (hb_face_t *face, unsigned int start_offset, unsigned int *entries_count, hb_ot_meta_tag_t *entries);

Fetches all available feature types.

Inputs:
- face:				a face object
- start_offset:		iteration's start offset
- entries_count:	buffer size as input, filled size as output. [inout][optional]
- entries:			entries tags buffer. [out caller-allocates][array length=entries_count]
Returns:
- Number of all available feature types.

Since: 2.6.0
*/
meta_get_entry_tags :: proc (face: ^hrfb.face_t, start_offset: c.uint, entries_count: ^c.uint, entries: [^]meta_tag_t)	-> c.uint ---

/*
hb_blob_t * hb_ot_meta_reference_entry (hb_face_t *face, hb_ot_meta_tag_t meta_tag);

It fetches metadata entry of a given tag from a font.

Inputs:
- face:		a hb_face_t object.
- meta_tag:	tag of metadata you like to have.
Returns:
- A blob containing the blob. [transfer full]

Since: 2.6.0
*/
meta_reference_entry :: proc (face: ^hrfb.face_t, meta_tag: meta_tag_t)	-> ^hrfb.blob_t ---

/*******************
hb-ot-metrics — OpenType Metrics

Functions for fetching metrics from fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-metrics.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-metrics.html
*******************/

/*
hb_bool_t hb_ot_metrics_get_position (hb_font_t *font, hb_ot_metrics_tag_t metrics_tag, hb_position_t *position);

Fetches metrics value corresponding to metrics_tag from font.

Inputs:
- font:			an hb_font_t object.
- metrics_tag:	tag of metrics value you like to fetch.
- position:		result of metrics value from the font. [out][optional]
Returns:
- Whether found the requested metrics in the font.

Since: 2.6.0
*/
metrics_get_position :: proc (font: ^hrfb.font_t, metrics_tag: metrics_tag_t, position: ^hrfb.position_t)	-> hrfb.bool_t ---

/*
void hb_ot_metrics_get_position_with_fallback (hb_font_t *font, hb_ot_metrics_tag_t metrics_tag, hb_position_t *position);

Fetches metrics value corresponding to metrics_tag from font , and synthesizes a value if it the value is missing in the font.

Inputs:
- font:			an hb_font_t object.
- metrics_tag:	tag of metrics value you like to fetch.
- position:		result of metrics value from the font. [out][optional]

Since: 4.0.0
*/
metrics_get_position_with_fallback :: proc (font: ^hrfb.font_t, metrics_tag: metrics_tag_t, position: ^hrfb.position_t)	---

/*
float hb_ot_metrics_get_variation (hb_font_t *font, hb_ot_metrics_tag_t metrics_tag);

Fetches metrics value corresponding to metrics_tag from font with the current font variation settings applied.

Inputs:
- font:			an hb_font_t object.
- metrics_tag:	tag of metrics value you like to fetch.
Returns:
- The requested metric value.

Since: 2.6.0
*/
metrics_get_variation :: proc (font: ^hrfb.font_t, metrics_tag: metrics_tag_t)	-> c.float ---

/*
hb_position_t hb_ot_metrics_get_x_variation (hb_font_t *font, hb_ot_metrics_tag_t metrics_tag);

Fetches horizontal metrics value corresponding to metrics_tag from font with the current font variation settings applied.

Inputs:
- font:			an hb_font_t object.
- metrics_tag:	tag of metrics value you like to fetch.
Returns:
- The requested metric value.

Since: 2.6.0
*/
metrics_get_x_variation :: proc (font: hrfb.font_t, metrics_tag: metrics_tag_t)	-> hrfb.position_t ---

/*
hb_position_t hb_ot_metrics_get_y_variation (hb_font_t *font, hb_ot_metrics_tag_t metrics_tag);

Fetches vertical metrics value corresponding to metrics_tag from font with the current font variation settings applied.

Inputs:
- font:			an hb_font_t object.
- metrics_tag:	tag of metrics value you like to fetch.
Returns:
- The requested metric value.

Since: 2.6.0
*/
metrics_get_y_variation :: proc (font: ^hrfb.font_t, metrics_tag: metrics_tag_t)	-> hrfb.position_t ---

/*******************
hb-ot-name — OpenType font name information

Functions for fetching name strings from OpenType fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-name.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-name.html
*******************/

/*
const hb_ot_name_entry_t * hb_ot_name_list_names (hb_face_t *face, unsigned int *num_entries);

Enumerates all available name IDs and language combinations. Returned array is owned by the face and should not be
modified. It can be used as long as face is alive.

Inputs:
- face:			font face.
- num_entries:	number of returned entries. [out][optional]
Returns:
- Array of available name entries. [transfer none][array length=num_entries]

Since: 2.1.0
*/
name_list_names :: proc (face: ^hrfb.face_t, num_entries: ^c.uint)	-> /*const*/ [^]name_entry_t ---

/*
unsigned int hb_ot_name_get_utf16 (hb_face_t *face, hb_ot_name_id_t name_id, hb_language_t language,
	unsigned int *text_size, uint16_t *text);

Fetches a font name from the OpenType 'name' table. If language is HB_LANGUAGE_INVALID, English ("en") is assumed.
Returns string in UTF-16 encoding. A NUL terminator is always written for convenience, and isn't included in the
output text_size.

Inputs:
- face:			font face.
- name_id:		OpenType name identifier to fetch.
- language:		language to fetch the name for.
- text_size:	input size of text buffer, and output size of text written to buffer. [inout][optional]
- text:			buffer to write fetched name into. [out caller-allocates][array length=text_size]
Returns:
- full length of the requested string, or 0 if not found.

Since: 2.1.0
*/
name_get_utf16 :: proc (face: ^hrfb.face_t, name_id: name_id_t, language: hrfb.language_t, text_size: ^c.uint, text: [^]u16)	-> c.uint ---

/*
unsigned int hb_ot_name_get_utf32 (hb_face_t *face, hb_ot_name_id_t name_id, hb_language_t language, unsigned int *text_size, uint32_t *text);

Fetches a font name from the OpenType 'name' table. If language is HB_LANGUAGE_INVALID, English ("en") is assumed.
Returns string in UTF-32 encoding. A NUL terminator is always written for convenience, and isn't included in the
output text_size.

Inputs:
- face:			font face.
- name_id:		OpenType name identifier to fetch.
- language:		language to fetch the name for.
- text_size:	input size of text buffer, and output size of text written to buffer. [inout][optional]
- text:			buffer to write fetched name into. [out caller-allocates][array length=text_size]
Returns:
- full length of the requested string, or 0 if not found.

Since: 2.1.0
*/
name_get_utf32 :: proc (face: ^hrfb.face_t, name_id: name_id_t, language: hrfb.language_t, text_size: ^c.uint, text: [^]u32)	-> c.uint ---

/*
unsigned int hb_ot_name_get_utf8 (hb_face_t *face, hb_ot_name_id_t name_id, hb_language_t language, unsigned int *text_size, char *text);

Fetches a font name from the OpenType 'name' table. If language is HB_LANGUAGE_INVALID, English ("en") is assumed.
Returns string in UTF-8 encoding. A NUL terminator is always written for convenience, and isn't included in the
output text_size.

Inputs:
- face:			font face.
- name_id:		OpenType name identifier to fetch.
- language:		language to fetch the name for.
- text_size:	input size of text buffer, and output size of text written to buffer. [inout][optional]
- text			buffer to write fetched name into. [out caller-allocates][array length=text_size]
Returns:
- full length of the requested string, or 0 if not found.

Since: 2.1.0
*/
name_get_utf8 :: proc (face: ^hrfb.face_t, name_id: name_id_t, language: hrfb.language_t, text_size: ^c.uint, text: [^]u8)	-> c.uint ---

/*******************
hb-ot-shape — OpenType shaping support

Support functions for OpenType shaping related queries.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-shape.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-shape.html
*******************/

/*
void hb_ot_shape_glyphs_closure (hb_font_t *font, hb_buffer_t *buffer, const hb_feature_t *features,
	unsigned int num_features, hb_set_t *glyphs);

Computes the transitive closure of glyphs needed for a specified input buffer under the given font and feature list.
The closure is computed as a set, not as a list.

Inputs:
- font:			hb_font_t to work upon
- buffer:		The input buffer to compute from
- features:		The features enabled on the buffer. [array length=num_features]
- num_features:	The number of features enabled on the buffer
- glyphs:		The hb_set_t set of glyphs comprising the transitive closure of the query. 	[out]

Since: 0.9.2
*/
shape_glyphs_closure :: proc (font: ^hrfb.font_t,  buffer: ^hrfb.buffer_t, features: /*const*/ ^hrfb.feature_t,
	num_features: c.uint, glyphs: ^hrfb.set_t) ---

/*******************
hb-ot-var — OpenType Font Variations

Functions for fetching information about OpenType Variable Fonts.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-ot-var.h
		https://harfbuzz.github.io/harfbuzz-hb-ot-var.html
*******************/

/*
hb_bool_t hb_ot_var_has_data (hb_face_t *face);

Tests whether a face includes any OpenType variation data in the fvar table.

Inputs:
- face:	The hb_face_t to work on
Returns:
- true if data found, false otherwise

Since: 1.4.2
*/
var_has_data :: proc (face: ^hrfb.face_t)	-> hrfb.bool_t ---

/*
hb_bool_t hb_ot_var_find_axis_info (hb_face_t *face, hb_tag_t axis_tag, hb_ot_var_axis_info_t *axis_info);

Fetches the variation-axis information corresponding to the specified axis tag in the specified face.

Inputs:
- face:			hb_face_t to work upon
- axis_tag:		The hb_tag_t of the variation axis to query
- axis_info:	The hb_ot_var_axis_info_t of the axis tag queried. [out]
Returns:
- true if data found, false otherwise

Since: 2.2.0
*/
var_find_axis_info :: proc (face: ^hrfb.face_t, axis_tag: hrfb.tag_t, axis_info: ^var_axis_info_t)	-> hrfb.bool_t ---

/*
unsigned int hb_ot_var_get_axis_count (hb_face_t *face);

Fetches the number of OpenType variation axes included in the face.

Inputs:
- face:	The hb_face_t to work on
Returns:
- the number of variation axes defined

Since: 1.4.2
*/
var_get_axis_count :: proc (face: ^hrfb.face_t)	-> c.uint ---

/*
unsigned int hb_ot_var_get_axis_infos (hb_face_t *face, unsigned int start_offset, unsigned int *axes_count, hb_ot_var_axis_info_t *axes_array);

Fetches a list of all variation axes in the specified face. The list returned will begin at the offset provided.

Inputs:
- face:			hb_face_t to work upon
- start_offset:	offset of the first lookup to retrieve
- axes_count:	Input = the maximum number of variation axes to return; Output = the actual number of variation axes returned (may be zero). [inout][optional]
- axes_array:	The array of variation axes found. [out caller-allocates][array length=axes_count]
Returns:
- the number of variation axes in the face

Since: 2.2.0
*/
var_get_axis_infos :: proc (face: ^hrfb.face_t, start_offset: c.uint, axes_count: ^c.uint, axes_array: ^var_axis_info_t)	-> c.uint ---

/*
unsigned int hb_ot_var_get_named_instance_count (hb_face_t *face);

Fetches the number of named instances included in the face.

Inputs:
- face:	The hb_face_t to work on
Returns:
- the number of named instances defined

Since: 2.2.0
*/
var_get_named_instance_count :: proc (face: ^hrfb.face_t)	-> c.uint ---

/*
hb_ot_name_id_t hb_ot_var_named_instance_get_subfamily_name_id (hb_face_t *face, unsigned int instance_index);

Fetches the name table Name ID that provides display names for the "Subfamily name" defined for the given named instance in the face.

Inputs:
- face:				The hb_face_t to work on
- instance_index:	The index of the named instance to query
Returns:
- the Name ID found for the Subfamily name

Since: 2.2.0
*/
var_named_instance_get_subfamily_name_id :: proc (face: ^hrfb.face_t, instance_index: c.uint)	-> name_id_t ---

/*
hb_ot_name_id_t hb_ot_var_named_instance_get_postscript_name_id (hb_face_t *face, unsigned int instance_index);

Fetches the name table Name ID that provides display names for the "PostScript name" defined for the given named instance in the face.

Inputs:
- face:				The hb_face_t to work on
- instance_index:	The index of the named instance to query
Returns:
- the Name ID found for the PostScript name

Since: 2.2.0
*/
var_named_instance_get_postscript_name_id :: proc (face: ^hrfb.face_t, instance_index: c.uint)	-> name_id_t ---

/*
unsigned int hb_ot_var_named_instance_get_design_coords (hb_face_t *face, unsigned int instance_index, unsigned int *coords_length, float *coords);

Fetches the design-space coordinates corresponding to the given named instance in the face.

Inputs:
- face:				The hb_face_t to work on
- instance_index:	The index of the named instance to query
- coords_length:	Input = the maximum number of coordinates to return; Output = the actual number of coordinates returned (may be zero). [inout][optional]
- coords:			The array of coordinates found for the query. [out][array length=coords_length]
Returns:
- the number of variation axes in the face

Since: 2.2.0
*/
var_named_instance_get_design_coords :: proc (face: ^hrfb.face_t, instance_index: c.uint, coords_length: ^c.uint, coords: [^]c.float)	-> c.uint ---

/*
void hb_ot_var_normalize_variations (hb_face_t *face, const hb_variation_t *variations, unsigned int variations_length, int *coords, unsigned int coords_length);

Normalizes all of the coordinates in the given list of variation axes.

Inputs:
- face:					The hb_face_t to work on
- variations:			The array of variations to normalize
- variations_length:	The number of variations to normalize
- coords:				The array of normalized coordinates. [out][array length=coords_length]
- coords_length:		The length of the coordinate array

Since: 1.4.2
*/
var_normalize_variations :: proc (face: ^hrfb.face_t, variations: /*const*/ ^hrfb.variation_t, variations_length: c.uint,
	coords: [^]c.int, coords_length: c.uint)	---

/*
void hb_ot_var_normalize_coords (hb_face_t *face, unsigned int coords_length, const float *design_coords, int *normalized_coords);

Normalizes the given design-space coordinates. The minimum and maximum values for the axis are mapped to the
interval [-1,1], with the default axis value mapped to 0.

The normalized values have 14 bits of fixed-point sub-integer precision as per OpenType specification.

Any additional scaling defined in the face's avar table is also applied, as described at
https://docs.microsoft.com/en-us/typography/opentype/spec/avar

Inputs:
- face:					The hb_face_t to work on
- coords_length:		The length of the coordinate array
- design_coords:		The design-space coordinates to normalize
- normalized_coords:	The normalized coordinates. [out]

Since: 1.4.2
*/
var_normalize_coords :: proc (face: ^hrfb.face_t, coords_length: c.uint, design_coords: /*const*/ [^]c.float, normalized_coords: [^]c.int)	---

}
