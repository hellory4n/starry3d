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

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-shape-plan.h
		https://harfbuzz.github.io/harfbuzz-hb-shape-plan.html
*/

/*
hb-shape-plan — Object representing a shaping plan

Shape plans are an internal mechanism. Each plan contains state describing how HarfBuzz will shape a particular text
* segment, based on the combination of segment properties and the capabilities in the font face in use.

Shape plans are not used for shaping directly, but can be queried to access certain information about how shaping will
* perform, given a set of specific input parameters (script, language, direction, features, etc.).

Most client programs will not need to deal with shape plans directly.
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
typedef struct hb_shape_plan_t hb_shape_plan_t;

Data type for holding a shaping plan.

Shape plans contain information about how HarfBuzz will shape a particular text segment, based on the segment's properties
and the capabilities in the font face in use.

Shape plans can be queried about how shaping will perform, given a set of specific input parameters (script, language,
direction, features, etc.).
*/
shape_plan_t :: struct {}					// opaque structure

//******************
// FUNCTIONS */
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
hb_shape_plan_t * hb_shape_plan_create (hb_face_t *face, const hb_segment_properties_t *props,
	const hb_feature_t *user_features, unsigned int num_user_features, const char * const *shaper_list);

Constructs a shaping plan for a combination of face, user_features, props, and shaper_list.

- face				hb_face_t to use
- props				The hb_segment_properties_t of the segment
- user_features		The list of user-selected features. [array length=num_user_features]
- num_user_features	The number of user-selected features
- shaper_list		List of shapers to try. [array zero-terminated=1]
- Returns			The shaping plan. [transfer full]

Since: 0.9.7
*/
shape_plan_create :: proc (face: ^face_t, props: /*const*/ ^segment_properties_t,
	user_features: /*const*/ ^feature_t, num_user_features: c.uint, shaper_list: /*const*/ ^cstring)	-> ^shape_plan_t ---

/*
hb_shape_plan_t * hb_shape_plan_create_cached (hb_face_t *face, const hb_segment_properties_t *props,
	const hb_feature_t *user_features, unsigned int num_user_features, const char * const *shaper_list);

Creates a cached shaping plan suitable for reuse, for a combination of face , user_features , props , and shaper_list .

- face				hb_face_t to use
- props				The hb_segment_properties_t of the segment
- user_features		The list of user-selected features. [array length=num_user_features]
- num_user_features	The number of user-selected features
- shaper_list		List of shapers to try. [array zero-terminated=1]
- Returns			The shaping plan. [transfer full]

Since: 0.9.7
*/
shape_plan_create_cached :: proc (face: ^face_t, props: /*const*/ ^segment_properties_t,
	user_features: /*const*/ ^feature_t, num_user_features: c.uint, shaper_list: /*const*/ ^cstring)	-> ^shape_plan_t ---

/*
hb_shape_plan_t * hb_shape_plan_create2 (hb_face_t *face, const hb_segment_properties_t *props,
	const hb_feature_t *user_features, unsigned int num_user_features, const int *coords,
	unsigned int num_coords, const char * const *shaper_list);

The variable-font version of hb_shape_plan_create. Constructs a shaping plan for a combination of face , user_features , props , and shaper_list , plus the variation-space coordinates coords .

- face				hb_face_t to use
- props				The hb_segment_properties_t of the segment
- user_features		The list of user-selected features. [array length=num_user_features]
- num_user_features	The number of user-selected features
- coords			The list of variation-space coordinates. [array length=num_coords]
- num_coords		The number of variation-space coordinates
- shaper_list		List of shapers to try. [array zero-terminated=1]
- Returns			The shaping plan. [transfer full]

Since: 1.4.0
*/
shape_plan_create2 :: proc (face: ^face_t, props: /*const*/ ^segment_properties_t, user_features: /*const*/ ^feature_t,
	num_user_features: c.uint, coords: /*const*/ ^c.int, num_coords: c.uint, shaper_list: /*const*/ ^cstring)	-> ^shape_plan_t ---

/*
hb_shape_plan_t * hb_shape_plan_create_cached2 (hb_face_t *face, const hb_segment_properties_t *props,
	const hb_feature_t *user_features, unsigned int num_user_features, const int *coords,
	unsigned int num_coords, const char * const *shaper_list);

The variable-font version of hb_shape_plan_create_cached. Creates a cached shaping plan suitable for reuse, for a
combination of face, user_features, props, and shaper_list, plus the variation-space coordinates coords.

- face				hb_face_t to use
- props				The hb_segment_properties_t of the segment
- user_features		The list of user-selected features. [array length=num_user_features]
- num_user_features	The number of user-selected features
- coords			The list of variation-space coordinates. [array length=num_coords]
- num_coords		The number of variation-space coordinates
- shaper_list		List of shapers to try. [array zero-terminated=1]
- Returns			The shaping plan. [transfer full]

Since: 1.4.0
*/
shape_plan_create_cached2 :: proc (face: ^face_t, props: /*const*/ ^segment_properties_t, user_features: /*const*/ ^feature_t,
	num_user_features: c.uint, coords: /*const*/ ^c.int, num_coords: c.uint, shaper_list: /*const*/ ^cstring)	-> ^shape_plan_t ---

/*
hb_shape_plan_t * hb_shape_plan_get_empty (void);

Fetches the singleton empty shaping plan.

- Returns	The empty shaping plan. [transfer full]

Since: 0.9.7
*/
shape_plan_get_empty :: proc ()	-> ^shape_plan_t ---

/*
hb_shape_plan_t * hb_shape_plan_reference (hb_shape_plan_t *shape_plan);

Increases the reference count on the given shaping plan.

- shape_plan	A shaping plan
- Returns		shape_plan. [transfer full]

Since: 0.9.7
*/
shape_plan_reference :: proc (shape_plan: ^shape_plan_t)	-> ^shape_plan_t ---

/*
void hb_shape_plan_destroy (hb_shape_plan_t *shape_plan);

Decreases the reference count on the given shaping plan. When the reference count reaches zero, the shaping plan is
destroyed, freeing all memory.

- shape_plan	A shaping plan

Since: 0.9.7
*/
shape_plan_destroy :: proc (shape_plan: ^shape_plan_t)	---

/*
hb_bool_t hb_shape_plan_set_user_data (hb_shape_plan_t *shape_plan, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the given shaping plan.

- shape_plan	A shaping plan
- key			The user-data key to set
- data			A pointer to the user data
- destroy		A callback to call when data is not needed anymore. [nullable]
- replace		Whether to replace an existing data with the same key
- Returns		true if success, false otherwise.

Since: 0.9.7
*/
shape_plan_set_user_data :: proc (shape_plan: ^shape_plan_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t,
	replace: bool_t)	-> bool_t ---

/*
void * hb_shape_plan_get_user_data (const hb_shape_plan_t *shape_plan, hb_user_data_key_t *key);

Fetches the user data associated with the specified key, attached to the specified shaping plan.

- shape_plan	A shaping plan
- key			The user-data key to query
- Returns		A pointer to the user data. [transfer none]

Since: 0.9.7
*/
hb_shape_plan_get_user_data :: proc (shape_plan: /*const*/ ^shape_plan_t, key: ^user_data_key_t)	-> rawptr ---

/*
hb_bool_t hb_shape_plan_execute (hb_shape_plan_t *shape_plan, hb_font_t *font, hb_buffer_t *buffer, const hb_feature_t *features, unsigned int num_features);

Executes the given shaping plan on the specified buffer, using the given font and features .

- shape_plan	A shaping plan
- font			The hb_font_t to use
- buffer		The hb_buffer_t to work upon
- features		Features to enable. [array length=num_features]
- num_features	The number of features to enable
- Returns		true if success, false otherwise.

Since: 0.9.7
*/
shape_plan_execute :: proc (shape_plan: ^shape_plan_t, font: ^font_t, buffer: ^buffer_t, features: /*const*/ ^feature_t,
	num_features: c.uint)	-> bool_t ---

/*
const char * hb_shape_plan_get_shaper (hb_shape_plan_t *shape_plan);

Fetches the shaper from a given shaping plan.

- shape_plan	A shaping plan
- Returns		The shaper. [transfer none]

Since: 0.9.7
*/
shape_plan_get_shaper :: proc (shape_plan: ^shape_plan_t)	-> cstring ---

}
