function app.on_init()
	g_size = vec2(32)
end

function app.on_update(dt)
	---- UPDATE
	local pos = app.mouse_pos()

	local color
	if app.mouse_held("left") then
		color = math.hex("#ff0000")
	else
		color = math.hex("#0000ff")
	end

	-- positive values = rectangle grows
	-- negative values = rectangle shrinks
	-- horizontal scroll is supported (use a touchpad)
	if not math.approx_equal(app.mouse_scroll(), vec2(0)) then
		g_size = math.clamp(g_size + app.mouse_scroll() * 16, 0, 256)
	end

	if app.key_just_pressed("h") then
		app.lock_mouse(not app.mouse_locked())
	end

	---- RENDERING
	gfx.clear(vec4())

	gfx.draw_text({
		text =
		    "move with mouse\n" ..
		    "click to change color\n" ..
		    "scroll to change size\n" ..
		    "press H to toggle visibility",
		pos = vec2(10),
		size = 12,
		color = vec4(1),
	})

	gfx.draw_rectangle({
		pos = pos,
		size = g_size,
		origin = vec2(0.5, 0.5),
		color = color,
	})

	gfx.end_drawing_2d()
end
