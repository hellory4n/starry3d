# Graphics module

The graphics module contains everything graphics.

## Textures

### `gfx.load_texture(path: string): (gfx.Texture, ok: boolean)`

Loads a texture from the app directory. This should be a `.png` or `.jpeg`.

### `gfx.Texture.id: integer`

The internal ID used by the engine.

### `gfx.Texture.size: vec2`

The size of the texture, in pixels.

### `gfx.Texture.path: string`

The path from which the texture was loaded.

## Fonts

### `gfx.load_font(path: string): (gfx.Font, ok: boolean)`

Loads a font from the app directory.

### `gfx.Font.id: integer`

The internal ID used by the engine.

### `gfx.Font.path: string`

The path from which the font was loaded.

## 2D rendering

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
```

### `gfx.draw_text(args)`

Draws text. Options:

```lua
gfx.draw_text({
	-- supported scripts:
	-- - ASCII
	-- - latin extended
	-- - cyrillic
	-- - greek
	-- other scripts will not render properly
	text = "Hej världen!",

	pos = vec2(10, 15),
	size = 16,
	color = vec4(1, 1, 1, 1),

	font = gfx.load_texture("font.ttf"), -- don't call every frame!

	-- defaults to "left"
	halign = "left" | "center" | "right",
	-- defaults to "baseline"
	valign = "top" | "middle" | "bottom" | "baseline"
})
```
