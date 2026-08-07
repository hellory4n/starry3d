/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

draw.odin - Types and functions for managing drawing operations.

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
author: Maurizio M. Gavioli, 2024-08-07

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-draw.h
		https://harfbuzz.github.io/harfbuzz-hb-draw.html
*/

/*
hb-draw — Glyph drawing

Functions for drawing (extracting) glyph shapes.

The hb_draw_funcs_t struct can be used with hb_font_draw_glyph().
*/

package harfbuzz

import "core:c"

// TODO : check Windows library name
when ODIN_OS == .Windows	{	foreign import hb "windows/harfbuzz.lib"	}
else when ODIN_OS == .Linux	{	foreign import hb "system:harfbuzz"	}

//******************
// TYPES
//******************

/*
typedef struct hb_draw_funcs_t hb_draw_funcs_t;

Glyph draw callbacks.

hb_draw_move_to_func_t, hb_draw_line_to_func_t and hb_draw_cubic_to_func_t calls are necessary to be defined but we
translate hb_draw_quadratic_to_func_t calls to hb_draw_cubic_to_func_t if the callback isn't defined.

Since: 4.0.0
*/
draw_funcs_t :: struct  {}			// opaque structure; use the various `draw_funcs_...()` procedures to manage it.

/*
typedef struct {
  hb_bool_t path_open;		// Whether there is an open path
  float path_start_x;		// X component of the start of current path
  float path_start_y;		// Y component of the start of current path
  float current_x;			// X component of current point
  float current_y;			// Y component of current point
} hb_draw_state_t;

Current drawing state.

Since: 4.0.0
*/
draw_state_t :: struct #packed
{
	path_open:		bool_t,		// Whether there is an open path
	path_start_x:	c.float,	// X component of the start of current path
	path_start_y:	c.float,	// Y component of the start of current path
	current_x:		c.float,	// X component of current point
	current_y:		c.float,	// Y component of current point
}

/*
#define HB_DRAW_STATE_DEFAULT {0, 0.f, 0.f, 0.f, 0.f, {0.}, {0.}, {0.}}

The default hb_draw_state_t at the start of glyph drawing.
*/
//DRAW_STATE_DEFAULT : draw_state_t : {0, 0.f, 0.f, 0.f, 0.f, {0.}, {0.}, {0.}}

/*
void (*hb_draw_move_to_func_t) (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st, float to_x, float to_y, void *user_data);

A virtual method for the hb_draw_funcs_t to perform a "move-to" draw operation.

- dfuncs	draw functions object
- draw_data	The data accompanying the draw functions in hb_font_draw_glyph()
- st		current draw state
- to_x		X component of target point
- to_y		Y component of target point
- user_data	User data pointer passed to hb_draw_funcs_set_move_to_func()

Since: 4.0.0
*/
draw_move_to_func_t :: #type proc "c"(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t, to_x: c.float, to_y: c.float, user_data: rawptr)

/*
void (*hb_draw_line_to_func_t) (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st, float to_x, float to_y, void *user_data);

A virtual method for the hb_draw_funcs_t to perform a "line-to" draw operation.

- dfuncs	draw functions object
- draw_data	The data accompanying the draw functions in hb_font_draw_glyph()
- st		current draw state
- to_x		X component of target point
- to_y		Y component of target point
- user_dataUser data pointer passed to hb_draw_funcs_set_line_to_func()

Since: 4.0.0
*/
draw_line_to_func_t :: #type proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t, to_x: c.float, to_y: c.float, user_data: rawptr)

/*
void (*hb_draw_quadratic_to_func_t) (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st,
	float control_x, float control_y, float to_x, float to_y, void *user_data);

A virtual method for the hb_draw_funcs_t to perform a "quadratic-to" draw operation.

- dfuncs	draw functions object
- draw_data	The data accompanying the draw functions in hb_font_draw_glyph()
- st		current draw state
- control_x	X component of control point
- control_y	Y component of control point
- to_x		X component of target point
- to_y		Y component of target point
- user_data	User data pointer passed to hb_draw_funcs_set_quadratic_to_func()

Since: 4.0.0
*/
draw_quadratic_to_func_t :: #type proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t,
	control_x: c.float, control_y: c.float, to_x: c.float, to_y: c.float, user_data: rawptr)

/*
void (*hb_draw_cubic_to_func_t) (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st, float control1_x, float control1_y,
	float control2_x, float control2_y, float to_x, float to_y, void *user_data);

A virtual method for the hb_draw_funcs_t to perform a "cubic-to" draw operation.

- dfuncs		draw functions object
- draw_data		The data accompanying the draw functions in hb_font_draw_glyph()
- st			current draw state
- control1_x	X component of first control point
- control1_y	Y component of first control point
- control2_x	X component of second control point
- control2_y	Y component of second control point
- to_x			X component of target point
- to_y			Y component of target point
- user_data		User data pointer passed to hb_draw_funcs_set_cubic_to_func()

Since: 4.0.0
*/
draw_cubic_to_func_t :: #type proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t, control1_x: c.float, control1_y: c.float,
	control2_x: c.float, control2_y: c.float, to_x: c.float, to_y: c.float, user_data: rawptr)

/*
void (*hb_draw_close_path_func_t) (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st, void *user_data);

A virtual method for the hb_draw_funcs_t to perform a "close-path" draw operation.

- dfuncs	draw functions object
- draw_data	The data accompanying the draw functions in hb_font_draw_glyph()
- st		current draw state
- user_data	User data pointer passed to hb_draw_funcs_set_close_path_func()

Since: 4.0.0
*/
draw_close_path_func_t :: #type proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t, user_data: rawptr)

//******************
// FUNCTIONS
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
hb_draw_funcs_t * hb_draw_funcs_create (void);

Creates a new draw callbacks object.

- Returns		A newly allocated hb_draw_funcs_t with a reference count of 1. The initial reference count should be
				released with hb_draw_funcs_destroy when you are done using the hb_draw_funcs_t. This function never
				returns NULL. If memory cannot be allocated, a special singleton hb_draw_funcs_t object will be returned. [transfer full]

Since: 4.0.0
*/
draw_funcs_create :: proc()	-> ^draw_funcs_t ---

/*
hb_draw_funcs_t * hb_draw_funcs_get_empty (void);

Fetches the singleton empty draw-functions structure.

- Returns		The empty draw-functions structure. [transfer full]

Since: 7.0.0
*/
draw_funcs_get_empty :: proc()	-> ^draw_funcs_t ---

/*
hb_draw_funcs_t * hb_draw_funcs_reference (hb_draw_funcs_t *dfuncs);

Increases the reference count on dfuncs by one.

This prevents dfuncs from being destroyed until a matching call to hb_draw_funcs_destroy() is made.

- dfuncs	draw functions
- Returns	The referenced hb_draw_funcs_t. [transfer full]

Since: 4.0.0
*/
draw_funcs_reference :: proc(dfuncs: ^draw_funcs_t)	-> ^draw_funcs_t ---

/*
void hb_draw_funcs_destroy (hb_draw_funcs_t *dfuncs);

Deallocate the dfuncs . Decreases the reference count on dfuncs by one. If the result is zero,
then dfuncs and all associated resources are freed. See hb_draw_funcs_reference().

- dfuncs	draw functions

Since: 4.0.0
*/
draw_funcs_destroy :: proc(dfuncs: ^draw_funcs_t)	---

/*
hb_bool_t hb_draw_funcs_set_user_data (hb_draw_funcs_t *dfuncs, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified draw-functions structure.

- dfuncs	The draw-functions structure
- key		The user-data key
- data		A pointer to the user data
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 7.0.0
*/
draw_funcs_set_user_data :: proc(dfuncs: ^draw_funcs_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_draw_funcs_get_user_data (const hb_draw_funcs_t *dfuncs, hb_user_data_key_t *key);

Fetches the user-data associated with the specified key, attached to the specified draw-functions structure.

- dfuncs	The draw-functions structure
- key		The user-data key to query
- Returns	A pointer to the user data. [transfer none]

Since: 7.0.0
*/
draw_funcs_get_user_data :: proc(dfuncs: /*const*/ ^draw_funcs_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_draw_funcs_make_immutable (hb_draw_funcs_t *dfuncs);

Makes dfuncs object immutable.

- dfuncs	draw functions

Since: 4.0.0
*/
draw_funcs_make_immutable :: proc(dfuncs: ^draw_funcs_t)	---

/*
hb_bool_t hb_draw_funcs_is_immutable (hb_draw_funcs_t *dfuncs);

Checks whether dfuncs is immutable.

- dfuncs	draw functions
- Returns	true if dfuncs is immutable, false otherwise

Since: 4.0.0
*/
draw_funcs_is_immutable :: proc(dfuncs: ^draw_funcs_t)	-> bool_t ---

/*
void hb_draw_funcs_set_move_to_func (hb_draw_funcs_t *dfuncs, hb_draw_move_to_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets move-to callback to the draw functions object.

- dfuncs	draw functions object
- func		move-to callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 4.0.0
*/
draw_funcs_set_move_to_func :: proc(dfuncs: ^draw_funcs_t, func: draw_move_to_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_draw_funcs_set_line_to_func (hb_draw_funcs_t *dfuncs, hb_draw_line_to_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets line-to callback to the draw functions object.

- dfuncs	draw functions object
- func		line-to callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. 	[nullable]

Since: 4.0.0
*/
draw_funcs_set_line_to_func :: proc(dfuncs: ^draw_funcs_t, func: draw_line_to_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_draw_funcs_set_quadratic_to_func (hb_draw_funcs_t *dfuncs, hb_draw_quadratic_to_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets quadratic-to callback to the draw functions object.

- dfuncs	draw functions object
- func		quadratic-to callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 4.0.0
*/
draw_funcs_set_quadratic_to_func :: proc(dfuncs: ^draw_funcs_t, func: draw_quadratic_to_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_draw_funcs_set_cubic_to_func (hb_draw_funcs_t *dfuncs, hb_draw_cubic_to_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets cubic-to callback to the draw functions object.

- dfuncs	draw functions
- func		cubic-to callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 4.0.0
*/
draw_funcs_set_cubic_to_func ::proc(dfuncs: ^draw_funcs_t, func: draw_cubic_to_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_draw_funcs_set_close_path_func (hb_draw_funcs_t *dfuncs, hb_draw_close_path_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets close-path callback to the draw functions object.

- dfuncs	draw functions object
- func		close-path callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	The function to call when user_data is not needed anymore. [nullable]

Since: 4.0.0
*/
draw_funcs_set_close_path_func :: proc(dfuncs: ^draw_funcs_t, func: draw_close_path_func_t, user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_draw_move_to (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st, float to_x, float to_y);

Perform a "move-to" draw operation.

- dfuncs	draw functions
- draw_data	associated draw data passed by the caller
- st		current draw state
- to_x		X component of target point
- to_y		Y component of target point

Since: 4.0.0
*/
draw_move_to :: proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t, to_x: c.float, to_y: c.float)	---

/*
void hb_draw_line_to (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st, float to_x, float to_y);

Perform a "line-to" draw operation.

- dfuncs	draw functions
- draw_data	associated draw data passed by the caller
- st		current draw state
- to_x		X component of target point
- to_y		Y component of target point

Since: 4.0.0
*/
draw_line_to ::proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t, to_x: c.float, to_y: c.float)	---

/*
void hb_draw_quadratic_to (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st,
	float control_x, float control_y, float to_x, float to_y);

Perform a "quadratic-to" draw operation.

- dfuncs	draw functions
- draw_data	associated draw data passed by the caller
- st		current draw state
- control_x	X component of control point
- control_y	Y component of control point
- to_x		X component of target point
- to_y		Y component of target point

Since: 4.0.0
*/
draw_quadratic_to :: proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t,
	control_x: c.float, control_y: c.float, to_x: c.float, to_y: c.float)	---

/*
void hb_draw_cubic_to (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st, float control1_x, float control1_y, float control2_x, float control2_y, float to_x, float to_y);

Perform a "cubic-to" draw operation.

- dfuncs		draw functions
- draw_data		associated draw data passed by the caller
- st			current draw state
- control1_x	X component of first control point
- control1_y	Y component of first control point
- control2_x	X component of second control point
- control2_y	Y component of second control point
- to_x			X component of target point
- to_y			Y component of target point

Since: 4.0.0
*/
draw_cubic_to :: proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t, control1_x: c.float, control1_y: c.float,
	control2_x: c.float, control2_y: c.float, to_x: c.float, to_y: c.float)	---

/*
void hb_draw_close_path (hb_draw_funcs_t *dfuncs, void *draw_data, hb_draw_state_t *st);

Perform a "close-path" draw operation.

- dfuncs	draw functions
- draw_data	associated draw data passed by the caller
- st		current draw state

Since: 4.0.0
*/
draw_close_path :: proc(dfuncs: ^draw_funcs_t, draw_data: rawptr, st: ^draw_state_t)	---

}
