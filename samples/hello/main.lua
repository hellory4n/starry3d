function app_init()
end

--- @param dt number
function app_update(dt)
	local dev = st.app.gpu()

	dev:begin_render_pass({
		framebuffer = dev:default_framebuffer(),
		color_load_op = "clear",
		clear_color = vec4(1, 0, 0, 1),
	})
	dev:end_render_pass()
end

--- @param width integer
--- @param height integer
function app_on_resize(width, height)
	print("resize!")
end
