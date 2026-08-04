function app.on_init()
	g_frame_square_pos = vec4(0, 300)
	g_delta_square_pos = vec4(0, 400)
end

function app.on_update(dt)
	---- UPDATE
	-- 'dt' is the time between the last frame and current frame, in seconds
	-- here it's used to move the squares at consistent speeds, regardless of FPS
	local SPEED = 100
	g_frame_square_pos.x = g_frame_square_pos.x + SPEED
	g_delta_square_pos.x = g_delta_square_pos.x + SPEED * dt

	-- wrap around the screen
	if g_frame_square_pos.x > app.frame_size().x then
		g_frame_square_pos.x = 0
	end
	if g_delta_square_pos.x > app.frame_size().x then
		g_delta_square_pos.x = 0
	end

	-- lag mode
	if app.key_just_pressed("f5") then
		g_lag = true
	end

	if g_lag then
		for i = 1, 100000000 do
			local _ = { math.sqrt(i), math.sqrt(i) * 2 }
		end
	end

	---- RENDERING
	gfx.clear(vec4())

	gfx.draw_text({
		text = string.format(
			"press F5 to lag\n" ..
			"FPS: %.0f\n" ..
			"delta time: %.3f",
			1 / dt, dt
		),
		pos = vec2(10),
		size = 12,
		color = vec4(1),
	})

	gfx.draw_rectangle({
		pos = g_frame_square_pos,
		size = vec2(40),
		color = math.hex("#ff0000")
	})
	gfx.draw_rectangle({
		pos = g_delta_square_pos,
		size = vec2(40),
		color = math.hex("#0000ff")
	})

	gfx.end_drawing_2d()
end
