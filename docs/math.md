## Math module

Starry extends Lua's math module, adding many functions that are useful for game development.

## Constants

### `math.pi: number`

The value of π.

### `math.huge: number`

A value larger than any other numeric value.

### `math.epsilon: number`

Smallest number such that `1.0 + math.epsilon != 1.0`.

## Functions

### `math.abs(x: number | vec): number | vec`

Returns the absolute value of x.

This may take in either a number or vector.

### `math.acos(x: number): number`

Returns the arc cosine of x (in radians).

### `math.asin(x: number): number`

Returns the arc sine of x (in radians).

### `math.atan(x: number): number`

Returns the arc tangent of x (in radians).

### `math.atan2(y: number, x: number): number`

Returns the arc tangent of `y/x` (in radians), but uses the signs of both parameters to find the quadrant of the result. (It also handles correctly the case of x being zero.)

### `math.ceil(x: number | vec): number | vec`

Returns the smallest integer larger than or equal to x.

This may take in either a number or vector.

### `math.cos(x: number): number`

Returns the cosine of x (assumed to be in radians).

### `math.cosh(x: number): number`

Returns the hyperbolic cosine of x.

### `math.deg(x: number | vec): number | vec`

Returns the angle x (given in radians) in degrees.

This may take in either a number or vector.

### `math.exp(x: number): number`

Returns the value `e^x`.

### `math.floor(x: number | vec): number | vec`

Returns the largest integer smaller than or equal to x.

This may take in either a number or vector.

### `math.fmod(x: number | vec, y: number | vec): number | vec`

Returns the remainder of the division of x by y that rounds the quotient towards zero.

This may take in either a number or vector.

### `math.ldexp(m: number, e: number)`

Returns `m * (2 ^ e)`, where `e` is an integer.

### `math.frexp(x: number): (m: number, e: number)`

Returns two numbers `m` and `e` such that `x = m * (2 ^ e)`, where `e` is an integer. When `x` is zero, NaN, +inf, or -inf, `m` is equal to `x`; otherwise, the absolute value of `m` is in the range [0.5, 1).

### `math.log(x: number): number`

Returns the natural logarithm of x.

### `math.log10(x: number): number`

Returns the base-10 logarithm of x.

### `math.max(x: number, ...): number`

Returns the maximum value among its arguments.

### `math.min(x: number, ...): number`

Returns the minimum value among its arguments.

### `math.modf(x: number): (integer, number)`

Returns two numbers, the integral part of x and the fractional part of x.

### `math.pow(x: number | vec, y: number | vec): number | vec`

Returns `x^y`.

This may take in either a number or a vector.

### `math.rad(x: number | vec): number | vec`

Returns the angle x (given in degrees) in radians.

This may take in either a number or vector.

### `math.random([m [, n]])`

- `math.random()`: Returns a float in the range [0,1).
- `math.random(n)`: Returns a integer in the range [1, n].
- `math.random(m, n)`: Returns a integer in the range [m, n].

### `math.randomseed(x: integer)`

Sets x as the "seed" for the pseudo-random generator: equal seeds produce equal sequences of numbers.

### `math.sin(x: number): number`

Returns the sine of x (assumed to be in radians).

### `math.sinh(x: number): number`

Returns the hyperbolic sine of x.

### `math.sqrt(x: number): number`

Returns the square root of x.

### `math.tan(x: number): number`

Returns the tangent of x (assumed to be in radians).

### `math.tanh(x: number): number`

Returns the hyperbolic tangent of x.

### `math.round(x: number | vec): number | vec`

Rounds a number to the nearest integral number.

This may take in either a number or vector.

### `math.clamp(x: number | vec, min: number | vec, max: number | vec): number | vec`

Clamps X between min and max.

This may take in either a number or vector.

### `math.lerp(a: number | vec, b: number | vec, t: number | vec): number | vec`

Returns `(1.0 - t) * a + t * b`.

This may take in either a number or vector.

### `math.inverse_lerp(a: number | vec, b: number | vec, v: number | vec)`

Returns `(v - a) / (b - a)`.

This may take in either a number or vector.

### `math.remap(val: number | vec, src_min: number | vec, src_max: number | vec, dst_min: number | vec, dst_max: number | vec): number | vec`

Converts a number from one scale to another.

This may take in either a number or vector.

### `math.approx_equal(x: number | vec, y: number | vec [, epsilon: number]): boolean`

Returns true if the 2 numbers are approximately equal, using `epsilon`. (defaults to `math.epsilon`)

This may take in either a number or vector.

## Vectors

### `vec2(x, y)`

Creates a new vector with 2 components.

Examples:
- `vec2() -> {x = 0, y = 0}`
- `vec2(1) -> {x = 1, y = 1}`
- `vec2(1, 2) -> {x = 1, y = 2}`

Supported operators:
- `+`, `-`, `*`, `/`, `%`, `^` (supports mixing vectors and scalars, e.g. `vec * 2`)
- `-` (negation)
- `==` (equality)

### `vec3(x, y, z)`

Creates a new vector with 3 components.

Examples:
- `vec3() -> {x = 0, y = 0, z = 0}`
- `vec3(1) -> {x = 1, y = 1, y = 1}`
- `vec3(1, 2, 3) -> {x = 1, y = 2, z = 3}`

Supported operators:
- `+`, `-`, `*`, `/`, `%`, `^` (supports mixing vectors and scalars, e.g. `vec * 2`)
- `-` (negation)
- `==` (equality)

### `vec4(x, y, z, w)`

Creates a new vector with 4 components.

Examples:
- `vec4() -> {x = 0, y = 0, z = 0, w = 0}`
- `vec4(1) -> {x = 1, y = 1, y = 1, w = 1}`
- `vec4(1, 2, 3, 4) -> {x = 1, y = 2, z = 3, w = 4}`

Supported operators:
- `+`, `-`, `*`, `/`, `%`, `^` (supports mixing vectors and scalars, e.g. `vec * 2`)
- `-` (negation)
- `==` (equality)

### `math.less_than(a: vec, b: vec): bvec`

Checks for each component for `a < b`. This returns a boolean vector, which you can use with `math.any` or `math.all`.

### `math.less_than_equal(a: vec, b: vec): bvec`

Checks for each component for `a <= b`. This returns a boolean vector, which you can use with `math.any` or `math.all`.

### `math.greater_than(a: vec, b: vec): bvec`

Checks for each component for `a > b`. This returns a boolean vector, which you can use with `math.any` or `math.all`.

### `math.greater_than_equal(a: vec, b: vec): bvec`

Checks for each component for `a >= b`. This returns a boolean vector, which you can use with `math.any` or `math.all`.

### `math.dot(a: vec | quat, b: vec | quat): number`

Returns the dot product of a and b.

### `math.length(x: vec | quat): number`

Returns the magnitude of a vector.

### `math.length_squared(x: vec | quat): number`

Returns `math.dot(x, x)`.

### `math.distance(a: vec, b: vec): number`

Returns the distance between a and b.

### `math.cross(a: vec3, b: vec3): vec3`

Returns the cross product of a and b. (must be vec3s)

### `math.normalize(x: vec | quat): vec | quat`

Returns a vector in the same direction but with a length of 1.

### `math.normalize_color_from_rgb8(src: vec3 | vec4): vec3 | vec4`

Converts a color (vec3 or vec4) from the 0-255 range to the 0.0-1.0 range.

### `math.rgb8_from_normalized_color(src: vec3 | vec4): vec3 | vec4`

Converts a color (vec3 or vec4) from the 0.0-1.0 range to the 0-255 range.

## `math.hex(src: string): vec4`

Converts a hex code to a normalized RGBA color (0-1).
Supports "#RGB", "#RGBA", "#RRGGBB", "#RRGGBBAA" (with or without '#')

## Quaternions

### `quat(x, y, z, w)`

Creates a new quaternion.

No arguments creates an identity quaternion, that is, `quat(0, 0, 0, 1)`.

### `math.axis_angle(axis: vec3, angle: number): quat`

Creates a quaternion from axis + angle (angle in radians)

### `math.euler_to_quat(pitch: number, yaw: number, roll: number): quat`

Returns a quaternion from an Euler angle (all in radians)

### `math.vec3_to_quat(v: vec3)`

Returns a quaternion from an Euler angle, where X = pitch, Y = yaw, and Z = roll. (all in radians)

### `math.quat_to_euler(q: quat): vec3`

Returns an euler angle from a quaternion, where X = pitch, Y = yaw, and Z = roll. (all in radians)

### `math.conjugate(q: quat): quat`

Returns `quat(-q.x, -q.y, -q.z, q.w)`.

### `math.inverse(q: quat): quat`

Returns the inverse of the quaternion.

### `math.slerp(a: quat, b: quat, t: number): quat`

SLERP (Spherical Linear Interpolation)

### `math.angle(q: quat): number`

Get rotation angle (radians)

### `math.axis(q: quat): vec3`

Get rotation axis

## Boolean vectors

### `bvec2(x, y)`

Creates a new boolean vector with 2 components.

Examples:
- `bvec2() -> {x = false, y = false}`
- `bvec2(true) -> {x = true, y = true}`
- `bvec2(false, true) -> {x = false, y = true}`

### `bvec3(x, y, z)`

Creates a new boolean vector with 3 components.

Examples:
- `bvec3() -> {x = false, y = false, z = false}`
- `bvec3(true) -> {x = true, y = true, z = true}`
- `bvec3(false, true, false) -> {x = false, y = true, z = false}`

### `bvec4(x, y, z, w)`

Creates a new boolean vector with 4 components.

Examples:
- `bvec4() -> {x = false, y = false, z = false, w = false}`
- `bvec4(true) -> {x = true, y = true, z = true, w = true}`
- `bvec4(false, true, false, true) -> {x = false, y = true, z = false, w = true}`

### `math.all(v: bvec2 | bvec3 | bvec4): boolean`

Returns true if all components in the boolean vector are true.

### `math.any(v: bvec2 | bvec3 | bvec4): boolean`

Returns true if any of the components in the boolean vector are true.

## TODO

- `vec[1]`, `quat[1]`
- `!bvec`
- `math.none(bvec)`
- `quat * vec3 -> vec3`
- `mat4`, maybe other matrices too
- swizzling
- rect, aabb
