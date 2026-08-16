gui = {
	version_num = 00800,
	version_str = "v0.8.0",

	-- configuration
	scale = app.scale_factor(),
	default_child_gap = 4,
	default_padding = 4,

	-- internal state
	--- @type gui.Element[]
	roots = {},
	--- @type gui.Element?
	open_element = nil,
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

--- internal, used while building layout
--- @class gui.Element
--- @field type gui.ElementType
--- @field parent gui.Element?
--- @field children gui.Element[]
--- @field closed boolean
--- @field pos Vec2
--- @field size Vec2
--- @field desc gui.BoxDesc

--- Examples:
--- - fixed size: 50
--- - percentage of size: "50%"
--- - flexible size: "grow" or "fit"
--- @alias gui.BoxSize [number | "grow" | "fit" | string, number | "grow" | "fit" | string]

--- @alias gui.BoxAlign ["left" | "center" | "right", "top" | "center" | "bottom"]

--- h = horizontal, v = vertical
--- @alias gui.BoxDirection "h" | "v"

--- Top, right, bottom, left (same order as CSS)
--- @alias gui.Sides [number, number, number, number]

--- note: `any` isn't used here since that allows nil (and nil can't be used as a table key)
--- @alias gui.ThemeVariation "" | "primary" | string | boolean | number | function | table

--- @class gui.BoxDesc
--- @field size gui.BoxSize
--- @field min_size gui.BoxSize?
--- @field align gui.BoxAlign?
--- @field dir gui.BoxDirection?
--- @field child_gap number? Defaults to `gui.default_child_gap`
--- @field padding gui.Sides? Defaults to `gui.default_padding`
--- @field variation gui.ThemeVariation? Can be anything; use when rendering for theming
--- @field element gui.ElementType internal, used by other elements based on `gui.box`

--- Always returns true (it's for indenting)
--- @param desc gui.BoxDesc
--- @return boolean
function gui.box(desc)
	-- defaults
	desc.min_size = desc.min_size or { 0, 0 }
	desc.align = desc.align or { "left", "top" }
	desc.dir = desc.dir or "h"
	desc.child_gap = desc.child_gap or gui.default_child_gap
	desc.padding = desc.padding or
	    { gui.default_padding, gui.default_padding, gui.default_padding, gui.default_padding }
	desc.variation = desc.variation or ""

	--- @type gui.Element
	local elem = {
		parent = gui.open_element,
		children = {},
		closed = false,
		pos = vec2(),
		size = vec2(),
		text = "",
		desc = desc,
		type = "",
	}

	if gui.open_element ~= nil then
		table.insert(gui.open_element.children, elem)
	else
		table.insert(gui.roots, elem)
	end
	gui.open_element = elem
	return true
end

function gui.close()
	if gui.open_element == nil then
		error("no open UI element")
	end
	gui.open_element.closed = true

	local parent = gui.open_element.parent
	if parent == nil then
		return
	end

	if parent.desc.size[1] == "fit" then
		if parent.desc.dir == "h" then
			parent.size.x = parent.size.x + gui.open_element.size.x
		else
			parent.size.y = parent.size.y + gui.open_element.size.y
		end
	end
end

function gui.update()
	for _, elem in ipairs(gui.roots) do
		gui._position_element(elem)
	end
end

--- @alias gui.DrawCmdType "rect" | "text" | "scissor"
--- @alias gui.ElementType "" | "text" | "button" | "button text"

--- @class gui.DrawCmd
--- @field type gui.DrawCmdType
--- @field element gui.ElementType
--- @field variation gui.ThemeVariation Can be anything; use when rendering for theming
--- @field pos Vec2
--- @field size Vec2
--- @field text string Available if type is "text", empty otherwise

--- Finishes building the layout and generates draw commands
--- @return gui.DrawCmd[]
function gui.draw()
	-- generate draw commands

	-- clean up
	gui.open_element = nil
	gui.roots = {}
end

--- @param elem gui.Element
function gui._position_element(elem)
	for _, child in ipairs(elem.children) do
		gui._position_element(child)
	end
end

--- Sample GUI renderer; use this as a base for your own renderer
--- @param cmds gui.DrawCmd[]
function gui.sample_renderer(cmds)
	-- mapped to element type and variation
	--- @type {[gui.ElementType]: {[gui.ThemeVariation]: Vec4}}
	local COLORS = {
		[""] = {
			[""] = vec4(),
		},
		["button"] = {
			-- secondary button
			[""] = math.hex("#485a6c"),
			["primary"] = math.hex("#a56de2")
		}
	}

	for _, cmd in ipairs(cmds) do
		if cmd.type == "rect" then
			gfx.draw_rectangle({
				pos = cmd.pos,
				size = cmd.size,
				color = COLORS[cmd.element][cmd.variation]
			})
		else
			error("TODO")
		end
	end
end
