function app.on_init()
	-- TODO
end

function app.on_update(dt)
	gfx.clear(vec4())
	gfx.draw_text({
		text = "hello Starry!",
		pos = vec2(10, 10),
		size = 16,
		color = vec4(1),
	})
	gfx.end_drawing_2d()
end
