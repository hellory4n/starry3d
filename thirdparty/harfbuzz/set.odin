/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

set.odin - Types and functions for managing sets of integers.

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
author: Maurizio M. Gavioli, 2024-08-11

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-set.h
		https://harfbuzz.github.io/harfbuzz-hb-set.html
*/

/*
hb-set — Objects representing a set of integers

Set objects represent a mathematical set of integer values. They are used in non-shaping APIs to query
* certain sets of characters or glyphs, or other integer values.
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
#define HB_SET_VALUE_INVALID HB_CODEPOINT_INVALID

Unset hb_set_t value.

Since: 0.9.21
*/
SET_VALUE_INVALID :: CODEPOINT_INVALID

/*
typedef struct hb_set_t hb_set_t;

Data type for holding a set of integers. hb_set_t's are used to gather and contain glyph IDs,
Unicode code points, and various other collections of discrete values.
*/
set_t :: struct {}		// opeque structure

//******************
// FUNCTIONS */
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
hb_set_t * hb_set_create (void);

Creates a new, initially empty set.
- Returns	The new hb_set_t. [transfer full]

Since: 0.9.2
*/
set_create :: proc ()	-> ^set_t ---

/*
hb_bool_t hb_set_allocation_successful (const hb_set_t *set);

Tests whether memory allocation for a set was successful.

- set		A set
- Returns	true if allocation succeeded, false otherwise

Since: 0.9.2
*/
set_allocation_successful :: proc (set: /*const*/ ^set_t)	-> bool_t ---

/*
hb_set_t * hb_set_copy (const hb_set_t *set);

Allocate a copy of set .

- set		A set
- Returns	Newly-allocated set. [transfer full]

Since: 2.8.2
*/
set_copy :: proc (set: /*const*/ ^set_t)	-> ^set_t ---

/*
hb_set_t * hb_set_get_empty (void);

Fetches the singleton empty hb_set_t.

- Returns	The empty hb_set_t. [transfer full]

Since: 0.9.2
*/
set_get_empty :: proc ()	-> ^set_t ---

/*
hb_set_t * hb_set_reference (hb_set_t *set);

Increases the reference count on a set.

- set		A set
- Returns	The set. [transfer full]

Since: 0.9.2
*/
set_reference :: proc (set: ^set_t)	-> ^set_t ---

/*
void hb_set_destroy (hb_set_t *set);

Decreases the reference count on a set. When the reference count reaches zero, the set is destroyed, freeing all memory.

- set	A set

Since: 0.9.2
*/
set_destroy :: proc (set: ^set_t)	---

/*
hb_bool_t hb_set_set_user_data (hb_set_t *set, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified set.

- set		A set
- key		The user-data key to set
- data		A pointer to the user data to set
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 0.9.2
*/
set_set_user_data :: proc (set: ^set_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_set_get_user_data (const hb_set_t *set, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified set.

- set		A set
- key		The user-data key to query
- Returns	A pointer to the user data. [transfer none]

Since: 0.9.2
*/
set_get_user_data :: proc (set: /*const*/ ^set_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_set_clear (hb_set_t *set);

Clears out the contents of a set.

- set		A set

Since: 0.9.2
*/
set_clear :: proc (set: ^set_t)	---

/*
void hb_set_set (hb_set_t *set, const hb_set_t *other);

Makes the contents of set equal to the contents of other .

- set		A set
- other		Another set

Since: 0.9.2
*/
set_set :: proc (set: ^set_t, other: /*const*/ ^set_t)	---

/*
hb_bool_t hb_set_has (const hb_set_t *set, hb_codepoint_t codepoint);

Tests whether codepoint belongs to set.

- set		A set
- codepoint	The element to query
- Returns	true if codepoint is in set , false otherwise

Since: 0.9.2
*/
set_has :: proc (set: /*const*/ ^set_t, codepoint: codepoint_t)	-> bool_t ---

/*
void hb_set_add (hb_set_t *set, hb_codepoint_t codepoint);

Adds codepoint to set .

- set		A set
- codepoint	The element to add to set

Since: 0.9.2
*/
set_add :: proc (set: ^set_t, codepoint: codepoint_t)	---

/*
void hb_set_add_range (hb_set_t *set, hb_codepoint_t first, hb_codepoint_t last);

Adds all of the elements from first to last (inclusive) to set .

- set		A set
- first		The first element to add to set
- last		The final element to add to set

Since: 0.9.7
*/
set_add_range :: proc (set: ^set_t, first: codepoint_t, last: codepoint_t)	---

/*
void hb_set_add_sorted_array (hb_set_t *set, const hb_codepoint_t *sorted_codepoints, unsigned int num_codepoints);

Adds num_codepoints codepoints to a set at once. The codepoints array must be in increasing order, with size at least num_codepoints.

- set				A set
- sorted_codepoints	Array of codepoints to add. [array length=num_codepoints]
- num_codepoints	Length of sorted_codepoints

Since: 4.1.0
*/
set_add_sorted_array :: proc (set: ^set_t, sorted_codepoints: /*const*/ ^codepoint_t, num_codepoints: c.uint)	---

/*
void hb_set_del (hb_set_t *set, hb_codepoint_t codepoint);

Removes codepoint from set .

- set		A set
- codepoint	Removes codepoint from set

Since: 0.9.2
*/
set_del :: proc (set: ^set_t, codepoint: codepoint_t)	---

/*
void hb_set_del_range (hb_set_t *set, hb_codepoint_t first, hb_codepoint_t last);

Removes all of the elements from first to last (inclusive) from set .

If last is HB_SET_VALUE_INVALID, then all values greater than or equal to first are removed.

- set		A set
- first		The first element to remove from set
- last		The final element to remove from set

Since: 0.9.7
*/
set_del_range :: proc (set: ^set_t, first: codepoint_t, last: codepoint_t)	---

/*
hb_codepoint_t hb_set_get_max (const hb_set_t *set);

Finds the largest element in the set.

- set		A set
Returns		maximum of set , or HB_SET_VALUE_INVALID if set is empty.

Since: 0.9.7
*/
set_get_max ::proc (set: /*const*/ ^set_t)	-> codepoint_t ---

/*
hb_codepoint_t hb_set_get_min (const hb_set_t *set);

Finds the smallest element in the set.

- set		A set
- Returns	minimum of set , or HB_SET_VALUE_INVALID if set is empty.

Since: 0.9.7
*/
set_get_min :: proc (set: /*const*/ ^set_t)	-> codepoint_t ---

/*
unsigned int hb_set_get_population (const hb_set_t *set);

Returns the number of elements in the set.

- set		A set
- Returns	The population of set

Since: 0.9.7
*/
set_get_population :: proc (set: /*const*/ ^set_t)	-> c.uint ---

/*
hb_bool_t hb_set_is_empty (const hb_set_t *set);

Tests whether a set is empty (contains no elements).

- set		a set.
- Returns	true if set is empty

Since: 0.9.7
*/
set_is_empty :: proc (set: /*const*/ ^set_t)	-> bool_t ---

/*
unsigned int hb_set_hash (const hb_set_t *set);

Creates a hash representing set.

- set		A set
- Returns	A hash of set.

Since: 4.4.0
*/
set_hash :: proc (set: /*const*/ ^set_t)	-> c.uint ---

/*
void hb_set_subtract (hb_set_t *set, const hb_set_t *other);

Subtracts the contents of other from set .

- set		A set
- other		Another set

Since: 0.9.2
*/
set_subtract :: proc (set: ^set_t, other: /*const*/ ^set_t)	---

/*
void hb_set_intersect (hb_set_t *set, const hb_set_t *other);

Makes set the intersection of set and other.

- set		A set
- other		Another set

Since: 0.9.2
*/
set_intersect :: proc (set: ^set_t, other: /*const*/ ^set_t)	---

/*
void hb_set_union (hb_set_t *set, const hb_set_t *other);

Makes set the union of set and other .

- set		A set
- other		Another set

Since: 0.9.2
*/
set_union :: proc (set: ^set_t, other: /*const*/ ^set_t)	---

/*
void hb_set_symmetric_difference (hb_set_t *set, const hb_set_t *other);

Makes set the symmetric difference of set and other .

- set		A set
- other		Another set

Since: 0.9.2
*/
set_symmetric_difference :: proc (set: ^set_t, other: /*const*/ ^set_t)	---

/*
void hb_set_invert (hb_set_t *set);

Inverts the contents of set .

- set		A set

Since: 3.0.0
*/
set_invert ::proc (set: ^set_t)	---

/*
hb_bool_t hb_set_is_inverted (const hb_set_t *set);

Returns whether the set is inverted.

- set		A set
- Returns	true if the set is inverted, false otherwise

Since: 7.0.0
*/
set_is_inverted :: proc (set: /*const*/ ^set_t)	-> bool_t ---

/*
hb_bool_t hb_set_is_equal (const hb_set_t *set, const hb_set_t *other);

Tests whether set and other are equal (contain the same elements).

- set		A set
- other		Another set
- Returns	true if the two sets are equal, false otherwise.

Since: 0.9.7
*/
set_is_equal :: proc (set: /*const*/ ^set_t, other: /*const*/ ^set_t)	-> bool_t ---

/*
hb_bool_t hb_set_is_subset (const hb_set_t *set, const hb_set_t *larger_set);

Tests whether set is a subset of larger_set .

- set			A set
- larger_set	Another set
- Returns		true if the set is a subset of (or equal to) larger_set , false otherwise.

Since: 1.8.1
*/
set_is_subset :: proc (set: /*const*/ ^set_t, larger_set: /*const*/ ^set_t)	-> bool_t ---

/*
hb_bool_t hb_set_next (const hb_set_t *set, hb_codepoint_t *codepoint);

Fetches the next element in set that is greater than current value of codepoint .

Set codepoint to HB_SET_VALUE_INVALID to get started.

- set		A set
- codepoint	Input = Code point to query Output = Code point retrieved. [inout]
- Returns	true if there was a next value, false otherwise

Since: 0.9.2
*/
set_next :: proc (set: /*const*/ ^set_t, codepoint: ^codepoint_t)	-> bool_t ---

/*
hb_bool_t hb_set_next_range (const hb_set_t *set, hb_codepoint_t *first, hb_codepoint_t *last);

Fetches the next consecutive range of elements in set that are greater than current value of last .

Set last to HB_SET_VALUE_INVALID to get started.

- set		A set
- first		The first code point in the range. [out]
- last		Input = The current last code point in the range Output = The last code point in the range. [inout]
- Returns	true if there was a next range, false otherwise

Since: 0.9.7
*/
set_next_range :: proc (set: /*const*/ ^set_t, first: ^codepoint_t, last: ^codepoint_t)	-> bool_t ---

/*
unsigned int hb_set_next_many (const hb_set_t *set, hb_codepoint_t codepoint, hb_codepoint_t *out, unsigned int size);

Finds the next element in set that is greater than codepoint . Writes out codepoints to out , until either the set runs
out of elements, or size codepoints are written, whichever comes first.

- set		A set
- codepoint	Outputting codepoints starting after this one. Use HB_SET_VALUE_INVALID to get started.
- out		An array of codepoints to write to. [array length=size]
- size		The maximum number of codepoints to write out.
- Returns	the number of values written.

Since: 4.2.0
*/
set_next_many :: proc (set: /*const*/ ^set_t, codepoint: codepoint_t, out: ^codepoint_t, size: c.uint)	-> c.uint ---

/*
hb_bool t hb_set_previous (const hb_set_t *set, hb_codepoint_t *codepoint);

Fetches the previous element in set that is lower than current value of codepoint .

Set codepoint to HB_SET_VALUE_INVALID to get started.

- set		A set
- codepoint	Input = Code point to query Output = Code point retrieved. [inout]
- Returns	true if there was a previous value, false otherwise

Since: 1.8.0
*/
set_previous :: proc (set: /*const*/ ^set_t, codepoint: ^codepoint_t)	-> bool_t ---

/*
hb_bool_t hb_set_previous_range (const hb_set_t *set, hb_codepoint_t *first, hb_codepoint_t *last);

Fetches the previous consecutive range of elements in set that are greater than current value of last.

Set first to HB_SET_VALUE_INVALID to get started.

- set		A set
- first		Input = The current first code point in the range Output = The first code point in the range. [inout]
- last		The last code point in the range. [out]
- Returns	true if there was a previous range, false otherwise

Since: 1.8.0
*/
set_previous_range :: proc (set: /*const*/ ^set_t, first: ^codepoint_t, last: ^codepoint_t)	-> bool_t ---

}
