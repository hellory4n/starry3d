function app_init()
	app.set_title("balls")
	counter = 0
end

--- @param dt number
function app_update(dt)
	__st.glorious_red_square(vec3(0, 0, 1))

	if app.key_just_pressed("a") then
		counter = counter + 1
		print("counter: " .. counter)
	end
	-- print(app.mouse_pos())
end

--- @param width integer
--- @param height integer
function app_on_resize(width, height)
	print("resizing it")
end
