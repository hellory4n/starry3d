function app_init()
	app.set_title("balls")
	g_texture = gfx.load_texture("fish.png")
	g_atlas = gfx.load_texture("atlas.png")
	counter = 0
end

--- @param dt number
function app_update(dt)
	gfx.clear(vec4(1, 0, 1, 1))

	if app.key_just_pressed("a") then
		counter = counter + 1
		print("counter: " .. counter)
	end

	-- amazing background
	gfx.draw_rectangle({
		pos = vec2(),
		size = app.frame_size() * vec2(0.5, 1),
		color = vec4(0, 0, 0, 1),
	})
	gfx.draw_rectangle({
		pos = app.frame_size() * vec2(0.5, 0),
		size = app.frame_size() * vec2(0.5, 1),
		color = vec4(1),
	})

	-- ying yang ahh
	gfx.draw_rectangle({
		pos = (app.frame_size() * vec2(0.5, 1)) / 2 - (vec2(100) / 2),
		size = vec2(100),
		texture = g_atlas,
		texture_pos = vec2(160, 0),
		texture_size = vec2(160),
	})
	gfx.draw_rectangle({
		pos = ((app.frame_size() * vec2(1.5, 1)) / 2 - (vec2(100) / 2)),
		size = vec2(100),
		texture = g_atlas,
		texture_pos = vec2(0),
		texture_size = vec2(160),
	})

	-- amazing cursor
	gfx.draw_rectangle({
		pos = app.mouse_pos(),
		size = vec2(32),
		texture = g_texture,
	})

	gfx.end_drawing_2d()
end

--- @param width integer
--- @param height integer
function app_on_resize(width, height)
	print("resizing it")
end
