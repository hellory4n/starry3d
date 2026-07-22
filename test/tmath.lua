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
