/*
H a r f b u z z  b i n d i n g s  - An Odin package with bindings to Harfbuzz.

paint.odin - Types and functions for managing painting operations.

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
author: Maurizio M. Gavioli, 2024-08-08

HARFBUZZ LICENSE

HarfBuzz itself is licensed under the so-called "Old MIT" license.
For up-to-date details, see https://github.com/harfbuzz/harfbuzz?tab=License-1-ov-file

From:	https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-paint.h
		https://harfbuzz.github.io/harfbuzz-hb-paint.html
*/

/*
hb-paint — Glyph painting

Description

Functions for painting glyphs.

The main purpose of these functions is to paint (extract) color glyph layers from the COLRv1 table,
but the API works for drawing ordinary outlines and images as well.

The hb_paint_funcs_t struct can be used with hb_font_paint_glyph().
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
typedef struct hb_paint_funcs_t hb_paint_funcs_t;

Glyph paint callbacks.

The callbacks assume that the caller maintains a stack of current transforms, clips and intermediate surfaces, as
evidenced by the pairs of push/pop callbacks. The push/pop calls will be properly nested, so it is fine to store the
different kinds of object on a single stack.

Not all callbacks are required for all kinds of glyphs. For rendering COLRv0 or non-color outline glyphs, the gradient
callbacks are not needed, and the composite callback only needs to handle simple alpha compositing
(HB_PAINT_COMPOSITE_MODE_SRC_OVER).

The paint-image callback is only needed for glyphs with image blobs in the CBDT, sbix or SVG tables.

The custom-palette-color callback is only necessary if you want to override colors from the font palette with custom colors.

Since: 7.0.0
*/
paint_funcs_t :: struct  {}					// opaque structure, use the `paint_funcs_...` procedures to access and manage it

/*
#define HB_PAINT_IMAGE_FORMAT_PNG HB_TAG('p','n','g',' ')

Tag identifying PNG images in hb_paint_image_func_t callbacks.

Since: 7.0.0
*/
PAINT_IMAGE_FORMAT_PNG	: tag_t = ('p' << 24) | ('n' << 16) | ('g' << 8) | ' '

/*
#define HB_PAINT_IMAGE_FORMAT_SVG HB_TAG('s','v','g',' ')

Tag identifying SVG images in hb_paint_image_func_t callbacks.

Since: 7.0.0
*/
PAINT_IMAGE_FORMAT_SVG	: tag_t = ('s' << 24) | ('v' << 16) | ('g' << 8) | ' '

/*
#define HB_PAINT_IMAGE_FORMAT_BGRA HB_TAG('B','G','R','A')

Tag identifying raw pixel-data images in hb_paint_image_func_t callbacks. The data is in BGRA pre-multiplied sRGBA color-space format.

Since: 7.0.0
*/
PAINT_IMAGE_FORMAT_BGRA	: tag_t = ('B' << 24) | ('G' << 16) | ('R' << 8) | 'A'

/*
typedef struct hb_color_line_t hb_color_line_t;

A struct containing color information for a gradient.

AS defined in hb-paint.h:

struct hb_color_line_t {
  void *data;

  hb_color_line_get_color_stops_func_t get_color_stops;
  void *get_color_stops_user_data;

  void *reserved0;
  void *reserved1;
  void *reserved2;
  void *reserved3;
  void *reserved5;
  void *reserved6;
  void *reserved7;
  void *reserved8;
};

Since: 7.0.0
*/
color_line_t :: struct {}					// opaque structure; `https://github.com/harfbuzz/harfbuzz/blob/main/src/hb-paint.h` has more details, presumably for harfbuzz own internal use.

/*
typedef struct {
  float offset;				// the offset of the color stop
  hb_bool_t is_foreground;	// whether the color is the foreground
  hb_color_t color;			// the color, unpremultiplied
} hb_color_stop_t;

Information about a color stop on a color line.

Color lines typically have offsets ranging between 0 and 1, but that is not required.

Note: despite color being unpremultiplied here, interpolation in gradients shall happen in premultiplied space. See the
OpenType spec COLR section for details.

Since: 7.0.0
*/
color_stop_t :: struct #packed
{
	offset:			c.float,
	is_foreground:	bool_t,
	color:			color_t
}

/*
typedef enum {
  HB_PAINT_EXTEND_PAD,		// Outside the defined interval, the color of the closest color stop is used.
  HB_PAINT_EXTEND_REPEAT,	// The color line is repeated over repeated multiples of the defined interval
  HB_PAINT_EXTEND_REFLECT	// The color line is repeated over repeated intervals, as for the repeat mode. However, in each repeated interval, the ordering of color stops is the reverse of the adjacent interval.
} hb_paint_extend_t;


The values of this enumeration determine how color values outside the minimum and maximum defined offset on a hb_color_line_t are determined.

See the OpenType spec COLR section for details.

Since: 7.0.0
*/
paint_extend_t :: enum
{
	PAINT_EXTEND_PAD,		// Outside the defined interval, the color of the closest color stop is used.
	PAINT_EXTEND_REPEAT,	// The color line is repeated over repeated multiples of the defined interval
	PAINT_EXTEND_REFLECT	// The color line is repeated over repeated intervals, as for the repeat mode. However, in each repeated interval, the ordering of color stops is the reverse of the adjacent interval.
}

/*
enum hb_paint_composite_mode_t

The values of this enumeration describe the compositing modes that can be used when combining temporary redirected drawing with the backdrop.

See the OpenType spec COLR section for details.
Since: 7.0.0
*/
paint_composite_mode_t :: enum
{
	PAINT_COMPOSITE_MODE_CLEAR,				// clear destination layer (bounded)
	PAINT_COMPOSITE_MODE_SRC,				// replace destination layer (bounded)
	PAINT_COMPOSITE_MODE_DEST,				// ignore the source
	PAINT_COMPOSITE_MODE_SRC_OVER,			// draw source layer on top of destination layer (bounded)
	PAINT_COMPOSITE_MODE_DEST_OVER,			// draw destination on top of source
	PAINT_COMPOSITE_MODE_SRC_IN,			// draw source where there was destination content (unbounded)
	PAINT_COMPOSITE_MODE_DEST_IN,			// leave destination only where there was source content (unbounded)
	PAINT_COMPOSITE_MODE_SRC_OUT,			// draw source where there was no destination content (unbounded)
	PAINT_COMPOSITE_MODE_DEST_OUT,			// leave destination only where there was no source content
	PAINT_COMPOSITE_MODE_SRC_ATOP,			// draw source on top of destination content and only there
	PAINT_COMPOSITE_MODE_DEST_ATOP,			// leave destination on top of source content and only there (unbounded)
	PAINT_COMPOSITE_MODE_XOR,				// source and destination are shown where there is only one of them
	PAINT_COMPOSITE_MODE_PLUS,				// source and destination layers are accumulated
	PAINT_COMPOSITE_MODE_SCREEN,			// source and destination are complemented and multiplied. This causes the result to be at least as light as the lighter inputs.
	PAINT_COMPOSITE_MODE_OVERLAY,			// multiplies or screens, depending on the lightness of the destination color.
	PAINT_COMPOSITE_MODE_DARKEN,			// replaces the destination with the source if it is darker, otherwise keeps the source.
	PAINT_COMPOSITE_MODE_LIGHTEN,			// replaces the destination with the source if it is lighter, otherwise keeps the source.
	PAINT_COMPOSITE_MODE_COLOR_DODGE,		// brightens the destination color to reflect the source color.
	PAINT_COMPOSITE_MODE_COLOR_BURN,		// darkens the destination color to reflect the source color.
	PAINT_COMPOSITE_MODE_HARD_LIGHT,		// Multiplies or screens, dependent on source color.
	PAINT_COMPOSITE_MODE_SOFT_LIGHT,		// Darkens or lightens, dependent on source color.
	PAINT_COMPOSITE_MODE_DIFFERENCE,		// Takes the difference of the source and destination color.
	PAINT_COMPOSITE_MODE_EXCLUSION,			// Produces an effect similar to difference, but with lower contrast.
	PAINT_COMPOSITE_MODE_MULTIPLY,			// source and destination layers are multiplied. This causes the result to be at least as dark as the darker inputs.
	PAINT_COMPOSITE_MODE_HSL_HUE,			// Creates a color with the hue of the source and the saturation and luminosity of the target.
	PAINT_COMPOSITE_MODE_HSL_SATURATION,	// Creates a color with the saturation of the source and the hue and luminosity of the target. Painting with this mode onto a gray area produces no change.
	PAINT_COMPOSITE_MODE_HSL_COLOR,			// Creates a color with the hue and saturation of the source and the luminosity of the target. This preserves the gray levels of the target and is useful for coloring monochrome images or tinting color images.
	PAINT_COMPOSITE_MODE_HSL_LUMINOSITY		// Creates a color with the luminosity of the source and the hue and saturation of the target. This produces an inverse effect to HB_PAINT_COMPOSITE_MODE_HSL_COLOR .
}

/*
void (*hb_paint_push_transform_func_t) (hb_paint_funcs_t *funcs, void *paint_data, float xx, float yx, float xy, float yy, float dx, float dy, void *user_data);

A virtual method for the hb_paint_funcs_t to apply a transform to subsequent paint calls.

This transform is applied after the current transform, and remains in effect until a matching call to the hb_paint_funcs_pop_transform_func_t vfunc.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- xx			xx component of the transform matrix
- yx			yx component of the transform matrix
- xy			xy component of the transform matrix
- yy			yy component of the transform matrix
- dx			dx component of the transform matrix
- dy			dy component of the transform matrix
- user_data		User data pointer passed to hb_paint_funcs_set_push_transform_func()

Since: 7.0.0
*/
paint_push_transform_func_t :: #type proc "c"(funcs: ^paint_funcs_t, paint_data: rawptr, xx: c.float,  yx: c.float,
	xy: c.float, yy: c.float, dx: c.float, dy: c.float, user_data: rawptr)

/*
void (*hb_paint_pop_transform_func_t) (hb_paint_funcs_t *funcs, void *paint_data, void *user_data);

A virtual method for the hb_paint_funcs_t to undo the effect of a prior call to the hb_paint_funcs_push_transform_func_t vfunc.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- user_data		User data pointer passed to hb_paint_funcs_set_pop_transform_func()

Since: 7.0.0
*/
paint_pop_transform_func_t :: #type proc "c"(funcs: ^paint_funcs_t, paint_data: rawptr, user_data: rawptr)

/*
hb_bool_t (*hb_paint_color_glyph_func_t) (hb_paint_funcs_t *funcs, void *paint_data, hb_codepoint_t glyph, hb_font_t *font, void *user_data);

A virtual method for the hb_paint_funcs_t to render a color glyph by glyph index.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- glyph			the glyph ID
- font			the font
- user_data		User data pointer passed to hb_paint_funcs_set_color_glyph_func()
- Returns		true if the glyph was painted, false otherwise.

Since: 8.2.0
*/
paint_color_glyph_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, glyph: codepoint_t, font: ^font_t, user_data: rawptr)	-> bool_t

/*
void (*hb_paint_push_clip_glyph_func_t) (hb_paint_funcs_t *funcs, void *paint_data,
	hb_codepoint_t glyph, hb_font_t *font, void *user_data);

A virtual method for the hb_paint_funcs_t to clip subsequent paint calls to the outline of a glyph.

The coordinates of the glyph outline are interpreted according to the current transform.

This clip is applied in addition to the current clip, and remains in effect until a matching call to the
hb_paint_funcs_pop_clip_func_t vfunc.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- glyph			the glyph ID
- font			the font
- user_data		User data pointer passed to hb_paint_funcs_set_push_clip_glyph_func()

Since: 7.0.0
*/
paint_push_clip_glyph_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr,
	glyph: codepoint_t, font: ^font_t, user_data: rawptr)

/*
void (*hb_paint_push_clip_rectangle_func_t) (hb_paint_funcs_t *funcs, void *paint_data,
	float xmin, float ymin, float xmax, float ymax, void *user_data);

A virtual method for the hb_paint_funcs_t to clip subsequent paint calls to a rectangle.

The coordinates of the rectangle are interpreted according to the current transform.

This clip is applied in addition to the current clip, and remains in effect until a matching call to the
hb_paint_funcs_pop_clip_func_t vfunc.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- xmin			min X for the rectangle
- ymin			min Y for the rectangle
- xmax			max X for the rectangle
- ymax			max Y for the rectangle
- user_data		User data pointer passed to hb_paint_funcs_set_push_clip_rectangle_func()

Since: 7.0.0
*/
paint_push_clip_rectangle_func_t :: #type proc "c"(funcs: ^paint_funcs_t, paint_data: rawptr,
	xmin: c.float,  ymin: c.float, xmax: c.float, ymax: c.float, user_data: rawptr)

/*
void (*hb_paint_pop_clip_func_t) (hb_paint_funcs_t *funcs, void *paint_data, void *user_data);

A virtual method for the hb_paint_funcs_t to undo the effect of a prior call to the hb_paint_funcs_push_clip_glyph_func_t
or hb_paint_funcs_push_clip_rectangle_func_t vfuncs.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- user_data		User data pointer passed to hb_paint_funcs_set_pop_clip_func()

Since: 7.0.0
*/
paint_pop_clip_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, user_data: rawptr)

/*
void (*hb_paint_color_func_t) (hb_paint_funcs_t *funcs, void *paint_data, hb_bool_t is_foreground, hb_color_t color, void *user_data);

A virtual method for the hb_paint_funcs_t to paint a color everywhere within the current clip.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- is_foreground	whether the color is the foreground
- color			The color to use, unpremultiplied
- user_data		User data pointer passed to hb_paint_funcs_set_color_func()

Since: 7.0.0
*/
paint_color_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, is_foreground: bool_t, color: color_t,  user_data: rawptr)

/*
hb_bool_t (*hb_paint_image_func_t) (hb_paint_funcs_t *funcs, void *paint_data, hb_blob_t *image, unsigned int width,
	unsigned int height, hb_tag_t format, float slant, hb_glyph_extents_t *extents, void *user_data);

A virtual method for the hb_paint_funcs_t to paint a glyph image.

This method is called for glyphs with image blobs in the CBDT, sbix or SVG tables. The format identifies the kind of data
that is contained in image. Possible values include HB_PAINT_IMAGE_FORMAT_PNG, HB_PAINT_IMAGE_FORMAT_SVG and
HB_PAINT_IMAGE_FORMAT_BGRA.

The image dimensions and glyph extents are provided if available, and should be used to size and position the image.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- image			the image data
- width			width of the raster image in pixels, or 0
- height		height of the raster image in pixels, or 0
- format		the image format as a tag
- slant			the synthetic slant ratio to be applied to the image during rendering
- extents		glyph extents for desired rendering. [nullable]
- user_data		User data pointer passed to hb_paint_funcs_set_image_func()
- Returns		Whether the operation was successful.

Since: 7.0.0
*/
 paint_image_func_t  :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, image: ^blob_t, width: c.uint,
	height: c.uint, format: tag_t, slant: c.float, extents: ^glyph_extents_t, user_data: rawptr)	-> bool_t

/*
unsigned int (*hb_color_line_get_color_stops_func_t) (hb_color_line_t *color_line, void *color_line_data,
	unsigned int start, unsigned int *count, hb_color_stop_t *color_stops, void *user_data);

A virtual method for the hb_color_line_t to fetch color stops.

- color_line		a hb_color_line_t object
- color_line_data	the data accompanying color_line
- start				the index of the first color stop to return
- count				Input = the maximum number of feature tags to return; Output = the actual number of feature tags returned (may be zero). [inout][optional]
- color_stops		Array of hb_color_stop_t to populate. [out][array length=count][optional]
- user_data			the data accompanying this method
- Returns			the total number of color stops in color_line

Since: 7.0.0
*/
color_line_get_color_stops_func_t :: #type proc "c" (color_line: ^color_line_t, color_line_data: rawptr,
	start: c.uint, count: ^c.uint, color_stops: ^color_stop_t, user_data: rawptr)	-> c.uint

/*
hb_paint_extend_t (*hb_color_line_get_extend_func_t) (hb_color_line_t *color_line, void *color_line_data, void *user_data);

A virtual method for the hb_color_line_t to fetches the extend mode.

- color_linea 		hb_color_line_t object
- color_line_data	the data accompanying color_line
- user_data			the data accompanying this method
- Returns			the extend mode of color_line

Since: 7.0.0
*/
color_line_get_extend_func_t :: #type proc "c"(color_line: ^color_line_t, color_line_data: rawptr, user_data: rawptr)	-> paint_extend_t

/*
void (*hb_paint_linear_gradient_func_t) (hb_paint_funcs_t *funcs, void *paint_data, hb_color_line_t *color_line,
	float x0, float y0, float x1, float y1, float x2, float y2, void *user_data);

A virtual method for the hb_paint_funcs_t to paint a linear gradient everywhere within the current clip.

The color_line object contains information about the colors of the gradients. It is only valid for the duration of the
callback, you cannot keep it around.

The coordinates of the points are interpreted according to the current transform.

See the OpenType spec COLR section for details on how the points define the direction of the gradient, and how to
interpret the color_line.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- color_line	Color information for the gradient
- x0			X coordinate of the first point
- y0			Y coordinate of the first point
- x1			X coordinate of the second point
- y1			Y coordinate of the second point
- x2			X coordinate of the third point
- y2			Y coordinate of the third point
- user_data		User data pointer passed to hb_paint_funcs_set_linear_gradient_func()

Since: 7.0.0
*/
paint_linear_gradient_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, color_line: ^color_line_t,
	x0: c.float, y0: c.float, x1: c.float, y1: c.float, x2: c.float, y2: c.float, user_data: rawptr)

/*
void (*hb_paint_radial_gradient_func_t) (hb_paint_funcs_t *funcs, void *paint_data, hb_color_line_t *color_line,
	float x0, float y0, float r0, float x1, float y1, float r1, void *user_data);

A virtual method for the hb_paint_funcs_t to paint a radial gradient everywhere within the current clip.

The color_line object contains information about the colors of the gradients. It is only valid for the duration of the
callback, you cannot keep it around.

The coordinates of the points are interpreted according to the current transform.

See the OpenType spec COLR section for details on how the points define the direction of the gradient, and how to
interpret the color_line .

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- color_line	Color information for the gradient
- x0			X coordinate of the first circle's center
- y0			Y coordinate of the first circle's center
- r0			radius of the first circle
- x1			X coordinate of the second circle's center
- y1			Y coordinate of the second circle's center
- r1			radius of the second circle
- user_data		User data pointer passed to hb_paint_funcs_set_radial_gradient_func()

Since: 7.0.0
*/
paint_radial_gradient_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, color_line: ^color_line_t,
	x0: c.float, y0: c.float, r0: c.float, x1: c.float, y1: c.float, r1: c.float, user_data: rawptr)

/*
void (*hb_paint_sweep_gradient_func_t) (hb_paint_funcs_t *funcs, void *paint_data, hb_color_line_t *color_line,
	float x0, float y0, float start_angle, float end_angle, void *user_data);

A virtual method for the hb_paint_funcs_t to paint a sweep gradient everywhere within the current clip.

The color_line object contains information about the colors of the gradients. It is only valid for the duration of
the callback, you cannot keep it around.

The coordinates of the points are interpreted according to the current transform.

See the OpenType spec COLR section for details on how the points define the direction of the gradient, and how to
interpret the color_line.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- color_line	Color information for the gradient
- x0			X coordinate of the circle's center
- y0			Y coordinate of the circle's center
- start_angle	the start angle, in radians
- end_angle		the end angle, in radians
- user_data		User data pointer passed to hb_paint_funcs_set_sweep_gradient_func()

Since: 7.0.0
*/
paint_sweep_gradient_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, color_line: ^color_line_t,
	x0: c.float, y0: c.float, start_angle: c.float, end_angle: c.float, user_data: rawptr)

/*
void (*hb_paint_push_group_func_t) (hb_paint_funcs_t *funcs, void *paint_data, void *user_data);

A virtual method for the hb_paint_funcs_t to use an intermediate surface for subsequent paint calls.

The drawing will be redirected to an intermediate surface until a matching call to the hb_paint_funcs_pop_group_func_t vfunc.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- user_data		User data pointer passed to hb_paint_funcs_set_push_group_func()

Since: 7.0.0
*/
paint_push_group_func_t :: #type proc "c" (funcs:^paint_funcs_t, paint_data: rawptr, user_data: rawptr)

/*
void (*hb_paint_pop_group_func_t) (hb_paint_funcs_t *funcs, void *paint_data, hb_paint_composite_mode_t mode,. void *user_data);

A virtual method for the hb_paint_funcs_t to undo the effect of a prior call to the hb_paint_funcs_push_group_func_t vfunc.

This call stops the redirection to the intermediate surface, and then composites it on the previous surface, using the
compositing mode passed to this call.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- mode			the compositing mode to use
- user_data		User data pointer passed to hb_paint_funcs_set_pop_group_func()

Since: 7.0.0
*/
paint_pop_group_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, mode: paint_composite_mode_t, user_data: rawptr)

/*
hb_bool_t (*hb_paint_custom_palette_color_func_t) (hb_paint_funcs_t *funcs, void *paint_data, unsigned int color_index, hb_color_t *color, void *user_data);

A virtual method for the hb_paint_funcs_t to fetch a color from the custom color palette.

Custom palette colors override the colors from the fonts selected color palette. It is not necessary to override all
palette entries; for entries that should be taken from the font palette, return false.

This function might get called multiple times, but the custom palette is expected to remain unchanged for duration of a
hb_font_paint_glyph() call.

- funcs			paint functions object
- paint_data	The data accompanying the paint functions in hb_font_paint_glyph()
- color_index	the color index
- color			fetched color. [out]
- user_data		User data pointer passed to hb_paint_funcs_set_pop_group_func()
- Returns		true if found, false otherwise

Since: 7.0.0
*/
paint_custom_palette_color_func_t :: #type proc "c" (funcs: ^paint_funcs_t, paint_data: rawptr, color_index: c.uint,
	color: ^color_t, user_data: rawptr)	-> bool_t

//******************
// FUNCTIONS */
//******************

@(default_calling_convention = "c", link_prefix = "hb_") foreign hb
{

/*
hb_paint_funcs_t * hb_paint_funcs_create (void);

Creates a new hb_paint_funcs_t structure of paint functions.

The initial reference count of 1 should be released with hb_paint_funcs_destroy() when you are done using the
hb_paint_funcs_t. This function never returns NULL. If memory cannot be allocated, a special singleton hb_paint_funcs_t
object will be returned.

- Returns	the paint-functions structure [transfer full]

Since: 7.0.0
*/
paint_funcs_create :: proc()	-> ^paint_funcs_t ---

/*
hb_paint_funcs_t * hb_paint_funcs_get_empty (void);

Fetches the singleton empty paint-functions structure.
- Returns	The empty paint-functions structure. [transfer full]

Since: 7.0.0
*/
paint_funcs_get_empty :: proc()	-> ^paint_funcs_t ---

/*
hb_paint_funcs_t * hb_paint_funcs_reference (hb_paint_funcs_t *funcs);

Increases the reference count on a paint-functions structure.

This prevents funcs from being destroyed until a matching call to hb_paint_funcs_destroy() is made.

- funcs		The paint-functions structure
- Returns	The paint-functions structure

Since: 7.0.0
*/
paint_funcs_reference :: proc(funcs: ^paint_funcs_t)	-> ^paint_funcs_t ---

/*
void hb_paint_funcs_destroy (hb_paint_funcs_t *funcs);

Decreases the reference count on a paint-functions structure.

When the reference count reaches zero, the structure is destroyed, freeing all memory.

- funcs		The paint-functions structure

Since: 7.0.0
*/
paint_funcs_destroy :: proc(funcs: ^paint_funcs_t)	---

/*
hb_bool_t hb_paint_funcs_set_user_data (hb_paint_funcs_t *funcs, hb_user_data_key_t *key, void *data, hb_destroy_func_t destroy, hb_bool_t replace);

Attaches a user-data key/data pair to the specified paint-functions structure.

- funcs		The paint-functions structure
- key		The user-data key
- data		A pointer to the user data
- destroy	A callback to call when data is not needed anymore. [nullable]
- replace	Whether to replace an existing data with the same key
- Returns	true if success, false otherwise

Since: 7.0.0
*/
paint_funcs_set_user_data :: proc(funcs: ^paint_funcs_t, key: ^user_data_key_t, data: rawptr, destroy: destroy_func_t, replace: bool_t)	-> bool_t ---

/*
void * hb_paint_funcs_get_user_data (const hb_paint_funcs_t *funcs, hb_user_data_key_t *key);

Fetches the user-data associated with the specified key, attached to the specified paint-functions structure.

- funcs		The paint-functions structure
- key		The user-data key to query
- Returns	A pointer to the user data. [transfer none]

Since: 7.0.0
*/
paint_funcs_get_user_data :: proc(funcs: /*const*/ ^paint_funcs_t, key: ^user_data_key_t)	-> rawptr ---

/*
void hb_paint_funcs_make_immutable (hb_paint_funcs_t *funcs);

Makes a paint-functions structure immutable.

After this call, all attempts to set one of the callbacks on funcs will fail.

- funcs	The paint-functions structure

Since: 7.0.0
*/
paint_funcs_make_immutable ::proc(funcs: ^paint_funcs_t)	---

/*
hb_bool_t hb_paint_funcs_is_immutable (hb_paint_funcs_t *funcs);

Tests whether a paint-functions structure is immutable.

- funcs		The paint-functions structure
- Returns	true if funcs is immutable, false otherwise

Since: 7.0.0
*/
paint_funcs_is_immutable :: proc (funcs: ^paint_funcs_t)	-> bool_t ---

/*
void hb_paint_funcs_set_push_transform_func (hb_paint_funcs_t *funcs, hb_paint_push_transform_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the push-transform callback on the paint functions struct.

- funcs		A paint functions struct
- func		The push-transform callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_push_transform_func :: proc(funcs: ^paint_funcs_t, func: paint_push_transform_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_pop_transform_func (hb_paint_funcs_t *funcs, hb_paint_pop_transform_func_t func, void *user_data, hb_destroy_func_t destroy);

Sets the pop-transform callback on the paint functions struct.

- funcs		A paint functions struct
- func		The pop-transform callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_pop_transform_func ::proc(funcs: ^paint_funcs_t, func: paint_pop_transform_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_color_glyph_func (hb_paint_funcs_t *funcs, hb_paint_color_glyph_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the color-glyph callback on the paint functions struct.

- funcs		A paint functions struct
- func		The color-glyph callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 8.2.0
*/
paint_funcs_set_color_glyph_func :: proc(funcs: ^paint_funcs_t, func: paint_color_glyph_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_push_clip_glyph_func (hb_paint_funcs_t *funcs, hb_paint_push_clip_glyph_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the push-clip-glyph callback on the paint functions struct.

- funcs		A paint functions struct
- func		The push-clip-glyph callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_push_clip_glyph_func :: proc(funcs: ^paint_funcs_t, func: paint_push_clip_glyph_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_push_clip_rectangle_func (hb_paint_funcs_t *funcs, hb_paint_push_clip_rectangle_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the push-clip-rect callback on the paint functions struct.

- funcs		A paint functions struct
- func		The push-clip-rectangle callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_push_clip_rectangle_func :: proc(funcs: ^paint_funcs_t, func: paint_push_clip_rectangle_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_pop_clip_func (hb_paint_funcs_t *funcs, hb_paint_pop_clip_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the pop-clip callback on the paint functions struct.

- funcs		A paint functions struct
- func		The pop-clip callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_pop_clip_func :: proc(funcs: ^paint_funcs_t, func: paint_pop_clip_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_color_func (hb_paint_funcs_t *funcs, hb_paint_color_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the paint-color callback on the paint functions struct.

- funcs		A paint functions struct
- func		The paint-color callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_color_func :: proc (funcs: ^paint_funcs_t, func: paint_color_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_image_func (hb_paint_funcs_t *funcs, hb_paint_image_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the paint-image callback on the paint functions struct.

- funcs		A paint functions struct
- func		The paint-image callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_image_func :: proc (funcs: ^paint_funcs_t, func: paint_image_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
unsigned int hb_color_line_get_color_stops (hb_color_line_t *color_line, unsigned int start,
	unsigned int *count, hb_color_stop_t *color_stops);

Fetches a list of color stops from the given color line object.

Note that due to variations being applied, the returned color stops may be out of order. It is the callers
responsibility to ensure that color stops are sorted by their offset before they are used.

- color_line	a hb_color_line_t object
- start			the index of the first color stop to return
- count			Input = the maximum number of feature tags to return; Output = the actual number of feature tags returned (may be zero). [inout][optional]
- color_stops	Array of hb_color_stop_t to populate. [out][array length=count][optional]
- Returns		the total number of color stops in color_line

Since: 7.0.0
*/
color_line_get_color_stops ::proc (color_line: ^color_line_t, start: c.uint,
	count: ^c.uint, color_stops: ^color_stop_t)	-> c.uint ---

/*
hb_paint_extend_t hb_color_line_get_extend (hb_color_line_t *color_line);

Fetches the extend mode of the color line object.

- color_line	a hb_color_line_t object
- Returns		the extend mode of color_line

Since: 7.0.0
*/
color_line_get_extend :: proc(color_line: ^color_line_t)	-> paint_extend_t ---

/*
void hb_paint_funcs_set_linear_gradient_func (hb_paint_funcs_t *funcs, hb_paint_linear_gradient_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the linear-gradient callback on the paint functions struct.

- funcs		A paint functions struct
- func		The linear-gradient callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_linear_gradient_func :: proc(funcs: ^paint_funcs_t, func: paint_linear_gradient_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_radial_gradient_func (hb_paint_funcs_t *funcs, hb_paint_radial_gradient_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the radial-gradient callback on the paint functions struct.

- funcs		A paint functions struct
- func		The radial-gradient callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_radial_gradient_func :: proc(funcs: ^paint_funcs_t, func: paint_radial_gradient_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---


/*void hb_paint_funcs_set_sweep_gradient_func (hb_paint_funcs_t *funcs, hb_paint_sweep_gradient_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the sweep-gradient callback on the paint functions struct.

- funcs		A paint functions struct
- func		The sweep-gradient callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_sweep_gradient_func :: proc(funcs: ^paint_funcs_t, func: paint_sweep_gradient_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_push_group_func (hb_paint_funcs_t *funcs, hb_paint_push_group_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the push-group callback on the paint functions struct.

- funcs		A paint functions struct
- func		The push-group callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_push_group_func ::proc(funcs: ^paint_funcs_t, func: paint_push_group_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_pop_group_func (hb_paint_funcs_t *funcs, hb_paint_pop_group_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the pop-group callback on the paint functions struct.

- funcs		A paint functions struct
- func		The pop-group callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_pop_group_func :: proc(funcs: ^paint_funcs_t, func: paint_pop_group_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_funcs_set_custom_palette_color_func (hb_paint_funcs_t *funcs, hb_paint_custom_palette_color_func_t func,
	void *user_data, hb_destroy_func_t destroy);

Sets the custom-palette-color callback on the paint functions struct.

- funcs		A paint functions struct
- func		The custom-palette-color callback. [closure user_data][destroy destroy][scope notified]
- user_data	Data to pass to func
- destroy	Function to call when user_data is no longer needed. [nullable]

Since: 7.0.0
*/
paint_funcs_set_custom_palette_color_func ::proc (funcs: ^paint_funcs_t, func: paint_custom_palette_color_func_t,
	user_data: rawptr, destroy: destroy_func_t)	---

/*
void hb_paint_push_transform (hb_paint_funcs_t *funcs, void *paint_data,
	float xx, float yx, float xy, float yy, float dx, float dy);

Perform a "push-transform" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- xx			xx component of the transform matrix
- yx			yx component of the transform matrix
- xy			xy component of the transform matrix
- yy			yy component of the transform matrix
- dx			dx component of the transform matrix
- dy			dy component of the transform matrix

Since: 7.0.0
*/
paint_push_transform :: proc (funcs: ^paint_funcs_t, paint_data: rawptr,
	xx: c.float, yx: c.float, xy: c.float, yy: c.float, dx: c.float, dy: c.float)	---

/*
void hb_paint_pop_transform (hb_paint_funcs_t *funcs, void *paint_data);

Perform a "pop-transform" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller

Since: 7.0.0
*/
paint_pop_transform :: proc (funcs: ^paint_funcs_t, paint_data: rawptr)	---

/*
hb_bool_t hb_paint_color_glyph (hb_paint_funcs_t *funcs, void *paint_data, hb_codepoint_t glyph, hb_font_t *font);

Perform a "color-glyph" paint operation.

- funcs			paint functions
-- paint_data	associated data passed by the caller
- glyph			the glyph ID
- font			the font

Since: 8.2.0
*/
paint_color_glyph :: proc (funcs: ^paint_funcs_t, paint_data: ^paint_funcs_t, glyph: codepoint_t, font: ^font_t)	-> bool_t ---

/*
void hb_paint_push_clip_glyph (hb_paint_funcs_t *funcs, void *paint_data, hb_codepoint_t glyph, hb_font_t *font);

Perform a "push-clip-glyph" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- glyph			the glyph ID
- font			the font

Since: 7.0.0
*/
paint_push_clip_glyph :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, glyph: codepoint_t, font: ^font_t)	---

/*
void hb_paint_push_clip_rectangle (hb_paint_funcs_t *funcs, float xmin, float ymin, float xmax, float ymax);

Perform a "push-clip-rect" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- xmin			min X for the rectangle
- ymin			min Y for the rectangle
- xmax			max X for the rectangle
- ymax			max Y for the rectangle


Since: 7.0.0
*/
paint_push_clip_rectangle :: proc (funcs: ^paint_funcs_t, xmin: c.float, ymin: c.float, xmax: c.float, ymax: c.float)	---

/*
void hb_paint_pop_clip (hb_paint_funcs_t *funcs, void *paint_data);

Perform a "pop-clip" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller

Since: 7.0.0
*/
paint_pop_clip :: proc (funcs: ^paint_funcs_t, paint_data: rawptr)	---

/*
void hb_paint_color (hb_paint_funcs_t *funcs, void *paint_data, hb_bool_t is_foreground, hb_color_t color);

Perform a "color" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- is_foreground	whether the color is the foreground
- color			The color to use

Since: 7.0.0
*/
paint_color :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, is_foreground: bool_t, color: color_t)	---

/*
void hb_paint_image (hb_paint_funcs_t *funcs, void *paint_data, hb_blob_t *image, unsigned int width,
	unsigned int height, hb_tag_t format, float slant, hb_glyph_extents_t *extents);

Perform a "image" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- image			image data
- width			width of the raster image in pixels, or 0
- height		height of the raster image in pixels, or 0
- format		the image format as a tag
- slant			the synthetic slant ratio to be applied to the image during rendering
- extents		the extents of the glyph. [nullable]

Since: 7.0.0
*/
paint_image :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, image: ^blob_t, width: c.uint,
	height: c.uint, format: tag_t, slant: c.float, extents: ^glyph_extents_t)	---

/*
void hb_paint_linear_gradient (hb_paint_funcs_t *funcs, void *paint_data, hb_color_line_t *color_line,
	float x0, float y0, float x1, float y1, float x2, float y2);

Perform a "linear-gradient" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- color_line	Color information for the gradient
- x0			X coordinate of the first point
- y0			Y coordinate of the first point
- x1			X coordinate of the second point
- y1			Y coordinate of the second point
- x2			X coordinate of the third point
- y2			Y coordinate of the third point

Since: 7.0.0
*/
paint_linear_gradient :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, color_line: ^color_line_t,
	x0: c.float, y0: c.float, x1: c.float, y1: c.float, x2: c.float, y2: c.float)	---

/*
void hb_paint_radial_gradient (hb_paint_funcs_t *funcs, void *paint_data, hb_color_line_t *color_line,
	float x0, float y0, float r0, float x1, float y1, float r1);

Perform a "radial-gradient" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- color_line	Color information for the gradient
- x0			X coordinate of the first circle's center
- y0			Y coordinate of the first circle's center
- r0			radius of the first circle
- x1			X coordinate of the second circle's center
- y1			Y coordinate of the second circle's center
- r1			radius of the second circle

Since: 7.0.0
*/
paint_radial_gradient :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, color_line: ^color_line_t,
	x0: c.float, y0: c.float, r0: c.float, x1: c.float, y1: c.float, r1: c.float)	---

/*
void hb_paint_sweep_gradient (hb_paint_funcs_t *funcs, void *paint_data, hb_color_line_t *color_line,
	float x0, float y0, float start_angle, float end_angle);

Perform a "sweep-gradient" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- color_line	Color information for the gradient
- x0			X coordinate of the circle's center
- y0			Y coordinate of the circle's center
- start_angle	the start angle
- end_angle		the end angle

Since: 7.0.0
*/
paint_sweep_gradient :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, color_line: ^color_line_t,
	x0: c.float, y0: c.float, start_angle: c.float, end_angle: c.float)	---

/*
void hb_paint_push_group (hb_paint_funcs_t *funcs, void *paint_data);

Perform a "push-group" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller

Since: 7.0.0
*/
paint_push_group :: proc (funcs: ^paint_funcs_t, paint_data: rawptr)	---

/*
void hb_paint_pop_group (hb_paint_funcs_t *funcs, void *paint_data, hb_paint_composite_mode_t mode);

Perform a "pop-group" paint operation.

- funcs			paint functions
- paint_data	associated data passed by the caller
- mode			the compositing mode to use

Since: 7.0.0
*/
paint_pop_group :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, mode: paint_composite_mode_t)	---

/*
hb_bool_t hb_paint_custom_palette_color (hb_paint_funcs_t *funcs, void *paint_data, unsigned int color_index, hb_color_t *color);

Gets the custom palette color for color_index .

- funcs			paint functions
- paint_data	associated data passed by the caller
- color_index	color index
- color			fetched color. [out]
- Returns		true if found, false otherwise

Since: 7.0.0
*/
paint_custom_palette_color :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, color_index: c.uint, color: ^color_t)	-> bool_t ---

/*
void hb_paint_push_font_transform (hb_paint_funcs_t *funcs, void *paint_data, const hb_font_t *font);

Push the transform reflecting the font's scale and slant settings onto the paint functions.

Inputs:
- funcs:		paint functions
- paint_data:	associated data passed by the caller
- font:			a font

Since: 11.0.0
*/
paint_push_font_transform :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, font: ^/*const*/font_t) ---

/*
void hb_paint_push_inverse_font_transform (hb_paint_funcs_t *funcs, void *paint_data, const hb_font_t *font);

Push the inverse of the transform reflecting the font's scale and slant settings onto the paint functions.

Inputs:
- funcs:		paint functions
- paint_data:	associated data passed by the caller
- font:			a font

Since: 11.0.0*/
paint_push_inverse_font_transform :: proc (funcs: ^paint_funcs_t, paint_data: rawptr, font: ^/*const*/ font_t) ---

}
