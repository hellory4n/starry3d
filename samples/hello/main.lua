function app_init()
	app.set_title("balls")
	local texture = gfx.load_texture("fish.png")
	counter = 0
end

--- @param dt number
function app_update(dt)
	gfx.clear(vec4(1, 0, 0, 1))

	if app.key_just_pressed("a") then
		counter = counter + 1
		print("counter: " .. counter)
	end

	gfx.end_drawing_2d()
end

--- @param width integer
--- @param height integer
function app_on_resize(width, height)
	print("resizing it")
end
