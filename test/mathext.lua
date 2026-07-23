-- starry math exte
local Test = require("testrunner")

Test.new("standard math", function(t)
	-- starry overrides these functions, check for standard lua behavior
	t:assert(math.abs(-2), 2)
	t:assert(math.abs(2), 2)

	t:assert_approx(math.acos(-1), math.pi)
	t:assert_approx(math.asin(1), math.pi / 2)
	t:assert_approx(math.atan(1), math.pi / 4)
	t:assert_approx(math.atan2(1, 2), 0.46364760900081)

	t:assert_approx(math.cos(1), 0.54030230586814)
	t:assert_approx(math.sin(1), 0.8414709848079)
	t:assert_approx(math.tan(1), 1.5574077246549)

	t:assert_approx(math.cosh(1), 1.5430806348152)
	t:assert_approx(math.sinh(1), 1.1752011936438)
	t:assert_approx(math.tanh(1), 0.76159415595576)

	t:assert_approx(math.exp(1), 2.718281828459)
	t:assert(math.ldexp(1, 2), 4)
	local m, e = math.frexp(2.5)
	t:assert_approx(m, 0.625)
	t:assert_approx(e, 2)

	t:assert_approx(math.log(1.5), 0.40546510810816)
	t:assert_approx(math.log10(1.5), 0.17609125905568)

	local i, f = math.modf(1.5)
	t:assert(i, 1)
	t:assert_approx(f, 0.5)

	t:assert_approx(math.sqrt(1.5), 1.2247448713916)
end)

Test.new("round", function(t)
	t:assert_approx(math.round(1), 1)
	t:assert_approx(math.round(1.2), 1)
	t:assert_approx(math.round(1.6), 2)
	t:assert_approx(math.round(1.8), 2)
	t:assert_approx(math.round(2), 2)
	t:assert_approx(math.round(2.1), 2)
end)

Test.new("vec2 constructor", function(t)
	-- default
	local zero = vec2()
	t:assert(zero.x, 0)
	t:assert(zero.y, 0)

	-- single number
	local one = vec2(5)
	t:assert(one.x, 5)
	t:assert(one.y, 5)

	-- two numbers
	local p = vec2(3, 7)
	t:assert(p.x, 3)
	t:assert(p.y, 7)
end)

Test.new("vec2 addition", function(t)
	local a = vec2(1, 2)
	local b = vec2(3, 4)

	local c = a + b
	t:assert(c.x, 4)
	t:assert(c.y, 6)

	-- vec + scalar
	local d = a + 5
	t:assert(d.x, 6)
	t:assert(d.y, 7)

	-- scalar + vec
	local e = 10 + a
	t:assert(e.x, 11)
	t:assert(e.y, 12)
end)

Test.new("Vec2 subtraction", function(t)
	local a = vec2(5, 7)
	local b = vec2(2, 3)

	local c = a - b
	t:assert(c.x, 3)
	t:assert(c.y, 4)

	-- vec - scalar
	local d = a - 2
	t:assert(d.x, 3)
	t:assert(d.y, 5)

	-- scalar - vec
	local e = 10 - a
	t:assert(e.x, 5)
	t:assert(e.y, 3)
end)

Test.new("vec2 division", function(t)
	local a = vec2(10, 20)
	local b = vec2(2, 5)

	local c = a / b
	t:assert(c.x, 5)
	t:assert(c.y, 4)

	-- vec / scalar
	local d = a / 2
	t:assert(d.x, 5)
	t:assert(d.y, 10)

	-- scalar / vec
	local e = 20 / a
	t:assert(e.x, 2)
	t:assert(e.y, 1)
end)

Test.new("vec2 modulo", function(t)
	local a = vec2(10, 7)
	local b = vec2(3, 2)

	local c = a % b
	t:assert(c.x, 1)
	t:assert(c.y, 1)

	-- vec % scalar
	local d = a % 3
	t:assert(d.x, 1)
	t:assert(d.y, 1)

	-- scalar % vec
	local e = 10 % a
	t:assert(e.x, 0)
	t:assert(e.y, 3)
end)

Test.new("vec2 power", function(t)
	local a = vec2(2, 3)
	local b = vec2(3, 2)

	local c = a ^ b
	t:assert(c.x, 8)
	t:assert(c.y, 9)

	-- vec ^ scalar
	local d = a ^ 3
	t:assert(d.x, 8)
	t:assert(d.y, 27)

	-- scalar ^ vec
	local e = 2 ^ a
	t:assert(e.x, 4)
	t:assert(e.y, 8)
end)

Test.new("vec2 unary minus", function(t)
	local a = vec2(1, -2)
	local b = -a
	t:assert(b.x, -1)
	t:assert(b.y, 2)
end)

Test.new("vec2 equality", function(t)
	local a = vec2(1, 2)
	local b = vec2(1, 2)
	local c = vec2(1, 3)
	local d = vec2(1.0, 2.0)

	t:assert(a == b, true)
	t:assert(a == c, false)
	t:assert(a == d, true)
	t:assert(a == vec2(1, 2.000001), false) -- exact equality
end)

Test.new("vec3 constructor", function(t)
	-- default
	local zero = vec3()
	t:assert(zero.x, 0)
	t:assert(zero.y, 0)
	t:assert(zero.z, 0)

	-- single number
	local one = vec3(5)
	t:assert(one.x, 5)
	t:assert(one.y, 5)
	t:assert(one.z, 5)

	-- three numbers
	local p = vec3(3, 7, 11)
	t:assert(p.x, 3)
	t:assert(p.y, 7)
	t:assert(p.z, 11)
end)

Test.new("vec3 rgb access", function(t)
	local v = vec3(1, 2, 3)
	t:assert(v.r, 1)
	t:assert(v.g, 2)
	t:assert(v.b, 3)

	-- alias should be the same as xyz
	t:assert(v.x, v.r)
	t:assert(v.y, v.g)
	t:assert(v.z, v.b)
end)

Test.new("vec3 addition", function(t)
	local a = vec3(1, 2, 3)
	local b = vec3(4, 5, 6)

	local c = a + b
	t:assert(c.x, 5)
	t:assert(c.y, 7)
	t:assert(c.z, 9)

	-- vec + scalar
	local d = a + 10
	t:assert(d.x, 11)
	t:assert(d.y, 12)
	t:assert(d.z, 13)
end)

Test.new("vec3 subtraction", function(t)
	local a = vec3(10, 20, 30)
	local b = vec3(3, 7, 11)

	local c = a - b
	t:assert(c.x, 7)
	t:assert(c.y, 13)
	t:assert(c.z, 19)

	-- vec - scalar
	local d = a - 5
	t:assert(d.x, 5)
	t:assert(d.y, 15)
	t:assert(d.z, 25)
end)

Test.new("vec3 division", function(t)
	local a = vec3(12, 20, 30)
	local b = vec3(3, 4, 5)

	local c = a / b
	t:assert(c.x, 4)
	t:assert(c.y, 5)
	t:assert(c.z, 6)

	-- vec / scalar
	local d = a / 2
	t:assert(d.x, 6)
	t:assert(d.y, 10)
	t:assert(d.z, 15)
end)

Test.new("vec3 modulo", function(t)
	local a = vec3(10, 7, 15)
	local b = vec3(3, 2, 4)

	local c = a % b
	t:assert(c.x, 1)
	t:assert(c.y, 1)
	t:assert(c.z, 3)
end)

Test.new("vec3 power", function(t)
	local a = vec3(2, 3, 4)
	local b = vec3(3, 2, 1)

	local c = a ^ b
	t:assert(c.x, 8)
	t:assert(c.y, 9)
	t:assert(c.z, 4)
end)

Test.new("vec3 unary minus", function(t)
	local a = vec3(1, -2, 3)
	local b = -a
	t:assert(b.x, -1)
	t:assert(b.y, 2)
	t:assert(b.z, -3)
end)

Test.new("vec3 equality", function(t)
	local a = vec3(1, 2, 3)
	local b = vec3(1, 2, 3)
	local c = vec3(1, 2, 4)

	t:assert(a == b, true)
	t:assert(a == c, false)
end)

Test.new("vec4 constructor", function(t)
	-- default
	local zero = vec4()
	t:assert(zero.x, 0)
	t:assert(zero.y, 0)
	t:assert(zero.z, 0)
	t:assert(zero.w, 0)

	-- single number
	local one = vec4(5)
	t:assert(one.x, 5)
	t:assert(one.y, 5)
	t:assert(one.z, 5)
	t:assert(one.w, 5)

	-- four numbers
	local p = vec4(3, 7, 11, 15)
	t:assert(p.x, 3)
	t:assert(p.y, 7)
	t:assert(p.z, 11)
	t:assert(p.w, 15)
end)

Test.new("vec4 rgba access", function(t)
	local v = vec4(1, 2, 3, 4)
	t:assert(v.r, 1)
	t:assert(v.g, 2)
	t:assert(v.b, 3)
	t:assert(v.a, 4)

	-- alias should match xyzw
	t:assert(v.x, v.r)
	t:assert(v.y, v.g)
	t:assert(v.z, v.b)
	t:assert(v.w, v.a)
end)

Test.new("vec4 addition", function(t)
	local a = vec4(1, 2, 3, 4)
	local b = vec4(5, 6, 7, 8)

	local c = a + b
	t:assert(c.x, 6)
	t:assert(c.y, 8)
	t:assert(c.z, 10)
	t:assert(c.w, 12)
end)

Test.new("vec4 subtraction", function(t)
	local a = vec4(10, 20, 30, 40)
	local b = vec4(1, 3, 5, 7)

	local c = a - b
	t:assert(c.x, 9)
	t:assert(c.y, 17)
	t:assert(c.z, 25)
	t:assert(c.w, 33)
end)

Test.new("vec4 division", function(t)
	local a = vec4(20, 30, 40, 50)
	local b = vec4(2, 3, 4, 5)

	local c = a / b
	t:assert(c.x, 10)
	t:assert(c.y, 10)
	t:assert(c.z, 10)
	t:assert(c.w, 10)

	-- vec / scalar
	local d = a / 5
	t:assert(d.x, 4)
	t:assert(d.y, 6)
	t:assert(d.z, 8)
	t:assert(d.w, 10)
end)

Test.new("vec4 modulo", function(t)
	local a = vec4(10, 7, 15, 9)
	local b = vec4(3, 2, 4, 3)

	local c = a % b
	t:assert(c.x, 1)
	t:assert(c.y, 1)
	t:assert(c.z, 3)
	t:assert(c.w, 0)
end)

Test.new("vec4 power", function(t)
	local a = vec4(2, 3, 4, 5)
	local b = vec4(3, 2, 1, 0)

	local c = a ^ b
	t:assert(c.x, 8)
	t:assert(c.y, 9)
	t:assert(c.z, 4)
	t:assert(c.w, 1)
end)

Test.new("vec4 unary minus", function(t)
	local a = vec4(1, -2, 3, -4)
	local b = -a
	t:assert(b.x, -1)
	t:assert(b.y, 2)
	t:assert(b.z, -3)
	t:assert(b.w, 4)
end)

Test.new("vec4 equality", function(t)
	local a = vec4(1, 2, 3, 4)
	local b = vec4(1, 2, 3, 4)
	local c = vec4(1, 2, 3, 5)

	t:assert(a == b, true)
	t:assert(a == c, false)
end)
