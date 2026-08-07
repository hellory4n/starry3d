/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

buffer.odin - Types and functions for managing buffers.

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
author: Maurizio M. Gavioli, 2024-07-24

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-buffer.h
		https://harfbuzz.github.io/harfbuzz-hb-buffer.html
*/

/*
hb-buffer — Input and output buffers

Buffers serve a dual role in HarfBuzz; before shaping, they hold the input characters that are passed to hb_shape(),
and after shaping they hold the output glyphs.

The input buffer is a sequence of Unicode codepoints, with associated attributes such as direction and script.
The output buffer is a sequence of glyphs, with associated attributes such as position and cluster.

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-buffer.h
		https://harfbuzz.github.io/harfbuzz-hb-buffer.html
*/

package	harfbuzz

import "core:c"
//import cm "./common"

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

//******************
// TYPES
//******************

// The #hb_glyph_info_t is the structure that holds information about the glyphs and their relation to input text.
//
//typedef struct hb_glyph_info_t {
//  hb_codepoint_t codepoint;
//  /*< private >*/
//  hb_mask_t      mask;
//  /*< public >*/
//  uint32_t       cluster;
//  /*< private >*/
//  hb_var_int_t   var1;
//  hb_var_int_t   var2;
//} hb_glyph_info_t;
//
glyph_info_t :: struct #packed
{
	codepoint	: codepoint_t,				// either a Unicode code point (before shaping) or a glyph index (after shaping).
	mask		: mask_t,					// private
	cluster		: u32,						// the index of the character in the original text that corresponds to this `#hb_glyph_info_t` or
											// whatever the client passes to hb_buffer_add(). More than one #hb_glyph_info_t can have the
											// same `cluster` value, if they resulted from the same character (e.g. one to many glyph
											// substitution), and when more than one character gets merged in the same glyph (e.g. many to
											// one glyph substitution) the `hb_glyph_info_t` will have the smallest cluster value of them.
											// By default some characters are merged into the same cluster (e.g. combining marks have the
											// same cluster as their bases) even if they are separate glyphs, hb_buffer_set_cluster_level()
											// allow selecting more fine-grained cluster handling.
	var1		: var_int_t,				// private
	var2		: var_int_t					// private
}

/*
enum hb_glyph_flags_t

Flags for hb_glyph_info_t.
*/
glyph_flags_t :: enum c.uint
{
	GLYPH_FLAG_UNSAFE_TO_BREAK = 1,		// Indicates that if input text is broken at the beginning of the cluster this glyph is part of,
										// then both sides need to be re-shaped, as the result might be different. On the flip side, it
										// means that when this flag is not present, then it is safe to break the glyph-run at the
										// beginning of this cluster, and the two sides will represent the exact same result one would get
										// if breaking input text at the beginning of this cluster and shaping the two sides separately.
										// This can be used to optimize paragraph layout, by avoiding re-shaping of each line after line-breaking.
	GLYPH_FLAG_UNSAFE_TO_CONCAT = 2,	// Indicates that if input text is changed on one side of the beginning of the cluster this
										// glyph is part of, then the shaping results for the other side might change. Note that the
										// absence of this flag will NOT by itself mean that it IS safe to concat text. Only two pieces
										// of text both of which clear of this flag can be concatenated safely. This can be used to optimize
										// paragraph layout, by avoiding re-shaping of each line after line-breaking, by limiting the
										// reshaping to a small piece around the breaking position only, even if the breaking position
										// carries the HB_GLYPH_FLAG_UNSAFE_TO_BREAK or when hyphenation or other text transformation
										// happens at line-break position, in the following way:
										// 1. Iterate back from the line-break position until the first cluster start position that
										// is NOT unsafe-to-concat,
										// 2. shape the segment from there till the end of line,
										// 3. check whether the resulting glyph-run also is clear of the unsafe-to-concat at its
										// start-of-text position; if it is, just splice it into place and the line is shaped;
										// If not, move on to a position further back that is clear of unsafe-to-concat and retry
										// from there, and repeat. At the start of next line a similar algorithm can be implemented. That is:
										// 1. Iterate forward from the line-break position until the first cluster start position that  is NOT unsafe-to-concat,
										// 2. shape the segment from beginning of the line to that position,
										// 3. check whether the resulting glyph-run also is clear of the unsafe-to-concat at its end-of-text position;
										// if it is, just splice it into place and the beginning is shaped; If not, move on to a position further
										// forward that is clear of unsafe-to-concat and retry up to there, and repeat. A slight complication will arise
										// in the implementation of the algorithm above, because while our buffer API has a way to return flags for
										// position corresponding to start-of-text, there is currently no position corresponding to end-of-text.
										// This limitation can be alleviated by shaping more text than needed and looking for unsafe-to-concat flag
										// within text clusters. The HB_GLYPH_FLAG_UNSAFE_TO_BREAK flag will always imply this flag. To use this flag,
										// you must enable the buffer flag HB_BUFFER_FLAG_PRODUCE_UNSAFE_TO_CONCAT during shaping, otherwise the buffer
										// flag will not be reliably produced.
										// Since: 4.0.0
	GLYPH_FLAG_SAFE_TO_INSERT_TATWEEL = 4,	// In scripts that use elongation (Arabic, Mongolian, Syriac, etc.), this flag signifies that it is safe to
										// insert a U+0640 TATWEEL character before this cluster for elongation. This flag does not determine the
										// script-specific elongation places, but only when it is safe to do the elongation without interrupting text shaping.
										// Since: 5.1.0
	GLYPH_FLAG_DEFINED = 7,				// All the currently defined flags.
}

/*
The hb_glyph_position_t is the structure that holds the positions of the glyph in both horizontal and vertical directions. All positions in hb_glyph_position_t are relative to the current point.
*/
glyph_position_t :: struct #packed
{
	x_advance	: position_t,				// how much the line advances after drawing this glyph when setting text in horizontal direction.
	y_advance	: position_t,				// how much the line advances after drawing this glyph when setting text in vertical direction.
	x_offset	: position_t,				// how much the glyph moves on the X-axis before drawing it, this should not affect how much the line advances.
	y_offset	: position_t,				// how much the glyph moves on the Y-axis before drawing it, this should not affect how much the line advances.
	var			: var_int_t,				// private
}

/**
 * #define HB_BUFFER_REPLACEMENT_CODEPOINT_DEFAULT 0xFFFDu
 *
 * The default code point for replacing invalid characters in a given encoding.
 * Set to U+FFFD REPLACEMENT CHARACTER.
 */
BUFFER_REPLACEMENT_CODEPOINT_DEFAULT: c.uint : 0xFFFD

/*
The type of hb_buffer_t contents.
*/
buffer_content_type_t :: enum c.uint
{
	BUFFER_CONTENT_TYPE_INVALID = 0,		// Initial value for new buffer.
	BUFFER_CONTENT_TYPE_UNICODE,			// The buffer contains input characters (before shaping).
	BUFFER_CONTENT_TYPE_GLYPHS				// The buffer contains output glyphs (after shaping).
}

/*
The structure that holds various text properties of an hb_buffer_t. Can be set
and retrieved using `buffer_set_segment_properties()` and
`buffer_get_segment_properties()`, respectively.
*/
//typedef struct hb_segment_properties_t {
//  hb_direction_t  direction;
//  hb_script_t     script;
//  hb_language_t   language;
//  /*< private >*/
//  void           *reserved1;
//  void           *reserved2;
//} hb_segment_properties_t;
segment_properties_t :: struct #packed
{
	direction	: direction_t,				// the `direction_t` of the buffer, see `buffer_set_direction()`.
	script		: script_t,					// the `script_t` of the buffer, see `buffer_set_script()`.
	language	: language_t,				// the `language_t` of the buffer, see `buffer_set_language()`.
	reserved1	: rawptr,					// private
	reserved2	: rawptr					// private
}

/**
 * #define HB_SEGMENT_PROPERTIES_DEFAULT {HB_DIRECTION_INVALID, HB_SCRIPT_INVALID, HB_LANGUAGE_INVALID, (void *) 0, (void *) 0}
 *
 * The default #hb_segment_properties_t of freshly created #hb_buffer_t.
 */
SEGMENT_PROPERTIES_DEFAULT : segment_properties_t : {.DIRECTION_INVALID, .SCRIPT_INVALID, /*.LANGUAGE_INVALID*/{}, {}, {} }

/**
 * typedef struct hb_buffer_t hb_buffer_t;
 *
 * The main structure holding the input text and its properties before shaping,
 * and output glyphs and their information after shaping.
 */
buffer_t :: struct #packed {}						// opaque structure

/*
Flags for hb_buffer_t.
*/
//typedef enum { /*< flags >*/
//  HB_BUFFER_FLAG_DEFAULT			= 0x00000000u,
//  HB_BUFFER_FLAG_BOT				= 0x00000001u, /* Beginning-of-text */
//  HB_BUFFER_FLAG_EOT				= 0x00000002u, /* End-of-text */
//  HB_BUFFER_FLAG_PRESERVE_DEFAULT_IGNORABLES	= 0x00000004u,
//  HB_BUFFER_FLAG_REMOVE_DEFAULT_IGNORABLES	= 0x00000008u,
//  HB_BUFFER_FLAG_DO_NOT_INSERT_DOTTED_CIRCLE	= 0x00000010u,
//  HB_BUFFER_FLAG_VERIFY				= 0x00000020u,
//  HB_BUFFER_FLAG_PRODUCE_UNSAFE_TO_CONCAT	= 0x00000040u,
//  HB_BUFFER_FLAG_PRODUCE_SAFE_TO_INSERT_TATWEEL	= 0x00000080u,
//
//  HB_BUFFER_FLAG_DEFINED			= 0x000000FFu
//} hb_buffer_flags_t;
buffer_flags_t :: enum c.uint
{
	BUFFER_FLAG_DEFAULT						= 0x0000,	// the default buffer flag.
	BUFFER_FLAG_BOT							= 0x0001,	// flag indicating that special handling of the beginning of text paragraph can be applied to this buffer.
														// Should usually be set, unless you are passing to the buffer only part of the text without the full context.
	BUFFER_FLAG_EOT							= 0x0002,	// flag indicating that special handling of the end of text paragraph can be applied to this buffer, similar to HB_BUFFER_FLAG_BOT.
	BUFFER_FLAG_PRESERVE_DEFAULT_IGNORABLES	= 0x0004,	// flag indication that character with Default_Ignorable Unicode property should use the corresponding glyph
														// from the font, instead of hiding them (done by replacing them with the space glyph and zeroing the advance width.)
														// This flag takes precedence over HB_BUFFER_FLAG_REMOVE_DEFAULT_IGNORABLES.
	BUFFER_FLAG_REMOVE_DEFAULT_IGNORABLES	= 0x0008,	// flag indication that character with Default_Ignorable Unicode property should be removed from glyph string
														// instead of hiding them (done by replacing them with the space glyph and zeroing the advance width.)
														// BUFFER_FLAG_PRESERVE_DEFAULT_IGNORABLES takes precedence over this flag. Since: 1.8.0
	BUFFER_FLAG_DO_NOT_INSERT_DOTTED_CIRCLE	= 0x010,	// flag indicating that a dotted circle should not be inserted in the rendering of incorrect
														// character sequences (such at <0905 093E>). Since: 2.4.0
//	BUFFER_FLAG_VERIFY						= 0x0020,	// flag indicating that the hb_shape() call and its variants should perform various verification processes
//														// on the results of the shaping operation on the buffer. If the verification fails, then either a buffer
//														// message is sent, if a message handler is installed on the buffer, or a message is written to standard
//														// error. In either case, the shaping result might be modified to show the failed output. Since: 3.4.0
//	BUFFER_FLAG_PRODUCE_UNSAFE_TO_CONCAT	= 0x0040,	// flag indicating that the HB_GLYPH_FLAG_UNSAFE_TO_CONCAT glyph-flag should be produced by the shaper.
//														// By default it will not be produced since it incurs a cost. Since: 4.0.0
//	BUFFER_FLAG_PRODUCE_SAFE_TO_INSERT_TATWEEL=0x0080,	// flag indicating that the HB_GLYPH_FLAG_SAFE_TO_INSERT_TATWEEL glyph-flag should be produced by the shaper.
//														// By default it will not be produced. Since: 5.1.0
//	BUFFER_FLAG_DEFINED						= 0x00FF	// All currently defined flags: Since: 4.4.0
}

/**
 * Data type for holding HarfBuzz's clustering behavior options. The cluster level dictates
 * one aspect of how HarfBuzz will treat non-base characters during shaping.
 */
//typedef enum {
//  HB_BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES	= 0,
//  HB_BUFFER_CLUSTER_LEVEL_MONOTONE_CHARACTERS	= 1,
//  HB_BUFFER_CLUSTER_LEVEL_CHARACTERS		= 2,
//  HB_BUFFER_CLUSTER_LEVEL_GRAPHEMES		= 3,
//  HB_BUFFER_CLUSTER_LEVEL_DEFAULT = HB_BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES
//} hb_buffer_cluster_level_t;
buffer_cluster_level_t :: enum c.uint
{
	BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES	= 0,	// non-base characters are merged into the cluster of the base character that precedes them.
													// Return cluster values grouped by graphemes into monotone order. This is the default,
													// because it maintains backward compatibility with older versions of HarfBuzz.
													// New client programs that do not need to maintain such backward compatibility are
													// recommended to use HB_BUFFER_CLUSTER_LEVEL_MONOTONE_CHARACTERS instead of the default.
	BUFFER_CLUSTER_LEVEL_MONOTONE_CHARACTERS= 1,	// non-base characters are initially assigned their own cluster values, which are not merged
													// into preceding base clusters. This allows HarfBuzz to perform additional operations like
													// reorder sequences of adjacent marks. Return cluster values grouped into monotone order.
	BUFFER_CLUSTER_LEVEL_CHARACTERS			= 2,	// Don't group cluster values.
	BUFFER_CLUSTER_LEVEL_GRAPHEMES			= 3,	// non-base characters are merged into the cluster of the base character
													// that precedes them. This is similar to the Unicode Grapheme Cluster
													// algorithm, but it is not exactly the same. The output is not forced to
													// be monotone. This is useful for clients that want to use HarfBuzz as a
													// cheap implementation of the Unicode Grapheme Cluster algorithm.
	BUFFER_CLUSTER_LEVEL_DEFAULT = BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES,	// Default cluster level, equal to HB_BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES.
}

/*
The buffer serialization and de-serialization format used in hb_buffer_serialize_glyphs() and hb_buffer_deserialize_glyphs().
*/
buffer_serialize_format_t :: enum tag_t
{
	BUFFER_SERIALIZE_FORMAT_TEXT	= ('T' << 24) | ('E' << 16) | ('X' << 8) | 'T', // "TEXT" , a human-readable, plain text format.
	BUFFER_SERIALIZE_FORMAT_JSON	= ('J' << 24) | ('S' << 16) | ('O' << 8) | 'N', // "JSON" , a machine-readable JSON format.
	BUFFER_SERIALIZE_FORMAT_INVALID	= TAG_NONE				// invalid format.
}

/*
Flags that control what glyph information are serialized in hb_buffer_serialize_glyphs().
*/
buffer_serialize_flags_t :: enum c.uint
{
	BUFFER_SERIALIZE_FLAG_DEFAULT		= 0x00,	// serialize glyph names, clusters and positions.
	BUFFER_SERIALIZE_FLAG_NO_CLUSTERS	= 0x01,	// do not serialize glyph cluster.
	BUFFER_SERIALIZE_FLAG_NO_POSITIONS	= 0x02,	// do not serialize glyph position information.
	BUFFER_SERIALIZE_FLAG_NO_GLYPH_NAMES= 0x04,	// do no serialize glyph name.
	BUFFER_SERIALIZE_FLAG_GLYPH_EXTENTS	= 0x08,	// serialize glyph extents.
	BUFFER_SERIALIZE_FLAG_GLYPH_FLAGS	= 0x10,	// serialize glyph flags. Since: 1.5.0
	BUFFER_SERIALIZE_FLAG_NO_ADVANCES	= 0x20,	// do not serialize glyph advances, glyph offsets will reflect absolute glyph positions. Since: 1.8.0
//	BUFFER_SERIALIZE_FLAG_DEFINED		= 0x3F,	// All currently defined flags. Since: 4.4.0
}

/*
Flags from comparing two `buffer_t`'s.

Buffer with different `buffer_content_type_t` cannot be meaningfully compared in any further detail.

For buffers with differing length, the per-glyph comparison is not attempted, though we do still scan reference buffer for dotted circle and `.notdef` glyphs.

If the buffers have the same length, we compare them glyph-by-glyph and report which aspect(s) of the glyph info/position are different.
*/
buffer_diff_flags_t :: enum c.uint
{
	BUFFER_DIFF_FLAG_EQUAL					= 0x00,	// equal buffers.
	// Buffers with different content_type cannot be meaningfully compared in any further detail.
	BUFFER_DIFF_FLAG_CONTENT_TYPE_MISMATCH	= 0x01,	// buffers with different `buffer_content_type_t`.
	// For buffers with differing length, the per-glyph comparison is not attempted, though we do still scan reference for dottedcircle / .notdef glyphs.
	BUFFER_DIFF_FLAG_LENGTH_MISMATCH		= 0x02,	// buffers with differing length.
	// We want to know if dottedcircle / .notdef glyphs are present in the reference, as we may not care so much about other differences in this case.
	BUFFER_DIFF_FLAG_NOTDEF_PRESENT			= 0x04,	// .notdef glyph is present in the reference buffer.
	BUFFER_DIFF_FLAG_DOTTED_CIRCLE_PRESENT	= 0x08,	// dotted circle glyph is present in the reference buffer.
	// If the buffers have the same length, we compare them glyph-by-glyph and report which aspect(s) of the glyph info/position are different.
	BUFFER_DIFF_FLAG_CODEPOINT_MISMATCH		= 0x10,	// difference in hb_glyph_info_t.codepoint
	BUFFER_DIFF_FLAG_CLUSTER_MISMATCH		= 0x20,	// difference in hb_glyph_info_t.cluster
	BUFFER_DIFF_FLAG_GLYPH_FLAGS_MISMATCH	= 0x40,	// difference in hb_glyph_flags_t.
	BUFFER_DIFF_FLAG_POSITION_MISMATCH		= 0x80,	// difference in hb_glyph_position_t.
}


/*
typedef hb_bool_t	(*hb_buffer_message_func_t)	(hb_buffer_t *buffer, hb_font_t *font, const char *message, void *user_data);

hb_bool_t (*hb_buffer_message_func_t)			(hb_buffer_t *buffer, hb_font_t *font, const char *message, void *user_data);

A callback method for hb_buffer_t. The method gets called with the hb_buffer_t it was set on, the hb_font_t the buffer is
shaped with and a message describing what step of the shaping process will be performed. Returning false from this method
will skip this shaping step and move to the next one.
- buffer		An hb_buffer_t to work upon
- font			The hb_font_t the buffer is shaped with
- message		NULL-terminated message passed to the function
- user_data		User data pointer passed by the caller
- Returns		true to perform the shaping step, false to skip it.

Since: 1.1.3
*/
buffer_message_func_t	:: #type proc "c" (buffer: ^buffer_t, font: ^font_t, message: cstring, user_data: rawptr)	-> bool_t

//******************
// 'C' MACROS CHANGED INTO FUNCTIONS
//******************

/*
#define HB_BUFFER_CLUSTER_LEVEL_IS_CHARACTERS(level) \
	((bool) ((1u << (unsigned) (level)) & \
		 ((1u << HB_BUFFER_CLUSTER_LEVEL_MONOTONE_CHARACTERS) | \
		  (1u << HB_BUFFER_CLUSTER_LEVEL_CHARACTERS))))

Tests whether a cluster level does not group cluster values by graphemes. Requires that the level be valid.
Parameters

- level:	hb_buffer_cluster_level_t to test

Since: 11.0.0
*/
BUFFER_CLUSTER_LEVEL_IS_CHARACTERS :: proc(level: uint) -> bool
{
	 return (
		(1 << level) &
		(	(1 << buffer_cluster_level_t.BUFFER_CLUSTER_LEVEL_MONOTONE_CHARACTERS) |
			(1 << buffer_cluster_level_t.BUFFER_CLUSTER_LEVEL_CHARACTERS)
		)
	) != 0;
}

/*
#define HB_BUFFER_CLUSTER_LEVEL_IS_GRAPHEMES(level) \
	((bool) ((1u << (unsigned) (level)) & \
		 ((1u << HB_BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES) | \
		  (1u << HB_BUFFER_CLUSTER_LEVEL_GRAPHEMES))))

Tests whether a cluster level groups cluster values by graphemes. Requires that the level be valid.

Parameters:
- level:	hb_buffer_cluster_level_t to test

Since: 11.0.0
*/

HB_BUFFER_CLUSTER_LEVEL_IS_GRAPHEMES :: proc (level: uint) -> bool
{
	return (
		(1 << level) &
		(
			(1 << buffer_cluster_level_t.BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES) |
			(1 << buffer_cluster_level_t.BUFFER_CLUSTER_LEVEL_GRAPHEMES)
		)
	) != 0;
}

/*
#define HB_BUFFER_CLUSTER_LEVEL_IS_MONOTONE(level) \
	((bool) ((1u << (unsigned) (level)) & \
		 ((1u << HB_BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES) | \
		  (1u << HB_BUFFER_CLUSTER_LEVEL_MONOTONE_CHARACTERS))))

Tests whether a cluster level groups cluster values into monotone order. Requires that the level be valid.

Parameters:
- level:	hb_buffer_cluster_level_t to test

Since: 11.0.0
*/

HB_BUFFER_CLUSTER_LEVEL_IS_MONOTONE :: proc(level: uint) -> bool
{
	return (
		(1 << level) &
		(
			(1 << buffer_cluster_level_t.BUFFER_CLUSTER_LEVEL_MONOTONE_GRAPHEMES) |
			(1 << buffer_cluster_level_t.BUFFER_CLUSTER_LEVEL_MONOTONE_CHARACTERS)
		)
	) != 0;
}

//******************
// FUNCTIONS
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

//*************
// Since 0.9.2
//*************

/*
hb_buffer_t *hb_buffer_create (void);

Creates a new hb_buffer_t with all properties to defaults.
- Returns	A newly allocated `buffer_t` with a reference count of 1. The initial reference count should be released
			with `hb_buffer_destroy()` when you are done using the hb_buffer_t. This function never returns NULL. If
			memory cannot be allocated, a special hb_buffer_t object will be returned on which
			`hb_buffer_allocation_successful()` returns false. [transfer full]

Since: 0.9.2
*/
buffer_create	:: proc()	-> ^buffer_t ---

/*
void hb_buffer_reset (hb_buffer_t *buffer);

Resets the buffer to its initial status, as if it was just newly created with hb_buffer_create().
- buffer	An hb_buffer_t

Since: 0.9.2
*/
buffer_reset	:: proc(buffer: ^buffer_t)	---

/*
hb_buffer_t * hb_buffer_get_empty (void);

Fetches an empty `buffer_t`.
- Returns		The empty buffer. [transfer full]

Since: 0.9.2
*/
buffer_get_empty	:: proc()	-> ^buffer_t ---

/*
hb_buffer_t * hb_buffer_reference (hb_buffer_t *buffer);

Increases the reference count on buffer by one. This prevents buffer from being destroyed until a matching call to `buffer_destroy()` is made.
- buffer	A `buffer_t`.
- Returns	The referenced `buffer_t`. [transfer full]

Since: 0.9.2
*/
buffer_reference	:: proc(buffer: ^buffer_t)	-> ^buffer_t ---

/*
void hb_buffer_destroy (hb_buffer_t *buffer);

Deallocate the buffer . Decreases the reference count on buffer by one. If the result is zero, then buffer and all associated resources are freed. See `buffer_reference()`.

- buffer		A `buffer_t`.

Since: 0.9.2
*/
buffer_destroy	:: proc(buffer: ^buffer_t)	---

/*
hb_bool_t hb_buffer_set_user_data (hb_buffer_t *buffer, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified buffer.
- buffer	A hb_buffer_t.
- key		The user-data key.
- data		A pointer to the user data.
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key.
- Returns	true if success, false otherwise.

Since: 0.9.2
*/
buffer_set_user_data	:: proc(buffer: ^buffer_t, key: ^user_data_key_t, data: rawptr,  destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_buffer_get_user_data (const hb_buffer_t *buffer, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified buffer.
- buffer	An hb_buffer_t
- key		The user-data key to query
- Returns	A pointer to the user data. [transfer none]

Since: 0.9.2
*/
hb_buffer_get_user_data	:: proc(buffer: /*const*/ ^buffer_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_buffer_set_unicode_funcs (hb_buffer_t *buffer, hb_unicode_funcs_t *unicode_funcs);

Sets the Unicode-functions structure of a buffer to unicode_funcs.
- buffer		An hb_buffer_t
- unicode_funcs	The Unicode-functions structure

Since: 0.9.2
*/
buffer_set_unicode_funcs	:: proc(buffer: ^buffer_t, unicode_funcs: ^unicode_funcs_t)	---

/*
hb_unicode_funcs_t * hb_buffer_get_unicode_funcs (const hb_buffer_t *buffer);

Fetches the Unicode-functions structure of a buffer.
- buffer		An hb_buffer_t
- Returns		The Unicode-functions structure

Since: 0.9.2
*/
buffer_get_unicode_funcs	:: proc(buffer: /*const*/ ^buffer_t)	-> unicode_funcs_t ---

/*
void hb_buffer_set_direction (hb_buffer_t *buffer, hb_direction_t direction);

Set the text flow direction of the buffer. No shaping can happen without setting buffer direction, and it controls the
visual direction for the output glyphs; for RTL direction the glyphs will be reversed. Many layout features depend on
the proper setting of the direction, for example, reversing RTL text before shaping, then shaping with LTR direction
is not the same as keeping the text in logical order and shaping with RTL direction.
- buffer		An hb_buffer_t
- direction		the hb_direction_t of the buffer

Since: 0.9.2
*/
buffer_set_direction	:: proc(buffer: ^buffer_t, direction: direction_t)	---

/*
hb_direction_t hb_buffer_get_direction (const hb_buffer_t *buffer);

See hb_buffer_set_direction()
- buffer		An hb_buffer_t
- Returns		The direction of the buffer .

Since: 0.9.2
*/
buffer_get_direction	:: proc(buffer: /*const*/ ^buffer_t)	-> direction_t ---

/*
void hb_buffer_set_script (hb_buffer_t *buffer, hb_script_t script);
Sets the script of buffer to script .

Script is crucial for choosing the proper shaping behaviour for scripts that require it (e.g. Arabic) and the which OpenType features defined in the font to be applied.

You can pass one of the predefined hb_script_t values, or use hb_script_from_string() or hb_script_from_iso15924_tag() to get the corresponding script from an ISO 15924 script tag.
- buffer		An hb_buffer_t
- script		An hb_script_t to set.

Since: 0.9.2
*/
buffer_set_script	:: proc(buffer: ^buffer_t, script: script_t)	---

/*
hb_script_t hb_buffer_get_script (const hb_buffer_t *buffer);

Fetches the script of buffer .
- buffer		An hb_buffer_t
- Returns		The hb_script_t of the buffer

Since: 0.9.2
*/
buffer_get_script	:: proc(buffer: /*const*/ ^buffer_t)	-> script_t ---

/*
void hb_buffer_set_language (hb_buffer_t *buffer, hb_language_t language);

Sets the language of buffer to language .

Languages are crucial for selecting which OpenType feature to apply to the buffer which can result in applying language-specific behaviour.
Languages are orthogonal to the scripts, and though they are related, they are different concepts and should not be confused with each other.

Use hb_language_from_string() to convert from BCP 47 language tags to hb_language_t.
- buffer		An hb_buffer_t
- language		An hb_language_t to set

Since: 0.9.2
*/
buffer_set_language	:: proc(buffer: ^buffer_t, language: language_t)	---

/*
hb_language_t hb_buffer_get_language (const hb_buffer_t *buffer);

See hb_buffer_set_language().
- buffer		An hb_buffer_t
- Returns		The hb_language_t of the buffer. Must not be freed by the caller. [transfer none]

Since: 0.9.2
*/
buffer_get_language	:: proc(buffer: /*const*/ ^buffer_t)	-> language_t ---

//*************
// Since 0.9.5
//*************

/*
void hb_buffer_set_content_type (hb_buffer_t *buffer, hb_buffer_content_type_t content_type);

Sets the type of buffer contents. Buffers are either empty, contain characters (before shaping), or contain glyphs (the result of shaping).

You rarely need to call this function, since a number of other functions transition the content type for you. Namely:
- A newly created buffer starts with content type HB_BUFFER_CONTENT_TYPE_INVALID. Calling hb_buffer_reset(), hb_buffer_clear_contents(), as well as calling hb_buffer_set_length() with an argument of zero all set the buffer content type to invalid as well.
- Calling hb_buffer_add_utf8(), hb_buffer_add_utf16(), hb_buffer_add_utf32(), hb_buffer_add_codepoints() and hb_buffer_add_latin1() expect that buffer is either empty and have a content type of invalid, or that buffer content type is HB_BUFFER_CONTENT_TYPE_UNICODE, and they also set the content type to Unicode if they added anything to an empty buffer.
- Finally hb_shape() and hb_shape_full() expect that the buffer is either empty and have content type of invalid, or that buffer content type is HB_BUFFER_CONTENT_TYPE_UNICODE, and upon success they set the buffer content type to HB_BUFFER_CONTENT_TYPE_GLYPHS.

The above transitions are designed such that one can use a buffer in a loop of "reset : add-text : shape" without needing to ever modify the content type manually.
- buffer		An hb_buffer_t
- content_type	The type of buffer contents to set

Since: 0.9.5
*/
buffer_set_content_type	:: proc(buffer: ^buffer_t, content_type: buffer_content_type_t)	---

/*
hb_buffer_content_type_t hb_buffer_get_content_type (const hb_buffer_t *buffer);

Fetches the type of buffer contents. Buffers are either empty, contain characters (before shaping), or contain glyphs (the result of shaping).
- buffer		An hb_buffer_t
- Returns		The type of buffer contents

Since: 0.9.5
*/
buffer_get_content_type	:: proc(buffer: /*const*/ ^buffer_t)	-> buffer_content_type_t ---

//*************
// Since 0.9.7
//*************

/*
 * #define hb_glyph_info_get_glyph_flags(info) ((hb_glyph_flags_t) ((unsigned int) (info)->mask & HB_GLYPH_FLAG_DEFINED))
 */

/*
hb_bool_t hb_segment_properties_equal (const hb_segment_properties_t *a, const hb_segment_properties_t *b);

Checks the equality of two hb_segment_properties_t's.
- a			first hb_segment_properties_t to compare.
- b			second hb_segment_properties_t to compare.
- Returns	true if all properties of a equal those of b , false otherwise.

Since: 0.9.7
*/
segment_properties_equal	:: proc(a: /*const*/ ^segment_properties_t, b: /*const*/ ^segment_properties_t)	-> bool_t ---

/*
unsigned int hb_segment_properties_hash (const hb_segment_properties_t *p);

Creates a hash representing p.
- p			hb_segment_properties_t to hash.
- Returns	A hash of p.

Since: 0.9.7
*/
segment_properties_hash	:: proc(p: /*const*/ ^segment_properties_t)	-> c.uint ---

/*
void hb_buffer_set_segment_properties (hb_buffer_t *buffer, const hb_segment_properties_t *props);

Sets the segment properties of the buffer, a shortcut for calling hb_buffer_set_direction(), hb_buffer_set_script() and hb_buffer_set_language() individually.
- buffer		An hb_buffer_t
- props			An hb_segment_properties_t to use

Since: 0.9.7
*/
buffer_set_segment_properties	:: proc(buffer: ^buffer_t, props: /*const*/ [^]segment_properties_t)	---

/*
void hb_buffer_get_segment_properties (const hb_buffer_t *buffer, hb_segment_properties_t *props);

Sets props to the hb_segment_properties_t of buffer .
- buffer		An hb_buffer_t
- props			The output hb_segment_properties_t. [out]

Since: 0.9.7
*/
buffer_get_segment_properties	:: proc(buffer: /*const*/ ^buffer_t, props: [^]segment_properties_t)	---

/*
void hb_buffer_guess_segment_properties (hb_buffer_t *buffer);

Sets unset buffer segment properties based on buffer Unicode contents. If buffer is not empty,
it must have content type HB_BUFFER_CONTENT_TYPE_UNICODE.

If buffer script is not set (ie. is HB_SCRIPT_INVALID), it will be set to the Unicode script of the
first character in the buffer that has a script other than HB_SCRIPT_COMMON, HB_SCRIPT_INHERITED,
and HB_SCRIPT_UNKNOWN.

Next, if buffer direction is not set (ie. is HB_DIRECTION_INVALID), it will be set to the natural
horizontal direction of the buffer script as returned by hb_script_get_horizontal_direction().
If hb_script_get_horizontal_direction() returns HB_DIRECTION_INVALID, then HB_DIRECTION_LTR is used.

Finally, if buffer language is not set (ie. is HB_LANGUAGE_INVALID), it will be set to the process's
default language as returned by hb_language_get_default(). This may change in the future by taking
buffer script into consideration when choosing a language. Note that hb_language_get_default() is
NOT threadsafe the first time it is called. See documentation for that function for details.
- buffer		An hb_buffer_t

Since: 0.9.7
*/
buffer_guess_segment_properties	:: proc(buffer: ^buffer_t)	---

/*
void hb_buffer_set_flags (hb_buffer_t *buffer, hb_buffer_flags_t  flags);

Sets buffer flags to flags . See hb_buffer_flags_t.
- buffer		An hb_buffer_t
- flags			The buffer flags to set

Since: 0.9.7
*/
buffer_set_flags	:: proc(buffer: ^buffer_t, flags: buffer_flags_t)	---

/*
hb_buffer_flags_t hb_buffer_get_flags (const hb_buffer_t *buffer);

Fetches the hb_buffer_flags_t of buffer .
- buffer		An hb_buffer_t
- Returns		The buffer flags

Since: 0.9.7
*/
buffer_get_flags	:: proc(buffer: /*const*/ ^buffer_t)	-> buffer_flags_t ---

//*************
// Since 0.9.31
//*************

/*
void hb_buffer_set_replacement_codepoint (hb_buffer_t *buffer, hb_codepoint_t replacement);

Sets the hb_codepoint_t that replaces invalid entries for a given encoding when adding text to buffer.

Default is HB_BUFFER_REPLACEMENT_CODEPOINT_DEFAULT.
- buffer		An hb_buffer_t
- replacement	The replacement hb_codepoint_t

Since: 0.9.31
*/
buffer_set_replacement_codepoint	:: proc(buffer: ^buffer_t, replacement: codepoint_t)	---

/*
hb_codepoint_t hb_buffer_get_replacement_codepoint (const hb_buffer_t *buffer);

Fetches the hb_codepoint_t that replaces invalid entries for a given encoding when adding text to buffer .
- buffer		An hb_buffer_t
- Returns		The buffer replacement hb_codepoint_t

Since: 0.9.31
*/
buffer_get_replacement_codepoint	:: proc(buffer: /*const*/ ^buffer_t)	-> codepoint_t ---

//*************
// Since 0.9.42
//*************

/*
void hb_buffer_set_cluster_level (hb_buffer_t *buffer, hb_buffer_cluster_level_t  cluster_level);

Sets the cluster level of a buffer. The hb_buffer_cluster_level_t dictates one aspect of how HarfBuzz will treat non-base characters during shaping.
- buffer		An hb_buffer_t
- cluster_level	The cluster level to set on the buffer

Since: 0.9.42
*/
buffer_set_cluster_level	:: proc(buffer: ^buffer_t, cluster_level: buffer_cluster_level_t)	---

/*
hb_buffer_cluster_level_t hb_buffer_get_cluster_level (const hb_buffer_t *buffer);

Fetches the cluster level of a buffer. The hb_buffer_cluster_level_t dictates one aspect of how HarfBuzz will treat non-base characters during shaping.
- buffer		An hb_buffer_t
- Returns		The cluster level of buffer

Since: 0.9.42
*/
buffer_get_cluster_level	:: proc(buffer: /*const*/ ^buffer_t)	-> buffer_cluster_level_t ---

//*************
// Since 1.5.0
//*************

/*
hb_glyph_flags_t hb_glyph_info_get_glyph_flags (const hb_glyph_info_t *info);

Returns glyph flags encoded within a hb_glyph_info_t.
- info		a hb_glyph_info_t
- Returns	The hb_glyph_flags_t encoded within info

Since: 1.5.0
*/
 glyph_info_get_glyph_flags	:: proc(info: /*const*/ ^glyph_info_t)	-> glyph_flags_t ---

//*************
// Since 3.3.0
//*************

/*
void hb_segment_properties_overlay (hb_segment_properties_t *p, const hb_segment_properties_t *src);

Fills in missing fields of p from src in a considered manner.

First, if p does not have direction set, direction is copied from src.

Next, if p and src have the same direction (which can be unset), if p does not have script set, script is copied from src.

Finally, if p and src have the same direction and script (which either can be unset), if p does not have language set,
language is copied from src.
- p			hb_segment_properties_t to fill in.
- src		hb_segment_properties_t to fill in from.

Since: 3.3.0
*/
segment_properties_overlay	:: proc(p:^segment_properties_t, src: /*const*/ ^segment_properties_t)	---

/*
hb_buffer_t * hb_buffer_create_similar (const hb_buffer_t *src);

Creates a new hb_buffer_t, similar to hb_buffer_create(). The only difference is that the buffer is configured similarly to src .
- src		A `buffer_t`
- Returns	A newly allocated `buffer_t`, similar to `buffer_create()`. [transfer full]

Since: 3.3.0
*/
buffer_create_similar	:: proc(src: /*const*/ ^buffer_t)	-> ^buffer_t ---	// Since: 3.3.0



// %%%%





/*
void hb_buffer_set_invisible_glyph (hb_buffer_t *buffer, hb_codepoint_t invisible);

Sets the hb_codepoint_t that replaces invisible characters in the shaping result. If set to zero (default), the glyph
for the U+0020 SPACE character is used. Otherwise, this value is used verbatim.
- buffer		An hb_buffer_t
- invisible		the invisible hb_codepoint_t

Since: 2.0.0
*/
buffer_set_invisible_glyph	:: proc(buffer: ^buffer_t, invisible: codepoint_t)	---

/*
hb_codepoint_t hb_buffer_get_invisible_glyph (const hb_buffer_t *buffer);

See hb_buffer_set_invisible_glyph().
- buffer		An hb_buffer_t
- Returns		The buffer invisible hb_codepoint_t

Since: 2.0.0
*/
buffer_get_invisible_glyph	:: proc(buffer: /*const*/ ^buffer_t)	-> codepoint_t ---

/*
void hb_buffer_set_not_found_glyph (hb_buffer_t *buffer, hb_codepoint_t not_found);

Sets the hb_codepoint_t that replaces characters not found in the font during shaping.

The not-found glyph defaults to zero, sometimes known as the ".notdef" glyph. This API allows for differentiating the two.
- buffer		An hb_buffer_t
- not_found		the not-found hb_codepoint_t

Since: 3.1.0
*/
buffer_set_not_found_glyph	:: proc(buffer: ^buffer_t, not_found: codepoint_t)	---

/*
hb_codepoint_t hb_buffer_get_not_found_glyph (const hb_buffer_t *buffer);

See hb_buffer_set_not_found_glyph().
- buffer		An hb_buffer_t
- Returns		The buffer not-found hb_codepoint_t

Since: 3.1.0
*/
buffer_get_not_found_glyph	:: proc(buffer: /*const*/ ^buffer_t)	-> codepoint_t ---

/*
void hb_buffer_set_random_state (hb_buffer_t *buffer, unsigned  state);

Sets the random state of the buffer. The state changes every time a glyph uses randomness (eg. the rand OpenType feature).
This function together with hb_buffer_get_random_state() allow for transferring the current random state to a subsequent
buffer, to get better randomness distribution.

Defaults to 1 and when buffer contents are cleared. A value of 0 disables randomness during shaping.
- buffer		An hb_buffer_t
- state			the new random state

Since: 8.4.0
*/
buffer_set_random_state	:: proc(buffer: ^buffer_t, state: c.uint)	---

/*
unsigned hb_buffer_get_random_state (const hb_buffer_t *buffer);

See hb_buffer_set_random_state().
- buffer		An hb_buffer_t
- Returns		The buffer random state

Since: 8.4.0
*/
buffer_get_random_state	:: proc(buffer: /*const*/ ^buffer_t)	-> c.uint ---

/*
 * Content API.
 */

/*
void hb_buffer_clear_contents (hb_buffer_t *buffer);

Similar to hb_buffer_reset(), but does not clear the Unicode functions and the replacement code point.
- buffer	An hb_buffer_t

Since: 0.9.11
*/
buffer_clear_contents :: proc(buffer: ^buffer_t)	---

/*
hb_bool_t hb_buffer_pre_allocate (hb_buffer_t *buffer, unsigned int size);

Pre allocates memory for buffer to fit at least size number of items.
- buffer	An hb_buffer_t
- size		Number of items to pre allocate.
- Returns	true if buffer memory allocation succeeded, false otherwise.

Since: 0.9.2
*/
buffer_pre_allocate	:: proc(buffer: ^buffer_t, size: c.uint)	-> bool_t ---


/*
hb_bool_t hb_buffer_allocation_successful (hb_buffer_t *buffer);

Check if allocating memory for the buffer succeeded.
- buffer	A `buffer_t`
- Returns	true if buffer memory allocation succeeded, false otherwise.

Since: 0.9.2
*/
buffer_allocation_successful	:: proc(buffer: ^buffer_t)	-> bool_t ---

/*
void hb_buffer_reverse (hb_buffer_t *buffer);

Reverses buffer contents.
- buffer		An hb_buffer_t

Since: 0.9.2
*/
buffer_reverse	:: proc(buffer: ^buffer_t)	---

/*
void hb_buffer_reverse_range (hb_buffer_t *buffer, unsigned int start, unsigned int end);

Reverses buffer contents between start and end.
- buffer		An hb_buffer_t
- start			start index
- end			end index

Since: 0.9.41
*/
buffer_reverse_range	:: proc(buffer: ^buffer_t, start: c.uint, end: c.uint)	---

/*
void hb_buffer_reverse_clusters (hb_buffer_t *buffer);

Reverses buffer clusters. That is, the buffer contents are reversed, then each cluster (consecutive items having the
same cluster number) are reversed again.
- buffer		An hb_buffer_t

Since: 0.9.2
*/
buffer_reverse_clusters	:: proc(buffer: ^buffer_t)	---


/* Filling the buffer in */

/*
void hb_buffer_add (hb_buffer_t *buffer, hb_codepoint_t codepoint, unsigned int cluster);

Appends a character with the Unicode value of codepoint to buffer, and gives it the initial cluster value of cluster.
Clusters can be any thing the client wants, they are usually used to refer to the index of the character in the input
text stream and are output in hb_glyph_info_t.cluster field.

This function does not check the validity of codepoint , it is up to the caller to ensure it is a valid Unicode code point.
- buffer	An hb_buffer_t.
- codepoint	A Unicode code point.
- cluster	The cluster value of codepoint.

Since: 0.9.7
*/
buffer_add	:: proc(buffer: ^buffer_t, codepoint: codepoint_t, cluster: c.uint)	---

/*
void hb_buffer_add_utf8 (hb_buffer_t *buffer, const char *text, int text_length, unsigned int item_offset, int item_length);

See hb_buffer_add_codepoints().

Replaces invalid UTF-8 characters with the buffer replacement code point, see hb_buffer_set_replacement_codepoint().

- buffer		An hb_buffer_t
- text			An array of UTF-8 characters to append. [array length=text_length][element-type uint8_t]
- text_length	The length of the text , or -1 if it is NULL terminated.
- item_offset	The offset of the first character to add to the buffer.
- item_length	The number of characters to add to the buffer , or -1 for the end of text (assuming it is NULL terminated).

Since: 0.9.2
*/
buffer_add_utf8	:: proc(buffer: ^buffer_t, text: /*const*/ [^]u8, text_length: c.int, item_offset: c.uint, item_length: c.int)	---

/*
void hb_buffer_add_utf16 (hb_buffer_t *buffer, const uint16_t *text, int text_length, unsigned int item_offset, int item_length);

See hb_buffer_add_codepoints().

Replaces invalid UTF-16 characters with the buffer replacement code point, see hb_buffer_set_replacement_codepoint().

- buffer		An hb_buffer_t
- text			An array of UTF-16 characters to append. [array length=text_length]
- text_length	The length of the text , or -1 if it is NULL terminated
- item_offset	The offset of the first character to add to the buffer
- item_length	The number of characters to add to the buffer , or -1 for the end of text (assuming it is NULL terminated)

Since: 0.9.2
*/
buffer_add_utf16	:: proc(buffer: ^buffer_t, text: /*const*/ [^]u16, text_length: c.int, item_offset: c.uint, item_length: c.int)	---

/*
void hb_buffer_add_utf32 (hb_buffer_t *buffer, const uint32_t *text, int text_length, unsigned int item_offset, int item_length);

See hb_buffer_add_codepoints().

Replaces invalid UTF-32 characters with the buffer replacement code point, see hb_buffer_set_replacement_codepoint().
Parameters

- buffer		a hb_buffer_t to append characters to.
- text			An array of UTF-32 characters to append. [array length=text_length]
- text_length	the length of the text , or -1 if it is NULL terminated.
- item_offset	the offset of the first code point to add to the buffer.
- item_length	the number of code points to add to the buffer , or -1 for the end of text (assuming it is NULL terminated).

Since: 0.9.2
*/
buffer_add_utf32	:: proc(buffer: ^buffer_t, text: /*const*/ [^]u32, text_length: c.int, item_offset: c.uint, item_length: c.int)	---

/*
void hb_buffer_add_latin1 (hb_buffer_t *buffer, const uint8_t *text, int text_length, unsigned int item_offset, int item_length);

Similar to hb_buffer_add_codepoints(), but allows only access to first 256 Unicode code points that can fit in 8-bit strings.
Has nothing to do with non-Unicode Latin-1 encoding.

- buffer		An hb_buffer_t
- text			an array of UTF-8 characters to append. [array length=text_length][element-type uint8_t]
- text_length	the length of the text , or -1 if it is NULL terminated
- item_offset	the offset of the first character to add to the buffer
- item_length	the number of characters to add to the buffer , or -1 for the end of text (assuming it is NULL terminated)

Since: 0.9.39
*/
buffer_add_latin1	:: proc(buffer: ^buffer_t, text: /*const*/ [^]u8, text_length: c.int, item_offset: c.uint, item_length: c.int)	---

/*
void hb_buffer_add_codepoints (hb_buffer_t *buffer, const hb_codepoint_t *text, int text_length, unsigned int item_offset, int item_length);

Appends characters from text array to buffer . The item_offset is the position of the first character from text that will
be appended, and item_length is the number of character. When shaping part of a larger text (e.g. a run of text from a
paragraph), instead of passing just the substring corresponding to the run, it is preferable to pass the whole paragraph
and specify the run start and length as item_offset and item_length , respectively, to give HarfBuzz the full context to
be able, for example, to do cross-run Arabic shaping or properly handle combining marks at stat of run.

This function does not check the validity of text , it is up to the caller to ensure it contains a valid Unicode scalar
values. In contrast, hb_buffer_add_utf32() can be used that takes similar input but performs sanity-check on the input.

- buffer		a hb_buffer_t to append characters to.
- text			an array of Unicode code points to append. [array length=text_length]
- text_length	the length of the text , or -1 if it is NULL terminated.
- item_offset	the offset of the first code point to add to the buffer.
- item_length	the number of code points to add to the buffer , or -1 for the end of text (assuming it is NULL terminated).

Since: 0.9.31
*/
buffer_add_codepoints	:: proc(buffer: ^buffer_t, text: /*const*/ [^]codepoint_t, text_length: c.int, item_offset: c.uint, item_length: c.int)	---

/*
void hb_buffer_append (hb_buffer_t *buffer, const hb_buffer_t *source, unsigned int start, unsigned int end);

Append (part of) contents of another buffer to this buffer.
- buffer		An hb_buffer_t
- source		source hb_buffer_t
- start			start index into source buffer to copy. Use 0 to copy from start of buffer.
- end			end index into source buffer to copy. Use HB_FEATURE_GLOBAL_END to copy to end of buffer.

Since: 1.5.0
*/
buffer_append	:: proc(buffer: ^buffer_t, source: /*const*/ ^buffer_t, start: c.uint, end: c.uint)	---

/*
hb_bool_t hb_buffer_set_length (hb_buffer_t  *buffer, unsigned int  length);

Similar to hb_buffer_pre_allocate(), but clears any new items added at the end.
- buffer		An hb_buffer_t
- length		The new length of buffer
- Returns		true if buffer memory allocation succeeded, false otherwise.

Since: 0.9.2
*/
buffer_set_length	:: proc(buffer: ^buffer_t, length: c.uint)	-> bool_t ---

/*
unsigned int hb_buffer_get_length (const hb_buffer_t *buffer);

Returns the number of items in the buffer.
- buffer		An hb_buffer_t
- Returns		The buffer length. The value valid as long as buffer has not been modified.

Since: 0.9.2
*/
buffer_get_length	:: proc(buffer: /*const*/ ^buffer_t)	-> c.uint ---

/* Getting glyphs out of the buffer */

/*
hb_glyph_info_t * hb_buffer_get_glyph_infos (hb_buffer_t  *buffer, unsigned int *length);

Returns buffer glyph information array. Returned pointer is valid as long as buffer contents are not modified.
- buffer		An hb_buffer_t
- length		The output-array length. [out]
- Returns		The buffer glyph information array. The value valid as long as buffer has not been modified. [transfer none][array length=length]

Since: 0.9.2
*/
buffer_get_glyph_infos	:: proc(buffer: ^buffer_t, length: ^c.uint)	-> ^glyph_info_t ---

/*
hb_glyph_position_t * hb_buffer_get_glyph_positions (hb_buffer_t *buffer, unsigned int *length);

Returns buffer glyph position array. Returned pointer is valid as long as buffer contents are not modified.

If buffer did not have positions before, the positions will be initialized to zeros, unless this function is called from
within a buffer message callback (see hb_buffer_set_message_func()), in which case NULL is returned.
- buffer		An hb_buffer_t
- length		The output length. [out]
- Returns		The buffer glyph position array. The value valid as long as buffer has not been modified. [transfer none][array length=length]

Since: 0.9.2
*/
buffer_get_glyph_positions	:: proc(buffer: ^buffer_t, length: ^c.uint)	-> ^glyph_position_t ---

/*
hb_bool_t hb_buffer_has_positions (hb_buffer_t *buffer);

Returns whether buffer has glyph position data. A buffer gains position data when hb_buffer_get_glyph_positions() is
called on it, and cleared of position data when hb_buffer_clear_contents() is called.
- buffer		an hb_buffer_t.
- Returns		true if the buffer has position array, false otherwise.

Since: 2.7.3
*/
buffer_has_positions	:: proc(buffer: ^buffer_t)	-> bool_t ---

/*
void hb_buffer_normalize_glyphs (hb_buffer_t *buffer);

Reorders a glyph buffer to have canonical in-cluster glyph order / position. The resulting clusters should behave
identical to pre-reordering clusters. This has nothing to do with Unicode normalization.
- buffer		An hb_buffer_t

Since: 0.9.2
*/
buffer_normalize_glyphs	:: proc(buffer: ^buffer_t)	---

/*
hb_buffer_serialize_format_t hb_buffer_serialize_format_from_string (const char *str, int len);

Parses a string into an hb_buffer_serialize_format_t. Does not check if str is a valid buffer serialization format, use
hb_buffer_serialize_list_formats() to get the list of supported formats.
- str		a string to parse. [array length=len][element-type uint8_t]
- len		length of str , or -1 if string is NULL terminated
- Returns	The parsed hb_buffer_serialize_format_t.

Since: 0.9.7
*/
buffer_serialize_format_from_string	:: proc(str: cstring, len: c.int)	-> buffer_serialize_format_t ---

/*
const char * hb_buffer_serialize_format_to_string (hb_buffer_serialize_format_t format);

Converts format to the string corresponding it, or NULL if it is not a valid hb_buffer_serialize_format_t.
- format		an hb_buffer_serialize_format_t to convert.
- Returns		A NULL terminated string corresponding to format . Should not be freed. [transfer none]

Since: 0.9.7
*/
buffer_serialize_format_to_string	:: proc(format: buffer_serialize_format_t)	-> cstring ---

/*
const char ** hb_buffer_serialize_list_formats (void);

Returns a list of supported buffer serialization formats.
- Returns		A string array of buffer serialization formats. Should not be freed. [transfer none]

Since: 0.9.7
*/
buffer_serialize_list_formats	:: proc()	-> [^]cstring ---

/*
unsigned int hb_buffer_serialize_glyphs (hb_buffer_t *buffer, unsigned int start, unsigned int end, char *buf, unsigned int buf_size,
	unsigned int *buf_consumed, hb_font_t *font, hb_buffer_serialize_format_t format, hb_buffer_serialize_flags_t flags);

Serializes buffer into a textual representation of its glyph content, useful for showing the contents of the buffer, for
example during debugging. There are currently two supported serialization formats:

- text	A human-readable, plain text format. The serialized glyphs will look something like:
	[uni0651=0@518,0+0|uni0628=0+1897]

    The serialized glyphs are delimited with [ and ].

    Glyphs are separated with |

    Each glyph starts with glyph name, or glyph index if HB_BUFFER_SERIALIZE_FLAG_NO_GLYPH_NAMES flag is set. Then,

        If HB_BUFFER_SERIALIZE_FLAG_NO_CLUSTERS is not set, = then hb_glyph_info_t.cluster.

        If HB_BUFFER_SERIALIZE_FLAG_NO_POSITIONS is not set, the hb_glyph_position_t in the format:

            If both hb_glyph_position_t.x_offset and hb_glyph_position_t.y_offset are not 0, @x_offset,y_offset. Then,

            +x_advance, then ,y_advance if hb_glyph_position_t.y_advance is not 0. Then,

        If HB_BUFFER_SERIALIZE_FLAG_GLYPH_EXTENTS is set, the hb_glyph_extents_t in the format <x_bearing,y_bearing,width,height>

- json	A machine-readable, structured format. The serialized glyphs will look something like:

	[{"g":"uni0651","cl":0,"dx":518,"dy":0,"ax":0,"ay":0}, {"g":"uni0628","cl":0,"dx":0,"dy":0,"ax":1897,"ay":0}]

	Each glyph is a JSON object, with the following properties:

		g: the glyph name or glyph index if HB_BUFFER_SERIALIZE_FLAG_NO_GLYPH_NAMES flag is set.

		cl: hb_glyph_info_t.cluster if HB_BUFFER_SERIALIZE_FLAG_NO_CLUSTERS is not set.

		dx,dy,ax,ay: hb_glyph_position_t.x_offset, hb_glyph_position_t.y_offset, hb_glyph_position_t.x_advance and hb_glyph_position_t.y_advance respectively, if HB_BUFFER_SERIALIZE_FLAG_NO_POSITIONS is not set.

		xb,yb,w,h: hb_glyph_extents_t.x_bearing, hb_glyph_extents_t.y_bearing, hb_glyph_extents_t.width and hb_glyph_extents_t.height respectively if HB_BUFFER_SERIALIZE_FLAG_GLYPH_EXTENTS is set.

- buffer		an hb_buffer_t buffer.
- start			the first item in buffer to serialize.
- end			the last item in buffer to serialize.
- buf			output string to write serialized buffer into. [out][array length=buf_size][element-type uint8_t]
- buf_size		the size of buf.
- buf_consumed	if not NULL, will be set to the number of bytes written into buf. [out][optional]
- font			the hb_font_t used to shape this buffer, needed to read glyph names and extents. If NULL, an empty font will be used. [nullable]
- format		the hb_buffer_serialize_format_t to use for formatting the output.
- flags			the hb_buffer_serialize_flags_t that control what glyph properties to serialize.
- Returns		The number of serialized items.

Since: 0.9.7
*/
buffer_serialize_glyphs	:: proc(buffer: ^buffer_t, start: c.uint, end: c.uint, buf: [^]u8, buf_size: c.uint, buf_consumed: ^c.uint,
	font: ^font_t, format: buffer_serialize_format_t, flags: buffer_serialize_flags_t)	-> c.uint ---

/*
unsigned int hb_buffer_serialize_unicode (hb_buffer_t *buffer, unsigned int start, unsigned int end, char *buf, unsigned int buf_size,
	unsigned int *buf_consumed, hb_buffer_serialize_format_t format, hb_buffer_serialize_flags_t flags);

Serializes buffer into a textual representation of its content, when the buffer contains Unicode codepoints (i.e., before
shaping). This is useful for showing the contents of the buffer, for example during debugging. There are currently two
supported serialization formats:

- text	A human-readable, plain text format. The serialized codepoints will look something like:

 <U+0651=0|U+0628=1>

    Glyphs are separated with |

    Unicode codepoints are expressed as zero-padded four (or more) digit hexadecimal numbers preceded by U+

    If HB_BUFFER_SERIALIZE_FLAG_NO_CLUSTERS is not set, the cluster will be indicated with a = then hb_glyph_info_t.cluster.

- json	A machine-readable, structured format. The serialized codepoints will be a list of objects with the following properties:

    u: the Unicode codepoint as a decimal integer

    cl: hb_glyph_info_t.cluster if HB_BUFFER_SERIALIZE_FLAG_NO_CLUSTERS is not set.

For example:

[{u:1617,cl:0},{u:1576,cl:1}]

- buffer		an hb_buffer_t buffer.
- start			the first item in buffer to serialize.
- end			the last item in buffer to serialize.
- buf			output string to write serialized buffer into. [out][array length=buf_size][element-type uint8_t]
- buf_size		the size of buf.
- buf_consumed	if not NULL, will be set to the number of bytes written into buf. [out][optional]
- format		the hb_buffer_serialize_format_t to use for formatting the output.
- flags			the hb_buffer_serialize_flags_t that control what glyph properties to serialize.
- Returns		The number of serialized items.

Since: 2.7.3
*/
buffer_serialize_unicode	:: proc(buffer: ^buffer_t, start: c.uint, end: c.uint, buf: [^]u8, buf_size: c.uint,
	buf_consumed: ^c.uint, format: buffer_serialize_format_t, flags: buffer_serialize_flags_t)	-> c.uint	---

/*
unsigned int hb_buffer_serialize (hb_buffer_t *buffer, unsigned int start, unsigned int end, char *buf, unsigned int buf_size,
	unsigned int *buf_consumed, hb_font_t *font, hb_buffer_serialize_format_t format, hb_buffer_serialize_flags_t flags);

Serializes buffer into a textual representation of its content, whether Unicode codepoints or glyph identifiers and
positioning information. This is useful for showing the contents of the buffer, for example during debugging. See the
documentation of hb_buffer_serialize_unicode() and hb_buffer_serialize_glyphs() for a description of the output format.
- buffer		an hb_buffer_t buffer.
- start			the first item in buffer to serialize.
- end			the last item in buffer to serialize.
- buf			output string to write serialized buffer into. [out][array length=buf_size][element-type uint8_t]
- buf_size		the size of buf.
- buf_consumed	if not NULL, will be set to the number of bytes written into buf. [out][optional]
- font			the hb_font_t used to shape this buffer, needed to read glyph names and extents. If NULL, an empty font will be used. [nullable]
- format		the hb_buffer_serialize_format_t to use for formatting the output.
- flags			the hb_buffer_serialize_flags_t that control what glyph properties to serialize.
- Returns		The number of serialized items.

Since: 2.7.3
*/
buffer_serialize	:: proc(buffer: ^buffer_t, start: c.uint, end: c.uint, buf: [^]u8, buf_size: c.uint, buf_consumed: ^c.uint,
	font: ^font_t, format: buffer_serialize_format_t, flags: buffer_serialize_flags_t)	-> c.uint ---

/*
hb_bool_t hb_buffer_deserialize_glyphs (hb_buffer_t *buffer, const char *buf, int buf_len, const char **end_ptr, hb_font_t *font, hb_buffer_serialize_format_t format);

Deserializes glyphs buffer from textual representation in the format produced by hb_buffer_serialize_glyphs().
- buffer		an hb_buffer_t buffer.
- buf			string to deserialize. [array length=buf_len]
- buf_len		the size of buf , or -1 if it is NULL-terminated
- end_ptr		output pointer to the character after last consumed one. [out][optional]
- font			font for getting glyph IDs. [nullable]
- format		the hb_buffer_serialize_format_t of the input buf
- Returns		true if parse was successful, false if an error occurred.

Since: 0.9.7
*/
buffer_deserialize_glyphs	:: proc(buffer: ^buffer_t, buf: cstring, buf_len: c.int, end_ptr: ^cstring, font: ^font_t, format: buffer_serialize_format_t)	-> bool_t ---

/*
hb_bool_t  hb_buffer_deserialize_unicode (hb_buffer_t *buffer, const char *buf, int buf_len, const char **end_ptr, hb_buffer_serialize_format_t format);

Deserializes Unicode buffer from textual representation in the format produced by hb_buffer_serialize_unicode().
- buffer		an hb_buffer_t buffer.
- buf			string to deserialize. [array length=buf_len]
- buf_len		the size of buf , or -1 if it is NULL-terminated
- end_ptr		output pointer to the character after last consumed one. [out][optional]
- format		the hb_buffer_serialize_format_t of the input buf
- Returns		true if parse was successful, false if an error occurred.

Since: 2.7.3
*/
buffer_deserialize_unicode	:: proc(buffer: ^buffer_t, buf: cstring, buf_len: c.int, end_ptr: ^cstring, format: buffer_serialize_format_t)	-> bool_t ---

/*
hb_buffer_diff_flags_t hb_buffer_diff (hb_buffer_t *buffer, hb_buffer_t *reference, hb_codepoint_t dottedcircle_glyph, unsigned int position_fuzz);

Compare the contents of two buffers, report types of differences.

If dottedcircle_glyph is (hb_codepoint_t) -1 then HB_BUFFER_DIFF_FLAG_DOTTED_CIRCLE_PRESENT and HB_BUFFER_DIFF_FLAG_NOTDEF_PRESENT
are never returned. This should be used by most callers if just comparing two buffers is needed.
- buffer				a buffer.
- reference				other buffer to compare to.
- dottedcircle_glyph	glyph id of U+25CC DOTTED CIRCLE, or (hb_codepoint_t) -1.
- position_fuzz			allowed absolute difference in position values.

Since: 1.5.0
*/
buffer_diff	:: proc(buffer: ^buffer_t, reference: ^buffer_t, dottedcircle_glyph: codepoint_t, position_fuzz: c.uint)	-> buffer_diff_flags_t ---

/*
 * Tracing.
 */

/*
void hb_buffer_set_message_func (hb_buffer_t *buffer, hb_buffer_message_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the implementation function for hb_buffer_message_func_t.
- buffer		An hb_buffer_t
- func			Callback function. [closure user_data][destroy destroy][scope notified]
- user_data		Data to pass to func. [nullable]
- destroy		The function to call when user_data is not needed anymore. [nullable]

Since: 1.1.3
*/
buffer_set_message_func	:: proc(buffer: ^buffer_t, func: buffer_message_func_t, user_data: rawptr, destroy: destroy_func_t)	---

//******************
// VERSION 10
//******************

/*
void hb_buffer_set_not_found_variation_selector_glyph (hb_buffer_t *buffer, hb_codepoint_t not_found_variation_selector);

Sets the hb_codepoint_t that replaces variation-selector characters not resolved in the font during shaping.

The not-found-variation-selector glyph defaults to HB_CODEPOINT_INVALID, in which case an unresolved variation-selector
will be removed from the glyph string during shaping. This API allows for changing that and retaining a glyph, such
that the situation can be detected by the client and handled accordingly (e.g. by using a different font).

Inputs:
- buffer:						An hb_buffer_t
- not_found_variation_selector:	the not-found-variation-selector hb_codepoint_t

Since: 10.0.0
*/
buffer_set_not_found_variation_selector_glyph :: proc (buffer: ^buffer_t, not_found_variation_selector: codepoint_t)	---

/*
hb_codepoint_t hb_buffer_get_not_found_variation_selector_glyph (const hb_buffer_t *buffer);

See hb_buffer_set_not_found_variation_selector_glyph().

Inputs:
- buffer:	An hb_buffer_t
Returns:
- The buffer not-found-variation-selector hb_codepoint_t

Since: 10.0.0
*/
buffer_get_not_found_variation_selector_glyph :: proc (buffer: /*const*/ ^buffer_t)	-> codepoint_t ---

}
