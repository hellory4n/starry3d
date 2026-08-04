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

Test.new("math.abs", function(t)
	-- number
	t:assert(math.abs(-5), 5)
	t:assert(math.abs(5), 5)
	t:assert(math.abs(0), 0)

	-- vec2
	local v2 = math.abs(vec2(-3, 4))
	t:assert(v2.x, 3)
	t:assert(v2.y, 4)

	-- vec3
	local v3 = math.abs(vec3(-1, 2, -3))
	t:assert(v3.x, 1)
	t:assert(v3.y, 2)
	t:assert(v3.z, 3)

	-- vec4
	local v4 = math.abs(vec4(-1, 2, -3, 4))
	t:assert(v4.x, 1)
	t:assert(v4.y, 2)
	t:assert(v4.z, 3)
	t:assert(v4.w, 4)
end)

Test.new("math.ceil", function(t)
	-- number
	t:assert(math.ceil(1.2), 2)
	t:assert(math.ceil(-1.2), -1)
	t:assert(math.ceil(5), 5)

	-- vec2
	local v2 = math.ceil(vec2(1.2, -1.8))
	t:assert(v2.x, 2)
	t:assert(v2.y, -1)

	-- vec3
	local v3 = math.ceil(vec3(0.1, 2.0, -0.5))
	t:assert(v3.x, 1)
	t:assert(v3.y, 2)
	t:assert(v3.z, 0)
end)

Test.new("math.floor", function(t)
	-- number
	t:assert(math.floor(1.8), 1)
	t:assert(math.floor(-1.2), -2)
	t:assert(math.floor(5), 5)

	-- vec2
	local v2 = math.floor(vec2(1.8, -1.2))
	t:assert(v2.x, 1)
	t:assert(v2.y, -2)

	-- vec4
	local v4 = math.floor(vec4(3.9, -0.1, 2.0, -4.7))
	t:assert(v4.x, 3)
	t:assert(v4.y, -1)
	t:assert(v4.z, 2)
	t:assert(v4.w, -5)
end)

Test.new("math.round", function(t)
	-- number
	t:assert(math.round(1.4), 1)
	t:assert(math.round(1.5), 2)
	t:assert(math.round(-1.5), -2)
	t:assert(math.round(-1.4), -1)

	-- vec2
	local v2 = math.round(vec2(1.4, 1.6))
	t:assert(v2.x, 1)
	t:assert(v2.y, 2)

	-- vec3
	local v3 = math.round(vec3(-1.5, 2.3, 0.5))
	t:assert(v3.x, -2)
	t:assert(v3.y, 2)
	t:assert(v3.z, 1)
end)

Test.new("math.deg", function(t)
	-- number
	t:assert_approx(math.deg(math.pi), 180)
	t:assert_approx(math.deg(math.pi / 2), 90)

	-- vec2
	local v2 = math.deg(vec2(math.pi, math.pi / 2))
	t:assert_approx(v2.x, 180)
	t:assert_approx(v2.y, 90)
end)

Test.new("math.rad", function(t)
	-- number
	t:assert_approx(math.rad(180), math.pi)
	t:assert_approx(math.rad(90), math.pi / 2)

	-- vec3
	local v3 = math.rad(vec3(180, 90, 0))
	t:assert_approx(v3.x, math.pi)
	t:assert_approx(v3.y, math.pi / 2)
	t:assert_approx(v3.z, 0)
end)

Test.new("math.fmod", function(t)
	-- number
	t:assert(math.fmod(10, 3), 1)
	t:assert(math.fmod(-10, 3), -1)

	-- vec2
	local v2 = math.fmod(vec2(10, 7), vec2(3, 4))
	t:assert(v2.x, 1)
	t:assert(v2.y, 3)

	-- mixed scalar
	local v2s = math.fmod(vec2(10, 7), 3)
	t:assert(v2s.x, 1)
	t:assert(v2s.y, 1)
end)

Test.new("math.pow", function(t)
	-- number
	t:assert(math.pow(2, 3), 8)
	t:assert_approx(math.pow(4, 0.5), 2)

	-- vec2
	local v2 = math.pow(vec2(2, 3), vec2(3, 2))
	t:assert(v2.x, 8)
	t:assert(v2.y, 9)

	-- vec ^ scalar
	local v2s = math.pow(vec2(2, 4), 2)
	t:assert(v2s.x, 4)
	t:assert(v2s.y, 16)
end)

Test.new("math.clamp", function(t)
	-- number
	t:assert(math.clamp(5, 0, 10), 5)
	t:assert(math.clamp(-5, 0, 10), 0)
	t:assert(math.clamp(15, 0, 10), 10)

	-- vec2
	local v2 = math.clamp(vec2(-5, 15), vec2(0, 0), vec2(10, 10))
	t:assert(v2.x, 0)
	t:assert(v2.y, 10)

	-- vec3 with scalar bounds
	local v3 = math.clamp(vec3(-1, 5, 20), 0, 10)
	t:assert(v3.x, 0)
	t:assert(v3.y, 5)
	t:assert(v3.z, 10)
end)

Test.new("math.lerp", function(t)
	-- number
	t:assert_approx(math.lerp(0, 10, 0.5), 5)
	t:assert_approx(math.lerp(0, 10, 0), 0)
	t:assert_approx(math.lerp(0, 10, 1), 10)

	-- vec2
	local v2 = math.lerp(vec2(0, 0), vec2(10, 20), 0.5)
	t:assert_approx(v2.x, 5)
	t:assert_approx(v2.y, 10)

	-- vec3 with vector t
	local v3 = math.lerp(vec3(0, 0, 0), vec3(10, 20, 30), vec3(0.5, 0.25, 0))
	t:assert_approx(v3.x, 5)
	t:assert_approx(v3.y, 5)
	t:assert_approx(v3.z, 0)
end)

Test.new("math.inverse_lerp", function(t)
	-- number
	t:assert_approx(math.inverse_lerp(0, 10, 5), 0.5)
	t:assert_approx(math.inverse_lerp(0, 10, 0), 0)
	t:assert_approx(math.inverse_lerp(0, 10, 10), 1)

	-- vec2
	local v2 = math.inverse_lerp(vec2(0, 0), vec2(10, 20), vec2(5, 10))
	t:assert_approx(v2.x, 0.5)
	t:assert_approx(v2.y, 0.5)
end)

Test.new("math.remap", function(t)
	-- number
	t:assert_approx(math.remap(5, 0, 10, 0, 100), 50)
	t:assert_approx(math.remap(0, 0, 10, 0, 100), 0)
	t:assert_approx(math.remap(10, 0, 10, 0, 100), 100)

	-- vec2
	local v2 = math.remap(vec2(5, 2), vec2(0, 0), vec2(10, 4), vec2(0, 0), vec2(100, 200))
	t:assert_approx(v2.x, 50)
	t:assert_approx(v2.y, 100)
end)

Test.new("math.approx_equal", function(t)
	-- number
	t:assert(math.approx_equal(1.0, 1.0), true)
	t:assert(math.approx_equal(1.0, 1.0000001), true)
	t:assert(math.approx_equal(1.0, 1.1), false)
	t:assert(math.approx_equal(1.0, 1.1, 0.2), true)

	-- vec2
	t:assert(math.approx_equal(vec2(1, 2), vec2(1, 2)), true)
	t:assert(math.approx_equal(vec2(1, 2), vec2(1.0000001, 2)), true)
	t:assert(math.approx_equal(vec2(1, 2), vec2(1, 3)), false)
end)

Test.new("bvec2 constructor", function(t)
	local z = bvec2()
	t:assert(z.x, false)
	t:assert(z.y, false)

	local a = bvec2(true)
	t:assert(a.x, true)
	t:assert(a.y, true)

	local b = bvec2(true, false)
	t:assert(b.x, true)
	t:assert(b.y, false)
end)

Test.new("bvec3 constructor", function(t)
	local z = bvec3()
	t:assert(z.x, false)
	t:assert(z.y, false)
	t:assert(z.z, false)

	local a = bvec3(true)
	t:assert(a.x, true)
	t:assert(a.y, true)
	t:assert(a.z, true)

	local b = bvec3(true, false, true)
	t:assert(b.x, true)
	t:assert(b.y, false)
	t:assert(b.z, true)
end)

Test.new("bvec4 constructor", function(t)
	local z = bvec4()
	t:assert(z.x, false)
	t:assert(z.y, false)
	t:assert(z.z, false)
	t:assert(z.w, false)

	local a = bvec4(true)
	t:assert(a.x, true)
	t:assert(a.y, true)
	t:assert(a.z, true)
	t:assert(a.w, true)

	local b = bvec4(true, false, true, false)
	t:assert(b.x, true)
	t:assert(b.y, false)
	t:assert(b.z, true)
	t:assert(b.w, false)
end)

Test.new("quat constructor", function(t)
	local id = quat()
	t:assert(id.x, 0)
	t:assert(id.y, 0)
	t:assert(id.z, 0)
	t:assert(id.w, 1)

	t:assert(Quat.identity.x, 0)
	t:assert(Quat.identity.y, 0)
	t:assert(Quat.identity.z, 0)
	t:assert(Quat.identity.w, 1)

	local q = quat(1, 2, 3, 4)
	t:assert(q.x, 1)
	t:assert(q.y, 2)
	t:assert(q.z, 3)
	t:assert(q.w, 4)
end)

Test.new("quat arithmetic", function(t)
	local a = quat(1, 2, 3, 4)
	local b = quat(5, 6, 7, 8)

	local sum = a + b
	t:assert(sum.x, 6)
	t:assert(sum.y, 8)
	t:assert(sum.z, 10)
	t:assert(sum.w, 12)

	local diff = a - b
	t:assert(diff.x, -4)
	t:assert(diff.y, -4)
	t:assert(diff.z, -4)
	t:assert(diff.w, -4)

	local neg = -a
	t:assert(neg.x, -1)
	t:assert(neg.y, -2)
	t:assert(neg.z, -3)
	t:assert(neg.w, -4)
end)

Test.new("quat multiply", function(t)
	local id = quat()
	local q = quat(0, 0, 0, 1)
	t:assert(id * q == id, true)

	-- simple non-identity multiply (Hamilton product)
	local a = quat(1, 0, 0, 0)
	local b = quat(0, 1, 0, 0)
	local c = a * b
	t:assert(c.x, 0)
	t:assert(c.y, 0)
	t:assert(c.z, 1)
	t:assert(c.w, 0)
end)

Test.new("quat equality", function(t)
	local a = quat(1, 2, 3, 4)
	local b = quat(1, 2, 3, 4)
	local c = quat(1, 2, 3, 5)

	t:assert(a == b, true)
	t:assert(a == c, false)
end)

Test.new("math.dot", function(t)
	t:assert(math.dot(vec2(1, 2), vec2(3, 4)), 11)
	t:assert(math.dot(vec3(1, 2, 3), vec3(4, 5, 6)), 32)
	t:assert(math.dot(vec4(1, 2, 3, 4), vec4(5, 6, 7, 8)), 70)
	t:assert(math.dot(quat(1, 2, 3, 4), quat(5, 6, 7, 8)), 70)
end)

Test.new("math.length / length_squared", function(t)
	t:assert_approx(math.length(vec2(3, 4)), 5)
	t:assert(math.length_squared(vec2(3, 4)), 25)

	t:assert_approx(math.length(vec3(1, 2, 2)), 3)
	t:assert(math.length_squared(vec3(1, 2, 2)), 9)

	t:assert_approx(math.length(quat(0, 0, 0, 1)), 1)
end)

Test.new("math.distance", function(t)
	t:assert_approx(math.distance(vec2(0, 0), vec2(3, 4)), 5)
	t:assert_approx(math.distance(vec3(1, 1, 1), vec3(1, 1, 1)), 0)
end)

Test.new("math.cross", function(t)
	local a = vec3(1, 0, 0)
	local b = vec3(0, 1, 0)
	local c = math.cross(a, b)
	t:assert(c.x, 0)
	t:assert(c.y, 0)
	t:assert(c.z, 1)

	local d = math.cross(b, a)
	t:assert(d.x, 0)
	t:assert(d.y, 0)
	t:assert(d.z, -1)
end)

Test.new("math.normalize", function(t)
	local v2 = math.normalize(vec2(3, 4))
	t:assert_approx(v2.x, 0.6)
	t:assert_approx(v2.y, 0.8)
	t:assert_approx(math.length(v2), 1)

	local v3 = math.normalize(vec3(0, 0, 5))
	t:assert_approx(v3.x, 0)
	t:assert_approx(v3.y, 0)
	t:assert_approx(v3.z, 1)

	local q = math.normalize(quat(0, 0, 0, 2))
	t:assert_approx(q.x, 0)
	t:assert_approx(q.y, 0)
	t:assert_approx(q.z, 0)
	t:assert_approx(q.w, 1)
end)

Test.new("math.normalize_color_from_rgb8 / rgb8_from_normalized_color", function(t)
	local c3 = math.normalize_color_from_rgb8(vec3(255, 128, 0))
	t:assert_approx(c3.x, 1)
	t:assert_approx(c3.y, 128 / 255)
	t:assert_approx(c3.z, 0)

	local c4 = math.normalize_color_from_rgb8(vec4(255, 0, 128, 255))
	t:assert_approx(c4.x, 1)
	t:assert_approx(c4.y, 0)
	t:assert_approx(c4.z, 128 / 255)
	t:assert_approx(c4.w, 1)

	local back = math.rgb8_from_normalized_color(c3)
	t:assert_approx(back.x, 255)
	t:assert_approx(back.y, 128)
	t:assert_approx(back.z, 0)
end)

Test.new("math.axis_angle", function(t)
	local q = math.axis_angle(vec3(0, 1, 0), math.pi)
	-- 180° around Y should be approximately (0, 1, 0, 0)
	t:assert_approx(q.x, 0)
	t:assert_approx(q.y, 1)
	t:assert_approx(q.z, 0)
	t:assert_approx(q.w, 0)
end)

Test.new("math.euler_to_quat / vec3_to_quat / quat_to_euler", function(t)
	local q1 = math.euler_to_quat(0, 0, 0)
	t:assert_approx(q1.x, 0)
	t:assert_approx(q1.y, 0)
	t:assert_approx(q1.z, 0)
	t:assert_approx(q1.w, 1)

	local q2 = math.vec3_to_quat(vec3(0, 0, 0))
	t:assert(q1 == q2, true)

	local euler = math.quat_to_euler(q1)
	t:assert_approx(euler.x, 0)
	t:assert_approx(euler.y, 0)
	t:assert_approx(euler.z, 0)
end)

Test.new("math.conjugate / inverse", function(t)
	local q = quat(1, 2, 3, 4)
	local c = math.conjugate(q)
	t:assert(c.x, -1)
	t:assert(c.y, -2)
	t:assert(c.z, -3)
	t:assert(c.w, 4)

	local inv = math.inverse(math.normalize(q))
	-- for unit quaternions inverse == conjugate
	local nq = math.normalize(q)
	local expected = math.conjugate(nq)
	t:assert_approx(inv.x, expected.x)
	t:assert_approx(inv.y, expected.y)
	t:assert_approx(inv.z, expected.z)
	t:assert_approx(inv.w, expected.w)
end)

Test.new("math.slerp", function(t)
	local a = quat()
	local b = math.axis_angle(vec3(0, 1, 0), math.pi)
	local mid = math.slerp(a, b, 0.5)
	t:assert_approx(math.length(mid), 1)
end)

Test.new("math.angle / axis", function(t)
	local q = math.axis_angle(vec3(0, 1, 0), math.pi / 2)
	t:assert_approx(math.angle(q), math.pi / 2)

	local ax = math.axis(q)
	t:assert_approx(ax.x, 0)
	t:assert_approx(ax.y, 1)
	t:assert_approx(ax.z, 0)
end)

Test.new("math.all / math.any", function(t)
	t:assert(math.all(bvec2(true, true)), true)
	t:assert(math.all(bvec2(true, false)), false)
	t:assert(math.all(bvec3(true, true, true)), true)
	t:assert(math.all(bvec4(true, true, true, false)), false)

	t:assert(math.any(bvec2(false, false)), false)
	t:assert(math.any(bvec2(false, true)), true)
	t:assert(math.any(bvec3(false, false, true)), true)
	t:assert(math.any(bvec4(false, false, false, false)), false)
end)

Test.new("math.less_than / less_than_equal", function(t)
	local lt = math.less_than(vec2(1, 3), vec2(2, 2))
	t:assert(lt.x, true)
	t:assert(lt.y, false)

	local le = math.less_than_equal(vec3(1, 2, 3), vec3(1, 3, 2))
	t:assert(le.x, true)
	t:assert(le.y, true)
	t:assert(le.z, false)
end)

Test.new("math.greater_than / greater_than_equal", function(t)
	local gt = math.greater_than(vec2(3, 1), vec2(2, 2))
	t:assert(gt.x, true)
	t:assert(gt.y, false)

	local ge = math.greater_than_equal(vec4(1, 2, 3, 4), vec4(1, 1, 4, 4))
	t:assert(ge.x, true)
	t:assert(ge.y, true)
	t:assert(ge.z, false)
	t:assert(ge.w, true)
end)

Test.new("math.hex string RGB", function(t)
	-- short form with #
	local c = math.hex("#F00")
	t:assert_approx(c.r, 1)
	t:assert_approx(c.g, 0)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 1)

	-- short form without #
	c = math.hex("0F0")
	t:assert_approx(c.r, 0)
	t:assert_approx(c.g, 1)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 1)

	-- full form
	c = math.hex("#00FF00")
	t:assert_approx(c.r, 0)
	t:assert_approx(c.g, 1)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 1)

	c = math.hex("0000FF")
	t:assert_approx(c.r, 0)
	t:assert_approx(c.g, 0)
	t:assert_approx(c.b, 1)
	t:assert_approx(c.a, 1)
end)

Test.new("math.hex string RGBA", function(t)
	-- short form
	local c = math.hex("#F008")
	t:assert_approx(c.r, 1)
	t:assert_approx(c.g, 0)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 0x88 / 255)

	-- full form
	c = math.hex("#FF000080")
	t:assert_approx(c.r, 1)
	t:assert_approx(c.g, 0)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 0x80 / 255)

	c = math.hex("00FF00FF")
	t:assert_approx(c.r, 0)
	t:assert_approx(c.g, 1)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 1)
end)

Test.new("math.hex edge cases", function(t)
	-- black
	local c = math.hex("#000")
	t:assert_approx(c.r, 0)
	t:assert_approx(c.g, 0)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 1)

	-- white
	c = math.hex("#FFFFFF")
	t:assert_approx(c.r, 1)
	t:assert_approx(c.g, 1)
	t:assert_approx(c.b, 1)
	t:assert_approx(c.a, 1)

	-- fully transparent
	c = math.hex("#00000000")
	t:assert_approx(c.r, 0)
	t:assert_approx(c.g, 0)
	t:assert_approx(c.b, 0)
	t:assert_approx(c.a, 0)

	-- mixed case
	c = math.hex("#aAbBcC")
	t:assert_approx(c.r, 0xAA / 255)
	t:assert_approx(c.g, 0xBB / 255)
	t:assert_approx(c.b, 0xCC / 255)
	t:assert_approx(c.a, 1)
end)
