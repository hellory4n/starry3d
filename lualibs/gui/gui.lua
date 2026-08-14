gui = {}

if gui.box({ size = { "100%", "100%" }, align = { "center", "center" } }) then
	if gui.panel_box({ size = { "50%", "30%" }, align = { "center", "center" }, dir = "h" }) then
		if gui.button({ text = "fuck", size = { "grow", "fit" }, variation = "primary" }) then
			print("fuck!")
		end
		if gui.button({ text = "shit", size = { "grow", "fit" } }) then
			print("shit!")
		end
		gui.end_box()
	end
	gui.end_box()
end

local cmds = gui.draw()
for i, cmd in ipairs(cmds) do
	-- cmd = {size, pos, variation, ...}
end

-- TODO implement lol
-- ideas:
--
