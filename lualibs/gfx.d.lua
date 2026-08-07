--- @meta

--- @class gfxlib: table
gfx = {}

--- @class gfx.Texture
--- @field size Vec2 The size of the texture, in pixels.
--- @field path string The path from which the texture was loaded.

--- Loads a texture from the app directory. This should be a `.png` or `.jpeg`.
--- @param path string
--- @return gfx.Texture texture
--- @return boolean ok
function gfx.load_texture(path) end

--- @class gfx.Font
--- @field path string The path from which the font was loaded.

--- Loads a font from the app directory.
--- @param path string
--- @return gfx.Font font
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
--- @field pos Vec2
--- @field size Vec2
--- @field rot number?
--- @field origin Vec2?
--- @field texture gfx.Texture?
--- @field color Vec4?
--- @field filter "nearest" | "linear"?
--- @field texture_pos Vec2?
--- @field texture_size Vec2?

--- Draws a rectangle.
--- @param args gfx.DrawRectangleDesc
function gfx.draw_rectangle(args) end

--- @class gfx.DrawTextDesc: table
--- @field text string
--- @field pos Vec2
--- @field size number
--- @field color Vec4
--- @field font gfx.Font?
--- @field line_spacing number?
--- @field wrap nil | "character" | "word"
--- @field bounds Vec2?

--- Draws text.
--- @param args gfx.DrawTextDesc
function gfx.draw_text(args) end
