/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

font.odin - Types and functions for managing fonts.

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
author: Maurizio M. Gavioli, 2024-08-06

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-font.h
		https://harfbuzz.github.io/harfbuzz-hb-font.html
*/

/*
hb-font — Font objects

Functions for working with font objects.

A font object represents a font face at a specific size and with certain other parameters (pixels-per-em, points-per-em,
* variation settings) specified. Font objects are created from font face objects, and are used as input to hb_shape(),
* among other things.

Client programs can optionally pass in their own functions that implement the basic, lower-level queries of font objects.
* This set of font functions is defined by the virtual methods in hb_font_funcs_t.

HarfBuzz provides a built-in set of lightweight default functions for each method in hb_font_funcs_t.

The default font functions are implemented in terms of the hb_font_funcs_t methods of the parent font object. This allows
* client programs to override only the methods they need to, and otherwise inherit the parent font's implementation, if any.
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

/* #define HB_FONT_NO_VAR_NAMED_INSTANCE 0xFFFFFFFF

Constant signifying that a font does not have any named-instance index set. This is the default of a font.

Since: 7.0.0
*/
FONT_NO_VAR_NAMED_INSTANCE : int : 0xFFFFFFFF

/*
typedef struct hb_font_t hb_font_t;

Data type for holding fonts.
*/
font_t :: struct #packed	{}					// opaque structure

/**
 * typedef struct hb_font_funcs_t hb_font_funcs_t;
 *
 * Data type containing a set of virtual methods used for working on #hb_font_t font objects.
 *
 * HarfBuzz provides a lightweight default function for each of the methods in #hb_font_funcs_t. Client programs can
 * implement their own replacements for the individual font functions, as needed, and replace the default by calling
 * the setter for a method.
 **/
font_funcs_t :: struct #packed	{}			// opaque structure

/*
hb_position_t (*hb_font_get_glyph_advance_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t glyph, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the advance for a specified glyph, in horizontal-direction text segments. Advances must be
returned in an hb_position_t output parameter.

- font		hb_font_t to work upon
- font_data	font user data pointer
- glyph		The glyph ID to query
- user_data	User data pointer passed by the caller
- Returns	The advance of glyph within font
*/
font_get_glyph_advance_func_t	:: #type proc "c"(font: ^font_t, font_data: rawptr, glyph: codepoint_t, user_data: rawptr)	-> position_t

/*
typedef hb_font_get_glyph_advance_func_t hb_font_get_glyph_h_advance_func_t;

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the advance for a specified glyph, in horizontal-direction text segments.
Advances must be returned in an hb_position_t output parameter.
*/
font_get_glyph_h_advance_func_t :: font_get_glyph_advance_func_t

/*
typedef hb_font_get_glyph_advance_func_t hb_font_get_glyph_v_advance_func_t;

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the advance for a specified glyph, in vertical-direction text segments.
Advances must be returned in an hb_position_t output parameter.
*/
font_get_glyph_v_advance_func_t :: font_get_glyph_advance_func_t

/*
void (*hb_font_get_glyph_advances_func_t) (hb_font_t *font, void *font_data, unsigned int count, const hb_codepoint_t *first_glyph,
	unsigned  glyph_stride, hb_position_t *first_advance, unsigned  advance_stride, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the advances for a sequence of glyphs.

- font				hb_font_t to work upon
- font_data			font user data pointer
- count				The number of glyph IDs in the sequence queried
- first_glyph		The first glyph ID to query
- glyph_stride		The stride between successive glyph IDs
- first_advance		The first advance retrieved. [out]
- advance_stride	The stride between successive advances
- user_data			User data pointer passed by the caller
*/
font_get_glyph_advances_func_t	:: #type proc "c"(font: ^font_t, font_data: rawptr, count: c.uint, first_glyph: /*const*/ ^codepoint_t,
	glyph_stride: c.uint, first_advance: ^position_t, advance_stride: c.uint, user_data: rawptr)

/**
 * typedef hb_font_get_glyph_advances_func_t hb_font_get_glyph_h_advances_func_t;
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advances for a sequence of glyphs, in horizontal-direction text segments.
 **/
font_get_glyph_h_advances_func_t :: font_get_glyph_advances_func_t

 /**
  * typedef hb_font_get_glyph_advances_func_t hb_font_get_glyph_v_advances_func_t;
  *
  * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
  *
  * This method should retrieve the advances for a sequence of glyphs, in vertical-direction text segments.
  **/
font_get_glyph_v_advances_func_t :: font_get_glyph_advances_func_t
 
 /*
typedef hb_font_get_font_extents_func_t hb_font_get_font_h_extents_func_t;

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the extents for a font, for horizontal-direction text segments.
Extents must be returned in an hb_glyph_extents output parameter.
*/
font_get_font_h_extents_func_t	:: font_get_font_extents_func_t

/*
typedef hb_font_get_font_extents_func_t hb_font_get_font_v_extents_func_t;

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the extents for a font, for vertical-direction text segments.
Extents must be returned in an hb_glyph_extents output parameter.
*/
font_get_font_v_extents_func_t :: font_get_font_extents_func_t

/*
hb_bool_t (*hb_font_get_glyph_contour_point_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t glyph, unsigned int point_index, hb_position_t *x, hb_position_t *y, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the (X,Y) coordinates (in font units) for a specified contour point in a glyph. Each
coordinate must be returned as an hb_position_t output parameter.

- font			hb_font_t to work upon
- font_data		font user data pointer
- glyph			The glyph ID to query
- point_index	The contour-point index to query
- x				The X value retrieved for the contour point. [out]
- y				The Y value retrieved for the contour point. [out]
- user_data		User data pointer passed by the caller
- Returns		true if data found, false otherwise
hb_font_funcs_set_glyph_contour_point_func ()
*/
font_get_glyph_contour_point_func_t	:: #type proc "c"(font: ^font_t, font_data: rawptr, glyph: codepoint_t, point_index: c.uint, x: ^position_t, y: ^position_t, user_data: rawptr)	-> bool_t

/*
hb_bool_t (*hb_font_get_glyph_from_name_func_t) (hb_font_t *font, void *font_data, const char *name, int len, hb_codepoint_t *glyph, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the glyph ID that corresponds to a glyph-name string.

- font		hb_font_t to work upon
- font_data	font user data pointer
- name		The name string to query. [array length=len]
- len		The length of the name queried
- glyph		The glyph ID retrieved. [out]
- user_data	User data pointer passed by the caller
- Returns	true if data found, false otherwise
*/
font_get_glyph_from_name_func_t	:: #type proc "c"(font: ^font_t, font_data: rawptr, name: cstring, len: c.int,
	glyph: ^codepoint_t, user_data: rawptr)	-> bool_t

/*
hb_bool_t (*hb_font_get_glyph_extents_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t glyph, hb_glyph_extents_t *extents, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the extents for a specified glyph. Extents must be returned in an hb_glyph_extents output parameter.

- font		hb_font_t to work upon
- font_data	font user data pointer
- glyph		The glyph ID to query
- extents	The hb_glyph_extents_t retrieved. 	[out]
- user_data	User data pointer passed by the caller
- Returns	true if data found, false otherwise
*/
font_get_glyph_extents_func_t	:: #type proc "c"(font: ^font_t, font_data: rawptr, glyph: codepoint_t,
	extents: ^glyph_extents_t, user_data: rawptr)	-> bool_t

/**
 * typedef hb_position_t (*hb_font_get_glyph_kerning_func_t) (hb_font_t *font, void *font_data,
	hb_codepoint_t first_glyph, hb_codepoint_t second_glyph, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object. This method should retrieve the kerning-adjustment
value for a glyph-pair in the specified font, for horizontal text segments.

- font		hb_font_t to work upon
- font_data	font user data pointer
- first_glyph	The glyph ID of the first glyph in the glyph pair
- second_glyph	The glyph ID of the second glyph in the glyph pair
- user_data		User data pointer passed by the caller
*/
font_get_glyph_kerning_func_t :: #type proc "c" (font: ^font_t, font_data: rawptr,
	first_glyph: codepoint_t, second_glyph: codepoint_t, user_data: rawptr)	-> position_t

/**
 * typedef hb_font_get_glyph_kerning_func_t hb_font_get_glyph_h_kerning_func_t;
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the kerning-adjustment value for a glyph-pair in
 * the specified font, for horizontal text segments.
 **/
font_get_glyph_h_kerning_func_t :: font_get_glyph_kerning_func_t
 
/*
hb_bool_t (*hb_font_get_glyph_origin_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t glyph, hb_position_t *x, hb_position_t *y, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the (X,Y) coordinates (in font units) of the origin for a glyph. Each coordinate must be
returned in an hb_position_t output parameter.

- font		hb_font_t to work upon
- font_data	font user data pointer
- glyph		The glyph ID to query
- x			The X coordinate of the origin. [out]
- y			The Y coordinate of the origin. [out]
- user_data	User data pointer passed by the caller
- Returns	true if data found, false otherwise
*/
font_get_glyph_origin_func_t	:: #type proc "c"(font: ^font_t, font_data: rawptr, glyph: codepoint_t, x: ^position_t, y: ^position_t, user_data: rawptr)	-> bool_t

/**
 * typedef hb_font_get_glyph_origin_func_t hb_font_get_glyph_h_origin_func_t;
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the (X,Y) coordinates (in font units) of the origin for a glyph,
 * for horizontal-direction text segments. Each coordinate must be returned in an #hb_position_t output parameter.
 **/
font_get_glyph_h_origin_func_t :: font_get_glyph_origin_func_t

 /**
  * hb_font_get_glyph_v_origin_func_t:
  *
  * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
  *
  * This method should retrieve the (X,Y) coordinates (in font units) of the origin for a glyph,
  * for vertical-direction text segments. Each coordinate must be returned in an #hb_position_t output parameter.
  **/
font_get_glyph_v_origin_func_t :: font_get_glyph_origin_func_t
 
 /*
hb_bool_t (*hb_font_get_glyph_name_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t glyph, char *name, unsigned int size, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the glyph name that corresponds to a glyph ID.
The name should be returned in a string output parameter.

- font		hb_font_t to work upon
- font_data	font user data pointer
- glyph		The glyph ID to query
- name		Name string retrieved for the glyph ID. [out][array length=size]
- size		Length of the glyph-name string retrieved
- user_data	User data pointer passed by the caller
- Returns	true if data found, false otherwise
*/
font_get_glyph_name_func_t	:: #type proc "c" (font: ^font_t, font_data: rawptr, glyph: codepoint_t, name: cstring, size: c.uint, user_data: rawptr)	-> bool_t

/*
void (*hb_font_draw_glyph_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t glyph, hb_draw_funcs_t *draw_funcs, void *draw_data, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

- font			hb_font_t to work upon
- font_data		font user data pointer
- glyph			The glyph ID to query
- draw_funcs	The draw functions to send the shape data to
- draw_data		The data accompanying the draw functions
- user_data		User data pointer passed by the caller

Since: 7.0.0
*/
font_draw_glyph_func_t	:: #type proc "c" (font: ^font_t, font_data: rawptr, glyph: codepoint_t, draw_funcs: ^draw_funcs_t, draw_data: rawptr, user_data: rawptr)

/*
void (*hb_font_paint_glyph_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t glyph, hb_paint_funcs_t *paint_funcs,
	void *paint_data, unsigned int palette_index, hb_color_t foreground, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

- font		hb_font_t to work upon
- font_data	font user data pointer
- glyph		The glyph ID to query
- paint_funcs	The paint functions to use
- paint_data	The data accompanying the paint functions
- palette_index	The color palette to use
- foreground	The foreground color
- user_data		User data pointer passed by the caller

Since: 7.0.0
*/
font_paint_glyph_func_t	:: #type proc "c" (font: ^font_t, font_data: rawptr, glyph: codepoint_t, paint_funcs: ^paint_funcs_t,
	paint_data: rawptr, palette_index: c.uint, foreground: color_t, user_data: rawptr);

/*
hb_bool_t (*hb_font_get_nominal_glyph_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t unicode, hb_codepoint_t *glyph, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the nominal glyph ID for a specified Unicode code point.
Glyph IDs must be returned in a hb_codepoint_t output parameter.

- font		hb_font_t to work upon
- font_data	font user data pointer
- unicode	The Unicode code point to query
- glyph		The glyph ID retrieved. [out]
- user_data	User data pointer passed by the caller
- Returns	true if data found, false otherwise
*/
font_get_nominal_glyph_func_t	:: #type proc "c" (font: ^font_t, font_data: rawptr, unicode: codepoint_t, glyph: ^codepoint_t, user_data: rawptr)	-> bool_t

/*
unsigned int (*hb_font_get_nominal_glyphs_func_t) (hb_font_t *font, void *font_data, unsigned int count, const hb_codepoint_t *first_unicode,
	unsigned int unicode_stride, hb_codepoint_t *first_glyph, unsigned int glyph_stride, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the nominal glyph IDs for a sequence of Unicode code points. Glyph IDs must be returned in a
hb_codepoint_t output parameter.

- font				hb_font_t to work upon
- font_data			font user data pointer
- count				number of code points to query
- first_unicode		The first Unicode code point to query
- unicode_stride	The stride between successive code points
- first_glyph		The first glyph ID retrieved. [out]
- glyph_stride		The stride between successive glyph IDs
- user_data			User data pointer passed by the caller
- Returns			the number of code points processed
*/
font_get_nominal_glyphs_func_t	:: #type proc "c" (font:^font_t, font_data: rawptr, count: c.uint, first_unicode: /*const*/ ^codepoint_t,
	unicode_stride: c.uint, first_glyph: ^codepoint_t, glyph_stride: c.uint, user_data: rawptr)	-> c.uint

/*
hb_bool_t (*hb_font_get_font_extents_func_t) (hb_font_t *font, void *font_data, hb_font_extents_t *extents, void *user_data);

This method should retrieve the extents for a font.

- font		hb_font_t to work upon
- font_data	font user data pointer
- extents	The font extents retrieved. [out]
- user_data	User data pointer passed by the caller
*/
font_get_font_extents_func_t	:: #type proc "c"(font: ^font_t, font_data: rawptr,
	extents: ^font_extents_t, user_data: rawptr)	-> bool_t

/**
 * hb_font_get_glyph_h_advance_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advance for a specified glyph, in horizontal-direction text segments. Advances must
 * be returned in an #hb_position_t output parameter.
 * 
 **/
//font_get_glyph_advance_func_t	:: #type proc "c" (???) ???

/**
 * hb_font_get_glyph_v_advance_func_t:
 *
 * A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 *
 * This method should retrieve the advance for a specified glyph, in vertical-direction text segments. Advances must
 * be returned in an #hb_position_t output parameter.
 * 
 **/
//font_font_get_glyph_advance_func_t	:: #type proc "c" (???) ???

/*
Font-wide extent values, measured in font units.

Note that typically ascender is positive and descender negative, in coordinate systems that grow up.

- hb_position_t	ascender	The height of typographic ascenders.
- hb_position_t descender	The depth of typographic descenders.
- hb_position_t line_gap	The suggested line-spacing gap.
typedef struct {
  hb_position_t ascender;
  hb_position_t descender;
  hb_position_t line_gap;
} hb_font_extents_t;
*/
font_extents_t :: struct #packed
{
	ascender:	position_t,
	descender:	position_t,
	line_gap:	position_t
}

/*
typedef struct {
  hb_position_t x_bearing;
  hb_position_t y_bearing;
  hb_position_t width;
  hb_position_t height;
} hb_glyph_extents_t;

Glyph extent values, measured in font units.

Note that height is negative, in coordinate systems that grow up.

- hb_position_t x_bearing	Distance from the x-origin to the left extremum of the glyph.
- hb_position_t y_bearing	Distance from the top extremum of the glyph to the y-origin.
- hb_position_t width		Distance from the left extremum of the glyph to the right extremum.
- hb_position_t height		Distance from the top extremum of the glyph to the bottom extremum.
*/
glyph_extents_t	:: struct #packed
{
	x_bearing:	position_t,
	y_bearing:	position_t,
	width:	position_t,
	height:	position_t
}

/*
hb_bool_t (*hb_font_get_variation_glyph_func_t) (hb_font_t *font, void *font_data, hb_codepoint_t unicode,
	hb_codepoint_t variation_selector, hb_codepoint_t *glyph, void *user_data);

A virtual method for the hb_font_funcs_t of an hb_font_t object.

This method should retrieve the glyph ID for a specified Unicode code point followed by a specified Variation Selector
code point. Glyph IDs must be returned in a hb_codepoint_t output parameter.

- font		hb_font_t to work upon
- font_data	font user data pointer
- unicode	The Unicode code point to query
- variation_selector	The variation-selector code point to query
- glyph		The glyph ID retrieved. [out]
- user_data	User data pointer passed by the caller
- Returns	true if data found, false otherwise
*/
font_get_variation_glyph_func_t	:: #type proc(font: ^font_t, font_data: rawptr, unicode: codepoint_t,
	variation_selector: codepoint_t, glyph: ^codepoint_t, user_data: rawptr)	-> bool_t

/**
typedef hb_bool_t (*hb_font_get_glyph_origins_func_t) (hb_font_t *font, void *font_data, unsigned int count,
	const hb_codepoint_t *first_glyph, unsigned glyph_stride, hb_position_t *first_x, unsigned x_stride,
	hb_position_t *first_y, unsigned y_stride, void *user_data);

 A virtual method for the #hb_font_funcs_t of an #hb_font_t object.
 
 This method should retrieve the (X,Y) coordinates (in scaled units) of the
 origin for each requested glyph. Each coordinate value must be returned in
 an #hb_position_t in the two output parameters.
 
 Inputs:
- font:			hb_font_t to work upon
- font_data:	font user data pointer
- first_glyph:	The first glyph ID to query
- count:		number of glyphs to query
- glyph_stride:	The stride between successive glyph IDs
- first_x:		The first origin X coordinate retrieved [out]
- x_stride:		The stride between successive origin X coordinates
- first_y:		The first origin Y coordinate retrieved [out]
- y_stride:		The stride between successive origin Y coordinates
- user_data:	User data pointer passed by the caller
Returns:
- `true` if data found, `false` otherwise

Since: 11.3.0
*/
font_get_glyph_origins_func_t :: #type proc (font: ^font_t, font_data: rawptr, count: c.uint,
	first_glyph: ^/*const*/ codepoint_t, glyph_stride: c.uint, first_x: ^position_t, x_stride: c.uint,
	first_y: ^position_t, y_stride: c.uint, user_data: rawptr) -> bool_t

/*
typedef hb_font_get_glyph_origins_func_t hb_font_get_glyph_h_origins_func_t;

A virtual method for the #hb_font_funcs_t of an #hb_font_t object.

This method should retrieve the (X,Y) coordinates (in scaled units) of the
origin for requested glyph, for horizontal-direction text segments. Each
coordinate must be returned in a the x/y #hb_position_t output parameters.

Since: 11.3.0
*/
font_get_glyph_h_origins_func_t :: font_get_glyph_origins_func_t;

/**
typedef hb_font_get_glyph_origins_func_t hb_font_get_glyph_v_origins_func_t;

A virtual method for the #hb_font_funcs_t of an #hb_font_t object.

This method should retrieve the (X,Y) coordinates (in scaled units) of the
origin for requested glyph, for vertical-direction text segments. Each
coordinate must be returned in a the x/y #hb_position_t output parameters.

Since: 11.3.0
*/
font_get_glyph_v_origins_func_t :: font_get_glyph_origins_func_t;

//******************
// FUNCTIONS
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

//*************
// Since 0.9.2
//*************

/*
void hb_font_add_glyph_origin_for_direction(hb_font_t *font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t *x, hb_position_t *y);

Adds the origin coordinates to an (X,Y) point coordinate, in the specified glyph ID in the specified font.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction .

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- direction	The direction of the text segment
- x			Input = The original X coordinate Output = The X coordinate plus the X-coordinate of the origin. [inout]
- y			Input = The original Y coordinate Output = The Y coordinate plus the Y-coordinate of the origin. [inout]

Since: 0.9.2
*/
font_add_glyph_origin_for_direction	:: proc(font: ^font_t, glyph: codepoint_t, direction: direction_t, x: ^position_t, y: position_t)	---

/*
hb_font_t * hb_font_create (hb_face_t *face);

Constructs a new font object from the specified face.
Note: If face's index value (as passed to hb_face_create() has non-zero top 16-bits, those bits minus one are passed to
hb_font_set_var_named_instance(), effectively loading a named-instance of a variable font, instead of the
default-instance. This allows specifying which named-instance to load by default when creating the face.

- face		a face.
- Returns	The new font object. [transfer full]

Since: 0.9.2
*/
font_create	:: proc(face: ^face_t)	-> ^font_t ---

/*
hb_font_t * hb_font_create_sub_font (hb_font_t *parent);

Constructs a sub-font font object from the specified parent font, replicating the parent's properties.

- parent	The parent font object
- Returns	The new sub-font font object. [transfer full]

Since: 0.9.2
*/
font_create_sub_font	:: proc(parent: ^font_t)	-> ^font_t ---

/*
hb_font_t * hb_font_get_empty (void);

Fetches the empty font object.

- Returns	The empty font object. [transfer full]

Since: 0.9.2
*/
font_get_empty	:: proc()	-> ^font_t ---

/*
hb_font_t * hb_font_reference (hb_font_t *font);

Increases the reference count on the given font object.

- font		hb_font_t to work upon
- Returns	The font object. [transfer full]

Since: 0.9.2
*/
font_reference	:: proc(font: ^font_t)	-> ^font_t ---

/*
void hb_font_destroy (hb_font_t *font);

Decreases the reference count on the given font object. When the reference count reaches zero, the font is destroyed, freeing all memory.

- font		hb_font_t to work upon

Since: 0.9.2
*/
font_destroy	:: proc(font: ^font_t)	---

/*
hb_bool_t hb_font_set_user_data (hb_font_t *font, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified font object.

- font		hb_font_t to work upon
- key		The user-data key
- data		A pointer to the user data
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 0.9.2
*/
font_set_user_data	:: proc(font: ^font_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_font_get_user_data (const hb_font_t *font, hb_user_data_key_t *key);

Fetches the user-data object associated with the specified key, attached to the specified font object.

- font		hb_font_t to work upon
- key		The user-data key to query
- Returns	Pointer to the user data. [transfer none]

Since: 0.9.2
*/
font_get_user_data	:: proc(font: /*const*/ ^font_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_font_make_immutable (hb_font_t *font);

Makes font immutable.

- font		hb_font_t to work upon

Since: 0.9.2
*/
font_make_immutable	:: proc(font: ^font_t)	---

/*
hb_bool_t hb_font_is_immutable (hb_font_t *font);

Tests whether a font object is immutable.

- font		hb_font_t to work upon
- Returns	true if font is immutable, false otherwise

Since: 0.9.2
*/
font_is_immutable	:: proc(font: ^font_t)	-> bool_t ---

/*
void hb_font_set_face (hb_font_t *font, hb_face_t *face);

Sets face as the font-face value of font.

- font		hb_font_t to work upon
- face		The hb_face_t to assign

Since: 1.4.3
*/
font_set_face	:: proc(font: ^font_t, face: ^face_t)	---

/*
hb_face_t * hb_font_get_face (hb_font_t *font);

Fetches the face associated with the specified font object.

- font		hb_font_t to work upon
- Returns	The hb_face_t value. [transfer none]

Since: 0.9.2
*/
font_get_face	:: proc(font: ^font_t)	-> ^face_t ---

/*
hb_bool_t hb_font_get_glyph (hb_font_t *font, hb_codepoint_t unicode, hb_codepoint_t variation_selector, hb_codepoint_t *glyph);

Fetches the glyph ID for a Unicode code point in the specified font, with an optional variation selector.

If variation_selector is 0, calls hb_font_get_nominal_glyph(); otherwise calls hb_font_get_variation_glyph().

- font					hb_font_t to work upon
- unicode				The Unicode code point to query
- variation_selector	A variation-selector code point
- glyph					The glyph ID retrieved. [out]
- Returns				true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph	:: proc(font: ^font_t, unicode: codepoint_t, variation_selector: codepoint_t, glyph: ^codepoint_t)	-> bool_t ---

/*
void hb_font_get_glyph_advance_for_direction (hb_font_t *font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t *x, hb_position_t *y);

Fetches the advance for a glyph ID from the specified font, in a text segment of the specified direction.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction .

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- direction	The direction of the text segment
- x			The horizontal advance retrieved. [out]
- y			The vertical advance retrieved. [out]

Since: 0.9.2
*/
font_get_glyph_advance_for_direction	:: proc(font: ^font_t, glyph: codepoint_t, direction: direction_t, x: ^position_t, y: ^position_t)	---

/*
void hb_font_get_glyph_advances_for_direction (hb_font_t *font, hb_direction_t direction, unsigned int count, const hb_codepoint_t *first_glyph, hb_position_t *first_advance, unsigned  advance_stride);

Fetches the advances for a sequence of glyph IDs in the specified font, in a text segment of the specified direction.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction .

- font				hb_font_t to work upon
- direction			The direction of the text segment
- count				The number of glyph IDs in the sequence queried
- first_glyph		The first glyph ID to query
- glyph_stride		The stride between successive glyph IDs
- first_advance		The first advance retrieved. [out]
- advance_stride	The stride between successive advances. [out]

Since: 1.8.6
*/
font_get_glyph_advances_for_direction	:: proc(font: ^font_t, direction: direction_t, count: c.uint,
	first_glyph: /*const*/ ^codepoint_t, first_advance: ^position_t, advance_stride: c.uint)	---

/*
hb_bool_t hb_font_get_glyph_contour_point (hb_font_t *font, hb_codepoint_t glyph, unsigned int point_index, hb_position_t *x, hb_position_t *y);

Fetches the (x,y) coordinates of a specified contour-point index in the specified glyph, within the specified font.

- font			hb_font_t to work upon
- glyph			The glyph ID to query
- point_index	The contour-point index to query
- x				The X value retrieved for the contour point. [out]
- y				The Y value retrieved for the contour point. [out]
- Returns		true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_contour_point	:: proc(font: ^font_t, glyph: codepoint_t, point_index: c.uint, x: ^position_t, y: ^position_t)	-> bool_t ---

/*
hb_bool_t hb_font_get_glyph_contour_point_for_origin (hb_font_t *font, hb_codepoint_t glyph, unsigned int point_index,
	hb_direction_t direction, hb_position_t *x, hb_position_t *y);

Fetches the (X,Y) coordinates of a specified contour-point index in the specified glyph ID in the specified font, with
respect to the origin in a text segment in the specified direction.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction.

- font			hb_font_t to work upon
- glyph			The glyph ID to query
- point_index	The contour-point index to query
- direction		The direction of the text segment
- x				The X value retrieved for the contour point. [out]
- y				The Y value retrieved for the contour point. [out]
- Returns		true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_contour_point_for_origin	:: proc(font: ^font_t, glyph: codepoint_t, point_index: c.uint, direction: direction_t,
	x: ^position_t, y: ^position_t)	-> bool_t ---

/*
hb_bool_t hb_font_get_glyph_extents (hb_font_t *font, hb_codepoint_t glyph, hb_glyph_extents_t *extents);

Fetches the hb_glyph_extents_t data for a glyph ID in the specified font.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- extents	The hb_glyph_extents_t retrieved. [out]
- Returns	true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_extents	:: proc(font: ^font_t, glyph: codepoint_t, extents: ^glyph_extents_t)	-> bool_t ---

/*
hb_bool_t hb_font_get_glyph_extents_for_origin (hb_font_t *font, hb_codepoint_t glyph, hb_direction_t direction, hb_glyph_extents_t *extents);

Fetches the hb_glyph_extents_t data for a glyph ID in the specified font, with respect to the origin in a text segment in the specified direction.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction .

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- direction	The direction of the text segment
- extents	The hb_glyph_extents_t retrieved. [out]
- Returns	true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_extents_for_origin	:: proc(font: ^font_t, glyph: codepoint_t, direction: direction_t, extents: ^glyph_extents_t)	-> bool_t ---

/*
hb_bool_t hb_font_get_glyph_from_name (hb_font_t *font, const char *name, int len, hb_codepoint_t *glyph);

Fetches the glyph ID that corresponds to a name string in the specified font.
Note: len == -1 means the name string is null-terminated.

- font		hb_font_t to work upon
- name		The name string to query. [array length=len]
- len		The length of the name queried
- glyph		The glyph ID retrieved. [out]
- Returns	true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_from_name	:: proc(font: ^font_t, name: cstring, len: c.int, glyph: ^codepoint_t)	-> bool_t ---

/*
hb_position_t hb_font_get_glyph_h_advance (hb_font_t *font, hb_codepoint_t glyph);

Fetches the advance for a glyph ID in the specified font, for horizontal text segments.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- Returns	The advance of glyph within font

Since: 0.9.2
*/
font_get_glyph_h_advance	:: proc(font: ^font_t, glyph: codepoint_t)	-> position_t ---

/*
hb_position_t hb_font_get_glyph_v_advance (hb_font_t *font, hb_codepoint_t glyph);

Fetches the advance for a glyph ID in the specified font, for vertical text segments.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- Returns	The advance of glyph within font

Since: 0.9.2
*/
font_get_glyph_v_advance	:: proc(font: ^font_t, glyph: codepoint_t)	-> position_t ---

/*
void hb_font_get_glyph_h_advances (hb_font_t *font, unsigned int count, const hb_codepoint_t *first_glyph, unsigned  glyph_stride, hb_position_t *first_advance, unsigned  advance_stride);

Fetches the advances for a sequence of glyph IDs in the specified font, for horizontal text segments.

- font				hb_font_t to work upon
- count				The number of glyph IDs in the sequence queried
- first_glyph		The first glyph ID to query
- glyph_stride		The stride between successive glyph IDs
- first_advance		The first advance retrieved. [out]
- advance_stride	The stride between successive advances

Since: 1.8.6
*/
font_get_glyph_h_advances	:: proc(font: ^font_t, count: c.uint, first_glyph: /*const*/ ^codepoint_t,
	glyph_stride: c.uint, first_advance: ^position_t, advance_stride: c.uint)	---

/*
void hb_font_get_glyph_v_advances (hb_font_t *font, unsigned int count, const hb_codepoint_t *first_glyph, unsigned  glyph_stride, hb_position_t *first_advance, unsigned  advance_stride);

Fetches the advances for a sequence of glyph IDs in the specified font, for vertical text segments.

- font				hb_font_t to work upon
- count				The number of glyph IDs in the sequence queried
- first_glyph		The first glyph ID to query
- glyph_stride		The stride between successive glyph IDs
- first_advance		The first advance retrieved. [out]
- advance_stride	The stride between successive advances. [out]

Since: 1.8.6
*/
font_get_glyph_v_advances	:: proc(font: ^font_t, count: c.uint, first_glyph: /*const*/ ^codepoint_t,
	glyph_stride: c.uint, first_advance: ^position_t, advance_stride: c.uint)	---

/*
hb_position_t hb_font_get_glyph_h_kerning (hb_font_t *font, hb_codepoint_t left_glyph, hb_codepoint_t right_glyph);

Fetches the kerning-adjustment value for a glyph-pair in the specified font, for horizontal text segments.
It handles legacy kerning only (as returned by the corresponding hb_font_funcs_t function).

- font		hb_font_t to work upon
- left_glyph	The glyph ID of the left glyph in the glyph pair
- right_glyph	The glyph ID of the right glyph in the glyph pair
- Returns		The kerning adjustment value

Since: 0.9.2
*/
font_get_glyph_h_kerning	:: proc(font: ^font_t, left_glyph: codepoint_t, right_glyph: codepoint_t)	-> position_t ---

/*
void hb_font_get_glyph_kerning_for_direction (hb_font_t *font, hb_codepoint_t first_glyph, hb_codepoint_t second_glyph,
	hb_direction_t direction, hb_position_t *x, hb_position_t *y);

Fetches the kerning-adjustment value for a glyph-pair in the specified font.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction .

- font			hb_font_t to work upon
- first_glyph	The glyph ID of the first glyph in the glyph pair to query
- second_glyph	The glyph ID of the second glyph in the glyph pair to query
- direction		The direction of the text segment
- x				The horizontal kerning-adjustment value retrieved. [out]
- y				The vertical kerning-adjustment value retrieved. [out]

Since: 0.9.2
*/
font_get_glyph_kerning_for_direction	:: proc(font: ^font_t, first_glyph: codepoint_t, second_glyph: codepoint_t,
	direction: direction_t, x: ^position_t, y: ^position_t)	---

/*
hb_bool_t hb_font_get_glyph_h_origin (hb_font_t *font, hb_codepoint_t glyph, hb_position_t *x, hb_position_t *y);

Fetches the (X,Y) coordinates of the origin for a glyph ID in the specified font, for horizontal text segments.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- x			The X coordinate of the origin. [out]
- y			The Y coordinate of the origin. [out]
- Returns	true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_h_origin	:: proc(font: ^font_t, glyph: codepoint_t, x: ^position_t, y: ^position_t)	-> bool_t ---

/*
hb_bool_t hb_font_get_glyph_v_origin (hb_font_t *font, hb_codepoint_t glyph, hb_position_t *x, hb_position_t *y);

Fetches the (X,Y) coordinates of the origin for a glyph ID in the specified font, for vertical text segments.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- x			The X coordinate of the origin. [out]
- y			The Y coordinate of the origin. [out]
- Returns	true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_v_origin	:: proc(font: ^font_t, glyph: codepoint_t, x: ^position_t, y: ^position_t)	-> bool_t ---

/*
void hb_font_get_glyph_origin_for_direction (hb_font_t *font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t *x, hb_position_t *y);

Fetches the (X,Y) coordinates of the origin for a glyph in the specified font.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- direction	The direction of the text segment
- x			The X coordinate retrieved for the origin. [out]
- y			The Y coordinate retrieved for the origin. [out]

Since: 0.9.2
*/
font_get_glyph_origin_for_direction	:: proc(font: ^font_t, glyph: codepoint_t, direction: direction_t, x: ^position_t, y: ^position_t)	---

/*
hb_bool_t hb_font_get_glyph_name (hb_font_t *font, hb_codepoint_t glyph, char *name, unsigned int size);

Fetches the glyph-name string for a glyph ID in the specified font .

According to the OpenType specification, glyph names are limited to 63 characters and can only contain (a subset of) ASCII.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- name		Name string retrieved for the glyph ID. [out][array length=size]
- size		Length of the glyph-name string retrieved
- Returns	true if data found, false otherwise

Since: 0.9.2
*/
font_get_glyph_name	:: proc(font: ^font_t, glyph: codepoint_t, name: [^]u8, size: c.uint)	-> bool_t ---

/*
void hb_font_draw_glyph (hb_font_t *font, hb_codepoint_t glyph, hb_draw_funcs_t *dfuncs, void *draw_data);

Draws the outline that corresponds to a glyph in the specified font .

The outline is returned by way of calls to the callbacks of the dfuncs objects, with draw_data passed to them.

- font		hb_font_t to work upon
- glyph		The glyph ID
- dfuncs	hb_draw_funcs_t to draw to
- draw_data	User data to pass to draw callbacks

Since: 7.0.0
*/
font_draw_glyph	:: proc(font: ^font_t, glyph: codepoint_t, dfuncs: ^draw_funcs_t, draw_data: rawptr)	---

/*
void hb_font_paint_glyph (hb_font_t *font, hb_codepoint_t glyph, hb_paint_funcs_t *pfuncs, void *paint_data, unsigned int palette_index, hb_color_t foreground);

Paints the glyph.

The painting instructions are returned by way of calls to the callbacks of the funcs object, with paint_data passed to them.

If the font has color palettes (see hb_ot_color_has_palettes()), then palette_index selects the palette to use. If the
font only has one palette, this will be 0.

- font			hb_font_t to work upon
- glyph			The glyph ID
- pfuncs		hb_paint_funcs_t to paint with
- paint_data	User data to pass to paint callbacks
- palette_index	The index of the font's color palette to use
- foreground	The foreground color, unpremultipled

Since: 7.0.0
*/
font_paint_glyph	:: proc(font: ^font_t, glyph: codepoint_t, pfuncs: ^paint_funcs_t, paint_data: rawptr, palette_index: c.uint, foreground: color_t)	---

/*
hb_bool_t hb_font_get_nominal_glyph (hb_font_t *font, hb_codepoint_t unicode, hb_codepoint_t *glyph);

Fetches the nominal glyph ID for a Unicode code point in the specified font.

This version of the function should not be used to fetch glyph IDs for code points modified by variation selectors.
For variation-selector support, user hb_font_get_variation_glyph() or use hb_font_get_glyph().

- font		hb_font_t to work upon
- unicode	The Unicode code point to query
- glyph		The glyph ID retrieved. [out]
- Returns	true if data found, false otherwise

Since: 1.2.3
*/
font_get_nominal_glyph	:: proc(font: ^font_t, unicode: codepoint_t, glyph: ^codepoint_t)	-> bool_t ---

/*
unsigned int hb_font_get_nominal_glyphs (hb_font_t *font, unsigned int count, const hb_codepoint_t *first_unicode,
		unsigned int unicode_stride, hb_codepoint_t *first_glyph, unsigned int glyph_stride);

Fetches the nominal glyph IDs for a sequence of Unicode code points. Glyph IDs must be returned in a hb_codepoint_t output
parameter. Stops at the first unsupported glyph ID.

- font				hb_font_t to work upon
- count				number of code points to query
- first_unicode		The first Unicode code point to query
- unicode_stride	The stride between successive code points
- first_glyph		The first glyph ID retrieved. [out]
- glyph_stride		The stride between successive glyph IDs
- Returns			the number of code points processed

Since: 2.6.3
*/
font_get_nominal_glyphs	:: proc(font: ^font_t, count: c.uint, first_unicode: /*const*/ ^codepoint_t,
		unicode_stride: c.uint, first_glyph: ^codepoint_t, glyph_stride: c.uint)	-> c.uint ---

/*
hb_bool_t hb_font_get_variation_glyph (hb_font_t *font, hb_codepoint_t unicode, hb_codepoint_t variation_selector,
		hb_codepoint_t *glyph);

Fetches the glyph ID for a Unicode code point when followed by by the specified variation-selector code point,
in the specified font.

- font					hb_font_t to work upon
- unicode				The Unicode code point to query
- variation_selector	The variation-selector code point to query
- glyph					The glyph ID retrieved. [out]
- Returns				true if data found, false otherwise

Since: 1.2.3
*/
font_get_variation_glyph	:: proc(font: ^font_t, unicode: codepoint_t, variation_selector: codepoint_t,
		glyph: ^codepoint_t)	-> bool_t ---

/*
void hb_font_set_parent (hb_font_t *font, hb_font_t *parent);

Sets the parent font of font.

- font		hb_font_t to work upon
- parent	The parent font object to assign

Since: 1.0.5
*/
font_set_parent	:: proc(font: ^font_t, parent: ^font_t)	---

/*
hb_font_t * hb_font_get_parent (hb_font_t *font);

Fetches the parent font of font.

- font		hb_font_t to work upon
- Returns	The parent font object. [transfer none]

Since: 0.9.2
*/
font_get_parent	:: proc(font: ^font_t)	-> ^font_t ---

/*
void hb_font_set_ppem (hb_font_t *font, unsigned int x_ppem, unsigned int y_ppem);

Sets the horizontal and vertical pixels-per-em (PPEM) of a font.

These values are used for pixel-size-specific adjustment to shaping and draw results, though for the most part they are
unused and can be left unset. A zero value means "no hinting in that direction".


- font		hb_font_t to work upon
- x_ppem	Horizontal ppem value to assign
- y_ppem	Vertical ppem value to assign

Since: 0.9.2
*/
font_set_ppem	:: proc(font: ^font_t, x_ppem: c.uint, y_ppem: c.uint)	---

/*
void hb_font_get_ppem (hb_font_t *font, unsigned int *x_ppem, unsigned int *y_ppem);

Fetches the horizontal and vertical points-per-em (ppem) of a font.

- font		hb_font_t to work upon
- x_ppem	Horizontal ppem value. [out]
- y_ppem	Vertical ppem value. [out]

Since: 0.9.2
*/
font_get_ppem	:: proc(font: ^font_t, x_ppem: ^c.uint, y_ppem: ^c.uint)	---

/*
void hb_font_set_ptem (hb_font_t *font, float ptem);

Sets the "point size" of a font. Set to zero to unset. Used in CoreText to implement optical sizing.
Note: There are 72 points in an inch.

- font		hb_font_t to work upon
- ptem		font size in points.

Since: 1.6.0
*/
font_set_ptem	:: proc(font: ^font_t, ptem: c.float)	---

/*
float hb_font_get_ptem (hb_font_t *font);

Fetches the "point size" of a font. Used in CoreText to implement optical sizing.

- font		hb_font_t to work upon
Returns		Point size. A value of zero means "not set."

Since: 1.6.0
*/
font_get_ptem	:: proc(font: ^font_t)	-> c.float ---

/*
void hb_font_set_scale (hb_font_t *font, int x_scale, int y_scale);

Sets the horizontal and vertical scale of a font.

The font scale is a number related to, but not the same as, font size. Typically the client establishes a scale factor
to be used between the two. For example, 64, or 256, which would be the fractional-precision part of the font scale.
This is necessary because hb_position_t values are integer types and you need to leave room for fractional values in there.

For example, to set the font size to 20, with 64 levels of fractional precision you would call
hb_font_set_scale(font, 20 * 64, 20 * 64).

In the example above, even what font size 20 means is up to you. It might be 20 pixels, or 20 points, or 20 millimeters.
HarfBuzz does not care about that. You can set the point size of the font using hb_font_set_ptem(), and the pixel size
using hb_font_set_ppem().

The choice of scale is yours but needs to be consistent between what you set here, and what you expect out of
hb_position_t as well has draw / paint API output values.

Fonts default to a scale equal to the UPEM value of their face. A font with this setting is sometimes called an "unscaled" font.

- font		hb_font_t to work upon
- x_scale	Horizontal scale value to assign
- y_scale	Vertical scale value to assign

Since: 0.9.2
*/
font_set_scale	:: proc(font: ^font_t, x_scale: c.int, y_scale: c.int)	---

/*
void hb_font_get_scale (hb_font_t *font, int *x_scale, int *y_scale);

Fetches the horizontal and vertical scale of a font.

- font		hb_font_t to work upon
- x_scale	Horizontal scale value. [out]
- y_scale	Vertical scale value. [out]

Since: 0.9.2
*/
font_get_scale	:: proc(font: ^font_t, x_scale: ^c.int, y_scale: ^c.int)	---

/*
void hb_font_get_synthetic_bold (hb_font_t *font, float *x_embolden, float *y_embolden, hb_bool_t *in_place);

Fetches the "synthetic boldness" parameters of a font.

- font			hb_font_t to work upon
- x_embolden	return location for horizontal value. [out]
- y_embolden	return location for vertical value. [out]
- In_place		return location for in-place value. [out]

Since: 7.0.0
*/
font_get_synthetic_bold	:: proc(font: ^font_t, x_embolden: ^c.float, y_embolden: ^c.float, in_place: ^bool_t)	---

/*
void hb_font_set_synthetic_bold (hb_font_t *font, float x_embolden, float y_embolden, hb_bool_t in_place);

Sets the "synthetic boldness" of a font.

Positive values for x_embolden / y_embolden make a font bolder, negative values thinner. Typical values are in the 0.01 to 0.05 range. The default value is zero.

Synthetic boldness is applied by offsetting the contour points of the glyph shape.

Synthetic boldness is applied when rendering a glyph via hb_font_draw_glyph().

If in_place is false, then glyph advance-widths are also adjusted, otherwise they are not. The in-place mode is useful for simulating font grading.

- font			hb_font_t to work upon
- x_embolden	the amount to embolden horizontally
- y_embolden	the amount to embolden vertically
- in_place		
whether to embolden glyphs in-place

Since: 7.0.0
*/
font_set_synthetic_bold	:: proc(font: ^font_t, x_embolden: c.float, y_embolden: c.float, in_place: bool_t)	---

/*
void hb_font_set_synthetic_slant (hb_font_t *font, float slant);

Sets the "synthetic slant" of a font. By default is zero. Synthetic slant is the graphical skew applied to the font at rendering time.

HarfBuzz needs to know this value to adjust shaping results, metrics, and style values to match the slanted rendering.
Note: The glyph shape fetched via the hb_font_draw_glyph() function is slanted to reflect this value as well.
Note: The slant value is a ratio. For example, a 20% slant would be represented as a 0.2 value.

- font		hb_font_t to work upon
- slant		synthetic slant value.

Since: 3.3.0
*/
font_set_synthetic_slant	:: proc(font: ^font_t, slant: c.float)	---

/*
float hb_font_get_synthetic_slant (hb_font_t *font);

Fetches the "synthetic slant" of a font.

- font		hb_font_t to work upon
- Returns	Synthetic slant. By default is zero.

Since: 3.3.0
*/
font_get_synthetic_slant	:: proc(font: ^font_t)	-> c.float ---

/*
void hb_font_set_variations (hb_font_t *font, const hb_variation_t *variations, unsigned int variations_length);

Applies a list of font-variation settings to a font.

Note that this overrides all existing variations set on font . Axes not included in variations will be effectively set to their default values.

- font				hb_font_t to work upon
- variations		Array of variation settings to apply. [array length=variations_length]
- variations_length	Number of variations to apply

Since: 1.4.2
*/
font_set_variations	:: proc(font: ^font_t, variations: /*const*/ ^variation_t, variations_length: c.uint)	---

/*
void hb_font_set_variation (hb_font_t *font,  hb_tag_t tag, float value);

Change the value of one variation axis on the font.

Note: This function is expensive to be called repeatedly. If you want to set multiple variation axes at the same time,
use hb_font_set_variations() instead.

- font		hb_font_t to work upon
- tag		The hb_tag_t tag of the variation-axis name
- value		The value of the variation axis

Since: 7.1.0
*/
font_set_variation	:: proc(font: ^font_t,  tag: tag_t, value: c.float)	---

/*
void hb_font_set_var_named_instance (hb_font_t *font, unsigned int instance_index);

Sets design coords of a font from a named-instance index.

- font				a font.
- instance_index	named instance index.

Since: 2.6.0
*/
font_set_var_named_instance	:: proc(font: ^font_t, instance_index: c.uint)	---

/*
unsigned int hb_font_get_var_named_instance (hb_font_t *font);

Returns the currently-set named-instance index of the font.

- font		a font.
- Returns	Named-instance index or HB_FONT_NO_VAR_NAMED_INSTANCE.

Since: 7.0.0
*/
font_get_var_named_instance	:: proc(font: ^font_t)	-> c.uint ---

/*
void hb_font_set_var_coords_design (hb_font_t *font, const float *coords, unsigned int coords_length);

Applies a list of variation coordinates (in design-space units) to a font.

Note that this overrides all existing variations set on font . Axes not included in coords will be effectively set
to their default values.

- font			hb_font_t to work upon
- coords		Array of variation coordinates to apply. [array length=coords_length]
- coords_length	Number of coordinates to apply

Since: 1.4.2
*/
font_set_var_coords_design	:: proc(font: ^font_t, coords: /*const*/ ^c.float, coords_length: c.uint)	---

/*
const float * hb_font_get_var_coords_design (hb_font_t *font, unsigned int *length);

Fetches the list of variation coordinates (in design-space units) currently set on a font.

Note that this returned array may only contain values for some (or none) of the axes; omitted axes effectively
have their default values.

Return value is valid as long as variation coordinates of the font are not modified.

- font		hb_font_t to work upon
- length	Number of coordinates retrieved. [out]
- Returns	coordinates array

Since: 3.3.0
*/
font_get_var_coords_design	:: proc(font: ^font_t, length: ^c.uint)	-> /*const*/ ^c.float ---

/*
void hb_font_set_var_coords_normalized (hb_font_t *font, const int *coords, unsigned int coords_length);

Applies a list of variation coordinates (in normalized units) to a font.

Note that this overrides all existing variations set on font . Axes not included in coords will be effectively set
to their default values.

Note: Coordinates should be normalized to 2.14.

- font			hb_font_t to work upon
- coords		Array of variation coordinates to apply. [array length=coords_length]
- coords_length	Number of coordinates to apply

Since: 1.4.2
*/
font_set_var_coords_normalized	:: proc(font: ^font_t, coords: /*const*/ ^c.int, coords_length: c.uint)	---

/*
const int * hb_font_get_var_coords_normalized (hb_font_t *font, unsigned int *length);

Fetches the list of normalized variation coordinates currently set on a font.

Note that this returned array may only contain values for some (or none) of the axes; omitted axes effectively have zero values.

Return value is valid as long as variation coordinates of the font are not modified.

- font		hb_font_t to work upon
- length	Number of coordinates retrieved. [out]
- Returns	coordinates array

Since: 1.4.2
*/
font_get_var_coords_normalized	:: proc(font: ^font_t, length: ^c.uint)	-> /*const*/ ^c.int ---

/*
hb_bool_t hb_font_glyph_from_string (hb_font_t *font, const char *s, int len, hb_codepoint_t *glyph);

Fetches the glyph ID from font that matches the specified string. Strings of the format gidDDD or uniUUUU are parsed automatically.

Note: len == -1 means the string is null-terminated.

- font		hb_font_t to work upon
- s			string to query. [array length=len][element-type uint8_t]
- len		The length of the string s
- glyph		The glyph ID corresponding to the string requested. [out]
- Returns	true if data found, false otherwise

Since: 0.9.2
*/
font_glyph_from_string	:: proc(font: ^font_t, s: cstring, len: c.int, glyph: ^codepoint_t)	-> bool_t ---

/*
void hb_font_glyph_to_string (hb_font_t *font, hb_codepoint_t glyph, char *s, unsigned int size);

Fetches the name of the specified glyph ID in font and returns it in string s.

If the glyph ID has no name in font , a string of the form gidDDD is generated, with DDD being the glyph ID.

According to the OpenType specification, glyph names are limited to 63 characters and can only contain (a subset of) ASCII.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- s			The string containing the glyph name. [out][array length=size]
- size		Length of string s

Since: 0.9.2
*/
font_glyph_to_string	:: proc(font: ^font_t, glyph: codepoint_t, s: cstring, size: c.uint)	---

/*
unsigned int hb_font_get_serial (hb_font_t *font);

Returns the internal serial number of the font. The serial number is increased every time a setting on the font is
changed, using a setter function.

- font		hb_font_t to work upon
- Returns	serial number

Since: 4.4.0
*/
font_get_serial	:: proc(font: ^font_t)	-> c.uint ---

/*
void hb_font_changed (hb_font_t *font);

Notifies the font that underlying font data has changed. This has the effect of increasing the serial as returned by
hb_font_get_serial(), which invalidates internal caches.

- font		hb_font_t to work upon

Since: 4.4.0
*/
font_changed	:: proc(font: ^font_t)	---

/*
void hb_font_set_funcs (hb_font_t *font, hb_font_funcs_t *klass, void *font_data, hb_destroy_func_t destroy);

Replaces the font-functions structure attached to a font, updating the font's user-data with font -data and the destroy callback.

- font		hb_font_t to work upon
- klass		The font-functions structure. [closure font_data][destroy destroy][scope notified]
- font_data	Data to attach to font
- destroy	The function to call when font_data is not needed anymore. 	[nullable]

Since: 0.9.2
*/
font_set_funcs	:: proc(font: ^font_t, klass: ^font_funcs_t, font_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_set_funcs_data (hb_font_t *font, void *font_data, hb_destroy_func_t destroy);

Replaces the user data attached to a font, updating the font's destroy callback.

- font		hb_font_t to work upon
- font_data	Data to attach to font . [destroy destroy][scope notified]
- destroy	The function to call when font_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_set_funcs_data	:: proc(font: ^font_t, font_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_subtract_glyph_origin_for_direction (hb_font_t *font, hb_codepoint_t glyph, hb_direction_t direction, hb_position_t *x, hb_position_t *y);

Subtracts the origin coordinates from an (X,Y) point coordinate, in the specified glyph ID in the specified font.

Calls the appropriate direction-specific variant (horizontal or vertical) depending on the value of direction.

- font		hb_font_t to work upon
- glyph		The glyph ID to query
- direction	The direction of the text segment
- x			Input = The original X coordinate Output = The X coordinate minus the X-coordinate of the origin. [inout]
- y			Input = The original Y coordinate Output = The Y coordinate minus the Y-coordinate of the origin. [inout]

Since: 0.9.2
*/
font_subtract_glyph_origin_for_direction	:: proc(font: ^font_t, glyph: codepoint_t, direction: direction_t, x: ^position_t, y: ^position_t)	---

/*
hb_font_funcs_t * hb_font_funcs_create (void);

Creates a new hb_font_funcs_t structure of font functions.

- Returns	The font-functions structure. [transfer full]

Since: 0.9.2
*/
font_funcs_create	:: proc()	-> ^font_funcs_t ---

/*
hb_font_funcs_t * hb_font_funcs_get_empty (void);

Fetches an empty font-functions structure.

- Returns	The font-functions structure. [transfer full]

Since: 0.9.2
*/
font_funcs_get_empty	:: proc()	-> ^font_funcs_t ---

/*
hb_font_funcs_t * hb_font_funcs_reference (hb_font_funcs_t *ffuncs);

Increases the reference count on a font-functions structure.

- ffuncs	The font-functions structure
- Returns	The font-functions structure

Since: 0.9.2
*/
font_funcs_reference	:: proc(ffuncs: ^font_funcs_t)	-> ^font_funcs_t ---

/*
void hb_font_funcs_destroy (hb_font_funcs_t *ffuncs);

Decreases the reference count on a font-functions structure. When the reference count reaches zero, the font-functions
structure is destroyed, freeing all memory.

- ffuncsThe font-functions structure

Since: 0.9.2
*/
font_funcs_destroy	:: proc(ffuncs: ^font_funcs_t)	---

/*
hb_bool_t hb_font_funcs_set_user_data (hb_font_funcs_t *ffuncs, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified font-functions structure.

- ffuncs	The font-functions structure
- key		The user-data key to set
- data		A pointer to the user data set
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 0.9.2
*/
font_funcs_set_user_data	:: proc(ffuncs: ^font_funcs_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_font_funcs_get_user_data (const hb_font_funcs_t *ffuncs, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified font-functions structure.

- ffuncs		The font-functions structure
- key			The user-data key to query
- Returns		A pointer to the user data. [transfer none]

Since: 0.9.2
*/
font_funcs_get_user_data	:: proc(ffuncs: /*const*/ ^font_funcs_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_font_funcs_make_immutable (hb_font_funcs_t *ffuncs);

Makes a font-functions structure immutable.

- ffuncs		The font-functions structure

Since: 0.9.2
*/
font_funcs_make_immutable	:: proc(ffuncs: ^font_funcs_t)	---

/*
hb_bool_t hb_font_funcs_is_immutable (hb_font_funcs_t *ffuncs);

Tests whether a font-functions structure is immutable.

- ffuncs		The font-functions structure
- Returns		true if ffuncs is immutable, false otherwise

Since: 0.9.2
*/
font_funcs_is_immutable	:: proc(ffuncs: ^font_funcs_t)	-> bool_t ---

/*
void hb_font_funcs_set_glyph_contour_point_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_contour_point_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_contour_point_func_t.

- ffuncs		A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_contour_point_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_contour_point_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_extents_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_extents_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_extents_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_extents_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_extents_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void  hb_font_funcs_set_glyph_from_name_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_from_name_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_from_name_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. 	[nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_from_name_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_from_name_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_h_advance_func(hb_font_funcs_t *ffuncs, hb_font_get_glyph_h_advance_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_h_advance_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_h_advance_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_h_advance_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_v_advance_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_v_advance_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_v_advance_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_v_advance_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_v_advance_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_h_advances_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_h_advances_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_h_advances_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 1.8.6
*/
font_funcs_set_glyph_h_advances_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_h_advances_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_v_advances_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_v_advances_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_v_advances_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 1.8.6
*/
font_funcs_set_glyph_v_advances_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_v_advances_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_h_kerning_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_h_kerning_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_h_kerning_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_h_kerning_func	:: proc(ffuncs: ^font_funcs_t, func:font_get_glyph_h_kerning_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_h_origin_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_h_origin_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_h_origin_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_h_origin_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_h_origin_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_v_origin_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_v_origin_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_v_origin_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. 	[nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_v_origin_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_v_origin_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_glyph_name_func (hb_font_funcs_t *ffuncs, hb_font_get_glyph_name_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_name_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
font_funcs_set_glyph_name_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_glyph_name_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_draw_glyph_func (hb_font_funcs_t *ffuncs, hb_font_draw_glyph_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_draw_glyph_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 7.0.0
*/
font_funcs_set_draw_glyph_func	:: proc(ffuncs: ^font_funcs_t, func: font_draw_glyph_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_paint_glyph_func (hb_font_funcs_t *ffuncs, hb_font_paint_glyph_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_paint_glyph_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
font_funcs_set_paint_glyph_func	:: proc(ffuncs: ^font_funcs_t, func: font_paint_glyph_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_nominal_glyph_func (hb_font_funcs_t *ffuncs, hb_font_get_nominal_glyph_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_nominal_glyph_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. 	[nullable]

Since: 1.2.3
*/
font_funcs_set_nominal_glyph_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_nominal_glyph_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_nominal_glyphs_func (hb_font_funcs_t *ffuncs, hb_font_get_nominal_glyphs_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_nominal_glyphs_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 2.0.0
*/
font_funcs_set_nominal_glyphs_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_nominal_glyphs_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_variation_glyph_func (hb_font_funcs_t *ffuncs, hb_font_get_variation_glyph_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_variation_glyph_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroyThe function to call when user_data is not needed anymore. [nullable]

Since: 1.2.3
*/
font_funcs_set_variation_glyph_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_variation_glyph_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_font_h_extents_func (hb_font_funcs_t *ffuncs, hb_font_get_font_h_extents_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_font_h_extents_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 1.1.2
*/
font_funcs_set_font_h_extents_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_font_h_extents_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_font_funcs_set_font_v_extents_func (hb_font_funcs_t *ffuncs, hb_font_get_font_v_extents_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_font_v_extents_func_t.

- ffuncs	A font-function structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 1.1.2
*/
font_funcs_set_font_v_extents_func	:: proc(ffuncs: ^font_funcs_t, func: font_get_font_v_extents_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
hb_bool_t hb_font_get_h_extents (hb_font_t *font, hb_font_extents_t *extents);

Fetches the extents for a specified font, for horizontal text segments.

- font		hb_font_t to work upon
- extents	The font extents retrieved. [out]
- Returns	true if data found, false otherwise

Since: 1.1.3
*/
font_get_h_extents	:: proc(font: ^font_t, extents: ^font_extents_t)	-> bool_t ---

/*
hb_bool_t hb_font_get_v_extents (hb_font_t *font, hb_font_extents_t *extents);

Fetches the extents for a specified font, for vertical text segments.

- font		hb_font_t to work upon
- extents	The font extents retrieved. [out]
- Returns	true if data found, false otherwise

Since: 1.1.3
*/
font_get_v_extents	:: proc(font: ^font_t, extents: ^font_extents_t)	-> bool_t ---

/*
void hb_font_get_extents_for_direction (hb_font_t *font, hb_direction_t direction, hb_font_extents_t *extents);

Fetches the extents for a font in a text segment of the specified direction.

Calls the appropriate direction-specific variant (horizontal or vertical)
depending on the value of direction .

- font		hb_font_t to work upon
- direction	The direction of the text segment
- extents	The hb_font_extents_t retrieved. [out]

Since: 1.1.3
*/
font_get_extents_for_direction	:: proc(font: ^font_t, direction: direction_t, extents: ^font_extents_t)	---

/*
const char ** hb_font_list_funcs (void);

Retrieves the list of font functions supported by HarfBuzz.

Returns:
- a NULL-terminated array of supported font functions constant strings. The returned array is owned
		by HarfBuzz and should not be modified or freed. [transfer none][array zero-terminated=1]

Since: 11.0.0
*/
font_list_funcs :: proc () -> [^]cstring ---

/*
hb_bool_t hb_font_set_funcs_using (hb_font_t *font, const char *name);

Sets the font-functions structure to use for a font, based on the specified name.

If name is NULL or the empty string, the default (first) functioning font-functions are used. This
default can be changed by setting the HB_FONT_FUNCS environment variable to the name of the desired
font-functions.

Inputs:
- font:	hb_font_t to work upon
- name:	The name of the font-functions structure to use, or NULL
Returns:
- true if the font-functions was found and set, false otherwise

Since: 11.0.0
*/
font_set_funcs_using :: proc (font: ^font_t, name: cstring) -> bool_t ---

/*
void hb_font_funcs_set_glyph_h_origins_func(hb_font_funcs_t *ffuncs,
	hb_font_get_glyph_h_origins_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_h_origins_func_t.

Inputs:
- ffuncs:		A font-function structure
- func:			The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data:	Data to pass to func
- destroy:		The function to call when user_data is not needed anymore. [nullable]

Since: 11.3.0
*/
font_funcs_set_glyph_h_origins_func :: proc (ffuncs: ^font_funcs_t,
	func: font_get_glyph_h_origins_func_t, user_data: rawptr, destroy: destroy_func_t) ---

/*
void hb_font_funcs_set_glyph_v_origins_func(hb_font_funcs_t *ffuncs,
		hb_font_get_glyph_v_origins_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_font_get_glyph_v_origins_func_t.

Inputs:
- ffuncs:		A font-function structure
- func:			The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data:	Data to pass to func
- destroy:		The function to call when user_data is not needed anymore. [nullable]

Since: 11.3.0
*/
font_funcs_set_glyph_v_origins_func :: proc (ffuncs: ^font_funcs_t,
		func: font_get_glyph_v_origins_func_t, user_data: rawptr, destroy: destroy_func_t) ---

/*
hb_bool_t hb_font_get_glyph_h_origins (hb_font_t *font, unsigned int count, const hb_codepoint_t *first_glyph,
	unsigned  glyph_stride, hb_position_t *first_x, unsigned  x_stride, hb_position_t *first_y, unsigned  y_stride);

Fetches the (X,Y) coordinates of the origin for requested glyph IDs in the specified font, for horizontal text segments.

Inputs:
- font:			hb_font_t to work upon
- count:		The number of glyph IDs in the sequence queried
- first_glyph:	The first glyph ID to query
- glyph_stride:	The stride between successive glyph IDs
- first_x:		The first X coordinate of the origin retrieved. [out]
- x_stride:		The stride between successive X coordinates
- first_y:		The first Y coordinate of the origin retrieved. [out]
- y_stride:		The stride between successive Y coordinates
Returns:
- true if data found, false otherwise

Since: 11.3.0
*/
font_get_glyph_h_origins :: proc (font: ^font_t, count: c.uint, first_glyph: ^/*const*/codepoint_t,
	glyph_stride: c.uint, first_x: ^position_t, x_stride: c.uint, first_y: ^position_t, y_stride: c.uint) -> bool_t ---

/*
hb_bool_t hb_font_get_glyph_v_origins (hb_font_t *font, unsigned int count,
	const hb_codepoint_t *first_glyph, unsigned  glyph_stride, hb_position_t *first_x,
	unsigned  x_stride, hb_position_t *first_y, unsigned  y_stride);

Fetches the (X,Y) coordinates of the origin for requested glyph IDs in the specified font, for vertical text segments.

Inputs:
- font:			hb_font_t to work upon
- count:		The number of glyph IDs in the sequence queried
- first_glyph:	The first glyph ID to query
- glyph_stride:	The stride between successive glyph IDs
	 

- first_x:		The first X coordinate of the origin retrieved. [out]
- x_stride:		The stride between successive X coordinates
- first_y:		The first Y coordinate of the origin retrieved. [out]
- y_stride:		The stride between successive Y coordinates
Returns:
- true if data found, false otherwise

Since: 11.3.0
*/
font_get_glyph_v_origins :: proc (font: ^font_t, count: c.uint, first_glyph: ^/*const*/ codepoint_t,
	glyph_stride: c.uint, first_x: ^position_t, x_stride: c.uint, first_y: ^position_t, y_stride: c.uint) -> bool_t ---

}
