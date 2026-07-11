-- preloaded code: math.lua
local ffi = require("ffi")

--- math functions have to be redefined to support vectors
--- @class oldmath: mathlib
local oldmath = table.shallow_copy(math)
--- @class starrymath: table
math = {
	pi = oldmath.pi,
	huge = oldmath.huge,
	random = oldmath.random,
	randomseed = oldmath.randomseed,
}

ffi.cdef [[
float st_round(float);
]]

--- @class Vec2: table
--- @field x number
--- @field y number
Vec2 = {}
Vec2.__index = Vec2

--- @param x number?
--- @param y number?
--- @return Vec2
function vec2(x, y)
	-- allow initializing vec2(1) -> {1, 1}
	if y == nil then y = x end

	local self = { x = x or 0, y = y or 0 }
	return setmetatable(self, Vec2)
end

--- @param a Vec2 | number
--- @param b Vec2 | number
--- @return Vec2
function Vec2.__add(a, b)
	local left = type(a) == "number" and vec2(a) or a
	local right = type(b) == "number" and vec2(b) or b
	return vec2(left.x + right.x, left.y + right.y)
end

--- @param a Vec2 | number
--- @param b Vec2 | number
--- @return Vec2
function Vec2.__sub(a, b)
	local left = type(a) == "number" and vec2(a) or a
	local right = type(b) == "number" and vec2(b) or b
	return vec2(left.x - right.x, left.y - right.y)
end

--- @param a Vec2 | number
--- @param b Vec2 | number
--- @return Vec2
function Vec2.__mul(a, b)
	local left = type(a) == "number" and vec2(a) or a
	local right = type(b) == "number" and vec2(b) or b
	return vec2(left.x * right.x, left.y * right.y)
end

--- @param a Vec2 | number
--- @param b Vec2 | number
--- @return Vec2
function Vec2.__div(a, b)
	local left = type(a) == "number" and vec2(a) or a
	local right = type(b) == "number" and vec2(b) or b
	return vec2(left.x / right.x, left.y / right.y)
end

--- @param a Vec2 | number
--- @param b Vec2 | number
--- @return Vec2
function Vec2.__mod(a, b)
	local left = type(a) == "number" and vec2(a) or a
	local right = type(b) == "number" and vec2(b) or b
	return vec2(left.x % right.x, left.y % right.y)
end

--- @param a Vec2 | number
--- @param b Vec2 | number
--- @return Vec2
function Vec2.__pow(a, b)
	local left = type(a) == "number" and vec2(a) or a
	local right = type(b) == "number" and vec2(b) or b
	return vec2(left.x ^ right.x, left.y ^ right.y)
end

--- @param a Vec2
--- @return Vec2
function Vec2.__unm(a)
	return vec2(-a.x, -a.y)
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.__eq(a, b)
	if type(a) ~= type(b) then return false end
	if getmetatable(a) ~= getmetatable(b) then return false end
	return a.x == b.x and a.y == b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.__lt(a, b)
	return a.x < b.x and a.y < b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.__le(a, b)
	return a.x <= b.x and a.y <= b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.all_less_than(a, b)
	return a.x < b.x and a.y < b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.any_less_than(a, b)
	return a.x < b.x or a.y < b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.all_less_than_or_equal(a, b)
	return a.x <= b.x and a.y <= b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.any_less_than_or_equal(a, b)
	return a.x <= b.x or a.y <= b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.all_greater_than(a, b)
	return a.x > b.x and a.y > b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.any_greater_than(a, b)
	return a.x > b.x or a.y > b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.all_greater_than_or_equal(a, b)
	return a.x >= b.x and a.y >= b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.any_greater_than_or_equal(a, b)
	return a.x >= b.x or a.y >= b.y
end

--- @param v Vec2
--- @return string
function Vec2.__tostring(v)
	return string.format("vec2(%.3f, %.3f)", v.x, v.y)
end

--- @param other Vec2
--- @return number
function Vec2:dot(other)
	return self.x * other.x + self.y * other.y
end

--- @return number
function Vec2:length()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

--- @return number
function Vec2:length_squared()
	return self.x * self.x + self.y * self.y
end

--- @return Vec2
function Vec2:normalize()
	local len = self:length()
	if len == 0 then return vec2() end
	return self / len
end

--- @return Vec2
function Vec2:clone()
	return vec2(self.x, self.y)
end

--- @class Vec3: table
--- @field x number
--- @field y number
--- @field z number
--- @field r number Red channel, equivalent to X.
--- @field g number Green channel, equivalent to Y.
--- @field b number Blue channel, equivalent to Z.
Vec3 = {}

function Vec3.__index(vec, comp)
	if comp == "r" then
		return vec.x
	elseif comp == "g" then
		return vec.y
	elseif comp == "b" then
		return vec.z
	else
		return vec[comp]
	end
end

--- @param x number?
--- @param y number?
--- @param z number?
--- @return Vec3
function vec3(x, y, z)
	-- allow initializing vec3(1) -> {1, 1, 1}
	if z == nil then z = x end
	if y == nil then y = x end

	local self = { x = x or 0, y = y or 0, z = z or 0 }
	return setmetatable(self, Vec3)
end

--- @param a Vec3 | number
--- @param b Vec3 | number
--- @return Vec3
function Vec3.__add(a, b)
	local left = type(a) == "number" and vec3(a) or a
	local right = type(b) == "number" and vec3(b) or b
	return vec3(left.x + right.x, left.y + right.y, left.z + right.z)
end

--- @param a Vec3 | number
--- @param b Vec3 | number
--- @return Vec3
function Vec3.__sub(a, b)
	local left = type(a) == "number" and vec3(a) or a
	local right = type(b) == "number" and vec3(b) or b
	return vec3(left.x - right.x, left.y - right.y, left.z - right.z)
end

--- @param a Vec3 | number
--- @param b Vec3 | number
--- @return Vec3
function Vec3.__mul(a, b)
	local left = type(a) == "number" and vec3(a) or a
	local right = type(b) == "number" and vec3(b) or b
	return vec3(left.x * right.x, left.y * right.y, left.z * right.z)
end

--- @param a Vec3 | number
--- @param b Vec3 | number
--- @return Vec3
function Vec3.__div(a, b)
	local left = type(a) == "number" and vec3(a) or a
	local right = type(b) == "number" and vec3(b) or b
	return vec3(left.x / right.x, left.y / right.y, left.z / right.z)
end

--- @param a Vec3 | number
--- @param b Vec3 | number
--- @return Vec3
function Vec3.__mod(a, b)
	local left = type(a) == "number" and vec3(a) or a
	local right = type(b) == "number" and vec3(b) or b
	return vec3(left.x % right.x, left.y % right.y, left.z % right.z)
end

--- @param a Vec3 | number
--- @param b Vec3 | number
--- @return Vec3
function Vec3.__pow(a, b)
	local left = type(a) == "number" and vec3(a) or a
	local right = type(b) == "number" and vec3(b) or b
	return vec3(left.x ^ right.x, left.y ^ right.y, left.z ^ right.z)
end

--- @param a Vec3
--- @return Vec3
function Vec3.__unm(a)
	return vec3(-a.x, -a.y, -a.z)
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.__eq(a, b)
	if type(a) ~= type(b) then return false end
	if getmetatable(a) ~= getmetatable(b) then return false end
	return a.x == b.x and a.y == b.y and a.z == b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.__lt(a, b)
	return a.x < b.x and a.y < b.y and a.z < b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.__le(a, b)
	return a.x <= b.x and a.y <= b.y and a.z <= b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.all_less_than(a, b)
	return a.x < b.x and a.y < b.y and a.z < b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.any_less_than(a, b)
	return a.x < b.x or a.y < b.y or a.z < b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.all_less_than_or_equal(a, b)
	return a.x <= b.x and a.y <= b.y and a.z <= b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.any_less_than_or_equal(a, b)
	return a.x <= b.x or a.y <= b.y or a.z <= b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.all_greater_than(a, b)
	return a.x > b.x and a.y > b.y and a.z > b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.any_greater_than(a, b)
	return a.x > b.x or a.y > b.y or a.z > b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.all_greater_than_or_equal(a, b)
	return a.x >= b.x and a.y >= b.y and a.z >= b.z
end

--- @param a Vec3
--- @param b Vec3
--- @return boolean
function Vec3.any_greater_than_or_equal(a, b)
	return a.x >= b.x or a.y >= b.y or a.z >= b.z
end

--- @param v Vec3
--- @return string
function Vec3.__tostring(v)
	return string.format("vec3(%.3f, %.3f, %.3f)", v.x, v.y, v.z)
end

--- @param other Vec3
--- @return number
function Vec3:dot(other)
	return self.x * other.x + self.y * other.y + self.z * other.z
end

--- @return number
function Vec3:length()
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

--- @return number
function Vec3:length_squared()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

--- @return Vec3
function Vec3:normalize()
	local len = self:length()
	if len == 0 then return vec3() end
	return self / len
end

--- @return Vec3
function Vec3:clone()
	return vec3(self.x, self.y, self.z)
end

--- @param other Vec3
--- @return Vec3
function Vec3:cross(other)
	return vec3(
		self.y * other.z - self.z * other.y,
		self.z * other.x - self.x * other.z,
		self.x * other.y - self.y * other.x
	)
end

--- @class Vec4: table
--- @field x number
--- @field y number
--- @field z number
--- @field w number
--- @field r number Red channel, equivalent to X.
--- @field g number Green channel, equivalent to Y.
--- @field b number Blue channel, equivalent to Z.
--- @field a number Alpha channel, equivalent to W.
Vec4 = {}

function Vec4.__index(vec, comp)
	if comp == "r" then
		return vec.x
	elseif comp == "g" then
		return vec.y
	elseif comp == "b" then
		return vec.z
	elseif comp == "a" then
		return vec.w
	else
		return vec[comp]
	end
end

--- @param x number?
--- @param y number?
--- @param z number?
--- @param w number?
--- @return Vec4
function vec4(x, y, z, w)
	-- allow initializing vec4(1) -> {1, 1, 1, 1}
	if w == nil then w = x end
	if z == nil then z = x end
	if y == nil then y = x end

	local self = { x = x or 0, y = y or 0, z = z or 0, w = w or 0 }
	return setmetatable(self, Vec4)
end

--- @param a Vec4 | number
--- @param b Vec4 | number
--- @return Vec4
function Vec4.__add(a, b)
	local left = type(a) == "number" and vec4(a) or a
	local right = type(b) == "number" and vec4(b) or b
	return vec4(left.x + right.x, left.y + right.y, left.z + right.z, left.w + right.w)
end

--- @param a Vec4 | number
--- @param b Vec4 | number
--- @return Vec4
function Vec4.__sub(a, b)
	local left = type(a) == "number" and vec4(a) or a
	local right = type(b) == "number" and vec4(b) or b
	return vec4(left.x - right.x, left.y - right.y, left.z - right.z, left.w - right.w)
end

--- @param a Vec4 | number
--- @param b Vec4 | number
--- @return Vec4
function Vec4.__mul(a, b)
	local left = type(a) == "number" and vec4(a) or a
	local right = type(b) == "number" and vec4(b) or b
	return vec4(left.x * right.x, left.y * right.y, left.z * right.z, left.w * right.w)
end

--- @param a Vec4 | number
--- @param b Vec4 | number
--- @return Vec4
function Vec4.__div(a, b)
	local left = type(a) == "number" and vec4(a) or a
	local right = type(b) == "number" and vec4(b) or b
	return vec4(left.x / right.x, left.y / right.y, left.z / right.z, left.w / right.w)
end

--- @param a Vec4 | number
--- @param b Vec4 | number
--- @return Vec4
function Vec4.__mod(a, b)
	local left = type(a) == "number" and vec4(a) or a
	local right = type(b) == "number" and vec4(b) or b
	return vec4(left.x % right.x, left.y % right.y, left.z % right.z, left.w % right.w)
end

--- @param a Vec4 | number
--- @param b Vec4 | number
--- @return Vec4
function Vec4.__pow(a, b)
	local left = type(a) == "number" and vec4(a) or a
	local right = type(b) == "number" and vec4(b) or b
	return vec4(left.x ^ right.x, left.y ^ right.y, left.z ^ right.z, left.w ^ right.w)
end

--- @param a Vec4
--- @return Vec4
function Vec4.__unm(a)
	return vec4(-a.x, -a.y, -a.z, -a.w)
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.__eq(a, b)
	if type(a) ~= type(b) then return false end
	if getmetatable(a) ~= getmetatable(b) then return false end
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.__lt(a, b)
	return a.x < b.x and a.y < b.y and a.z < b.z and a.w < b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.__le(a, b)
	return a.x <= b.x and a.y <= b.y and a.z <= b.z and a.w <= b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.all_less_than(a, b)
	return a.x < b.x and a.y < b.y and a.z < b.z and a.w < b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.any_less_than(a, b)
	return a.x < b.x or a.y < b.y or a.z < b.z or a.w < b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.all_less_than_or_equal(a, b)
	return a.x <= b.x and a.y <= b.y and a.z <= b.z and a.w <= b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.any_less_than_or_equal(a, b)
	return a.x <= b.x or a.y <= b.y or a.z <= b.z or a.w <= b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.all_greater_than(a, b)
	return a.x > b.x and a.y > b.y and a.z > b.z and a.w > b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.any_greater_than(a, b)
	return a.x > b.x or a.y > b.y or a.z > b.z or a.w > b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.all_greater_than_or_equal(a, b)
	return a.x >= b.x and a.y >= b.y and a.z >= b.z and a.w >= b.w
end

--- @param a Vec4
--- @param b Vec4
--- @return boolean
function Vec4.any_greater_than_or_equal(a, b)
	return a.x >= b.x or a.y >= b.y or a.z >= b.z or a.w >= b.w
end

--- @param v Vec4
--- @return string
function Vec4.__tostring(v)
	return string.format("vec4(%.3f, %.3f, %.3f, %.3f)", v.x, v.y, v.z, v.w)
end

--- @param other Vec4
--- @return number
function Vec4:dot(other)
	return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w
end

--- @return number
function Vec4:length()
	return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
end

--- @return number
function Vec4:length_squared()
	return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
end

--- @return Vec4
function Vec4:normalize()
	local len = self:length()
	if len == 0 then return vec4() end
	return self / len
end

--- @return Vec4
function Vec4:clone()
	return vec4(self.x, self.y, self.z, self.w)
end

-- redefine math functions to support vectors

--- @generic T number | Vec2 | Vec3 | Vec4
--- @param func function
--- @param arg1 T
local function oldmath_call1(func, arg1)
	if type(arg1) == "number" then
		return func(arg1)
	end

	ret = {}
	setmetatable(ret, getmetatable(arg1))

	for key, val in pairs(arg1) do
		ret[key] = func(val)
	end
	return ret
end

--- @generic T number | Vec2 | Vec3 | Vec4
--- @param func function
--- @param arg1 T
--- @param arg2 T
local function oldmath_call2(func, arg1, arg2)
	if type(arg1) == "number" then
		return func(arg1, arg2)
	end

	ret = {}
	setmetatable(ret, getmetatable(arg1))

	for key, _ in pairs(arg1) do
		ret[key] = func(arg1[key], arg2[key])
	end
	return ret
end

--- @generic T number | Vec2 | Vec3 | Vec4
--- @param func function
--- @param arg1 T
--- @param arg2 T
--- @param arg3 T
local function oldmath_call3(func, arg1, arg2, arg3)
	if type(arg1) == "number" then
		return func(arg1, arg2, arg3)
	end

	ret = {}
	setmetatable(ret, getmetatable(arg1))

	for key, _ in pairs(arg1) do
		ret[key] = func(arg1[key], arg2[key], arg3[key])
	end
	return ret
end

--- @generic T number | Vec2 | Vec3 | Vec4
--- @param func function
--- @param arg1 T
--- @param arg2 T
--- @param arg3 T
--- @param arg4 T
--- @param arg5 T
local function oldmath_call5(func, arg1, arg2, arg3, arg4, arg5)
	if type(arg1) == "number" then
		return func(arg1, arg2, arg3, arg4, arg5)
	end

	ret = {}
	setmetatable(ret, getmetatable(arg1))

	for key, _ in pairs(arg1) do
		ret[key] = func(arg1[key], arg2[key], arg3[key], arg4[key], arg5[key])
	end
	return ret
end

--- Returns the absolute value of `x`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.abs(x)
	return oldmath_call1(oldmath.abs, x)
end

--- Returns the arc cosine of `x` (in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.acos(x)
	return oldmath_call1(oldmath.acos, x)
end

--- Returns the arc sine of `x` (in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.asin(x)
	return oldmath_call1(oldmath.asin, x)
end

--- Returns the arc tangent of `x` (in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.atan(x)
	return oldmath_call1(oldmath.atan, x)
end

--- Returns the arc tangent of `y/x` (in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param y T
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.atan2(y, x)
	return oldmath_call2(oldmath.atan2, y, x)
end

--- Returns the smallest integral value larger than or equal to `x`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.ceil(x)
	return oldmath_call1(oldmath.ceil, x)
end

--- Returns the cosine of `x` (assumed to be in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.cos(x)
	return oldmath_call1(oldmath.cos, x)
end

--- Returns the hyperbolic cosine of `x` (assumed to be in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.cosh(x)
	return oldmath_call1(oldmath.cosh, x)
end

--- Converts the angle `x` from radians to degrees.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.deg(x)
	return oldmath_call1(oldmath.deg, x)
end

--- Returns the value `e^x` (where `e` is the base of natural logarithms).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.exp(x)
	return oldmath_call1(oldmath.exp, x)
end

--- Returns the largest integral value smaller than or equal to `x`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.floor(x)
	return oldmath_call1(oldmath.floor, x)
end

--- Returns the remainder of the division of `x` by `y` that rounds the quotient towards zero.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @param y T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.fmod(x, y)
	return oldmath_call2(oldmath.fmod, x, y)
end

--- Returns two numbers `m` and `e` such that `x = m * (2 ^ e)`, where `e` is an integer. When `x` is zero, NaN, +inf, or -inf, `m` is equal to `x`; otherwise, the absolute value of `m` is in the range [0.5, 1).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T m
--- @return T e
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.frexp(x)
	if type(x) == "number" then
		return oldmath.frexp(x)
	end

	m = {}
	e = {}
	setmetatable(ret, getmetatable(x))

	for key, val in pairs(x) do
		m[key], e[key] = oldmath.frexp(val)
	end
	return m, e
end

--- Returns `m * (2 ^ e)`, where `e` is an integer.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param m T
--- @param e T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.ldexp(m, e)
	return oldmath_call2(oldmath.ldexp, m, e)
end

--- Returns the logarithm of `x` in the given base.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @param base T?
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.log(x, base)
	return oldmath_call2(oldmath.log, x, base)
end

--- Returns the base-10 logarithm of x.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.log10(x)
	return oldmath_call1(oldmath.log10, x)
end

--- Returns the argument with the maximum value, according to the Lua operator `<`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param ... T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.max(...)
	local n = select('#', ...)
	if n == 0 then
		error("bad argument #1 to 'math.min' (number expected)")
	end

	local max = select(1, ...)
	for i = 2, n do
		local v = select(i, ...)
		if v > max then
			max = v
		end
	end
	return max
end

--- Returns the argument with the minimum value, according to the Lua operator `<`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param ... T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.min(...)
	local n = select('#', ...)
	if n == 0 then
		error("bad argument #1 to 'math.min' (number expected)")
	end

	local min = select(1, ...)
	for i = 2, n do
		local v = select(i, ...)
		if v < min then
			min = v
		end
	end
	return min
end

--- Returns the integral part of `x` and the fractional part of `x`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T | integer integral
--- @return T fractional
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.modf(x)
	if type(x) == "number" then
		return oldmath.modf(x)
	end

	integral = {}
	fractional = {}
	setmetatable(ret, getmetatable(x))

	for key, val in pairs(x) do
		integral[key], fractional[key] = oldmath.modf(val)
	end
	return integral, fractional
end

--- Returns `x ^ y` .
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @param y T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.pow(x, y)
	return oldmath_call2(oldmath.pow, x, y)
end

--- Converts the angle `x` from degrees to radians.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.rad(x)
	return oldmath_call1(oldmath.rad, x)
end

--- Returns the sine of `x` (assumed to be in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.sin(x)
	return oldmath_call1(oldmath.sin, x)
end

--- Returns the hyperbolic sine of `x` (assumed to be in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.sinh(x)
	return oldmath_call1(oldmath.sinh, x)
end

--- Returns the square root of `x`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.sqrt(x)
	return oldmath_call1(oldmath.sqrt, x)
end

--- Returns the tangent of `x` (assumed to be in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.tan(x)
	return oldmath_call1(oldmath.tan, x)
end

--- Returns the hyperbolic tangent of `x` (assumed to be in radians).
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.tanh(x)
	return oldmath_call1(oldmath.tanh, x)
end

--- Rounds a number. Mysteriously this isn't included in Lua by default.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
function math.round(x)
	local function base_round(value)
		return ffi.C.st_round(value)
	end
	return oldmath_call1(base_round, x)
end

--- Clamps X between min and max.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @param min T
--- @param max T
--- @return T
--- @nodiscard
function math.clamp(x, min, max)
	local function base_clamp(x_, min_, max_)
		return math.min(math.min(min_, x_), max_)
	end
	return oldmath_call3(base_clamp, x, min, max)
end

--- Linear interpolation
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param a T
--- @param b T
--- @param t T
--- @return T
--- @nodiscard
function math.lerp(a, b, t)
	local function base_lerp(a_, b_, t_)
		return (1.0 - t_) * a_ + t_ * b_
	end

	return oldmath_call3(base_lerp, a, b, t)
end

--- Similar to lerp, but inverse.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param a T
--- @param b T
--- @param v T
--- @return T
--- @nodiscard
function math.inverse_lerp(a, b, v)
	local function base_inverse_lerp(a_, b_, v_)
		return (v_ - a_) / (b_ - a_)
	end
	return oldmath_call3(base_inverse_lerp, a, b, v)
end

--- Converts a number from one scale to another
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param val T
--- @param src_min T
--- @param src_max T
--- @param dst_min T
--- @param dst_max T
--- @return T
--- @nodiscard
function oldmath.remap(val, src_min, src_max, dst_min, dst_max)
	return oldmath.lerp(dst_min, dst_max, oldmath.inverse_lerp(src_min, src_max, val))
end
