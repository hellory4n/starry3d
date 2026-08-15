gui = {
	version_num = 00800,
	version_str = "v0.8.0"
}

-- starry and gui versions should match
local engine_info = app.engine_info()
if gui.version_num > engine_info.version_num then
	error(string.format("gui %s is incompatible with starry %s; please update starry",
		gui.version_str, engine_info.version_str))
end
if engine_info.version_num > gui.version_num then
	print(string.format("gui %s out of date; update gui from the starry %s release",
		gui.version_str, engine_info.version_str))
end

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
