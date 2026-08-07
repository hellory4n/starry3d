local LOREM_IPSUM =
[[Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]
local TITIN =
[[The full name of Titin is Methionylthreonylthreonylglutaminylarginyltyrosylglutamylserylleucylphenylalanylalanylglutaminylleucyllysylglutamylarginyllysylglutamylglycylalanylphenylalanylvalylprolylphenylalanylvalylthreonylleucylglycylaspartylprolylglycylisoleucylglutamylglutaminylserylleucyllysylisoleucylaspartylthreonylleucylisoleucylglutamylalanylglycylalanylaspartylalanylleucylglutamylleucylglycylisoleucylprolylphenylalanylserylaspartylprolylleucylalanylaspartylglycylprolylthreonylisoleucylglutaminylasparaginylalanylthreonylleucylarginylalanylphenylalanylalanylalanylglycylvalylthreonylprolylalanylglutaminylcysteinylphenylalanylglutamylmethionylleucylalanylleucylisoleucylarginylglutaminyllysylhistidylprolylthreonylisoleucylprolylisoleucylglycylleucylleucylmethionyltyrosylalanylasparaginylleucylvalylphenylalanylasparaginyllysylglycylisoleucylaspart...]]

function app.on_update()
	if app.key_just_pressed("1") then
		g_mode = "no wrap"
	end
	if app.key_just_pressed("2") then
		g_mode = "character wrap"
	end
	if app.key_just_pressed("3") then
		g_mode = "word wrap"
	end

	gfx.begin_render_pass({ clear_color = vec4() })

	gfx.draw_text({
		text = "press 1-3 to switch examples",
		size = 16,
		pos = vec2(10),
		color = vec4(1),
	})

	if g_mode == "no wrap" then
		gfx.draw_text({
			pos = vec2(10, 40),
			color = vec4(1),
			size = 16,
			text = "no wrap\n" .. LOREM_IPSUM .. "\n\n" .. TITIN
		})
	end

	-- draw bounds
	local bounds = vec2(app.frame_size().x - 20, app.frame_size().y - 50)
	if g_mode == "character wrap" or g_mode == "word wrap" then
		gfx.draw_rectangle({
			pos = vec2(10, 40),
			color = math.hex("#141414"),
			size = bounds
		})
	end

	if g_mode == "character wrap" then
		gfx.draw_text({
			pos = vec2(10, 40),
			color = vec4(1),
			size = 16,
			bounds = bounds,
			wrap = "character",
			text = "character wrap\n" .. LOREM_IPSUM .. "\n\n" .. TITIN,
		})
	end

	if g_mode == "word wrap" then
		gfx.draw_text({
			pos = vec2(10, 40),
			color = vec4(1),
			size = 16,
			bounds = bounds,
			wrap = "word",
			text = "word wrap\n" .. LOREM_IPSUM .. "\n\n" .. TITIN,
		})
	end

	gfx.end_render_pass()
end
