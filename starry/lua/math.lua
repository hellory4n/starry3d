-- preloaded code: math.lua
local ffi = require("ffi")

--- math functions have to be redefined to support vectors
--- @class oldmath: mathlib
local oldmath = table.shallow_copy(math)
--- @class starrymath: table
math = { pi = oldmath.pi, huge = oldmath.huge }

ffi.cdef [[
float st_round(float);
]]

--- Rounds a number. Mysteriously this isn't included in Lua by default.
--- @param value number
--- @return number
--- @nodiscard
function oldmath.round(value)
	return ffi.C.st_round(value)
end

--- Converts radians to degrees
--- @param x number
--- @return number
--- @nodiscard
function oldmath.rad2deg(x)
	return x * (180.0 / math.pi);
end

--- Converts degrees to radians
--- @param x number
--- @return number
--- @nodiscard
function oldmath.deg2rad(x)
	return x * (math.pi / 180.0);
end

oldmath.radians = oldmath.deg2rad
oldmath.degrees = oldmath.rad2deg

--- Clamps X between min and max.
--- @param x number
--- @param min number
--- @param max number
--- @return number
--- @nodiscard
function oldmath.clamp(x, min, max)
	return oldmath.min(oldmath.max(min, x), max);
end

--- Linear interpolation
--- @param a number
--- @param b number
--- @param t number
--- @return number
--- @nodiscard
function oldmath.lerp(a, b, t)
	return (1.0 - t) * a + t * b
end

--- Similar to lerp, but inverse.
--- @param a number
--- @param b number
--- @param v number
--- @return number
--- @nodiscard
function oldmath.inverse_lerp(a, b, v)
	return (v - a) / (b - a)
end

--- Converts a number from one scale to another
--- @param val number
--- @param src_min number
--- @param src_max number
--- @param dst_min number
--- @param dst_max number
--- @return number
--- @nodiscard
function oldmath.remap(val, src_min, src_max, dst_min, dst_max)
	return oldmath.lerp(dst_min, dst_max, oldmath.inverse_lerp(src_min, src_max, val))
end

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

--- Returns the absolute value of `x`.
--- @param x number | Vec2 | Vec3 | Vec4
--- @return number | Vec2 | Vec3 | Vec4
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.abs(x)

end
