/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

style.odin - Functions for fetching style information from fonts.

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
author: Maurizio M. Gavioli, 2024-09-20

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file


From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-style.h
		https://harfbuzz.github.io/harfbuzz-hb-style.html
*/

package	harfbuzz_ot

import 	"core:c"
//import cm "./common"
import hrfb ".."

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "../windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

/*******************
hb-style — Font Styles

Functions for fetching style information from fonts.
*******************/

//******************
// TYPES
//******************

/*
enum hb_style_tag_t

Defined by OpenType Design-Variation Axis Tag Registry.

Since: 3.0.0
*/

style_tag_t :: enum (hrfb.tag_t)
{
	STYLE_TAG_ITALIC		= ('i' << 24) | ('t' << 16) | ('a' << 8) | 'l',	// ital, Used to vary between non-italic and italic. A value of 0 can be interpreted
																					// as "Roman" (non-italic); a value of 1 can be interpreted as (fully) italic.
	STYLE_TAG_OPTICAL_SIZE	= ('o' << 24) | ('p' << 16) | ('s' << 8) | 'z',	// opsz, Used to vary design to suit different text sizes. Non-zero. Values can be
																					// interpreted as text size, in points.
	STYLE_TAG_SLANT_ANGLE	= ('s' << 24) | ('l' << 16) | ('n' << 8) | 't',	// slnt, Used to vary between upright and slanted text. Values must be greater than
																					// -90 and less than +90. Values can be interpreted as the angle,  in counter-clockwise
																					// degrees, of oblique slant from whatever the designer considers to be upright for that font
																					// design.  Typical right-leaning Italic fonts have a negative slant angle (typically around -12)
	STYLE_TAG_SLANT_RATIO	= ('S' << 24) | ('l' << 16) | ('n' << 8) | 't',	// Slnt, same as HB_STYLE_TAG_SLANT_ANGLE expression as ratio. Typical right-leaning Italic fonts
																					// have a positive slant ratio (typically around 0.2)
	STYLE_TAG_WIDTH			= ('w' << 24) | ('d' << 16) | ('t' << 8) | 'h',	// wdth, Used to vary width of text from narrower to wider. Non-zero. Values can be interpreted
																					// as a percentage of whatever the font designer considers “normal width” for that font design.
	STYLE_TAG_WEIGHT		= ('w' << 24) | ('g' << 16) | ('h' << 8) | 't',	// wght, Used to vary stroke thicknesses or other design details to give variation from lighter to
																					// blacker. Values can be interpreted in direct comparison to values for usWeightClass in the
																					// OS/2 table, or the CSS font-weight property.
	_HB_STYLE_TAG_MAX_VALUE	= hrfb.TAG_MAX_SIGNED									//< private >
}

//******************
// FUNCTIONS
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
float hb_style_get_value (hb_font_t *font, hb_style_tag_t style_tag);

Searches variation axes of a hb_font_t object for a specific axis first, if not set, first tries to get default style
values in STAT table then tries to polyfill from different tables of the font.

Inputs:
- font:			a hb_font_t object.
- style_tag:	a style tag.
Returns:
- Corresponding axis or default value to a style tag.

Since: 3.0.0
*/
style_get_value :: proc (font: ^hrfb.font_t, style_tag: style_tag_t)	-> c.float ---

}
