dofile("../lualibs/gui/gui.lua")

function app.on_update(dt)
	gfx.begin_render_pass({ clear_color = vec4() })
	gfx.draw_text({
		text = "oughhhh im editing it",
		pos = vec2(),
		size = 16,
		color = math.hex("#ffffff")
	})
	gfx.end_render_pass()
end
