--- @meta

--- @class gfxlib: table
gfx = {}

--- @class (exact) gfx.Texture*
--- @field size Vec2 The size of the texture, in pixels.
--- @field path string The path from which the texture was loaded.

--- Loads a texture from the app directory. This should be a `.png` or `.jpeg`.
--- @param path string
--- @return gfx.Texture* texture
--- @return boolean ok
function gfx.load_texture(path) end

--- @class (exact) gfx.Font*
--- @field path string The path from which the font was loaded.

--- Loads a font from the app directory.
--- @param path string
--- @return gfx.Font* font
--- @return boolean ok
function gfx.load_font(path) end

--- @class gfx.RenderPassDesc
--- @field clear_color Vec4? If nil, doesn't clear the screen.

--- Begins 2D rendering in the default framebuffer.
--- @param args gfx.RenderPassDesc
function gfx.begin_render_pass(args) end

--- Ends 2D rendering in this framebuffer.
function gfx.end_render_pass() end

--- Crops rendering to a section of the screen. If no arguments are passed, disables scissor testing. (same as `gfx.set_scissor(vec2(), app.frame_size())`)
--- @param pos Vec2?
--- @param size Vec2?
function gfx.set_scissor(pos, size) end

--- @class gfx.DrawRectangleDesc: table
--- @field pos Vec2 in pixels
--- @field size Vec2 in pixels
--- @field rot number? in radians
--- @field origin Vec2? from vec2(0.0) to vec2(1.0), e.g. vec2(0.0) = top left, vec2(0.5) = center, vec2(1.0) = bottom right
--- @field texture gfx.Texture*?
--- @field color Vec4? defaults to vec4(1.0) (white)
--- @field filter "nearest" | "linear"? defaults to linear
--- @field texture_pos Vec2? crops a texture
--- @field texture_size Vec2? crops a texture

--- Draws a rectangle.
--- @param args gfx.DrawRectangleDesc
function gfx.draw_rectangle(args) end

--- @class gfx.DrawRectangleOutlineDesc: table
--- @field pos Vec2 in pixels
--- @field size Vec2 in pixels
--- @field rot number? in radians
--- @field origin Vec2? from vec2(0.0) to vec2(1.0), e.g. vec2(0.0) = top left, vec2(0.5) = center, vec2(1.0) = bottom right
--- @field color Vec4
--- @field width number

--- Draws a rectangle outline.
--- @param args gfx.DrawRectangleOutlineDesc
function gfx.draw_rectangle_outline(args) end

--- @class gfx.DrawTextDesc: table
--- @field text string unicode is supported!
--- @field pos Vec2 in pixels
--- @field size number in pixels
--- @field color Vec4? defaults to vec4(1.0) (white)
--- @field font gfx.Font*? defaults to Noto Sans
--- @field line_spacing number? defaults to 1.25
--- @field wrap nil | "character" | "word"
--- @field bounds Vec2? only used if wrapping is enabled
--- @field halign "left" | "center" | "right"? defaults to "left"
--- @field valign "top" | "center" | "bottom"? defaults to "top"

--- Draws text.
--- @param args gfx.DrawTextDesc
function gfx.draw_text(args) end

--- @class gfx.MeasureTextDesc: table
--- @field text string unicode is supported!
--- @field size number in pixels
--- @field font gfx.Font*? defaults to Noto Sans
--- @field line_spacing number? defaults to 1.25
--- @field wrap nil | "character" | "word"
--- @field bounds Vec2? only used if wrapping is enabled

--- Returns the visual width and height of the text.
--- @param args gfx.MeasureTextDesc
--- @return Vec2
function gfx.measure_text(args) end
