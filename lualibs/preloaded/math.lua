--- @class BVec2: table
--- @field x boolean
--- @field y boolean
BVec2 = {}
BVec2.__index = BVec2

--- @param x boolean?
--- @param y boolean?
--- @return BVec2
function bvec2(x, y)
	if x == nil then x = false end
	-- allow initializing bvec2(true) -> {true, true}
	if y == nil then y = x end

	local self = { x = x, y = y }
	return setmetatable(self, BVec2)
end

--- @class BVec3: table
--- @field x boolean
--- @field y boolean
--- @field z boolean
BVec3 = {}
BVec3.__index = BVec3

--- @param x boolean?
--- @param y boolean?
--- @param z boolean?
--- @return BVec3
function bvec3(x, y, z)
	if x == nil then x = false end
	-- allow initializing bvec3(true) -> {true, true, true}
	if z == nil then z = x end
	if y == nil then y = x end

	local self = { x = x, y = y, z = z }
	return setmetatable(self, BVec3)
end

--- @class BVec4: table
--- @field x boolean
--- @field y boolean
--- @field z boolean
--- @field w boolean
BVec4 = {}
BVec4.__index = BVec4

--- @param x boolean?
--- @param y boolean?
--- @param z boolean?
--- @param w boolean?
--- @return BVec4
function bvec4(x, y, z, w)
	if x == nil then x = false end
	-- allow initializing bvec4(true) -> {true, true, true, true}
	if w == nil then w = x end
	if z == nil then z = x end
	if y == nil then y = x end

	local self = { x = x, y = y, z = z, w = w }
	return setmetatable(self, BVec4)
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
function Vec2.__lt(a, b)
	return a.x < b.x and a.y < b.y
end

--- @param a Vec2
--- @param b Vec2
--- @return boolean
function Vec2.__le(a, b)
	return a.x <= b.x and a.y <= b.y
end

--- @param v Vec2
--- @return string
function Vec2.__tostring(v)
	return string.format("vec2(%.3f, %.3f)", v.x, v.y)
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

--- @param v Vec3
--- @return string
function Vec3.__tostring(v)
	return string.format("vec3(%.3f, %.3f, %.3f)", v.x, v.y, v.z)
end

--- @return Vec3
function Vec3:clone()
	return vec3(self.x, self.y, self.z)
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

--- @param v Vec4
--- @return string
function Vec4.__tostring(v)
	return string.format("vec4(%.3f, %.3f, %.3f, %.3f)", v.x, v.y, v.z, v.w)
end

--- @return Vec4
function Vec4:clone()
	return vec4(self.x, self.y, self.z, self.w)
end

--- Quaternion
--- @class Quat: table
--- @field x number
--- @field y number
--- @field z number
--- @field w number
Quat = {}
Quat.__index = Quat

--- No arguments creates an identity quaternion (0, 0, 0, 1)
--- @param x number?
--- @param y number?
--- @param z number?
--- @param w number?
--- @return Quat
function quat(x, y, z, w)
	if not x then
		return setmetatable({ x = 0, y = 0, z = 0, w = 1 }, Quat)
	end

	return setmetatable({
		x = x or 0,
		y = y or 0,
		z = z or 0,
		w = w or 1
	}, Quat)
end

Quat.identity = quat()

--- @param a Quat | number
--- @param b Quat | number
--- @return Quat
function Quat.__mul(a, b)
	if type(b) == "number" then
		return quat(a.x * b, a.y * b, a.z * b, a.w * b)
	end
	if type(a) == "number" then
		return quat(a * b.x, a * b.y, a * b.z, a * b.w)
	end
	-- quat * quat
	return quat(
		a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
		a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z,
		a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x,
		a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z
	)
end

--- @param a Quat
--- @param b Quat
--- @return Quat
function Quat.__add(a, b)
	return vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
end

--- @param a Quat
--- @param b Quat
--- @return Quat
function Quat.__sub(a, b)
	return quat(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
end

--- @param a Quat
--- @return Quat
function Quat.__unm(a)
	return quat(-a.x, -a.y, -a.z, -a.w)
end

--- @param a Quat
--- @param b Quat
--- @return boolean
function Quat.__eq(a, b)
	if type(a) ~= type(b) then return false end
	if getmetatable(a) ~= getmetatable(b) then return false end
	return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
end

--- @param v Quat
--- @return string
function Quat.__tostring(v)
	return string.format("quat(%.4f, %.4f, %.4f, %.4f)", v.x, v.y, v.z, v.w)
end

--- @return Quat
function Quat:clone()
	return quat(self.x, self.y, self.z, self.w)
end

-- redefine math functions to support vectors

--- math functions have to be redefined to support vectors
--- @class oldmath: mathlib
local oldmath = table.shallow_copy(math)
--- @class starrymath: table
math = {
	pi = oldmath.pi,
	huge = oldmath.huge,
	-- Smallest number such that `1.0 + math.epsilon != 1.0`.
	epsilon = 1.192092896e-07,
	random = oldmath.random,
	randomseed = oldmath.randomseed,
	acos = oldmath.acos,
	asin = oldmath.asin,
	atan = oldmath.atan,
	atan2 = oldmath.atan2,
	cos = oldmath.cos,
	sin = oldmath.sin,
	tan = oldmath.tan,
	cosh = oldmath.cosh,
	sinh = oldmath.sinh,
	tanh = oldmath.tanh,
	exp = oldmath.exp,
	ldexp = oldmath.ldexp,
	frexp = oldmath.frexp,
	log = oldmath.log,
	log10 = oldmath.log10,
	modf = oldmath.modf,
	sqrt = oldmath.sqrt,
}

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

--- Returns the absolute value of `x`.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.abs(x)
	return oldmath_call1(oldmath.abs, x)
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

--- Converts the angle `x` from radians to degrees.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
--- @diagnostic disable-next-line: duplicate-set-field
function math.deg(x)
	return oldmath_call1(oldmath.deg, x)
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

--- Rounds a number. Mysteriously this isn't included in Lua by default.
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @return T
--- @nodiscard
function math.round(x)
	local function base_round(value)
		return __st.round(value)
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
function math.remap(val, src_min, src_max, dst_min, dst_max)
	return math.lerp(dst_min, dst_max, math.inverse_lerp(src_min, src_max, val))
end

--- Returns the dot product of `a` and `b`
--- @generic T Vec2 | Vec3 | Vec4 | Quat
--- @param a T
--- @param b T
--- @return number
function math.dot(a, b)
	local ret = 0
	for key, _ in pairs(a) do
		ret = ret + a[key] * b[key]
	end
	return ret
end

--- Returns the magnitude of a vector
--- @param vec Vec2 | Vec3 | Vec4 | Quat
--- @return number
function math.length(vec)
	return math.sqrt(math.dot(vec, vec))
end

--- @param vec Vec2 | Vec3 | Vec4 | Quat
--- @return number
function math.length_squared(vec)
	return math.dot(vec, vec)
end

--- Returns the distance between `a` and `b`
--- @generic T Vec2 | Vec3 | Vec4
--- @param a T
--- @param b T
--- @return number
function math.distance(a, b)
	return math.length(a - b)
end

--- Returns the cross product of `a` and `b`
--- @param a Vec3
--- @param b Vec3
--- @return Vec3
function math.cross(a, b)
	return vec3(a.y * b.z - b.y * a.z, a.z * b.x - b.z * a.x, a.x * b.y - b.x * a.y)
end

--- Returns a vector in the same direction but with a length of 1
--- @generic T Vec2 | Vec3 | Vec4 | Quat
--- @param vec T
--- @return T
function math.normalize(vec)
	local len = math.length(vec)
	if len == 0 then
		if getmetatable(vec) == Vec2 then
			return vec2()
		elseif getmetatable(vec) == Vec3 then
			return vec3()
		elseif getmetatable(vec) == Vec4 then
			return vec4()
		elseif getmetatable(vec) == Quat then
			return quat()
		end
	end
	return vec / len
end

--- Returns true if the 2 numbers are approximately equal
--- @generic T number | Vec2 | Vec3 | Vec4
--- @param x T
--- @param y T
--- @param epsilon number? Defaults to `math.epsilon`
--- @return T
function math.approx_equal(x, y, epsilon)
	local epsilon_but_vec = nil
	if type(x) == "number" then
		epsilon_but_vec = epsilon or math.epsilon
	elseif getmetatable(x) == Vec2 then
		epsilon_but_vec = vec2(epsilon or math.epsilon)
	elseif getmetatable(x) == Vec3 then
		epsilon_but_vec = vec3(epsilon or math.epsilon)
	elseif getmetatable(x) == Vec4 then
		epsilon_but_vec = vec4(epsilon or math.epsilon)
	end

	local function base_approx_equal(x_, y_, epsilon_)
		return math.abs(x_ - y_) < epsilon_
	end
	return oldmath_call3(base_approx_equal, x, y, epsilon_but_vec)
end

--- Converts a color from the 0-255 range to the 0.0-1.0 range
--- @generic T Vec3 | Vec4
--- @param src T
--- @return T
function math.normalize_8bit_color(src)
	return src / 255.0
end

--- Creates a quaternion from axis + angle (angle in radians)
--- @param axis Vec3
--- @param angle number
--- @return Quat
function math.axis_angle(axis, angle)
	local s = math.sin(angle * 0.5)
	return quat(
		axis.x * s,
		axis.y * s,
		axis.z * s,
		math.cos(angle * 0.5)
	)
end

--- Returns a quaternion from an Euler angle (all in radians)
--- @param pitch number
--- @param yaw number
--- @param roll number
--- @return Quat
function math.euler_to_quat(pitch, yaw, roll)
	local imag, jmag, kmag, real = __st.euler_to_quat(pitch, yaw, roll)
	return quat(imag, jmag, kmag, real)
end

--- Returns a quaternion from an Euler angle (all in radians)
--- @param vec Vec3 X = pitch, Y = yaw, Z = roll
--- @return Quat
function math.vec3_to_quat(vec)
	return math.euler_to_quat(vec.x, vec.y, vec.z)
end

--- Converts a quaternion to Euler angle (radians)
--- @param quat Quat
--- @return Vec3 X = pitch, Y = yaw, Z = roll
function math.quat_to_euler(quat)
	local x, y, z = __st.quat_to_euler(quat.x, quat.y, quat.z, quat.w)
	return vec3(x, y, z)
end

--- @param quat Quat
--- @return Quat
function math.conjugate(quat)
	return quat(-quat.x, -quat.y, -quat.z, quat.w)
end

--- @param quat Quat
--- @return Quat
function math.inverse(quat)
	local conj = math.conjugate(quat)
	local lensq = math.length_squared(quat)
	if lensq == 0 then return quat() end
	return quat(conj.x / lensq, conj.y / lensq, conj.z / lensq, conj.w / lensq)
end

--- SLERP (Spherical Linear Interpolation)
--- @param a Quat
--- @param b Quat
--- @param t number
--- @return Quat
function math.slerp(a, b, t)
	local cos_theta = math.dot(a, b)
	if cos_theta < 0 then
		--- @diagnostic disable-next-line: cast-local-type -- mate i defined the operators
		b = -b
		cos_theta = -cos_theta
	end

	if cos_theta > 0.9995 then
		-- lerp for small angles
		local result = a + (b - a) * t
		return result:normalize()
	end

	local theta = math.acos(math.min(math.max(cos_theta, -1), 1))
	local sin_theta = math.sin(theta)

	local wa = math.sin((1 - t) * theta) / sin_theta
	local wb = math.sin(t * theta) / sin_theta

	return (a * wa) + (b * wb)
end

--- Get rotation angle (radians)
--- @param quat Quat
--- @return number
function math.angle(quat)
	return 2 * math.acos(math.abs(quat.w))
end

--- Get rotation axis
--- @param quat Quat
--- @return Vec3
function math.axis(quat)
	local s = math.sqrt(1 - quat.w * quat.w)
	if s < 0.0001 then
		return { x = 1, y = 0, z = 0 } -- arbitrary axis
	end

	return vec3(
		quat.x / s,
		quat.y / s,
		quat.z / s
	)
end

--- Returns true if all components in the boolean vector are true
--- @param vec BVec2 | BVec3 | BVec4
--- @return boolean
function math.all(vec)
	if getmetatable(vec) == BVec2 then
		return vec.x and vec.y
	elseif getmetatable(vec) == BVec3 then
		return vec.x and vec.y and vec.z
	elseif getmetatable(vec) == BVec4 then
		return vec.x and vec.y and vec.z and vec.w
	else
		error("expected BVec2 or BVec3 or BVec4, got " .. type(vec))
	end
end

--- Returns true if any of the components in the boolean vector are true
--- @param vec BVec2 | BVec3 | BVec4
--- @return boolean
function math.any(vec)
	if getmetatable(vec) == BVec2 then
		return vec.x or vec.y
	elseif getmetatable(vec) == BVec3 then
		return vec.x or vec.y or vec.z
	elseif getmetatable(vec) == BVec4 then
		return vec.x or vec.y or vec.z or vec.w
	else
		error("expected BVec2 or BVec3 or BVec4, got " .. type(vec))
	end
end

--- Only for vectors
--- @param a Vec2 | Vec3 | Vec4
--- @param b Vec2 | Vec3 | Vec4
--- @return BVec2 | BVec3 | BVec4
function math.less_than(a, b)
	assert(getmetatable(a) == getmetatable(b), "vectors should be the same length")

	if getmetatable(a) == Vec2 then
		return bvec2(a.x < b.x, a.y < b.y)
	elseif getmetatable(a) == Vec3 then
		return bvec3(a.x < b.x, a.y < b.y, a.z < b.z)
	elseif getmetatable(a) == Vec4 then
		return bvec4(a.x < b.x, a.y < b.y, a.z < b.z, a.w < b.w)
	else
		error("expected Vec2 or Vec3 or Vec4, got " .. type(a))
	end
end

--- Only for vectors
--- @param a Vec2 | Vec3 | Vec4
--- @param b Vec2 | Vec3 | Vec4
--- @return BVec2 | BVec3 | BVec4
function math.less_than_equal(a, b)
	assert(getmetatable(a) == getmetatable(b), "vectors should be the same length")

	if getmetatable(a) == Vec2 then
		return bvec2(a.x <= b.x, a.y <= b.y)
	elseif getmetatable(a) == Vec3 then
		return bvec3(a.x <= b.x, a.y <= b.y, a.z <= b.z)
	elseif getmetatable(a) == Vec4 then
		return bvec4(a.x <= b.x, a.y <= b.y, a.z <= b.z, a.w <= b.w)
	else
		error("expected Vec2 or Vec3 or Vec4, got " .. type(a))
	end
end

--- Only for vectors
--- @param a Vec2 | Vec3 | Vec4
--- @param b Vec2 | Vec3 | Vec4
--- @return BVec2 | BVec3 | BVec4
function math.greater_than(a, b)
	assert(getmetatable(a) == getmetatable(b), "vectors should be the same length")

	if getmetatable(a) == Vec2 then
		return bvec2(a.x > b.x, a.y > b.y)
	elseif getmetatable(a) == Vec3 then
		return bvec3(a.x > b.x, a.y > b.y, a.z > b.z)
	elseif getmetatable(a) == Vec4 then
		return bvec4(a.x > b.x, a.y > b.y, a.z > b.z, a.w > b.w)
	else
		error("expected Vec2 or Vec3 or Vec4, got " .. type(a))
	end
end

--- Only for vectors
--- @param a Vec2 | Vec3 | Vec4
--- @param b Vec2 | Vec3 | Vec4
--- @return BVec2 | BVec3 | BVec4
function math.greater_than_equal(a, b)
	assert(getmetatable(a) == getmetatable(b), "vectors should be the same length")

	if getmetatable(a) == Vec2 then
		return bvec2(a.x >= b.x, a.y >= b.y)
	elseif getmetatable(a) == Vec3 then
		return bvec3(a.x >= b.x, a.y >= b.y, a.z >= b.z)
	elseif getmetatable(a) == Vec4 then
		return bvec4(a.x >= b.x, a.y >= b.y, a.z >= b.z, a.w >= b.w)
	else
		error("expected Vec2 or Vec3 or Vec4, got " .. type(a))
	end
end
