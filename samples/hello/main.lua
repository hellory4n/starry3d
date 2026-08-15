function app.on_init()
	-- TODO
end

function app.on_update(dt)
	gfx.begin_render_pass({ clear_color = vec4() })
	gfx.draw_text({
		text = "hello Starry!",
		pos = vec2(32, 0),
		size = 64,
		color = vec4(1),
	})
	gfx.end_render_pass()
end
