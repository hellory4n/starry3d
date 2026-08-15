gui = {}

--- @alias gui.DrawCmdType "rect" | "text" | "scissor"

--- @class gui.DrawCmd
--- @field type gui.DrawCmdType
--- @field variation gui.ThemeVariation | any
--- @field pos Vec2
--- @field size Vec2
--- @field text string Available if type is "text", empty otherwise

--- common theme variations
--- @alias gui.ThemeVariation "button" | "button text"

function gui.box(t) end
