dofile("../lualibs/gui/gui.lua")

function app.on_update(dt)
	gfx.begin_render_pass({ clear_color = vec4() })

	if gui.box({ size = { "fit", "fit" }, element = "button" }) then
		if gui.box({ size = { 40, 40 }, element = "button", variation = "primary" }) then
			gui.close()
		end
		if gui.box({ size = { 40, 40 }, element = "button", variation = "primary" }) then
			gui.close()
		end
		gui.close()
	end

	gui.update()
	local cmds = gui.draw()
	gui.sample_renderer(cmds)

	gfx.end_render_pass()
end
