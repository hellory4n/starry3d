function app.on_init()
	g_parrot = gfx.load_texture("parrot.jpg")
end

function app.on_update(dt)
	gfx.begin_render_pass({ clear_color = vec4() })

	local size = vec2(96)
	local pad = 10

	gfx.draw_rectangle({
		pos = vec2(pad),
		size = size,
		color = math.hex("#ff0000"),
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 2 + size.y, pad) + size / 2,
		size = size * vec2(0.5, 1),
		rot = app.now_secs() * 2,
		origin = vec2(0.5),
		color = math.hex("#ff0000"),
	})

	gfx.draw_rectangle({
		pos = vec2(pad, pad * 2 + size.y),
		size = size,
		texture = g_parrot,
		filter = "linear",
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 2 + size.x, pad * 2 + size.y),
		size = size,
		texture = g_parrot,
		filter = "linear",
		color = math.hex("#ff00ff")
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 3 + size.x * 2, pad * 2 + size.y),
		size = size,
		texture = g_parrot,
		filter = "nearest",
		texture_pos = vec2(125, 0),
		texture_size = vec2(200, 400),
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 4 + size.x * 3, pad * 2 + size.y) + size / 2,
		size = size * vec2(1, 0.5),
		origin = vec2(0.5),
		rot = app.now_secs() * 2,
		texture = g_parrot,
		filter = "linear",
		texture_pos = vec2(125, 0),
		texture_size = vec2(200, 400),
		color = math.hex("#ffff00"),
	})

	gfx.end_render_pass()
end
