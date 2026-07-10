-- preloaded code: builtin.lua
-- note: this is massive, search for "----" to find different sections
local ffi = require("ffi")

st = {}

-----------------------
---- C DEFINITIONS ----
-----------------------
ffi.cdef [[
void st_test(void);
]]

function st.test()
	ffi.C.st_test()
end

--------------
---- MATH ----
--------------

-- TODO it'd be nice to use simd here but i genuinely can't be bothered it's probably
-- optimized already to do that anyway who cares

--- @class st.Vec2: table
--- @field x number
--- @field y number
st.Vec2 = {}
st.Vec2.__index = st.Vec2

--- @param x number?
--- @param y number?
--- @return st.Vec2
function st.vec2(x, y)
	-- allow initializing st.vec2(1) -> {1, 1}
	if y == nil then y = x end

	local self = { x = x or 0, y = y or 0 }
	return setmetatable(self, st.Vec2)
end

--- @param a st.Vec2 | number
--- @param b st.Vec2 | number
--- @return st.Vec2
function st.Vec2.__add(a, b)
	if type(b) == "number" then
		return st.vec2(a.x + b, a.y + b)
	elseif type(a) == "number" then
		return st.vec2(a + b.x, a + b.y)
	end
	return st.vec2(a.x + b.x, a.y + b.y)
end

--- @param a st.Vec2 | number
--- @param b st.Vec2 | number
--- @return st.Vec2
function st.Vec2.__sub(a, b)
	if type(b) == "number" then
		return st.vec2(a.x - b, a.y - b)
	elseif type(a) == "number" then
		return st.vec2(a - b.x, a - b.y)
	end
	return st.vec2(a.x - b.x, a.y - b.y)
end

--- @param a st.Vec2 | number
--- @param b st.Vec2 | number
--- @return st.Vec2
function st.Vec2.__mul(a, b)
	if type(b) == "number" then
		return st.vec2(a.x * b, a.y * b)
	elseif type(a) == "number" then
		return st.vec2(a * b.x, a * b.y)
	end
	return st.vec2(a.x * b.x, a.y * b.y)
end

--- @param a st.Vec2 | number
--- @param b st.Vec2 | number
--- @return st.Vec2
function st.Vec2.__div(a, b)
	if type(b) == "number" then
		return st.vec2(a.x / b, a.y / b)
	elseif type(a) == "number" then
		return st.vec2(a / b.x, a / b.y)
	end
	return st.vec2(a.x / b.x, a.y / b.y)
end

--- @param a st.Vec2 | number
--- @param b st.Vec2 | number
--- @return st.Vec2
function st.Vec2.__mod(a, b)
	if type(b) == "number" then
		return st.vec2(a.x % b, a.y % b)
	elseif type(a) == "number" then
		return st.vec2(a % b.x, a % b.y)
	end
	return st.vec2(a.x % b.x, a.y % b.y)
end

--- @param a st.Vec2 | number
--- @param b st.Vec2 | number
--- @return st.Vec2
function st.Vec2.__pow(a, b)
	if type(b) == "number" then
		return st.vec2(a.x ^ b, a.y ^ b)
	elseif type(a) == "number" then
		return st.vec2(a ^ b.x, a ^ b.y)
	end
	return st.vec2(a.x ^ b.x, a.y ^ b.y)
end

--- @param a st.Vec2
--- @return st.Vec2
function st.Vec2.__unm(a)
	return st.vec2(-a.x, -a.y)
end

--- @param a st.Vec2
--- @param b st.Vec2
--- @return boolean
function st.Vec2.__eq(a, b)
	return a.x == b.x and a.y == b.y
end

--- @param v st.Vec2
--- @return string
function st.Vec2.__tostring(v)
	return string.format("vec2(%.3f, %.3f)", v.x, v.y)
end

function st.Vec2:dot(other)
	return self.x * other.x + self.y * other.y
end
