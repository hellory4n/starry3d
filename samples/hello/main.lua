function app_init()
	app.set_title("balls")
end

--- @param dt number
function app_update(dt)
	__st.glorious_red_square()
end

--- @param width integer
--- @param height integer
function app_on_resize(width, height)
	print("resize!")
end
