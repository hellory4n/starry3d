function app.on_init()
	g_just_pressed_pos = vec2()
	g_just_released_pos = vec2()
	g_held_pos = vec2()
end

function app.on_update(dt)
	---- UPDATE
	if app.key_just_pressed("left") then
		g_just_pressed_pos.x = g_just_pressed_pos.x - 32
	end
	if app.key_just_pressed("right") then
		g_just_pressed_pos.x = g_just_pressed_pos.x + 32
	end
	if app.key_just_pressed("up") then
		g_just_pressed_pos.y = g_just_pressed_pos.y - 32
	end
	if app.key_just_pressed("down") then
		g_just_pressed_pos.y = g_just_pressed_pos.y + 32
	end

	if app.key_just_released("left") then
		g_just_released_pos.x = g_just_released_pos.x - 32
	end
	if app.key_just_released("right") then
		g_just_released_pos.x = g_just_released_pos.x + 32
	end
	if app.key_just_released("up") then
		g_just_released_pos.y = g_just_released_pos.y - 32
	end
	if app.key_just_released("down") then
		g_just_released_pos.y = g_just_released_pos.y + 32
	end

	if app.key_held("left") then
		g_held_pos.x = g_held_pos.x - 64 * dt
	end
	if app.key_held("right") then
		g_held_pos.x = g_held_pos.x + 64 * dt
	end
	if app.key_held("up") then
		g_held_pos.y = g_held_pos.y - 64 * dt
	end
	if app.key_held("down") then
		g_held_pos.y = g_held_pos.y + 64 * dt
	end

	---- RENDERING
	gfx.clear(vec4())

	gfx.draw_text({
		text = "move with arrow keys",
		pos = vec2(10),
		size = 12,
		color = vec4(1),
	})

	gfx.draw_rectangle({
		pos = g_just_pressed_pos + (app.frame_size() / 2) - vec2(128, 0),
		size = vec2(32),
		origin = vec2(0.5, 0.5),
		color = math.hex("#ff0000")
	})
	gfx.draw_rectangle({
		pos = g_just_released_pos + (app.frame_size() / 2) + vec2(128, 0),
		size = vec2(32),
		origin = vec2(0.5, 0.5),
		color = math.hex("#0000ff")
	})
	gfx.draw_rectangle({
		pos = g_held_pos + (app.frame_size() / 2),
		size = vec2(32),
		origin = vec2(0.5, 0.5),
		color = math.hex("#00ff00")
	})

	gfx.end_drawing_2d()
end
