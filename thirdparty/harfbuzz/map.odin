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
hb-map — Object representing integer to integer mapping

Map objects are integer-to-integer hash-maps. Currently they are not used in the HarfBuzz public API, but are provided for client's use if desired.
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
#define HB_MAP_VALUE_INVALID HB_CODEPOINT_INVALID

Unset #hb_map_t value.

Since: 1.7.7
*/
MAP_VALUE_INVALID :: CODEPOINT_INVALID

/*
typedef struct hb_map_t hb_map_t;

Data type for holding integer-to-integer hash maps.
*/
map_t :: struct {}							// opaque structure

//******************
// FUNCTIONS */
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
hb_map_t * hb_map_create (void);

Creates a new, initially empty map.
- Returns	The new hb_map_t. [transfer full]

Since: 1.7.7
*/
map_create :: proc ()	-> ^map_t ---

/*
hb_bool_t hb_map_allocation_successful (const hb_map_t *map);

Tests whether memory allocation for a set was successful.

- a_map		A map
- Returns	true if allocation succeeded, false otherwise

Since: 1.7.7
*/
map_allocation_successful :: proc (a_map: /*const*/ ^map_t)	-> bool_t ---

/*
hb_map_t * hb_map_copy (const hb_map_t *map);

Allocate a copy of map .

- a_map		A map
- Returns	Newly-allocated map. [transfer full]

Since: 4.4.0
*/
map_copy :: proc (a_map: /*const*/ ^map_t)	-> ^map_t ---

/*
void hb_map_clear (hb_map_t *map);

Clears out the contents of map .

- a_map		A map

Since: 1.7.7
*/
map_clear :: proc (a_map: ^map_t)	---

/*
hb_map_t * hb_map_get_empty (void);

Fetches the singleton empty hb_map_t.

- Returns		The empty hb_map_t. [transfer full]

Since: 1.7.7
*/
map_get_empty :: proc ()	-> ^map_t ---

/*
hb_map_t * hb_map_reference (hb_map_t *map);

Increases the reference count on a map.

- a_map		A map
- Returns	The map. [transfer full]

Since: 1.7.7
*/
map_reference :: proc (a_map: ^map_t)	-> ^map_t ---

/*
void hb_map_destroy (hb_map_t *map);

Decreases the reference count on a map. When the reference count reaches zero, the map is destroyed, freeing all memory.

- a_map		A map

Since: 1.7.7
*/
map_destroy :: proc (a_map: ^map_t)	---

/*
hb_bool_t hb_map_set_user_data (hb_map_t *map, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified map.

- a_map		A map
- key		The user-data key to set
- data		A pointer to the user data to set
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 1.7.7
*/
map_set_user_data :: proc (a_map: ^map_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_map_get_user_data (const hb_map_t *map, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified map.

- a_map		A map
- key		The user-data key to query
- Returns	A pointer to the user data. [transfer none]

Since: 1.7.7
*/
map_get_user_data :: proc(a_map: /*const*/ ^map_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_map_set (hb_map_t *map, hb_codepoint_t key, hb_codepoint_t value);

Stores key :value in the map.

- a_map		A map
- key		The key to store in the map
- value		The value to store for key

Since: 1.7.7
*/
map_set :: proc (a_map: ^map_t, key: codepoint_t, value: codepoint_t)	---

/*
hb_codepoint_t hb_map_get (const hb_map_t *map, hb_codepoint_t key);

Fetches the value stored for key in map .

- a_map		A map
- key		The key to query

Since: 1.7.7
*/
map_get :: proc (a_map: /*const*/ ^map_t, key: codepoint_t)	-> codepoint_t ---

/*
void hb_map_del (hb_map_t *map, hb_codepoint_t key);

Removes key and its stored value from map .

- a_map		A map
- key		The key to delete

Since: 1.7.7
*/
map_del :: proc (a_map: ^map_t, key: codepoint_t)	---

/*
hb_bool_t hb_map_has (const hb_map_t *map, hb_codepoint_t key);

Tests whether key is an element of map .

- a_map		A map
- key		The key to query
- Returns	true if key is found in map , false otherwise

Since: 1.7.7
*/
map_has :: proc (a_map: /*const*/ ^map_t, key: codepoint_t)	-> bool_t ---

/*
unsigned int hb_map_get_population (const hb_map_t *map);

Returns the number of key-value pairs in the map.

- a_map		A map
- Returns	The population of map

Since: 1.7.7
*/
map_get_population :: proc (a_map: /*const*/ ^map_t)	-> c.uint ---

/*
hb_bool_t hb_map_is_empty (const hb_map_t *map);

Tests whether map is empty (contains no elements).

- a_map		A map
- Returns	true if map is empty

Since: 1.7.7
*/
map_is_empty :: proc (a_map: /*const*/ ^map_t)	-> bool_t ---

/*
hb_bool_t hb_map_is_equal (const hb_map_t *map, const hb_map_t *other);

Tests whether map and other are equal (contain the same elements).

- a_map		A map
- other		Another map
- Returns	true if the two maps are equal, false otherwise.

Since: 4.3.0
*/
map_is_equal :: proc (a_map: /*const*/ ^map_t, other: /*const*/ ^map_t)	-> bool_t ---

/*
unsigned int hb_map_hash (const hb_map_t *map);

Creates a hash representing map .

- a_map		A map
- Returns	A hash of map.

Since: 4.4.0
*/
map_hash :: proc (a_map: /*const*/ ^map_t)	-> c.uint ---

/*
void hb_map_update (hb_map_t *map, const hb_map_t *other);

Add the contents of other to map .

- a_map		A map
- other		Another map

Since: 7.0.0
*/
map_update :: proc (a_map: ^map_t, other: /*const*/ ^map_t)	---

/*
hb_bool_t hb_map_next (const hb_map_t *map, int *idx, hb_codepoint_t *key, hb_codepoint_t *value);

Fetches the next key/value pair in map .

Set idx to -1 to get started.

If the map is modified during iteration, the behavior is undefined.

The order in which the key/values are returned is undefined.

- a_map		A map
- idx		Iterator internal state. [inout]
- key		Key retrieved. [out]
- value		Value retrieved. [out]
- Returns	true if there was a next value, false otherwise

Since: 7.0.0
*/
map_next :: proc (a_map: /*const*/ ^map_t, idx: ^c.int, key: ^codepoint_t, value: ^codepoint_t)	-> bool_t ---

/*
void hb_map_keys (const hb_map_t *map, hb_set_t *keys);

Add the keys of map to keys.

- a_map		A map
- keys		A set

Since: 7.0.0
*/
map_keys :: proc (a_map: /*const*/ ^map_t, keys: ^set_t)	---

/*
void hb_map_values (const hb_map_t *map, hb_set_t *values);

Add the values of map to values .

- a_map		A map
- values	A set

Since: 7.0.0
*/
map_values :: proc (a_map: /*const*/ ^map_t, values: ^set_t)	---

}
