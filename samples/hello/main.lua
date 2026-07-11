function app_init()
	print(vec2(1, 2))
	print(vec2(1))
	print(vec2())
	print(vec2(5) - 1)
	print(vec2(5) - vec2(1, 2))
	print(vec3(5) / 2)
	print(math.abs(vec3(-1.2, -1.3, -1.4)))
	print(math.min(5, 1, -2, 62346, 4))
	print(math.max(5, 1, -2, 62346, 4))
	print(math.normalize(vec3(72472, 424, 13)))
	print(math.euler_to_quat(1, 2, 3))
	print(math.quat_to_euler(math.euler_to_quat(math.pi, math.pi / 2, 0)))
end

--- @param dt number
function app_update(dt)
	print("hi!")
end

--- @param width integer
--- @param height integer
function app_on_resize(width, height)
	print("resize!")
end
