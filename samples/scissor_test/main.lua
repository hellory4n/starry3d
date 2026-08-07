local LOREM_IPSUM = string.rep(
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
	10
)

function app.on_update()
	gfx.begin_render_pass({ clear_color = vec4() })

	local scissor_size = vec2(64)
	local scissor_pos = app.mouse_pos() - (scissor_size / 2)
	gfx.set_scissor(scissor_pos, scissor_size)

	gfx.draw_rectangle({
		pos = vec2(),
		size = app.frame_size(),
		color = math.hex("#0000ff")
	})
	gfx.draw_text({
		pos = vec2(),
		color = vec4(1),
		size = 16,
		bounds = app.frame_size(),
		wrap = "character",
		text = LOREM_IPSUM,
	})

	gfx.set_scissor() -- disable scissor testing
	gfx.end_render_pass()
end
