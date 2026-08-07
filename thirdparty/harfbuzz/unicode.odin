/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

map.odin - Types and functions for managing integer maps.

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

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-map.h
		https://harfbuzz.github.io/harfbuzz-hb-map.html
*/

/*
hb-unicode — Unicode character property access

Unicode functions are used to access Unicode character properties. With these functions, client programs can query
various properties from the Unicode Character Database for any code point, such as General Category (gc), Script (sc),
Canonical Combining Class (ccc), etc.

Client programs can optionally pass in their own Unicode functions that implement the same queries. The set of functions
available is defined by the virtual methods in hb_unicode_funcs_t.

HarfBuzz provides built-in default functions for each method in hb_unicode_funcs_t.
*/

package	harfbuzz

import "core:c"

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

//******************
// TYPES
//******************

/*
#define HB_UNICODE_MAX 0x10FFFFu

Maximum valid Unicode code point.

Since: 1.9.0
*/
UNICODE_MAX : u32 : 0x10FFFF

/*
enum hb_unicode_combining_class_t

Data type for the Canonical_Combining_Class (ccc) property from the Unicode Character Database.
Note: newer versions of Unicode may add new values. Client programs should be ready to handle any value in the 0..254 range being returned from hb_unicode_combining_class().
*/
unicode_combining_class_t :: enum
{
	UNICODE_COMBINING_CLASS_NOT_REORDERED,			// Spacing and enclosing marks; also many vowel and consonant signs, even if nonspacing
	UNICODE_COMBINING_CLASS_OVERLAY,				// Marks which overlay a base letter or symbol
	UNICODE_COMBINING_CLASS_NUKTA,					// Diacritic nukta marks in Brahmi-derived scripts
	UNICODE_COMBINING_CLASS_KANA_VOICING,			// Hiragana/Katakana voicing marks
	UNICODE_COMBINING_CLASS_VIRAMA,					// Viramas
	UNICODE_COMBINING_CLASS_CCC10,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC11,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC12,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC13,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC14,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC15,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC16,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC17,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC18,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC19,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC20,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC21,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC22,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC23,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC24,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC25,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC26,					// [Hebrew]
	UNICODE_COMBINING_CLASS_CCC27,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC28,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC29,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC30,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC31,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC32,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC33,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC34,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC35,					// [Arabic]
	UNICODE_COMBINING_CLASS_CCC36,					// [Syriac]
	UNICODE_COMBINING_CLASS_CCC84,					// [Telugu]
	UNICODE_COMBINING_CLASS_CCC91,					// [Telugu]
	UNICODE_COMBINING_CLASS_CCC103,					// [Thai]
	UNICODE_COMBINING_CLASS_CCC107,					// [Thai]
	UNICODE_COMBINING_CLASS_CCC118,					// [Lao]
	UNICODE_COMBINING_CLASS_CCC122,					// [Lao]
	UNICODE_COMBINING_CLASS_CCC129,					// [Tibetan]
	UNICODE_COMBINING_CLASS_CCC130,					// [Tibetan]
	UNICODE_COMBINING_CLASS_CCC132,					// [Tibetan] Since: 7.2.0
	UNICODE_COMBINING_CLASS_ATTACHED_BELOW_LEFT,	// Marks attached at the bottom left
	UNICODE_COMBINING_CLASS_ATTACHED_BELOW,			// Marks attached directly below
	UNICODE_COMBINING_CLASS_ATTACHED_ABOVE,			// Marks attached directly above
	UNICODE_COMBINING_CLASS_ATTACHED_ABOVE_RIGHT,	// Marks attached at the top right
	UNICODE_COMBINING_CLASS_BELOW_LEFT,				// Distinct marks at the bottom left
	UNICODE_COMBINING_CLASS_BELOW,					// Distinct marks directly below
	UNICODE_COMBINING_CLASS_BELOW_RIGHT,			// Distinct marks at the bottom right
	UNICODE_COMBINING_CLASS_LEFT,					// Distinct marks to the left
	UNICODE_COMBINING_CLASS_RIGHT,					// Distinct marks to the right
	UNICODE_COMBINING_CLASS_ABOVE_LEFT,				// Distinct marks at the top left
	UNICODE_COMBINING_CLASS_ABOVE,					// Distinct marks directly above
	UNICODE_COMBINING_CLASS_ABOVE_RIGHT,			// Distinct marks at the top right
	UNICODE_COMBINING_CLASS_DOUBLE_BELOW,			// Distinct marks subtending two bases
	UNICODE_COMBINING_CLASS_DOUBLE_ABOVE,			// Distinct marks extending above two bases
	UNICODE_COMBINING_CLASS_IOTA_SUBSCRIPT,			// Greek iota subscript only
	UNICODE_COMBINING_CLASS_INVALID,				// Invalid combining class
}

/*
enum hb_unicode_general_category_t

Data type for the "General_Category" (gc) property from the Unicode Character Database.
*/
unicode_general_category_t :: enum
{
	UNICODE_GENERAL_CATEGORY_CONTROL,				// [Cc]
	UNICODE_GENERAL_CATEGORY_FORMAT,				// [Cf]
	UNICODE_GENERAL_CATEGORY_UNASSIGNED,			// [Cn]
	UNICODE_GENERAL_CATEGORY_PRIVATE_USE,			// [Co]
	UNICODE_GENERAL_CATEGORY_SURROGATE,				// [Cs]
	UNICODE_GENERAL_CATEGORY_LOWERCASE_LETTER,		// [Ll]
	UNICODE_GENERAL_CATEGORY_MODIFIER_LETTER,		// [Lm]
	UNICODE_GENERAL_CATEGORY_OTHER_LETTER,			// [Lo]
	UNICODE_GENERAL_CATEGORY_TITLECASE_LETTER,		// [Lt]
	UNICODE_GENERAL_CATEGORY_UPPERCASE_LETTER,		// [Lu]
	UNICODE_GENERAL_CATEGORY_SPACING_MARK,			// [Mc]
	UNICODE_GENERAL_CATEGORY_ENCLOSING_MARK,		// [Me]
	UNICODE_GENERAL_CATEGORY_NON_SPACING_MARK,		// [Mn]
	UNICODE_GENERAL_CATEGORY_DECIMAL_NUMBER,		// [Nd]
	UNICODE_GENERAL_CATEGORY_LETTER_NUMBER,			// [Nl]
	UNICODE_GENERAL_CATEGORY_OTHER_NUMBER,			// [No]
	UNICODE_GENERAL_CATEGORY_CONNECT_PUNCTUATION,	// [Pc]
	UNICODE_GENERAL_CATEGORY_DASH_PUNCTUATION,		// [Pd]
	UNICODE_GENERAL_CATEGORY_CLOSE_PUNCTUATION,		// [Pe]
	UNICODE_GENERAL_CATEGORY_FINAL_PUNCTUATION,		// [Pf]
	UNICODE_GENERAL_CATEGORY_INITIAL_PUNCTUATION,	// [Pi]
	UNICODE_GENERAL_CATEGORY_OTHER_PUNCTUATION,		// [Po]
	UNICODE_GENERAL_CATEGORY_OPEN_PUNCTUATION,		// [Ps]
	UNICODE_GENERAL_CATEGORY_CURRENCY_SYMBOL,		// [Sc]
	UNICODE_GENERAL_CATEGORY_MODIFIER_SYMBOL,		// [Sk]
	UNICODE_GENERAL_CATEGORY_MATH_SYMBOL,			// [Sm]
	UNICODE_GENERAL_CATEGORY_OTHER_SYMBOL,			// [So]
	UNICODE_GENERAL_CATEGORY_LINE_SEPARATOR,		// [Zl]
	UNICODE_GENERAL_CATEGORY_PARAGRAPH_SEPARATOR,	// [Zp]
	UNICODE_GENERAL_CATEGORY_SPACE_SEPARATOR,		// [Zs]
}

/*
typedef struct hb_unicode_funcs_t hb_unicode_funcs_t;

Data type containing a set of virtual methods used for accessing various Unicode character properties.

HarfBuzz provides a default function for each of the methods in hb_unicode_funcs_t. Client programs can implement their own
replacements for the individual Unicode functions, as needed, and replace the default by calling the setter for a method.
*/
unicode_funcs_t :: struct {}				// opaque structure

/*
hb_unicode_general_category_t (*hb_unicode_general_category_func_t) (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode, void *user_data);

A virtual method for the hb_unicode_funcs_t structure.

This method should retrieve the General Category property for a specified Unicode code point.

- ufuncs	A Unicode-functions structure
- unicode	The code point to query
- user_data	User data pointer passed by the caller
- Returns	The hb_unicode_general_category_t of unicode
*/
unicode_general_category_func_t :: #type proc "c" (ufuncs: ^unicode_funcs_t, unicode: codepoint_t,
	user_data: rawptr)	-> unicode_general_category_t

/*
hb_unicode_combining_class_t (*hb_unicode_combining_class_func_t) (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode,
	void *user_data);

A virtual method for the hb_unicode_funcs_t structure.

This method should retrieve the Canonical Combining Class (ccc) property for a specified Unicode code point.

- ufuncs	A Unicode-functions structure
- unicode	The code point to query
- user_data	User data pointer passed by the caller
- Returns	The hb_unicode_combining_class_t of unicode
*/
unicode_combining_class_func_t :: #type proc "c" (ufuncs: ^unicode_funcs_t, unicode: codepoint_t,
	user_data: rawptr)	-> unicode_combining_class_t

/*
hb_codepoint_t (*hb_unicode_mirroring_func_t) (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode, void *user_data);

A virtual method for the hb_unicode_funcs_t structure.

This method should retrieve the Bi-Directional Mirroring Glyph code point for a specified Unicode code point.
Note: If a code point does not have a specified Bi-Directional Mirroring Glyph defined, the method should return
the original code point.

- ufuncs	A Unicode-functions structure
- unicode	The code point to query
- user_data	User data pointer passed by the caller
- Returns	The hb_codepoint_t of the Mirroring Glyph for unicode
*/
unicode_mirroring_func_t :: #type proc "c" (ufuncs: ^unicode_funcs_t, unicode: codepoint_t, user_data: rawptr)	-> codepoint_t

/*
hb_script_t (*hb_unicode_script_func_t) (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode, void *user_data);

A virtual method for the hb_unicode_funcs_t structure.

This method should retrieve the Script property for a specified Unicode code point.

- ufuncs	A Unicode-functions structure
- unicode	The code point to query
- user_data	User data pointer passed by the caller
- Returns	The hb_script_t of unicode
*/
unicode_script_func_t :: #type proc "c" (ufuncs: ^unicode_funcs_t, unicode: codepoint_t, user_data: rawptr)	-> script_t

/*
hb_bool_t (*hb_unicode_compose_func_t) (hb_unicode_funcs_t *ufuncs, hb_codepoint_t a, hb_codepoint_t b,
	hb_codepoint_t *ab, void *user_data);

A virtual method for the hb_unicode_funcs_t structure.

This method should compose a sequence of two input Unicode code points by canonical equivalence, returning the composed
code point in a hb_codepoint_t output parameter (if successful). The method must return an hb_bool_t indicating the
success of the composition.

- ufuncs	A Unicode-functions structure
- a			The first code point to compose
- b			The second code point to compose
- ab		The composed code point. [out]
- user_data	user data pointer passed by the caller
- Returns	true is a ,b composed, false otherwise
*/
unicode_compose_func_t :: #type proc "c" (ufuncs: ^unicode_funcs_t, a:codepoint_t, b: codepoint_t,
	ab: ^codepoint_t, user_data: rawptr)	-> bool_t

/*
hb_bool_t (*hb_unicode_decompose_func_t) (hb_unicode_funcs_t *ufuncs, hb_codepoint_t ab, hb_codepoint_t *a,
	hb_codepoint_t *b, void *user_data);

A virtual method for the hb_unicode_funcs_t structure.

This method should decompose an input Unicode code point, returning the two decomposed code points in hb_codepoint_t
output parameters (if successful). The method must return an hb_bool_t indicating the success of the composition.

- ufuncs	A Unicode-functions structure
- ab		The code point to decompose
- a			The first decomposed code point. [out]
- b			The second decomposed code point. [out]
- user_data	user data pointer passed by the caller
- Returns	true if ab decomposed, false otherwise
*/
unicode_decompose_func_t :: #type proc "c" (ufuncs: ^unicode_funcs_t, ab: codepoint_t, a: ^codepoint_t,
	b: ^codepoint_t, user_data: rawptr)	-> bool_t

//******************
// FUNCTIONS */
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
hb_unicode_general_category_t hb_unicode_general_category (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode);

Retrieves the General Category (gc) property of code point unicode.

- ufuncs	The Unicode-functions structure
- unicode	The code point to query
- Returns	The hb_unicode_general_category_t of unicode

Since: 0.9.2
*/
unicode_general_category :: proc (ufuncs: ^unicode_funcs_t, unicode: codepoint_t)	-> unicode_general_category_t ---

/*
hb_unicode_combining_class_t hb_unicode_combining_class (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode);

Retrieves the Canonical Combining Class (ccc) property of code point unicode.

- ufuncs	The Unicode-functions structure
- unicode	The code point to query
- Returns	The hb_unicode_combining_class_t of unicode

Since: 0.9.2
*/
unicode_combining_class :: proc (ufuncs: ^unicode_funcs_t, unicode: codepoint_t)	-> unicode_combining_class_t ---

/*
hb_codepoint_t hb_unicode_mirroring (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode);

Retrieves the Bi-directional Mirroring Glyph code point defined for code point unicode.

- ufuncs	The Unicode-functions structure
- unicode	The code point to query
- Returns	The hb_codepoint_t of the Mirroring Glyph for unicode

Since: 0.9.2
*/
unicode_mirroring :: proc (ufuncs: ^unicode_funcs_t, unicode: codepoint_t)	-> codepoint_t ---

/*
hb_script_t hb_unicode_script (hb_unicode_funcs_t *ufuncs, hb_codepoint_t unicode);

Retrieves the hb_script_t script to which code point unicode belongs.

- ufuncs	The Unicode-functions structure
- unicode	The code point to query
- Returns	The hb_script_t of unicode

Since: 0.9.2
*/
unicode_script :: proc (ufuncs: ^unicode_funcs_t, unicode: codepoint_t)	-> script_t ---

/*
hb_bool_t hb_unicode_compose (hb_unicode_funcs_t *ufuncs, hb_codepoint_t a, hb_codepoint_t b, hb_codepoint_t *ab);

Fetches the composition of a sequence of two Unicode code points.

Calls the composition function of the specified Unicode-functions structure ufuncs.

- ufuncs	The Unicode-functions structure
- a			The first Unicode code point to compose
- b			The second Unicode code point to compose
- ab		The composition of a, b. [out]
- Returns	true if a and b composed, false otherwise

Since: 0.9.2
*/
unicode_compose :: proc (ufuncs: ^unicode_funcs_t, a: codepoint_t, b: codepoint_t, ab: ^codepoint_t)	-> bool_t ---

/*
hb_bool_t hb_unicode_decompose (hb_unicode_funcs_t *ufuncs, hb_codepoint_t ab, hb_codepoint_t *a, hb_codepoint_t *b);

Fetches the decomposition of a Unicode code point.

Calls the decomposition function of the specified Unicode-functions structure ufuncs.

- ufuncs	The Unicode-functions structure
- ab		Unicode code point to decompose
- a			The first code point of the decomposition of ab. [out]
- b			The second code point of the decomposition of ab. [out]
- Returns	true if ab was decomposed, false otherwise

Since: 0.9.2
*/
unicode_decompose :: proc (ufuncs: ^unicode_funcs_t, ab: codepoint_t, a: ^codepoint_t, b: ^codepoint_t)	-> bool_t ---

/*
hb_unicode_funcs_t * hb_unicode_funcs_create (hb_unicode_funcs_t *parent);

Creates a new hb_unicode_funcs_t structure of Unicode functions.

- parent	Parent Unicode-functions structure. [nullable]
- Returns	The Unicode-functions structure. [transfer full]

Since: 0.9.2
*/
unicode_funcs_create :: proc (parent: ^unicode_funcs_t)	-> ^unicode_funcs_t ---

/*
hb_unicode_funcs_t * hb_unicode_funcs_get_empty (void);

Fetches the singleton empty Unicode-functions structure.

- Returns	The empty Unicode-functions structure. [transfer full]

Since: 0.9.2
*/
unicode_funcs_get_empty :: proc ()	-> ^unicode_funcs_t ---

/*
hb_unicode_funcs_t * hb_unicode_funcs_reference (hb_unicode_funcs_t *ufuncs);

Increases the reference count on a Unicode-functions structure.

- ufuncs	The Unicode-functions structure
- Returns	The Unicode-functions structure. [transfer full]

Since: 0.9.2
*/
unicode_funcs_reference :: proc (ufuncs: ^unicode_funcs_t)	-> ^unicode_funcs_t ---

/*
void hb_unicode_funcs_destroy (hb_unicode_funcs_t *ufuncs);

Decreases the reference count on a Unicode-functions structure. When the reference count reaches zero, the
Unicode-functions structure is destroyed, freeing all memory.

- ufuncs	The Unicode-functions structure

Since: 0.9.2
*/
unicode_funcs_destroy :: proc (ufuncs: ^unicode_funcs_t)	---

/*
hb_bool_t hb_unicode_funcs_set_user_data (hb_unicode_funcs_t *ufuncs, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified Unicode-functions structure.

- ufuncs	The Unicode-functions structure
- key		The user-data key
- data		A pointer to the user data
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 0.9.2
*/
unicode_funcs_set_user_data :: proc (ufuncs: ^unicode_funcs_t, key: ^user_data_key_t, data: rawptr,
	destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_unicode_funcs_get_user_data (const hb_unicode_funcs_t *ufuncs, hb_user_data_key_t *key);

Fetches the user-data associated with the specified key, attached to the specified Unicode-functions structure.

- ufuncs	The Unicode-functions structure
- key		The user-data key to query
- Returns	A pointer to the user data. [transfer none]

Since: 0.9.2
*/
unicode_funcs_get_user_data :: proc (ufuncs: /*const*/ ^unicode_funcs_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_unicode_funcs_make_immutable (hb_unicode_funcs_t *ufuncs);

Makes the specified Unicode-functions structure immutable.

- ufuncs	The Unicode-functions structure

Since: 0.9.2
*/
unicode_funcs_make_immutable :: proc (ufuncs: ^unicode_funcs_t)	---

/*
hb_bool_t hb_unicode_funcs_is_immutable (hb_unicode_funcs_t *ufuncs);

Tests whether the specified Unicode-functions structure is immutable.

- ufuncs	The Unicode-functions structure
- Returns	true if ufuncs is immutable, false otherwise

Since: 0.9.2
*/
unicode_funcs_is_immutable :: proc (ufuncs: ^unicode_funcs_t)	-> bool_t ---

/*
hb_unicode_funcs_t * hb_unicode_funcs_get_default (void);

Fetches a pointer to the default Unicode-functions structure that is used when no functions are explicitly set on hb_buffer_t.

- Returns	a pointer to the hb_unicode_funcs_t Unicode-functions structure. [transfer none]

Since: 0.9.2
*/
unicode_funcs_get_default :: proc ()	-> ^unicode_funcs_t ---

/*
hb_unicode_funcs_t * hb_unicode_funcs_get_parent (hb_unicode_funcs_t *ufuncs);

Fetches the parent of the Unicode-functions structure ufuncs .

- ufuncs	The Unicode-functions structure
- Returns	The parent Unicode-functions structure

Since: 0.9.2
*/
unicode_funcs_get_parent :: proc (ufuncs: ^unicode_funcs_t)	-> ^unicode_funcs_t ---

/*
void hb_unicode_funcs_set_general_category_func (hb_unicode_funcs_t *ufuncs, hb_unicode_general_category_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_unicode_general_category_func_t.

- ufuncs	A Unicode-functions structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
unicode_funcs_set_general_category_func :: proc (ufuncs: ^unicode_funcs_t, func: unicode_general_category_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_unicode_funcs_set_combining_class_func (hb_unicode_funcs_t *ufuncs, hb_unicode_combining_class_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_unicode_combining_class_func_t.

- ufuncs	A Unicode-functions structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
unicode_funcs_set_combining_class_func :: proc (ufuncs: ^unicode_funcs_t, func: unicode_combining_class_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_unicode_funcs_set_mirroring_func (hb_unicode_funcs_t *ufuncs, hb_unicode_mirroring_func_t func, void *user_data,
	hb_destroy_func_t destroy);

Sets the implementation function for hb_unicode_mirroring_func_t.

- ufuncs	A Unicode-functions structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
unicode_funcs_set_mirroring_func :: proc (ufuncs: ^unicode_funcs_t, func: unicode_mirroring_func_t, user_data: rawptr,
	destroy: destroy_func_t)	---

/*
void hb_unicode_funcs_set_script_func (hb_unicode_funcs_t *ufuncs, hb_unicode_script_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_unicode_script_func_t.

- ufuncs	A Unicode-functions structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
unicode_funcs_set_script_func :: proc (ufuncs: ^unicode_funcs_t, func: unicode_script_func_t, user_data: rawptr,
	destroy: destroy_func_t)	---

/*
void hb_unicode_funcs_set_compose_func (hb_unicode_funcs_t *ufuncs, hb_unicode_compose_func_t func, void *user_data,
	hb_destroy_func_t destroy);

Sets the implementation function for hb_unicode_compose_func_t.

- ufuncs	A Unicode-functions structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
unicode_funcs_set_compose_func :: proc (ufuncs: ^unicode_funcs_t, func: unicode_compose_func_t, user_data: rawptr,
	destroy: destroy_func_t)	---

/*
void hb_unicode_funcs_set_decompose_func (hb_unicode_funcs_t *ufuncs, hb_unicode_decompose_func_t func, void *user_data,
	hb_destroy_func_t destroy);

Sets the implementation function for hb_unicode_decompose_func_t.

- ufuncs	A Unicode-functions structure
- func		The callback function to assign. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 0.9.2
*/
unicode_funcs_set_decompose_func :: proc (ufuncs: ^unicode_funcs_t, func: unicode_decompose_func_t, user_data: rawptr,
	destroy: destroy_func_t)	---

}
