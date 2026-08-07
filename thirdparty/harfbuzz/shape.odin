/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

shape.odin - Types and functions for managing shapes.

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
author: Maurizio M. Gavioli, 2024-07-24

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-shape.h
		https://harfbuzz.github.io/harfbuzz-hb-shape.html
*/

/*
Conversion of text strings into positioned glyphs
Shaping is the central operation of HarfBuzz. Shaping operates on buffers, which are sequences of Unicode characters
that use the same font and have the same text direction, script, and language. After shaping the buffer contains the
output glyphs and their positions.
*/

package	harfbuzz

import "core:c"

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

HB_EXPERIMENTAL_API :: #config(HB_EXPERIMENTAL_API, false)

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

//******************
// FUNCTIONS
//******************

/*
void hb_shape (hb_font_t *font, hb_buffer_t *buffer, const hb_feature_t *features, unsigned int num_features);

Shapes buffer using font turning its Unicode characters content to positioned glyphs. If features is not NULL,
it will be used to control the features applied during shaping. If two features have the same tag but overlapping
ranges the value of the feature with the higher index takes precedence.

- font			an hb_font_t to use for shaping
- buffer		an hb_buffer_t to shape
- features		an array of user specified hb_feature_t or NULL. [array length=num_features][nullable]
- num_features	the length of features array
*/
shape	:: proc(font: ^font_t, buffer: ^buffer_t, features: /*const*/ [^]feature_t, num_features: c.uint)	---

/*
hb_bool_t hb_shape_full (hb_font_t *font, hb_buffer_t *buffer, const hb_feature_t *features, unsigned int num_features, const char * const *shaper_list);

See hb_shape() for details. If shaper_list is not NULL, the specified shapers will be used in the given order, otherwise the default shapers list will be used.

- font			an hb_font_t to use for shaping
- buffer		an hb_buffer_t to shape
- features		an array of user specified hb_feature_t or NULL. [array length=num_features][nullable]
- num_features	the length of features array
- shaper_list	a NULL-terminated array of shapers to use or NULL. [array zero-terminated=1][nullable]
- Returns		false if all shapers failed, true otherwise
*/
shape_full	:: proc(font: ^font_t, buffer: ^buffer_t, features: /*const*/ [^]feature_t,
	num_features: c.uint, shaper_list: /*const char * const * */ ^[^]u8)	-> bool_t ---

/*
hb_bool_t hb_shape_justify (hb_font_t *font, hb_buffer_t *buffer, const hb_feature_t *features, unsigned int num_features, const char * const *shaper_list,
	float min_target_advance, float max_target_advance, float *advance, hb_tag_t *var_tag, float *var_value);

See hb_shape_full() for basic details. If shaper_list is not NULL, the specified shapers
will be used in the given order, otherwise the default shapers list will be used.

In addition, justify the shaping results such that the shaping results reach the target
advance width/height, depending on the buffer direction.

If the advance of the buffer shaped with hb_shape_full() is already known, put that in
*advance. Otherwise set *advance to zero.

This API is currently experimental and will probably change in the future.

- font					a mutable hb_font_t to use for shaping
- buffer				an hb_buffer_t to shape
- features				an array of user specified hb_feature_t or NULL. [array length=num_features][nullable]
- um_features			the length of features array
- shaper_list			a NULL-terminated array of shapers to use or NULL. [array zero-terminated=1][nullable]
- min_target_advance	Minimum advance width/height to aim for.
- max_target_advance	Maximum advance width/height to aim for.
- advance				Input/output advance width/height of the buffer. [inout]
- var_tag				Variation-axis tag used for justification. [out]
- var_value				Variation-axis value used to reach target justification. [out]
- Returns				false if all shapers failed, true otherwise

XSince: EXPERIMENTAL
*/
when HB_EXPERIMENTAL_API
{
	shape_justify	:: proc(font: ^font_t, buffer: ^buffer_t, features: /*const*/ [^]feature_t,
		num_features: c.uint, shaper_list: /*const char * const * */ ^[^]u8, min_target_advance: c.float,
		max_target_advance: c.float, advance: ^c.float, var_tag: ^tag_t, var_value: ^c.float)	-> bool_t ---
}

/*
const char ** hb_shape_list_shapers (void);

Retrieves the list of shapers supported by HarfBuzz.

- Returns	an array of constant strings. [transfer none][array zero-terminated=1]
*/
shape_list_shapers	:: proc()	-> /*const*/ ^[^]u8 ---

}
