function app.on_init()
	-- the default font only supports Latin, Cyrillic, and Greek
	g_arabic_font = gfx.load_font("NotoSansArabic-Medium.ttf")
	g_devanagari_font = gfx.load_font("NotoSansDevanagari-Medium.ttf")
	g_japanese_font = gfx.load_font("NotoSansJP-Medium.ttf")
end

function app.on_update(dt)
	gfx.begin_render_pass({ clear_color = vec4() })

	local y = 10
	gfx.draw_text({
		text = "Hej världen!",
		pos = vec2(10, y),
		size = 32,
		color = vec4(1),
	})
	y = y + gfx.measure_text({
		text = "Hej världen!",
		size = 32,
	}).y

	gfx.draw_text({
		text = "Привет, мир!",
		pos = vec2(10, y),
		size = 32,
		color = vec4(1),
	})
	y = y + gfx.measure_text({
		text = "Привет, мир!",
		size = 32,
	}).y

	gfx.draw_text({
		text = "Γεια σου, κόσμε!",
		pos = vec2(10, y),
		size = 32,
		color = vec4(1),
	})
	y = y + gfx.measure_text({
		text = "Γεια σου, κόσμε!",
		size = 32,
	}).y

	gfx.draw_text({
		text = "مرحبا بالعالم!",
		pos = vec2(10, y),
		size = 32,
		color = vec4(1),
		font = g_arabic_font,
	})
	y = y + gfx.measure_text({
		text = "مرحبا بالعالم!",
		size = 32,
		font = g_arabic_font,
	}).y

	gfx.draw_text({
		text = "हैलो वर्ल्ड!",
		pos = vec2(10, y),
		size = 32,
		color = vec4(1),
		font = g_devanagari_font,
	})
	y = y + gfx.measure_text({
		text = "हैलो वर्ल्ड!",
		size = 32,
		font = g_devanagari_font,
	}).y

	gfx.draw_text({
		text = "こんにちは世界！",
		pos = vec2(10, y),
		size = 32,
		color = vec4(1),
		font = g_japanese_font,
	})
	y = y + gfx.measure_text({
		text = "こんにちは世界！",
		size = 32,
		font = g_japanese_font,
	}).y

	gfx.end_render_pass()
end
