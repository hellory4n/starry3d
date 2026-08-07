/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

common.odin - Types and functions common to several binding files.

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
author: Maurizio M. Gavioli, 2024-06-28

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-common.h
		https://harfbuzz.github.io/harfbuzz-hb-common.html
		https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-style.h
		https://harfbuzz.github.io/harfbuzz-hb-version.html
*/

package harfbuzz

import "core:c"

//******************
// TYPES
//******************

/**
 * typedef int hb_bool_t;
 * 
 * Data type for booleans.
 **/
bool_t	:: distinct c.int

/**
 * typedef uint32_t hb_codepoint_t;
 * 
 * Data type for holding Unicode codepoints. Also used to hold glyph IDs.
 **/
codepoint_t	:: distinct u32

/**
 * #define HB_CODEPOINT_INVALID ((hb_codepoint_t) -1)
 *
 * Unused #hb_codepoint_t value.
 */
CODEPOINT_INVALID 	:: transmute(codepoint_t) i32(-1)		//  Since: 8.0.0

/**
 * typedef int32_t hb_position_t;
 * 
 * Data type for holding a single coordinate value. Contour points and other multi-dimensional data are stored as tuples of #hb_position_t's.
 **/
position_t	:: distinct i32
/**
 * typedef uint32_t hb_mask_t;
 * 
 * Data type for bitmasks.
 **/
mask_t	:: distinct u32

/*
typedef union _hb_var_int_t {
  uint32_t u32;
  int32_t i32;
  uint16_t u16[2];
  int16_t i16[2];
  uint8_t u8[4];
  int8_t i8[4];
} hb_var_int_t;
*/
var_int_t :: struct #raw_union
{
	u32:	u32,
	i32:	i32,
	u16:	[2]u16,
	i16:	[2]i16,
	u8:		[4]u8,
	i8:		[4]i8,
}

/*
typedef union _hb_var_num_t {
  float f;
  uint32_t u32;
  int32_t i32;
  uint16_t u16[2];
  int16_t i16[2];
  uint8_t u8[4];
  int8_t i8[4];
} hb_var_num_t;
*/

var_num_t :: struct #raw_union
{
  f:	c.float,
  u32:	u32,
  i32:	i32,
  u16:	[2]u16,
  i16:	[2]i16,
  u8:	[4]u8,
  i8:	[4]i8
}

/**
 * typedef uint32_t hb_tag_t;
 *
 * Data type for tag identifiers. Tags are four byte integers, each byte representing a character.
 *
 * Tags are used to identify tables, design-variation axes, scripts, languages, font features, and baselines with human-readable names.
 **/
tag_t	:: distinct u32

/**
 * #define HB_TAG(c1,c2,c3,c4) ((hb_tag_t)((((uint32_t)(c1)&0xFF)<<24)|(((uint32_t)(c2)&0xFF)<<16)|(((uint32_t)(c3)&0xFF)<<8)|((uint32_t)(c4)&0xFF)))
 * @c1: 1st character of the tag
 * @c2: 2nd character of the tag
 * @c3: 3rd character of the tag
 * @c4: 4th character of the tag
 *
 * Constructs an #hb_tag_t from four character literals.
 **/
TAG	:: #force_inline proc($c1:u8, $c2:u8, $c3:u8, $c4:u8)	-> tag_t
{
	return (tag_t) ( (((u32)(c1 & 0xFF)) << 24) | (((u32)(c2 & 0xFF)) << 16) |
		(((u32)(c3 & 0xFF)) << 8) | ((u32)((c4)) & 0xFF ) )
}

/**
 * #define HB_UNTAG(tag)   (uint8_t)(((tag)>>24)&0xFF), (uint8_t)(((tag)>>16)&0xFF), (uint8_t)(((tag)>>8)&0xFF), (uint8_t)((tag)&0xFF)
 * @tag: an #hb_tag_t
 *
 * Extracts four character literals from an #hb_tag_t.
 **/
UNTAG	:: proc(tag: tag_t)	-> (u8, u8, u8, u8)
{
	return   (u8) ((tag >> 24) & 0xFF), (u8) ((tag >> 16) & 0xFF), (u8) ((tag >> 8) & 0xFF), (u8) (tag & 0xFF)
}

/**
 * #define HB_TAG_NONE HB_TAG(0,0,0,0)
 *
 * Unset #hb_tag_t.
 */
TAG_NONE : tag_t : (0 << 24) | (0 << 16) | (0 << 8) | 0	//TAG(0,0,0,0)

/**
 * #define HB_TAG_MAX HB_TAG(0xff,0xff,0xff,0xff)
 *
 * Maximum possible unsigned #hb_tag_t.
 */
TAG_MAX	: tag_t : (0xFF << 24) | (0xFF << 16) | (0xFF << 8) | 0xFF	//TAG(0xff,0xff,0xff,0xff)

/**
 * #define HB_TAG_MAX_SIGNED HB_TAG(0x7f,0xff,0xff,0xff)
 *
 * Maximum possible signed #hb_tag_t.
 */
TAG_MAX_SIGNED	: tag_t : (0x7F << 24) | (0xFF << 16) | (0xFF << 8) | 0xFF	//TAG(0x7f,0xff,0xff,0xff)

INT_MAX_SIGNED 	: i32	: 0x7FFFFFFF

/**
typedef enum {
  HB_DIRECTION_INVALID = 0,
  HB_DIRECTION_LTR = 4,
  HB_DIRECTION_RTL,
  HB_DIRECTION_TTB,
  HB_DIRECTION_BTT
} hb_direction_t;
 * The direction of a text segment or buffer.
 * 
 * A segment can also be tested for horizontal or vertical orientation (irrespective
 * of specific direction) with HB_DIRECTION_IS_HORIZONTAL() or HB_DIRECTION_IS_VERTICAL().
 */
direction_t :: enum c.uint
{
	DIRECTION_INVALID	= 0,			// Initial, unset direction.
	DIRECTION_LTR		= 4,			// Text is set horizontally from left to right.
	DIRECTION_RTL,						// Text is set horizontally from right to left.
	DIRECTION_TTB,						// Text is set vertically from top to bottom.
	DIRECTION_BTT						// ext is set vertically from bottom to top.
}

/**
 * #define HB_DIRECTION_IS_VALID(dir)	((((unsigned int) (dir)) & ~3U) == 4)
 * Tests whether a text direction is valid.
 **/
DIRECTION_IS_VALID		:: proc(dir: direction_t)	-> bool	{	return (c.uint(dir) &~ 3 ) == 4	}

/**
 * #define HB_DIRECTION_IS_HORIZONTAL(dir)	((((unsigned int) (dir)) & ~1U) == 4)
 * Tests whether a text direction is horizontal. Requires that the direction be valid.
 **/
DIRECTION_IS_HORIZONTAL	:: proc(dir: direction_t)	-> bool	{	return ( (c.uint(dir) &~ 1) == 4)	}

/**
 * #define HB_DIRECTION_IS_VERTICAL(dir)	((((unsigned int) (dir)) & ~1U) == 6)
 * Tests whether a text direction is vertical. Requires that the direction be valid.
 **/
DIRECTION_IS_VERTICAL	:: proc(dir: direction_t)	-> bool	{	return ( (c.uint(dir) &~ 1) == 6)	}

/**
 * #define HB_DIRECTION_IS_FORWARD(dir)	((((unsigned int) (dir)) & ~2U) == 4)
 * Tests whether a text direction moves forward (from left to right, or from top to bottom). Requires that the direction be valid.
 **/
DIRECTION_IS_FORWARD	:: proc(dir: direction_t)	-> bool	{	return ( (c.uint(dir) &~ 2) == 4)	}

/**
 * #define HB_DIRECTION_IS_BACKWARD(dir)	((((unsigned int) (dir)) & ~2U) == 5)
 * Tests whether a text direction moves backward (from right to left, or from bottom to top). Requires that the direction be valid.
 **/
DIRECTION_IS_BACKWARD	:: proc(dir: direction_t)	-> bool	{	return ( (c.uint(dir) &~ 2) == 5)	}

/**
 * #define HB_DIRECTION_REVERSE(dir)	((hb_direction_t) (((unsigned int) (dir)) ^ 1))
 * Reverses a text direction. Requires that the direction be valid.
 **/
DIRECTION_REVERSE		:: proc(dir: direction_t)	-> direction_t	{ return  direction_t(c.uint(dir) ~ c.uint(1) )	}

/**
 * typedef const struct hb_language_impl_t *hb_language_t;
 * Data type for languages. Each #hb_language_t corresponds to a BCP 47 language tag.
 */
language_t	:: distinct cstring

/**
 * #define HB_LANGUAGE_INVALID ((hb_language_t) 0)
 * An unset #hb_language_t.
 */
LANGUAGE_INVALID : language_t : {}

/**
 * hb_script_t:
 *
 * Data type for scripts. Each #hb_script_t's value is an #hb_tag_t corresponding
 * to the four-letter values defined by [ISO 15924](https://unicode.org/iso15924/).
 *
 * See also the Script (sc) property of the Unicode Character Database.
 **/

/* https://docs.google.com/spreadsheets/d/1Y90M0Ie3MUJ6UVCRDOypOtijlMDLNNyyLk36T6iMu0o */
script_t :: enum tag_t
{
	SCRIPT_COMMON			= ('Z' << 24) | ('y' << 16) | ('y' << 8) | 'y', /* Zyyy*/ /*1.1 <= Unicode version*/
	SCRIPT_INHERITED		= ('Z' << 24) | ('i' << 16) | ('n' << 8) | 'h', /* Zinh 1.1*/
	SCRIPT_UNKNOWN			= ('Z' << 24) | ('z' << 16) | ('z' << 8) | 'z', /* Zzzz 5.0*/

	SCRIPT_ARABIC			= ('A' << 24) | ('r' << 16) | ('a' << 8) | 'b', /* Arab 1.1*/
	SCRIPT_ARMENIAN			= ('A' << 24) | ('r' << 16) | ('m' << 8) | 'n', /* Armn 1.1*/
	SCRIPT_BENGALI			= ('B' << 24) | ('e' << 16) | ('n' << 8) | 'g', /* Beng 1.1*/
	SCRIPT_CYRILLIC			= ('C' << 24) | ('y' << 16) | ('r' << 8) | 'l', /* Cyrl 1.1*/
	SCRIPT_DEVANAGARI		= ('D' << 24) | ('e' << 16) | ('v' << 8) | 'a', /* Deva 1.1*/
	SCRIPT_GEORGIAN			= ('G' << 24) | ('e' << 16) | ('o' << 8) | 'r', /* Geor 1.1*/
	SCRIPT_GREEK			= ('G' << 24) | ('r' << 16) | ('e' << 8) | 'k', /* Grek 1.1*/
	SCRIPT_GUJARATI			= ('G' << 24) | ('u' << 16) | ('j' << 8) | 'r', /* Gujr 1.1*/
	SCRIPT_GURMUKHI			= ('G' << 24) | ('u' << 16) | ('r' << 8) | 'u', /* Guru 1.1*/
	SCRIPT_HANGUL			= ('H' << 24) | ('a' << 16) | ('n' << 8) | 'g', /* Hang 1.1*/
	SCRIPT_HAN				= ('H' << 24) | ('a' << 16) | ('n' << 8) | 'i', /* Hani 1.1*/
	SCRIPT_HEBREW			= ('H' << 24) | ('e' << 16) | ('b' << 8) | 'r', /* Hebr 1.1*/
	SCRIPT_HIRAGANA			= ('H' << 24) | ('i' << 16) | ('r' << 8) | 'a', /* Hira 1.1*/
	SCRIPT_KANNADA			= ('K' << 24) | ('n' << 16) | ('d' << 8) | 'a', /* Knda 1.1*/
	SCRIPT_KATAKANA			= ('K' << 24) | ('a' << 16) | ('n' << 8) | 'a', /* Kana 1.1*/
	SCRIPT_LAO				= ('L' << 24) | ('a' << 16) | ('o' << 8) | 'o', /* Laoo 1.1*/
	SCRIPT_LATIN			= ('L' << 24) | ('a' << 16) | ('t' << 8) | 'n', /* Latn 1.1*/
	SCRIPT_MALAYALAM		= ('M' << 24) | ('l' << 16) | ('y' << 8) | 'm', /* Mlym 1.1*/
	SCRIPT_ORIYA			= ('O' << 24) | ('r' << 16) | ('y' << 8) | 'a', /* Orya 1.1*/
	SCRIPT_TAMIL			= ('T' << 24) | ('a' << 16) | ('m' << 8) | 'l', /* Taml 1.1*/
	SCRIPT_TELUGU			= ('T' << 24) | ('e' << 16) | ('l' << 8) | 'u', /* Telu 1.1*/
	SCRIPT_THAI				= ('T' << 24) | ('h' << 16) | ('a' << 8) | 'i', /* Thai 1.1*/

	SCRIPT_TIBETAN			= ('T' << 24) | ('i' << 16) | ('b' << 8) | 't', /* Tibt 2.0*/

	SCRIPT_BOPOMOFO			= ('B' << 24) | ('o' << 16) | ('p' << 8) | 'o', /* Bopo 3.0*/
	SCRIPT_BRAILLE			= ('B' << 24) | ('r' << 16) | ('a' << 8) | 'i', /* Brai 3.0*/
	SCRIPT_CANADIAN_SYLLABICS	= ('C' << 24) | ('a' << 16) | ('n' << 8) | 's', /* Cans 3.0*/
	SCRIPT_CHEROKEE			= ('C' << 24) | ('h' << 16) | ('e' << 8) | 'r', /* Cher 3.0*/
	SCRIPT_ETHIOPIC			= ('E' << 24) | ('t' << 16) | ('h' << 8) | 'i', /* Ethi 3.0*/
	SCRIPT_KHMER			= ('K' << 24) | ('h' << 16) | ('m' << 8) | 'r', /* Khmr 3.0*/
	SCRIPT_MONGOLIAN		= ('M' << 24) | ('o' << 16) | ('n' << 8) | 'g', /* Mong 3.0*/
	SCRIPT_MYANMAR			= ('M' << 24) | ('y' << 16) | ('m' << 8) | 'r', /* Mymr 3.0*/
	SCRIPT_OGHAM			= ('O' << 24) | ('g' << 16) | ('a' << 8) | 'm', /* Ogam 3.0*/
	SCRIPT_RUNIC			= ('R' << 24) | ('u' << 16) | ('n' << 8) | 'r', /* Runr 3.0*/
	SCRIPT_SINHALA			= ('S' << 24) | ('i' << 16) | ('n' << 8) | 'h', /* Sinh 3.0*/
	SCRIPT_SYRIAC			= ('S' << 24) | ('y' << 16) | ('r' << 8) | 'c', /* Syrc 3.0*/
	SCRIPT_THAANA			= ('T' << 24) | ('h' << 16) | ('a' << 8) | 'a', /* Thaa 3.0*/
	SCRIPT_YI				= ('Y' << 24) | ('i' << 16) | ('i' << 8) | 'i', /* Yiii 3.0*/

	SCRIPT_DESERET			= ('D' << 24) | ('s' << 16) | ('r' << 8) | 't', /* Dsrt 3.1*/
	SCRIPT_GOTHIC			= ('G' << 24) | ('o' << 16) | ('t' << 8) | 'h', /* Goth 3.1*/
	SCRIPT_OLD_ITALIC		= ('I' << 24) | ('t' << 16) | ('a' << 8) | 'l', /* Ital 3.1*/

	SCRIPT_BUHID			= ('B' << 24) | ('u' << 16) | ('h' << 8) | 'd', /* Buhd 3.2*/
	SCRIPT_HANUNOO			= ('H' << 24) | ('a' << 16) | ('n' << 8) | 'o', /* Hano 3.2*/
	SCRIPT_TAGALOG			= ('T' << 24) | ('g' << 16) | ('l' << 8) | 'g', /* Tglg 3.2*/
	SCRIPT_TAGBANWA			= ('T' << 24) | ('a' << 16) | ('g' << 8) | 'b', /* Tagb 3.2*/

	SCRIPT_CYPRIOT			= ('C' << 24) | ('p' << 16) | ('r' << 8) | 't', /* Cprt 4.0*/
	SCRIPT_LIMBU			= ('L' << 24) | ('i' << 16) | ('m' << 8) | 'b', /* Limb 4.0*/
	SCRIPT_LINEAR_B			= ('L' << 24) | ('i' << 16) | ('n' << 8) | 'b', /* Linb 4.0*/
	SCRIPT_OSMANYA			= ('O' << 24) | ('s' << 16) | ('m' << 8) | 'a', /* Osma 4.0*/
	SCRIPT_SHAVIAN			= ('S' << 24) | ('h' << 16) | ('a' << 8) | 'w', /* Shaw 4.0*/
	SCRIPT_TAI_LE			= ('T' << 24) | ('a' << 16) | ('l' << 8) | 'e', /* Tale 4.0*/
	SCRIPT_UGARITIC			= ('U' << 24) | ('g' << 16) | ('a' << 8) | 'r', /* Ugar 4.0*/

	SCRIPT_BUGINESE			= ('B' << 24) | ('u' << 16) | ('g' << 8) | 'i', /* Bugi 4.1*/
	SCRIPT_COPTIC			= ('C' << 24) | ('o' << 16) | ('p' << 8) | 't', /* Copt 4.1*/
	SCRIPT_GLAGOLITIC		= ('G' << 24) | ('l' << 16) | ('a' << 8) | 'g', /* Glag 4.1*/
	SCRIPT_KHAROSHTHI		= ('K' << 24) | ('h' << 16) | ('a' << 8) | 'r', /* Khar 4.1*/
	SCRIPT_NEW_TAI_LUE		= ('T' << 24) | ('a' << 16) | ('l' << 8) | 'u', /* Talu 4.1*/
	SCRIPT_OLD_PERSIAN		= ('X' << 24) | ('p' << 16) | ('e' << 8) | 'o', /* Xpeo 4.1*/
	SCRIPT_SYLOTI_NAGRI		= ('S' << 24) | ('y' << 16) | ('l' << 8) | 'o', /* Sylo 4.1*/
	SCRIPT_TIFINAGH			= ('T' << 24) | ('f' << 16) | ('n' << 8) | 'g', /* Tfng 4.1*/

	SCRIPT_BALINESE			= ('B' << 24) | ('a' << 16) | ('l' << 8) | 'i', /* Bali 5.0*/
	SCRIPT_CUNEIFORM		= ('X' << 24) | ('s' << 16) | ('u' << 8) | 'x', /* Xsux 5.0*/
	SCRIPT_NKO				= ('N' << 24) | ('k' << 16) | ('o' << 8) | 'o', /* Nkoo 5.0*/
	SCRIPT_PHAGS_PA			= ('P' << 24) | ('h' << 16) | ('a' << 8) | 'g', /* Phag 5.0*/
	SCRIPT_PHOENICIAN		= ('P' << 24) | ('h' << 16) | ('n' << 8) | 'x', /* Phnx 5.0*/

	SCRIPT_CARIAN			= ('C' << 24) | ('a' << 16) | ('r' << 8) | 'i', /* Cari 5.1*/
	SCRIPT_CHAM				= ('C' << 24) | ('h' << 16) | ('a' << 8) | 'm', /* Cham 5.1*/
	SCRIPT_KAYAH_LI			= ('K' << 24) | ('a' << 16) | ('l' << 8) | 'i', /* Kali 5.1*/
	SCRIPT_LEPCHA			= ('L' << 24) | ('e' << 16) | ('p' << 8) | 'c', /* Lepc 5.1*/
	SCRIPT_LYCIAN			= ('L' << 24) | ('y' << 16) | ('c' << 8) | 'i', /* Lyci 5.1*/
	SCRIPT_LYDIAN			= ('L' << 24) | ('y' << 16) | ('d' << 8) | 'i', /* Lydi 5.1*/
	SCRIPT_OL_CHIKI			= ('O' << 24) | ('l' << 16) | ('c' << 8) | 'k', /* Olck 5.1*/
	SCRIPT_REJANG			= ('R' << 24) | ('j' << 16) | ('n' << 8) | 'g', /* Rjng 5.1*/
	SCRIPT_SAURASHTRA		= ('S' << 24) | ('a' << 16) | ('u' << 8) | 'r', /* Saur 5.1*/
	SCRIPT_SUNDANESE		= ('S' << 24) | ('u' << 16) | ('n' << 8) | 'd', /* Sund 5.1*/
	SCRIPT_VAI				= ('V' << 24) | ('a' << 16) | ('i' << 8) | 'i', /* Vaii 5.1*/

	SCRIPT_AVESTAN			= ('A' << 24) | ('v' << 16) | ('s' << 8) | 't', /* Avst 5.2*/
	SCRIPT_BAMUM			= ('B' << 24) | ('a' << 16) | ('m' << 8) | 'u', /* Bamu 5.2*/
	SCRIPT_EGYPTIAN_HIEROGLYPHS		= ('E' << 24) | ('g' << 16) | ('y' << 8) | 'p', /* Egyp 5.2*/
	SCRIPT_IMPERIAL_ARAMAIC	= ('A' << 24) | ('r' << 16) | ('m' << 8) | 'i', /* Armi 5.2*/
	SCRIPT_INSCRIPTIONAL_PAHLAVI	= ('P' << 24) | ('h' << 16) | ('l' << 8) | 'i', /* Phli 5.2*/
	SCRIPT_INSCRIPTIONAL_PARTHIAN	= ('P' << 24) | ('r' << 16) | ('t' << 8) | 'i', /* Prti 5.2*/
	SCRIPT_JAVANESE			= ('J' << 24) | ('a' << 16) | ('v' << 8) | 'a', /* Java 5.2*/
	SCRIPT_KAITHI			= ('K' << 24) | ('t' << 16) | ('h' << 8) | 'i', /* Kthi 5.2*/
	SCRIPT_LISU				= ('L' << 24) | ('i' << 16) | ('s' << 8) | 'u', /* Lisu 5.2*/
	SCRIPT_MEETEI_MAYEK		= ('M' << 24) | ('t' << 16) | ('e' << 8) | 'i', /* Mtei 5.2*/
	SCRIPT_OLD_SOUTH_ARABIAN= ('S' << 24) | ('a' << 16) | ('r' << 8) | 'b', /* Sarb 5.2*/
	SCRIPT_OLD_TURKIC		= ('O' << 24) | ('r' << 16) | ('k' << 8) | 'h', /* Orkh 5.2*/
	SCRIPT_SAMARITAN		= ('S' << 24) | ('a' << 16) | ('m' << 8) | 'r', /* Samr 5.2*/
	SCRIPT_TAI_THAM			= ('L' << 24) | ('a' << 16) | ('n' << 8) | 'a', /* Lana 5.2*/
	SCRIPT_TAI_VIET			= ('T' << 24) | ('a' << 16) | ('v' << 8) | 't', /* Tavt 5.2*/

	SCRIPT_BATAK			= ('B' << 24) | ('a' << 16) | ('t' << 8) | 'k', /* Batk 6.0*/
	SCRIPT_BRAHMI			= ('B' << 24) | ('r' << 16) | ('a' << 8) | 'h', /* Brah 6.0*/
	SCRIPT_MANDAIC			= ('M' << 24) | ('a' << 16) | ('n' << 8) | 'd', /* Mand 6.0*/

	SCRIPT_CHAKMA			= ('C' << 24) | ('a' << 16) | ('k' << 8) | 'm', /* Cakm 6.1*/
	SCRIPT_MEROITIC_CURSIVE	= ('M' << 24) | ('e' << 16) | ('r' << 8) | 'c', /* Merc 6.1*/
	SCRIPT_MEROITIC_HIEROGLYPHS	= ('M' << 24) | ('e' << 16) | ('r' << 8) | 'o', /* Mero 6.1*/
	SCRIPT_MIAO				= ('P' << 24) | ('l' << 16) | ('r' << 8) | 'd', /* Plrd 6.1*/
	SCRIPT_SHARADA			= ('S' << 24) | ('h' << 16) | ('r' << 8) | 'd', /* Shrd 6.1*/
	SCRIPT_SORA_SOMPENG		= ('S' << 24) | ('o' << 16) | ('r' << 8) | 'a', /* Sora 6.1*/
	SCRIPT_TAKRI			= ('T' << 24) | ('a' << 16) | ('k' << 8) | 'r', /* Takr 6.1*/

	/* Since: 0.9.30 */
	SCRIPT_BASSA_VAH		= ('B' << 24) | ('a' << 16) | ('s' << 8) | 's', /* Bass 7.0*/
	SCRIPT_CAUCASIAN_ALBANIAN	= ('A' << 24) | ('g' << 16) | ('h' << 8) | 'b', /* Aghb 7.0*/
	SCRIPT_DUPLOYAN			= ('D' << 24) | ('u' << 16) | ('p' << 8) | 'l', /* Dupl 7.0*/
	SCRIPT_ELBASAN			= ('E' << 24) | ('l' << 16) | ('b' << 8) | 'a', /* Elba 7.0*/
	SCRIPT_GRANTHA			= ('G' << 24) | ('r' << 16) | ('a' << 8) | 'n', /* Gran 7.0*/
	SCRIPT_KHOJKI			= ('K' << 24) | ('h' << 16) | ('o' << 8) | 'j', /* Khoj 7.0*/
	SCRIPT_KHUDAWADI		= ('S' << 24) | ('i' << 16) | ('n' << 8) | 'd', /* Sind 7.0*/
	SCRIPT_LINEAR_A			= ('L' << 24) | ('i' << 16) | ('n' << 8) | 'a', /* Lina 7.0*/
	SCRIPT_MAHAJANI			= ('M' << 24) | ('a' << 16) | ('h' << 8) | 'j', /* Mahj 7.0*/
	SCRIPT_MANICHAEAN		= ('M' << 24) | ('a' << 16) | ('n' << 8) | 'i', /* Mani 7.0*/
	SCRIPT_MENDE_KIKAKUI	= ('M' << 24) | ('e' << 16) | ('n' << 8) | 'd', /* Mend 7.0*/
	SCRIPT_MODI				= ('M' << 24) | ('o' << 16) | ('d' << 8) | 'i', /* Modi 7.0*/
	SCRIPT_MRO				= ('M' << 24) | ('r' << 16) | ('o' << 8) | 'o', /* Mroo 7.0*/
	SCRIPT_NABATAEAN		= ('N' << 24) | ('b' << 16) | ('a' << 8) | 't', /* Nbat 7.0*/
	SCRIPT_OLD_NORTH_ARABIAN	= ('N' << 24) | ('a' << 16) | ('r' << 8) | 'b', /* Narb 7.0*/
	SCRIPT_OLD_PERMIC		= ('P' << 24) | ('e' << 16) | ('r' << 8) | 'm', /* Perm 7.0*/
	SCRIPT_PAHAWH_HMONG		= ('H' << 24) | ('m' << 16) | ('n' << 8) | 'g', /* Hmng 7.0*/
	SCRIPT_PALMYRENE		= ('P' << 24) | ('a' << 16) | ('l' << 8) | 'm', /* Palm 7.0*/
	SCRIPT_PAU_CIN_HAU		= ('P' << 24) | ('a' << 16) | ('u' << 8) | 'c', /* Pauc 7.0*/
	SCRIPT_PSALTER_PAHLAVI	= ('P' << 24) | ('h' << 16) | ('l' << 8) | 'p', /* Phlp 7.0*/
	SCRIPT_SIDDHAM			= ('S' << 24) | ('i' << 16) | ('d' << 8) | 'd', /* Sidd 7.0*/
	SCRIPT_TIRHUTA			= ('T' << 24) | ('i' << 16) | ('r' << 8) | 'h', /* Tirh 7.0*/
	SCRIPT_WARANG_CITI		= ('W' << 24) | ('a' << 16) | ('r' << 8) | 'a', /* Wara 7.0*/

	SCRIPT_AHOM				= ('A' << 24) | ('h' << 16) | ('o' << 8) | 'm', /* Ahom 8.0*/
	SCRIPT_ANATOLIAN_HIEROGLYPHS	= ('H' << 24) | ('l' << 16) | ('u' << 8) | 'w', /* Hluw 8.0*/
	SCRIPT_HATRAN			= ('H' << 24) | ('a' << 16) | ('t' << 8) | 'r', /* Hatr 8.0*/
	SCRIPT_MULTANI			= ('M' << 24) | ('u' << 16) | ('l' << 8) | 't', /* Mult 8.0*/
	SCRIPT_OLD_HUNGARIAN	= ('H' << 24) | ('u' << 16) | ('n' << 8) | 'g', /* Hung 8.0*/
	SCRIPT_SIGNWRITING		= ('S' << 24) | ('g' << 16) | ('n' << 8) | 'w', /* Sgnw 8.0*/

	/* Since 1.3.0 */
	SCRIPT_ADLAM			= ('A' << 24) | ('d' << 16) | ('l' << 8) | 'm', /* Adlm 9.0*/
	SCRIPT_BHAIKSUKI		= ('B' << 24) | ('h' << 16) | ('k' << 8) | 's', /* Bhks 9.0*/
	SCRIPT_MARCHEN			= ('M' << 24) | ('a' << 16) | ('r' << 8) | 'c', /* Marc 9.0*/
	SCRIPT_OSAGE			= ('O' << 24) | ('s' << 16) | ('g' << 8) | 'e', /* Osge 9.0*/
	SCRIPT_TANGUT			= ('T' << 24) | ('a' << 16) | ('n' << 8) | 'g', /* Tang 9.0*/
	SCRIPT_NEWA				= ('N' << 24) | ('e' << 16) | ('w' << 8) | 'a', /* Newa 9.0*/

	/* Since 1.6.0 */
	SCRIPT_MASARAM_GONDI	= ('G' << 24) | ('o' << 16) | ('n' << 8) | 'm', /* Gonm 10.0*/
	SCRIPT_NUSHU			= ('N' << 24) | ('s' << 16) | ('h' << 8) | 'u', /* Nshu 10.0*/
	SCRIPT_SOYOMBO			= ('S' << 24) | ('o' << 16) | ('y' << 8) | 'o', /* Soyo 10.0*/
	SCRIPT_ZANABAZAR_SQUARE	= ('Z' << 24) | ('a' << 16) | ('n' << 8) | 'b', /* Zanb 10.0*/

	/* Since 1.8.0 */
	SCRIPT_DOGRA			= ('D' << 24) | ('o' << 16) | ('g' << 8) | 'r', /* Dogr 11.0*/
	SCRIPT_GUNJALA_GONDI	= ('G' << 24) | ('o' << 16) | ('n' << 8) | 'g', /* Gong 11.0*/
	SCRIPT_HANIFI_ROHINGYA	= ('R' << 24) | ('o' << 16) | ('h' << 8) | 'g', /* Rohg 11.0*/
	SCRIPT_MAKASAR			= ('M' << 24) | ('a' << 16) | ('k' << 8) | 'a', /* Maka 11.0*/
	SCRIPT_MEDEFAIDRIN		= ('M' << 24) | ('e' << 16) | ('d' << 8) | 'f', /* Medf 11.0*/
	SCRIPT_OLD_SOGDIAN		= ('S' << 24) | ('o' << 16) | ('g' << 8) | 'o', /* Sogo 11.0*/
	SCRIPT_SOGDIAN			= ('S' << 24) | ('o' << 16) | ('g' << 8) | 'd', /* Sogd 11.0*/

	/* Since 2.4.0 */
	SCRIPT_ELYMAIC			= ('E' << 24) | ('l' << 16) | ('y' << 8) | 'm', /* Elym 12.0*/
	SCRIPT_NANDINAGARI		= ('N' << 24) | ('a' << 16) | ('n' << 8) | 'd', /* Nand 12.0*/
	SCRIPT_NYIAKENG_PUACHUE_HMONG	= ('H' << 24) | ('m' << 16) | ('n' << 8) | 'p', /* Hmnp 12.0*/
	SCRIPT_WANCHO			= ('W' << 24) | ('c' << 16) | ('h' << 8) | 'o', /* Wcho 12.0*/

	/* Since 2.6.7 */
	SCRIPT_CHORASMIAN		= ('C' << 24) | ('h' << 16) | ('r' << 8) | 's', /* Chrs 13.0*/
	SCRIPT_DIVES_AKURU		= ('D' << 24) | ('i' << 16) | ('a' << 8) | 'k', /* Diak 13.0*/
	SCRIPT_KHITAN_SMALL_SCRIPT= ('K' << 24) | ('i' << 16) | ('t' << 8) | 's', /* Kits 13.0*/
	SCRIPT_YEZIDI			= ('Y' << 24) | ('e' << 16) | ('z' << 8) | 'i', /* Yezi 13.0*/

	/* Since 3.0.0 */
	SCRIPT_CYPRO_MINOAN		= ('C' << 24) | ('p' << 16) | ('m' << 8) | 'n', /* Cpmn 14.0*/
	SCRIPT_OLD_UYGHUR		= ('O' << 24) | ('u' << 16) | ('g' << 8) | 'r', /* Ougr 14.0*/
	SCRIPT_TANGSA			= ('T' << 24) | ('n' << 16) | ('s' << 8) | 'a', /* Tnsa 14.0*/
	SCRIPT_TOTO				= ('T' << 24) | ('o' << 16) | ('t' << 8) | 'o', /* Toto 14.0*/
	SCRIPT_VITHKUQI			= ('V' << 24) | ('i' << 16) | ('t' << 8) | 'h', /* Vith 14.0*/

	/* Since 3.4.0 */
	SCRIPT_MATH				= ('Z' << 24) | ('m' << 16) | ('t' << 8) | 'h',

	/* Since 5.2.0 */
	SCRIPT_KAWI				= ('K' << 24) | ('a' << 16) | ('w' << 8) | 'i', /* Kawi 15.0*/
	SCRIPT_NAG_MUNDARI		= ('N' << 24) | ('a' << 16) | ('g' << 8) | 'm', /* Nagm 15.0*/

	/* No script set. */
	SCRIPT_INVALID			= TAG_NONE,

	/*< private >*/

	/* Dummy values to ensure any tag_t value can be passed/stored as script_t
	* without risking undefined behavior.  We have two, for historical reasons.
	* TAG_MAX used to be unsigned, but that was invalid Ansi C, so was changed
	* to _SCRIPT_MAX_VALUE to be equal to TAG_MAX_SIGNED as well.
	*
	* See this thread for technicalities:
	*
	*   https://lists.freedesktop.org/archives/harfbuzz/2014-March/004150.html
	*/
//	_SCRIPT_MAX_VALUE			= TAG_MAX_SIGNED, /*< skip >*/
//	_SCRIPT_MAX_VALUE_SIGNED	= TAG_MAX_SIGNED /*< skip >*/
}

/*************/
/* User data */
/*************/

/**
 * typedef struct hb_user_data_key_t {
  //< private >
  char unused;
} hb_user_data_key_t;

 * Data structure for holding user-data keys.
 **/
user_data_key_t :: struct {}				// opaque structure

/**
 * typedef void (*hb_destroy_func_t) (void *user_data);
 * - user_data: the data to be destroyed
 *
 * A virtual method for destroy user-data callbacks.
 */
destroy_func_t :: #type proc(user_data: rawptr)

/*********************************/
/* Font features and variations. */
/*********************************/

/**
 * #define HB_FEATURE_GLOBAL_START	0
 *
 * Special setting for #hb_feature_t.start to apply the feature from the start of the buffer.
 */
FEATURE_GLOBAL_START : c.int : 0

/**
 * #define HB_FEATURE_GLOBAL_END	((unsigned int) -1)
 *
 * Special setting for #hb_feature_t.end to apply the feature from to the end of the buffer.
 */
FEATURE_GLOBAL_END : c.int : -1

/**
typedef struct hb_feature_t {
  hb_tag_t      tag;
  uint32_t      value;
  unsigned int  start;
  unsigned int  end;
} hb_feature_t;
 * @tag: The #hb_tag_t tag of the feature
 * @value: The value of the feature. 0 disables the feature, non-zero (usually
 * 1) enables the feature.  For features implemented as lookup type 3 (like
 * 'salt') the @value is a one based index into the alternates.
 * @start: the cluster to start applying this feature setting (inclusive).
 * @end: the cluster to end applying this feature setting (exclusive).
 *
 * The #hb_feature_t is the structure that holds information about requested
 * feature application. The feature will be applied with the given value to all
 * glyphs which are in clusters between @start (inclusive) and @end (exclusive).
 * Setting start to #HB_FEATURE_GLOBAL_START and end to #HB_FEATURE_GLOBAL_END
 * specifies that the feature always applies to the entire buffer.
 */
feature_t :: struct
{
  tag	: tag_t,
  value	: u32,
  start	: c.uint,
  end	: c.uint
}

/**
typedef struct hb_variation_t {
  hb_tag_t tag;
  float    value;
} hb_variation_t;
 * @tag: The #hb_tag_t tag of the variation-axis name
 * @value: The value of the variation axis
 *
 * Data type for holding variation data. Registered OpenType variation-axis tags are listed in
 * [OpenType Axis Tag Registry](https://docs.microsoft.com/en-us/typography/opentype/spec/dvaraxisreg).
 */
variation_t :: struct
{
	tag		: tag_t,
	value	: c.float
}

/**
 * typedef uint32_t hb_color_t;
 *
 * Data type for holding color values. Colors are eight bits per channel RGB plus alpha transparency.
 */
 color_t	:: distinct u32

/**
 * #define HB_COLOR(b,g,r,a) ((hb_color_t) HB_TAG ((b),(g),(r),(a)))
 * @b: blue channel value
 * @g: green channel value
 * @r: red channel value
 * @a: alpha channel value
 *
 * Constructs an #hb_color_t from four integers.
 */
COLOR	:: proc(b: u8, g: u8, r: u8, a: u8)	-> color_t
{	return color_t( (u32(b) << 24) | (u32(g) << 16) | (u32(r) << 8) | u32(a) )	}

/* WHY BOTH FUNCTIONS AND MACROS ?
HB_EXTERN uint8_t hb_color_get_alpha (hb_color_t color);
HB_EXTERN uint8_t hb_color_get_red (hb_color_t color);
HB_EXTERN uint8_t hb_color_get_green (hb_color_t color);
HB_EXTERN uint8_t hb_color_get_blue (hb_color_t color);

#define hb_color_get_alpha(color)	((color) & 0xFF)
#define hb_color_get_red(color)		(((color) >> 8) & 0xFF)
#define hb_color_get_green(color)	(((color) >> 16) & 0xFF)
#define hb_color_get_blue(color)	(((color) >> 24) & 0xFF)
*/
color_get_alpha	:: proc(color: color_t)	-> u8	{	return u8( color        & 0xFF)	}
color_get_red	:: proc(color: color_t)	-> u8	{	return u8((color >>  8) & 0xFF)	}
color_get_green	:: proc(color: color_t)	-> u8	{	return u8((color >> 16) & 0xFF)	}
color_get_blue	:: proc(color: color_t)	-> u8	{	return u8((color >> 24) & 0xFF)	}

//
// From https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-style.h
//

/*
typedef enum
{
  HB_STYLE_TAG_ITALIC		= HB_TAG ('i','t','a','l'),
  HB_STYLE_TAG_OPTICAL_SIZE	= HB_TAG ('o','p','s','z'),
  HB_STYLE_TAG_SLANT_ANGLE	= HB_TAG ('s','l','n','t'),
  HB_STYLE_TAG_SLANT_RATIO	= HB_TAG ('S','l','n','t'),
  HB_STYLE_TAG_WIDTH		= HB_TAG ('w','d','t','h'),
  HB_STYLE_TAG_WEIGHT		= HB_TAG ('w','g','h','t'),

  //< private >
  _HB_STYLE_TAG_MAX_VALUE	= HB_TAG_MAX_SIGNED // < skip >
} hb_style_tag_t;

Since: 3.0.0
*/
style_tag_t :: enum
{
	STYLE_TAG_ITALIC		= ('i' << 24) | ('t' << 16) | ('a' << 8) | 'l',	// Used to vary between non-italic and italic. A value of 0 can be interpreted as "Roman" (non-italic); a value of 1 can be interpreted as (fully) italic.
	STYLE_TAG_OPTICAL_SIZE	= ('o' << 24) | ('p' << 16) | ('s' << 8) | 'z',	// Used to vary design to suit different text sizes. Non-zero. Values can be interpreted as text size, in points.
	STYLE_TAG_SLANT_ANGLE	= ('s' << 24) | ('l' << 16) | ('n' << 8) | 't',	// Used to vary between upright and slanted text. Values must be greater than -90 and less than +90. Values can be interpreted as the angle,
														// in counter-clockwise degrees, of oblique slant from whatever the designer considers to be upright for that font design.
														// Typical right-leaning Italic fonts have a negative slant angle (typically around -12)
	STYLE_TAG_SLANT_RATIO	= ('S' << 24) | ('l' << 16) | ('n' << 8) | 't',	// same as @HB_STYLE_TAG_SLANT_ANGLE expression as ratio. Typical right-leaning Italic fonts have a positive slant ratio (typically around 0.2)
	STYLE_TAG_WIDTH			= ('w' << 24) | ('d' << 16) | ('t' << 8) | 'h',	// Used to vary width of text from narrower to wider. Non-zero. Values can be interpreted
														// as a percentage of whatever the font designer considers “normal width” for that font design.
	STYLE_TAG_WEIGHT		= ('w' << 24) | ('g' << 16) | ('h' << 8) | 't'	// Used to vary stroke thicknesses or other design details to give variation from lighter to blacker. Values can be interpreted in direct
														// comparison to values for usWeightClass in the OS/2 table, or the CSS font-weight property.
//
//	STYLE_TAG_MAX_VALUE	= HB_TAG_MAX_SIGNED /*< skip >*/
}

//******************
// FUNCTIONS
//******************

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "../libs/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/* 
HB_EXTERN hb_tag_t hb_tag_from_string (const char *str, int len);

Converts a string into an hb_tag_t. Valid tags are four characters. Shorter input strings
will be padded with spaces. Longer input strings will be truncated.
- str		String to convert. [array length=len][element-type uint8_t]
- len		Length of str , or -1 if it is NULL-terminated
- Returns	The hb_tag_t corresponding to str
*/
tag_from_string			:: proc(str: cstring, len: c.int)	-> tag_t ---

/*
HB_EXTERN void hb_tag_to_string (hb_tag_t tag, char *buf);

Converts an hb_tag_t to a string and returns it in buf. Strings will be four characters long.
- tag		hb_tag_t to convert
- buf		Converted string. [out caller-allocates][array fixed-size=4][element-type uint8_t]buf should have 4 bytes.
*/
tag_to_string			:: proc(tag: tag_t, buf: [^]u8)	---

/*
HB_EXTERN hb_direction_t hb_direction_from_string (const char *str, int len);

Converts a string to an hb_direction_t.
Matching is loose and applies only to the first letter. For examples, "LTR" and "left-to-right" will both return HB_DIRECTION_LTR.
Unmatched strings will return HB_DIRECTION_INVALID.
- str		String to convert. [array length=len][element-type uint8_t]
- len		Length of str , or -1 if it is NULL-terminated
- Returns	The hb_direction_t matching str
*/
direction_from_string	:: proc(str: cstring, len: c.int)	-> direction_t ---

/*
HB_EXTERN const char * hb_direction_to_string (hb_direction_t direction);

Converts an hb_direction_t to a string.
- direction	The hb_direction_t to convert
- Returns	The string corresponding to direction. 
*/
direction_to_string		:: proc(direction: direction_t)	-> cstring ---

/*
HB_EXTERN hb_language_t hb_language_from_string (const char *str, int len);

Converts str representing a BCP 47 language tag to the corresponding hb_language_t.
- str		a string representing a BCP 47 language tag. [array length=len][element-type uint8_t]
- len		length of the str , or -1 if it is NULL-terminated.
- Returns	The hb_language_t corresponding to the BCP 47 language tag. [transfer none]
*/
language_from_string	:: proc(str: cstring, len: c.int)	-> language_t ---

/*
HB_EXTERN const char * hb_language_to_string (hb_language_t language);

Converts an hb_language_t to a string.
- language	The hb_language_t to convert
- Returns	A NULL-terminated string representing the language . Must not be freed by the caller. [transfer none]
*/
language_to_string		:: proc(language: language_t)	-> cstring ---

/*
HB_EXTERN hb_language_t hb_language_get_default (void);

Fetch the default language from current locale.
Note that the first time this function is called, it calls "setlocale (LC_CTYPE, nullptr)" to fetch current locale.
The underlying setlocale function is, in many implementations, NOT threadsafe. To avoid problems, call this function
once before multiple threads can call it. This function is only used from hb_buffer_guess_segment_properties() by HarfBuzz itself.
- Returns	The default language of the locale as an hb_language_t. [transfer none]
*/
language_get_default	:: proc()	-> language_t ---
/*
HB_EXTERN hb_bool_t hb_language_matches (hb_language_t language, hb_language_t specific);

Check whether a second language tag is the same or a more specific version of the provided language tag.
For example, "fa_IR.utf8" is a more specific tag for "fa" or for "fa_IR".
- language	The hb_language_t to work on
- specific	Another hb_language_t
- Returns	true if languages match, false otherwise.
*/
language_matches		:: proc(language: language_t, specific: language_t)	-> bool_t ---

/* Script functions
HB_EXTERN hb_script_t hb_script_from_iso15924_tag (hb_tag_t tag);

Converts an ISO 15924 script tag to a corresponding hb_script_t.
- tag		an hb_tag_t representing an ISO 15924 tag.
- Returns	An hb_script_t corresponding to the ISO 15924 tag.
*/
script_from_iso15924_tag		:: proc(tag: tag_t)					-> script_t ---
/*
HB_EXTERN hb_tag_t hb_script_to_iso15924_tag (hb_script_t script);

Converts an hb_script_t to a corresponding ISO 15924 script tag.
- script	an hb_script_t to convert.
- Returns	An hb_tag_t representing an ISO 15924 script tag.
*/
script_to_iso15924_tag			:: proc(script: script_t)			-> tag_t ---
/*
HB_EXTERN hb_script_t hb_script_from_string (const char *str, int len);

Converts a string str representing an ISO 15924 script tag to a corresponding hb_script_t.
Shorthand for hb_tag_from_string() then hb_script_from_iso15924_tag().
- str		a string representing an ISO 15924 tag. [array length=len][element-type uint8_t]
- len		length of the str , or -1 if it is NULL-terminated.
- Returns	An hb_script_t corresponding to the ISO 15924 tag.
*/
script_from_string				:: proc(str: cstring, len: c.int)	-> script_t ---
/*
hb_direction_t hb_script_get_horizontal_direction (hb_script_t script);

Fetches the hb_direction_t of a script when it is set horizontally. All right-to-left scripts will return HB_DIRECTION_RTL. All left-to-right scripts will return HB_DIRECTION_LTR. Scripts that can be written either horizontally or vertically will return HB_DIRECTION_INVALID. Unknown scripts will return HB_DIRECTION_LTR.
- script	The hb_script_t to query
- Returns	The horizontal hb_direction_t of script
*/
script_get_horizontal_direction	:: proc(script: script_t)			-> direction_t ---

/*
HB_EXTERN hb_bool_t hb_feature_from_string (const char *str, int len, hb_feature_t *feature);

Parses a string into a hb_feature_t.

The format for specifying feature strings follows. All valid CSS font-feature-settings values other than 'normal'
and the global values are also accepted, though not documented below. CSS string escapes are not supported.

The range indices refer to the positions between Unicode characters. The position before the first character is always 0.

The format is Python-esque. Here is how it all works:
Syntax 	Value		Start 	End 	 
Setting value: 	  	  	  	 
kern		1		0		∞	Turn feature on
+kern		1		0	 	∞	Turn feature on
-kern		0		0		∞	Turn feature off
kern=0		0		0		∞	Turn feature off
kern=1		1		0		∞	Turn feature on
aalt=2		2		0		∞	Choose 2nd alternate
Setting index: 	  	  	  	 
kern[]		1		0		∞	Turn feature on
kern[:]		1		0		∞	Turn feature on
kern[5:]	1		5		∞	Turn feature on, partial
kern[:5]	1		0		5	Turn feature on, partial
kern[3:5]	1		3		5	Turn feature on, range
kern[3]		1		3		3+1	Turn feature on, single char
Mixing it all: 	  	  	  	 
aalt[3:5]=2 2		3		5	Turn 2nd alternate on for range

- str		a string to parse. [array length=len][element-type uint8_t]
- len		length of str , or -1 if string is NULL terminated
- feature	the hb_feature_t to initialize with the parsed values. [out]
- Returns	true if str is successfully parsed, false otherwise
*/
feature_from_string		:: proc(str: cstring, len: c.int, feature: ^feature_t)	-> bool_t ---

/*
HB_EXTERN void hb_feature_to_string (hb_feature_t *feature, char *buf, unsigned int size);

Converts a hb_feature_t into a NULL-terminated string in the format understood by hb_feature_from_string(). The client in responsible for allocating big enough size for buf , 128 bytes is more than enough.
- feature	an hb_feature_t to convert
- buf		output string. [array length=size][out]
- size		the allocated size of buf 
*/
feature_to_string		:: proc(feature: ^feature_t, buf: [^]u8, size: c.uint)	---

/*
HB_EXTERN hb_bool_t hb_variation_from_string (const char *str, int len, hb_variation_t *variation);

Parses a string into a hb_variation_t.

The format for specifying variation settings follows. All valid CSS font-variation-settings values other than 'normal'
and 'inherited' are also accepted, though, not documented below.

The format is a tag, optionally followed by an equals sign, followed by a number. For example wght=500, or slnt=-7.5.

- str		a string to parse. [array length=len][element-type uint8_t]
- len		length of str , or -1 if string is NULL terminated
- variation	the hb_variation_t to initialize with the parsed values. [out]
- Returns	true if str is successfully parsed, false otherwise
*/
variation_from_string	:: proc(str: cstring, len: c.int, variation: ^variation_t)	-> bool_t ---

/*
HB_EXTERN void hb_variation_to_string (hb_variation_t *variation, char *buf, unsigned int size);

Converts an hb_variation_t into a NULL-terminated string in the format understood by hb_variation_from_string(). The client in responsible for allocating big enough size for buf , 128 bytes is more than enough.

- variation	an hb_variation_t to convert
- buf		output string. [array length=size][out caller-allocates]
- size		the allocated size of buf 
*/
variation_to_string		:: proc(variation: ^variation_t, buf: [^]u8, size: c.uint)	---

// Additional version-related function
// From https://harfbuzz.github.io/harfbuzz-hb-version.html

/*
void hb_version (unsigned int *major, unsigned int *minor, unsigned int *micro);

Returns library version as three integer components.

- major	Library major version component. [out]
- minor	Library minor version component. [out]
- micro	Library micro version component. [out]

Since: 0.9.2
*/
version :: proc (major: ^c.uint, minor: ^c.uint, micro: ^c.uint)	---

/*
hb_bool_t hb_version_atleast (unsigned int major, unsigned int minor, unsigned int micro);

Tests the library version against a minimum value, as three integer components.

- major		Library major version component
- minor		Library minor version component
- micro		Library micro version component
- Returns	true if the library is equal to or greater than the test value, false otherwise

Since: 0.9.30
*/
version_atleast :: proc (major: c.uint, minor: c.uint, micro: c.uint)	-> bool_t ---

/*
const char * hb_version_string (void);

- Returns	library version as a string with three components.

Since: 0.9.2
*/
version_string :: proc ()	-> cstring ---

}
