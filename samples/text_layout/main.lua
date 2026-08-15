function app.on_init()
	g_mode = "no wrap"
	g_size = 16
end

function app.on_update()
	---- UPDATE
	if app.key_just_pressed("1") then
		g_mode = "no wrap"
	end
	if app.key_just_pressed("2") then
		g_mode = "character wrap"
	end
	if app.key_just_pressed("3") then
		g_mode = "word wrap"
	end

	if app.key_just_pressed("c") then
		g_halign = "center"
		g_valign = "center"
	end
	if app.key_just_pressed("r") then
		g_halign = "right"
	end
	if app.key_just_pressed("b") then
		g_valign = "bottom"
	end

	if app.key_just_pressed("up") then
		g_size = g_size * 1.5
	end
	if app.key_just_pressed("down") then
		g_size = g_size / 1.5
	end

	---- RENDER
	gfx.begin_render_pass({ clear_color = vec4() })

	gfx.draw_text({
		text =
		"press 1-3 to switch layout\npress C for center alignment, R for right alignment, B for bottom alignment\npress up/down to increase/decrease font size",
		size = 16,
		pos = vec2(10, 10),
	})

	-- draw bounds
	local bounds = vec2(app.frame_size().x - 20, app.frame_size().y - 90)
	if g_mode == "character wrap" or g_mode == "word wrap" then
		gfx.draw_rectangle({
			pos = vec2(10, 80),
			color = math.hex("#141414"),
			size = bounds
		})
	end

	if g_mode == "no wrap" then
		gfx.draw_text({
			pos = vec2(10, 80),
			size = g_size,
			bounds = bounds,
			halign = g_halign or "left",
			valign = g_valign or "top",
			text = "no wrap\n" .. sample_text(),
		})
	end

	if g_mode == "character wrap" then
		gfx.draw_text({
			pos = vec2(10, 80),
			size = g_size,
			bounds = bounds,
			wrap = "character",
			halign = g_halign or "left",
			valign = g_valign or "top",
			text = "character wrap\n" .. sample_text(),
		})
	end

	if g_mode == "word wrap" then
		gfx.draw_text({
			pos = vec2(10, 80),
			size = g_size,
			bounds = bounds,
			wrap = "word",
			halign = g_halign or "left",
			valign = g_valign or "top",
			text = "word wrap\n" .. sample_text(),
		})
	end

	gfx.end_render_pass()
end

function sample_text()
	return
	[[Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

The full name of Titin is Methionylthreonylthreonylglutaminylarginyltyrosylglutamylserylleucylphenylalanylalanylglutaminylleucyllysylglutamylarginyllysylglutamylglycylalanylphenylalanylvalylprolylphenylalanylvalylthreonylleucylglycylaspartylprolylglycylisoleucylglutamylglutaminylserylleucyllysylisoleucylaspartylthreonylleucylisoleucylglutamylalanylglycylalanylaspartylalanylleucylglutamylleucylglycylisoleucylprolylphenylalanylserylaspartylprolylleucylalanylaspartylglycylprolylthreonylisoleucylglutaminylasparaginylalanylthreonylleucylarginylalanylphenylalanylalanylalanylglycylvalylthreonylprolylalanylglutaminylcysteinylphenylalanylglutamylmethionylleucylalanylleucylisoleucylarginylglutaminyllysylhistidylprolylthreonylisoleucylprolylisoleucylglycylleucylleucylmethionyltyrosylalanylasparaginylleucylvalylphenylalanylasparaginyllysylglycylisoleucylaspart...

Artykuł 1
    Wszyscy ludzie rodzą się wolni i równi pod względem swej godności i swych praw. Są oni obdarzeni rozumem i sumieniem i powinni postępować wobec innych w duchu braterstwa.
Artykuł 2
    Każdy człowiek posiada wszystkie prawa i wolności zawarte w niniejszej Deklaracji bez względu na jakiekolwiek różnice rasy, koloru, płci, języka, wyznania, poglądów politycznych i innych, narodowości, pochodzenia społecznego, majątku, urodzenia lub jakiegokolwiek innego stanu.
    Nie wolno ponadto czynić żadnej różnicy w zależności od sytuacji politycznej, prawnej lub międzynarodowej kraju lub obszaru, do którego dana osoba przynależy, bez względu na to, czy dany kraj lub obszar jest niepodległy, czy też podlega systemowi powiernictwa, nie rządzi się samodzielnie lub jest w jakikolwiek sposób ograniczony w swej niepodległości.
Artykuł 3
    Każdy człowiek ma prawo do życia, wolności i bezpieczeństwa swej osoby.
...
]]
end
