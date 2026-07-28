function app_init()
	app.set_title("balls")
	g_texture = gfx.load_texture("fish.png")

	-- you can also handle any errors found
	local ok = false
	g_atlas, ok = gfx.load_texture("atlas.png")
	if not ok then
		error("uh oh")
	end

	-- g_font = gfx.load_font("OpenSans-Medium.ttf")

	g_counter = 0
end

--- @param dt number
function app_update(dt)
	gfx.clear(vec4(1, 0, 1, 1))

	if app.key_just_pressed("a") then
		g_counter = g_counter + 1
		print("counter: " .. g_counter)
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

	-- movement + modulate
	local SPEED = 5000
	gfx.draw_rectangle({
		pos = vec2(
			(app.frame_size().x / 2 - 20) * math.sin(app.now_secs() * SPEED * dt) +
			app.frame_size().x / 2 - 20, 0),
		size = vec2(40),
		texture = g_texture,
		color = vec4(app.now_secs() % 2),
	})

	-- amazing cursor
	g_rotation = (g_rotation or 0) + 5 * dt
	gfx.draw_rectangle({
		pos = app.mouse_pos(),
		size = vec2(32),
		rot = g_rotation,
		origin = vec2(0.5),
		texture = g_texture,
	})

	-- gfx.draw_text({
	-- 	text = ":)",
	-- 	pos = vec2(50, 50),
	-- 	size = 16,
	-- 	color = vec4(1),
	-- 	font = g_font,
	-- })

	gfx.end_drawing_2d()
end

--- @param width integer
--- @param height integer
function app_on_resize(width, height)
	print("resizing it")
end
