# Graphics module

The graphics module contains everything 2D and 3D graphics.

## Textures

### `gfx.load_texture(path: string): (Texture, ok: boolean)`

Loads a texture from the app directory. This should be a `.png` or `.jpeg`.

### `Texture.size: vec2`

The size of the texture, in pixels.

### `Texture.path: string`

The path from which the texture was loaded.

## Fonts

### `gfx.load_font(path: string): (Font, ok: boolean)`

Loads a font from the app directory.

### `Font.path: string`

The path from which the font was loaded.

### `gfx.measure_text(args: table): vec2`

Returns the visual width and height of the text. This takes in the same parameters as `gfx.draw_text`.

## 2D rendering

### `gfx.begin_render_pass(args: table)`

Begins 2D rendering in the default framebuffer. Options:

```lua
gfx.begin_render_pass({
	-- if nil, doesn't clear screen
	clear_color = vec4(1),
})
```

### `gfx.end_render_pass()`

Ends 2D rendering in this framebuffer.

### `gfx.set_scissor([pos: vec2, size: vec2])`

Crops rendering to a section of the screen. If no arguments are passed, disables scissor testing. (same as `gfx.set_scissor(vec2(), app.frame_size())`)

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
	color = math.hex("#ffffff") -- optional

	-- defaults to linear
	filter = "nearest" | "linear",

	-- for rendering a portion of the texture
	-- optional
	texture_pos = vec2(50, 10),
	texture_size = vec2(100, 100),
})
```

### `gfx.draw_text(args: table)`

Draws text. Options:

```lua
gfx.draw_text({
	-- unicode is supported!
	text = "Hej världen!",

	pos = vec2(10, 15),
	size = 16,
	color = math.hex("#ffffff"),

	font = gfx.load_font("font.ttf"), -- don't call every frame!

	-- defaults to 1.25
	line_spacing = 1.25,

	wrap = nil | "character" | "word",
	-- only used if wrapping is enabled
	bounds = vec2(100, 200),

	-- defaults to "left"
	halign = "left" | "center" | "right",
	-- defaults to "top"
	valign = "top" | "center" | "bottom",
})
```
