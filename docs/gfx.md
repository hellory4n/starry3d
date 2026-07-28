# Graphics module

The graphics module contains everything graphics.

## Textures

### `gfx.load_texture(path: string): gfx.Texture`

Loads a texture from the app directory. This should be a `.png` or `.jpeg`.

### `gfx.load_texture_from_memory(data: string): gfx.Texture`

Loads a texture from a buffer. This should be a PNG or JPEG buffer.

### `gfx.Texture.id: integer`

The internal ID used by the engine.

### `gfx.Texture.size: vec2`

The size of the texture, in pixels.

### `gfx.Texture.path: string`

The path from which the texture was loaded, if any.

## 2D graphics

### `gfx.clear([color: vec4])`

Clears the screen and prepares rendering for this frame. If `color` is missing, clears the screen to black.

### `gfx.end_drawing_2d()`

Finishes drawing 2D graphics.

### `gfx.draw_rectangle(args: table)`

Draws a rectangle. Options:

```lua
gfx.draw_rectangle({
	-- position and size in pixels
	pos = vec2(40, 50),
	size = vec2(100, 150),
	rot = 3.14, -- optional, in radians

	-- origin point, from vec2(0.0) to vec2(1.0)
	-- examples:
	--     - top left:     vec2(0.0, 0.0)
	--     - center:       vec2(0.5, 0.5)
	--     - bottom right: vec2(1.0, 1.0)
	-- optional
	origin = vec2(0.5),

	-- color and texture can be combined
	texture = gfx.load_texture("img.png"), -- don't call every frame!
	color = vec4(1, 1, 1, 1) -- optional

	-- defaults to nearest
	filter = "nearest" | "linear",

	-- for rendering a portion of the texture
	-- optional
	texture_pos = vec2(50, 10),
	texture_size = vec2(100, 100)
})
``
