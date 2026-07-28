--- @meta

--- @class gfxlib: table
gfx = {}

--- @class gfx.Texture
--- @field id integer The internal ID used by the engine.
--- @field size Vec2 The size of the texture, in pixels.
--- @field path string The path from which the texture was loaded, if any.

--- Loads a texture from the app directory. This should be a `.png` or `.jpeg`.
--- @param path string
--- @return gfx.Texture
function gfx.load_texture(path) end

--- Loads a texture from a buffer. This should be a PNG or JPEG buffer.
--- @param data string
--- @return gfx.Texture
function gfx.load_texture_from_memory(data) end

--- Clears the screen and prepares rendering for this frame. If `color` is missing, clears the screen to black.
--- @param color Vec4?
function gfx.clear(color) end

--- Finishes drawing 2D graphics.
function gfx.end_drawing_2d() end

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
