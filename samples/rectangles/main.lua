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
		pos = vec2(pad * 2 + size.x, pad) + size / 2,
		size = size * vec2(0.5, 1),
		rot = app.now_secs() * 2,
		origin = vec2(0.5),
		color = math.hex("#ff0000"),
	})

	gfx.draw_rectangle_outline({
		pos = vec2(pad * 3 + size.x * 2, pad) + size / 2,
		size = size * vec2(0.5, 1.0),
		rot = app.now_secs() * 2,
		origin = vec2(0.5),
		width = 4,
		color = math.hex("#00ff00"),
	})

	gfx.draw_rectangle({
		pos = vec2(pad, pad * 2 + size.y),
		size = size,
		texture = g_parrot,
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 2 + size.x, pad * 2 + size.y),
		size = size,
		texture = g_parrot,
		color = math.hex("#ff00ff")
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 3 + size.x * 2, pad * 2 + size.y),
		size = size,
		texture = g_parrot,
		texture_pos = vec2(125, 0),
		texture_size = vec2(200, 400),
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 4 + size.x * 3, pad * 2 + size.y) + size / 2,
		size = size * vec2(1, 0.5),
		origin = vec2(0.5),
		rot = app.now_secs() * 2,
		texture = g_parrot,
		texture_pos = vec2(125, 0),
		texture_size = vec2(200, 400),
		color = math.hex("#ffff00"),
	})

	gfx.draw_rectangle({
		pos = vec2(pad * 5 + size.x * 4, pad * 2 + size.y),
		size = size,
		texture = g_parrot,
		color = math.hex("#00ffff")
	})
	gfx.draw_rectangle_outline({
		pos = vec2(pad * 5 + size.x * 4, pad * 2 + size.y),
		size = size,
		color = vec4(1, 1, 1, 0.3),
		width = 16,
	})

	gfx.end_render_pass()
end
