--[[
Usage:
```lua
local Test = require("test")

Test.new("addition", function(t)
	t:assert(2 + 2, 4)
end)

Test.run_all()
```
]]

--- @class Test
--- @field name string
--- @field callback fun(t: Test)
local Test = {}
Test.__index = Test

all_tests = {}

--- Creates a new test. This will then be run with `Test.run_all()`
--- @param name string
--- @param func fun(t: Test)
function Test.new(name, func)
	local test_instance = { name = name, callback = func }
	setmetatable(test_instance, Test)
	table.insert(all_tests, test_instance)
end

--- Runs all tests.
function Test.run_all()
	local failed_tests = 0
	for _, test in ipairs(all_tests) do
		local ok = xpcall(test.callback, function(x)
			print(debug.traceback(string.format("test \"%s\" failed: %s", test.name, x)))
		end, test)

		if not ok then
			failed_tests = failed_tests + 1
		end
	end

	if failed_tests == 0 then
		print(string.format("all %d tests succeded", #all_tests))
	else
		print(string.format("%d/%d tests failed", failed_tests, #all_tests))
	end
end

function Test:assert(actual, expected)
	if actual ~= expected then
		error(
			"failed assertion: expected " ..
			tostring(expected) .. ", got " .. tostring(actual))
	end
end

--- Tests if 2 float numbers are approximately equal
--- @param actual number
--- @param expected number
--- @param epsilon number? Defaults to 1.192092896e-07
function Test:assert_approx(actual, expected, epsilon)
	epsilon = epsilon or 1.192092896e-07
	local difference = math.abs(actual - expected)
	if difference > epsilon then
		error("failed assertion: expected " ..
			tostring(expected) .. ", got " .. tostring(actual))
	end
end

return Test
