//! Touching linear algebra library inspired by GLSL. Everything uses OpenGL conventions, with
//! column-major matrices, +Y is up, right-handed coordinates, etc.
const std = @import("std");
const testing = std.testing;

/// A vector with 2 components. Extraordinary.
pub fn Vec2(comptime T: type) type {
    return struct {
        repr: @Vector(2, T),

        pub fn x(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setX(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setY(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
        }

        pub fn setNth(vec: *@This(), comptime idx: comptime_int, val: T) void {
            vec.repr[idx] = val;
        }

        pub fn toArray(vec: @This()) [2]T {
            return [2]T{ vec.x(), vec.y() };
        }
    };
}

/// A vector with 3 components. Extraordinary.
pub fn Vec3(comptime T: type) type {
    return struct {
        repr: @Vector(3, T),

        pub fn x(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setX(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setY(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn z(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setZ(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn r(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setR(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn g(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setG(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn b(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setB(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
        }

        pub fn setNth(vec: *@This(), comptime idx: comptime_int, val: T) void {
            vec.repr[idx] = val;
        }

        pub fn toArray(vec: @This()) [3]T {
            return [3]T{ vec.x(), vec.y(), vec.z() };
        }
    };
}

/// A vector with 4 components. Extraordinary.
pub fn Vec4(comptime T: type) type {
    return struct {
        repr: @Vector(4, T),

        pub fn x(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setX(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setY(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn z(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setZ(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn w(vec: @This()) T {
            return vec.repr[3];
        }

        pub fn setW(vec: *@This(), val: T) void {
            vec.repr[3] = val;
        }

        pub fn r(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn setR(vec: *@This(), val: T) void {
            vec.repr[0] = val;
        }

        pub fn g(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn setG(vec: *@This(), val: T) void {
            vec.repr[1] = val;
        }

        pub fn b(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn setB(vec: *@This(), val: T) void {
            vec.repr[2] = val;
        }

        pub fn a(vec: @This()) T {
            return vec.repr[3];
        }

        pub fn setA(vec: *@This(), val: T) void {
            vec.repr[3] = val;
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
        }

        pub fn setNth(vec: *@This(), comptime idx: comptime_int, val: T) void {
            vec.repr[idx] = val;
        }

        pub fn toArray(vec: @This()) [4]T {
            return [4]T{ vec.x(), vec.y(), vec.z(), vec.w() };
        }
    };
}

/// Makes a vector of 2. Impressive. Very nice.
pub fn vec2(comptime T: type, x: T, y: T) Vec2(T) {
    return Vec2(T){ .repr = .{ x, y } };
}

/// Makes a vector of 3. Impressive. Very nice.
pub fn vec3(comptime T: type, x: T, y: T, z: T) Vec3(T) {
    return Vec3(T){ .repr = .{ x, y, z } };
}

/// Makes a vector of 4. Impressive. Very nice.
pub fn vec4(comptime T: type, x: T, y: T, z: T, w: T) Vec4(T) {
    return Vec4(T){ .repr = .{ x, y, z, w } };
}

test "basic vectors" {
    const v2: Vec2(i32) = vec2(i32, 1, 2);
    try testing.expectEqual(v2.x(), 1);
    try testing.expectEqual(v2.nth(0), v2.x());
    try testing.expectEqual(v2.toArray()[0], v2.nth(0));
    try testing.expectEqual(v2.y(), 2);
    try testing.expectEqual(v2.nth(1), v2.y());
    try testing.expectEqual(v2.toArray()[1], v2.nth(1));

    const v3: Vec3(i32) = vec3(i32, 1, 2, 3);
    try testing.expectEqual(v3.x(), 1);
    try testing.expectEqual(v3.r(), v3.x());
    try testing.expectEqual(v3.nth(0), v3.r());
    try testing.expectEqual(v3.toArray()[0], v3.nth(0));
    try testing.expectEqual(v3.y(), 2);
    try testing.expectEqual(v3.g(), v3.y());
    try testing.expectEqual(v3.nth(1), v3.g());
    try testing.expectEqual(v3.toArray()[1], v3.nth(1));
    try testing.expectEqual(v3.z(), 3);
    try testing.expectEqual(v3.b(), v3.z());
    try testing.expectEqual(v3.nth(2), v3.b());
    try testing.expectEqual(v3.toArray()[2], v3.nth(2));

    const v4: Vec4(i32) = vec4(i32, 1, 2, 3, 4);
    try testing.expectEqual(v4.x(), 1);
    try testing.expectEqual(v4.r(), v4.x());
    try testing.expectEqual(v4.nth(0), v4.r());
    try testing.expectEqual(v4.toArray()[0], v4.nth(0));
    try testing.expectEqual(v4.y(), 2);
    try testing.expectEqual(v4.g(), v4.y());
    try testing.expectEqual(v4.nth(1), v4.g());
    try testing.expectEqual(v4.toArray()[1], v4.nth(1));
    try testing.expectEqual(v4.z(), 3);
    try testing.expectEqual(v4.b(), v4.z());
    try testing.expectEqual(v4.nth(2), v4.b());
    try testing.expectEqual(v4.toArray()[2], v4.nth(2));
    try testing.expectEqual(v4.w(), 4);
    try testing.expectEqual(v4.a(), v4.a());
    try testing.expectEqual(v4.nth(3), v4.a());
    try testing.expectEqual(v4.toArray()[3], v4.nth(3));
}

// why not
pub const Rgb = Vec3;
pub const Rgba = Vec4;
pub const rgb = vec3;
pub const rgba = vec4;

const VecInfo = struct {
    len: comptime_int,
    child: type,
};

fn vecInfo(comptime T: type) VecInfo {
    if (@typeInfo(T) != .@"struct") {
        @compileError("not a vector");
    }
    if (!@hasField(T, "repr")) {
        @compileError("not a vector");
    }
    const mn = @typeInfo(@FieldType(T, "repr")).vector;
    return .{ .len = mn.len, .child = mn.child };
}

fn VectorWithLen(comptime len: comptime_int, comptime T: type) type {
    return switch (len) {
        2 => Vec2(T),
        3 => Vec3(T),
        4 => Vec4(T),
        else => @compileError("invalid vector length"),
    };
}

fn TypeOfVector(vec: anytype) type {
    const vec_info = vecInfo(@TypeOf(vec));
    return comptime VectorWithLen(vec_info.len, vec_info.child);
}

fn ChildTypeOfVector(comptime T: type) type {
    const vec_info = vecInfo(T);
    return vec_info.child;
}

fn lengthOfVector(comptime T: type) comptime_int {
    return vecInfo(T).len;
}

fn zeroVector(comptime len: comptime_int, comptime T: type) VectorWithLen(len, T) {
    var result: VectorWithLen(len, T) = undefined;
    inline for (0..len) |i| {
        result.setNth(i, 0);
    }
    return result;
}

/// Casting it rn
pub fn intVecFromFloatVec(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @intFromFloat(vec.x()), @intFromFloat(vec.y())),
        3 => vec3(To, @intFromFloat(vec.x()), @intFromFloat(vec.y()), @intFromFloat(vec.z())),
        4 => vec4(To, @intFromFloat(vec.x()), @intFromFloat(vec.y()), @intFromFloat(vec.z()), @intFromFloat(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

/// Casting it rn
pub fn floatVecFromIntVec(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @floatFromInt(vec.x()), @floatFromInt(vec.y())),
        3 => vec3(To, @floatFromInt(vec.x()), @floatFromInt(vec.y()), @floatFromInt(vec.z())),
        4 => vec4(To, @floatFromInt(vec.x()), @floatFromInt(vec.y()), @floatFromInt(vec.z()), @floatFromInt(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

/// Casting it rn
pub fn intVecCast(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @intCast(vec.x()), @intCast(vec.y())),
        3 => vec3(To, @intCast(vec.x()), @intCast(vec.y()), @intCast(vec.z())),
        4 => vec4(To, @intCast(vec.x()), @intCast(vec.y()), @intCast(vec.z()), @intCast(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

/// Casting it rn
pub fn floatVecCast(
    comptime To: type,
    vec: anytype,
) VectorWithLen(lengthOfVector(@TypeOf(vec)), To) {
    return switch (lengthOfVector(@TypeOf(vec))) {
        2 => vec2(To, @floatCast(vec.x()), @floatCast(vec.y())),
        3 => vec3(To, @floatCast(vec.x()), @floatCast(vec.y()), @floatCast(vec.z())),
        4 => vec4(To, @floatCast(vec.x()), @floatCast(vec.y()), @floatCast(vec.z()), @floatCast(vec.w())),
        else => @compileError("invalid vector length"),
    };
}

test "vector casting" {
    const v2i = vec2(i32, 1, 2);
    const v2f = vec2(f64, 1, 2);
    try testing.expectEqual(intVecCast(i16, v2i), vec2(i16, 1, 2));
    try testing.expectEqual(floatVecCast(f32, v2f), vec2(f32, 1, 2));
    try testing.expectEqual(floatVecFromIntVec(f32, v2i), vec2(f32, 1, 2));
    try testing.expectEqual(intVecFromFloatVec(i32, v2f), vec2(i32, 1, 2));
}

/// "Quaternions and spatial rotation", from Wikipedia, the free encyclopedia
pub const Quat = struct {
    repr: @Vector(4, f32),

    pub fn x(q: Quat) f32 {
        return q.repr[0];
    }

    pub fn setX(q: *Quat, val: f32) void {
        q.repr[0] = val;
    }

    pub fn y(q: Quat) f32 {
        return q.repr[1];
    }

    pub fn setY(q: *Quat, val: f32) void {
        q.repr[1] = val;
    }

    pub fn z(q: Quat) f32 {
        return q.repr[2];
    }

    pub fn setZ(q: *Quat, val: f32) void {
        q.repr[2] = val;
    }

    pub fn w(q: Quat) f32 {
        return q.repr[3];
    }

    pub fn setW(q: *Quat, val: f32) void {
        q.repr[3] = val;
    }

    pub fn nth(q: Quat, comptime idx: comptime_int) f32 {
        return q.repr[idx];
    }

    pub fn setNth(q: *Quat, comptime idx: comptime_int, val: f32) void {
        q.repr[idx] = val;
    }

    pub fn toArray(q: Quat) [4]f32 {
        return [4]f32{ q.x(), q.y(), q.z(), q.w() };
    }
};

pub fn quat(x: f32, y: f32, z: f32, w: f32) Quat {
    return .{ .repr = .{ x, y, z, w } };
}

/// Converts an euler rotation in radians (right handed, X=pitch, Y=yaw, Z=roll) to a quaternion
pub fn eulerRad(vec: Vec3(f32)) Quat {
    const hx = vec.x() * 0.5;
    const hy = vec.y() * 0.5;
    const hz = vec.z() * 0.5;

    const sx = @sin(hx);
    const cx = @cos(hx);
    const sy = @sin(hy);
    const cy = @cos(hy);
    const sz = @sin(hz);
    const cz = @cos(hz);

    return quat(
        sx * cy * cz - cx * sy * sz,
        cx * sy * cz + sx * cy * sz,
        cx * cy * sz - sx * sy * cz,
        cx * cy * cz + sx * sy * sz,
    );
}

/// Converts an euler rotation in degrees (right handed, X=pitch, Y=yaw, Z=roll) to a quaternion
pub fn eulerDeg(vec: Vec3(f32)) Quat {
    return eulerRad(vec3(
        f32,
        std.math.degreesToRadians(vec.x()),
        std.math.degreesToRadians(vec.y()),
        std.math.degreesToRadians(vec.z()),
    ));
}

/// Converts a quaternion to euler rotation in radians
pub fn quatToEulerRad(q: Quat) Vec3(f32) {
    const sinp = 2.0 * (q.w() * q.x() + q.y() * q.z());
    const cosp = 1.0 - 2.0 * (q.x() * q.x() + q.y() * q.y());
    const pitch = std.math.atan2(sinp, cosp);

    const siny = 2.0 * (q.w() * q.y() - q.z() * q.x());
    const yaw = std.math.asin(std.math.clamp(siny, -1.0, 1.0));

    const sinr = 2.0 * (q.w() * q.z() + q.x() * q.y());
    const cosr = 1.0 - 2.0 * (q.y() * q.y() + q.z() * q.z());
    const roll = std.math.atan2(sinr, cosr);

    return vec3(f32, pitch, yaw, roll);
}

/// Converts a quaternion to euler rotation in degrees
pub fn quatToEulerDeg(q: Quat) Vec3(f32) {
    const crap = quatToEulerRad(q);
    return vec3(
        f32,
        std.math.radiansToDegrees(crap.x()),
        std.math.radiansToDegrees(crap.y()),
        std.math.radiansToDegrees(crap.z()),
    );
}

test "identity quaternion to euler and back" {
    const q1 = quat(0, 0, 0, 1);
    const e = quatToEulerRad(q1);
    try testing.expectApproxEqAbs(e.x(), 0, 0.001);
    try testing.expectApproxEqAbs(e.y(), 0, 0.001);
    try testing.expectApproxEqAbs(e.y(), 0, 0.001);

    const q2 = eulerRad(e);
    try testing.expectApproxEqAbs(q2.x(), 0, 0.001);
    try testing.expectApproxEqAbs(q2.y(), 0, 0.001);
    try testing.expectApproxEqAbs(q2.z(), 0, 0.001);
    try testing.expectApproxEqAbs(q2.w(), 1, 0.001);
}

test "single axis euler -> quaternion and back" {
    const pitch_quat = eulerRad(vec3(f32, 0.5, 0, 0));
    const pitch_euler = quatToEulerRad(pitch_quat);
    try testing.expectApproxEqAbs(pitch_euler.x(), 0.5, 0.001);
    try testing.expectApproxEqAbs(pitch_euler.y(), 0.0, 0.001);
    try testing.expectApproxEqAbs(pitch_euler.z(), 0.0, 0.001);

    const yaw_quat = eulerRad(vec3(f32, 0, 1, 0));
    const yaw_euler = quatToEulerRad(yaw_quat);
    try testing.expectApproxEqAbs(yaw_euler.x(), 0.0, 0.001);
    try testing.expectApproxEqAbs(yaw_euler.y(), 1.0, 0.001);
    try testing.expectApproxEqAbs(yaw_euler.z(), 0.0, 0.001);

    const roll_quat = eulerRad(vec3(f32, 0, 0, -0.75));
    const roll_euler = quatToEulerRad(roll_quat);
    try testing.expectApproxEqAbs(roll_euler.x(), 0.0, 0.001);
    try testing.expectApproxEqAbs(roll_euler.y(), 0.0, 0.001);
    try testing.expectApproxEqAbs(roll_euler.z(), -0.75, 0.001);
}

test "combined axis euler -> quaternion and back" {
    const q = eulerRad(vec3(f32, -0.3, 0.7, 0.2));
    const e = quatToEulerRad(q);
    try testing.expectApproxEqAbs(e.x(), -0.3, 0.001);
    try testing.expectApproxEqAbs(e.y(), 0.7, 0.001);
    try testing.expectApproxEqAbs(e.z(), 0.2, 0.001);
}

test "90 degree rotations" {
    const pitch_quat = eulerRad(vec3(f32, std.math.pi / 2.0, 0, 0));
    const pitch_euler = quatToEulerRad(pitch_quat);
    try testing.expectApproxEqAbs(pitch_euler.x(), std.math.pi / 2.0, 0.001);
    try testing.expectApproxEqAbs(pitch_euler.y(), 0.0, 0.001);
    try testing.expectApproxEqAbs(pitch_euler.z(), 0.0, 0.001);

    const yaw_quat = eulerRad(vec3(f32, 0, std.math.pi / 2.0, 0));
    const yaw_euler = quatToEulerRad(yaw_quat);
    try testing.expectApproxEqAbs(yaw_euler.x(), 0.0, 0.001);
    try testing.expectApproxEqAbs(yaw_euler.y(), std.math.pi / 2.0, 0.001);
    try testing.expectApproxEqAbs(yaw_euler.z(), 0.0, 0.001);

    const roll_quat = eulerRad(vec3(f32, 0, 0, std.math.pi / 2.0));
    const roll_euler = quatToEulerRad(roll_quat);
    try testing.expectApproxEqAbs(roll_euler.x(), 0.0, 0.001);
    try testing.expectApproxEqAbs(roll_euler.y(), 0.0, 0.001);
    try testing.expectApproxEqAbs(roll_euler.z(), std.math.pi / 2.0, 0.001);
}

test "near gimbal lock" {
    const q = eulerRad(vec3(f32, 0.4, std.math.pi * 0.5 - 0.0001, 0.2));
    const e = quatToEulerRad(q);
    try testing.expectApproxEqAbs(e.x(), 0.4, 0.001);
    try testing.expectApproxEqAbs(e.y(), std.math.pi * 0.5 - 0.0001, 0.001);
    try testing.expectApproxEqAbs(e.z(), 0.2, 0.001);
}

/// Adds 2 vectors or quaternions together. Doesn't handle overflows.
pub fn add(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) + b.nth(i));
    }
    return result;
}

/// Subtracts 2 vectors or quaternions together. Doesn't handle overflows.
pub fn sub(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) - b.nth(i));
    }
    return result;
}

/// Multiplies 2 vectors or quaternions together. Doesn't handle overflows.
pub fn mul(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("types must be the same");
    }

    // quaternions are tricky
    if (@TypeOf(a) == Quat) {
        var result: Quat = undefined;
        result.repr[0] = b.repr[3] * a.repr[0];
        result.repr[1] = b.repr[2] * -a.repr[0];
        result.repr[2] = b.repr[1] * a.repr[0];
        result.repr[3] = b.repr[0] * -a.repr[0];

        result.repr[0] += b.repr[2] * a.repr[1];
        result.repr[1] += b.repr[3] * a.repr[1];
        result.repr[2] += b.repr[0] * -a.repr[1];
        result.repr[3] += b.repr[1] * -a.repr[1];

        result.repr[0] += b.repr[1] * -a.repr[2];
        result.repr[1] += b.repr[0] * a.repr[2];
        result.repr[2] += b.repr[3] * a.repr[2];
        result.repr[3] += b.repr[2] * -a.repr[2];

        result.repr[0] += b.repr[0] * a.repr[3];
        result.repr[1] += b.repr[1] * a.repr[3];
        result.repr[2] += b.repr[2] * a.repr[3];
        result.repr[3] += b.repr[3] * a.repr[3];
        return result;
    } else {
        var result: @TypeOf(a) = undefined;
        inline for (0..lengthOfVector(@TypeOf(a))) |i| {
            result.setNth(i, a.nth(i) * b.nth(i));
        }
        return result;
    }
}

/// Multiplies a vector or quaternion by a scalar. `a` *must* be a vector or quaternion. Doesn't
/// handle overflows.
pub fn muls(a: anytype, b: anytype) @TypeOf(a) {
    if (ChildTypeOfVector(@TypeOf(a)) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) * b);
    }
    return result;
}

/// Divides 2 vectors or quaternions together. Does *not* handle division by zero.
pub fn div(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) / b.nth(i));
    }
    return result;
}

/// Divides a vector or quaternion by a scalar. `a` *must* be a vector or quaternion. Does *not* handle
/// division by zero.
pub fn divs(a: anytype, b: anytype) @TypeOf(a) {
    if (ChildTypeOfVector(@TypeOf(a)) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) / b);
    }
    return result;
}

/// Gets the remainder of dividing 2 vectors or quaternions together. Does *not* handle division by
/// zero.
pub fn mod(a: anytype, b: anytype) @TypeOf(a) {
    if (@TypeOf(a) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) % b.nth(i));
    }
    return result;
}

/// Gets the remainder of diving a vector or quaternion by a scalar. `a` *must* be a vector or
/// quaternion. Does *not* handle division by zero.
pub fn mods(a: anytype, b: anytype) @TypeOf(a) {
    if (ChildTypeOfVector(@TypeOf(a)) != @TypeOf(b)) {
        @compileError("vector types must be the same");
    }

    var result: @TypeOf(a) = undefined;
    inline for (0..lengthOfVector(@TypeOf(a))) |i| {
        result.setNth(i, a.nth(i) % b);
    }
    return result;
}

test "vector arithmetic" {
    const a = vec2(i32, 1, 2);
    const b = vec2(i32, 2, 4);
    try testing.expectEqual(vec2(i32, 3, 6), add(a, b));

    const c = vec3(u64, 1, 2, 3);
    const d = vec3(u64, 2, 4, 6);
    try testing.expectEqual(vec3(u64, 3, 6, 9), add(c, d));

    try testing.expectEqual(vec2(i32, 3, 6), muls(a, @as(i32, 3)));

    // TODO test the rest probably
}

test "quaternion arithmetic" {
    // quaternions should be able to use the same functions thanks to duck typing
    const a = quat(1, 2, 3, 4);
    const b = quat(2, 3, 4, 5);
    try testing.expectEqual(quat(3, 5, 7, 9), add(a, b));
}

test "quaternion multiplication" {
    const q1 = quat(1, 2, 3, 4);
    const q2 = quat(5, 6, 7, 8);
    const q3 = mul(q1, q2);

    try testing.expectApproxEqAbs(24, q3.x(), 0.001);
    try testing.expectApproxEqAbs(48, q3.y(), 0.001);
    try testing.expectApproxEqAbs(48, q3.z(), 0.001);
    try testing.expectApproxEqAbs(-6, q3.w(), 0.001);
}

pub fn lengthSquared(v: anytype) f32 {
    const vec = switch (@typeInfo(ChildTypeOfVector(@TypeOf(v)))) {
        .float => floatVecCast(f32, v),
        .int => floatVecFromIntVec(f32, v),
        else => @compileError("what?"),
    };

    var result: f32 = 0;
    inline for (0..lengthOfVector(@TypeOf(vec))) |i| {
        result += vec.nth(i) * vec.nth(i);
    }
    return result;
}

/// Returns the length of a vector or quaternion
pub fn length(v: anytype) f32 {
    return @sqrt(lengthSquared(v));
}

/// Normalizes a vector or quaternion
pub fn normalize(v: anytype) VectorWithLen(lengthOfVector(@TypeOf(v)), f32) {
    const vec = switch (@typeInfo(ChildTypeOfVector(@TypeOf(v)))) {
        .float => floatVecCast(f32, v),
        .int => floatVecFromIntVec(f32, v),
        else => @compileError("what?"),
    };

    const len = length(vec);
    if (len == 0) {
        return zeroVector(lengthOfVector(@TypeOf(v)), f32);
    }
    return divs(vec, len);
}

const VecComponents = enum { unused, x, y, z, w };

fn getSwizzleComps(comps: anytype) [4]VecComponents {
    const type_info = @typeInfo(@TypeOf(comps));
    if (type_info != .enum_literal) {
        @compileError("components must be an enum literal");
    }

    const comp_str = @tagName(comps);
    if (comp_str.len > 4) {
        @compileError("swizzle literal '." ++ comp_str ++ " too long");
    }

    var components: [4]VecComponents = .{ .unused, .unused, .unused, .unused };
    inline for (comp_str, 0..comp_str.len) |comp, i| {
        components[i] = switch (comp) {
            'x', 'r' => .x,
            'y', 'g' => .y,
            'z', 'b' => .z,
            'w', 'a' => .w,
            else => @compileError("invalid swizzle literal '." ++ comp_str ++ "'"),
        };
    }
    return components;
}

fn TypeFromSwizzleLiteral(comptime T: type, comptime comps: anytype) type {
    const components = getSwizzleComps(comps);
    var component_count = 0;
    inline for (components) |comp| {
        if (comp == .unused) {
            break;
        }
        component_count += 1;
    }
    return VectorWithLen(component_count, T);
}

/// Implements vector swizzling through major amounts of tomfoolery. For example `.xy`, `.zxy`, `.zzzw`,
/// really any combination of xyzw that comes to mind. RGBA is also supported, for example `.abgr`.
pub fn swizzle(
    src: anytype,
    comptime components: anytype,
) TypeFromSwizzleLiteral(ChildTypeOfVector(@TypeOf(src)), components) {
    // TODO this parses the swizzle literal 3 times who gives a shit
    const comps = comptime getSwizzleComps(components);
    var dst: TypeFromSwizzleLiteral(ChildTypeOfVector(@TypeOf(src)), components) = undefined;
    const len = lengthOfVector(@TypeOf(dst));

    inline for (comps, 0..comps.len) |comp, i| {
        if (i >= len) break;
        switch (comp) {
            .x => dst.repr[i] = src.repr[0],
            .y => dst.repr[i] = src.repr[1],
            .z => dst.repr[i] = src.repr[2],
            .w => dst.repr[i] = src.repr[3],
            .unused => break,
        }
    }

    return dst;
}

test "vec2 -> vec2 swizzle" {
    const v = vec2(i32, 1, 2);
    try testing.expectEqual(vec2(i32, 1, 2), swizzle(v, .xy));
    try testing.expectEqual(vec2(i32, 2, 1), swizzle(v, .yx));
    try testing.expectEqual(vec2(i32, 1, 1), swizzle(v, .xx));
    try testing.expectEqual(vec2(i32, 2, 2), swizzle(v, .yy));
}

test "vec2 -> vec3 swizzle" {
    const v = vec2(i32, 2, 3);
    try testing.expectEqual(vec3(i32, 3, 2, 2), swizzle(v, .yxx));
    try testing.expectEqual(vec3(i32, 2, 3, 2), swizzle(v, .xyx));
    try testing.expectEqual(vec3(i32, 3, 3, 2), swizzle(v, .yyx));
}

test "vec3 -> vec2 swizzle" {
    const v = vec3(i32, 4, 5, 6);
    try testing.expectEqual(vec2(i32, 4, 5), swizzle(v, .xy));
    try testing.expectEqual(vec2(i32, 6, 4), swizzle(v, .zx));
    try testing.expectEqual(vec2(i32, 5, 5), swizzle(v, .yy));
}

test "vec3 -> vec3 swizzle" {
    const v = vec3(i32, 7, 8, 9);
    try testing.expectEqual(vec3(i32, 7, 8, 9), swizzle(v, .xyz));
    try testing.expectEqual(vec3(i32, 9, 8, 7), swizzle(v, .zyx));
    try testing.expectEqual(vec3(i32, 8, 7, 8), swizzle(v, .yxy));
}

test "vec3 -> vec4 swizzle" {
    const v = vec3(i32, 1, 2, 3);
    try testing.expectEqual(vec4(i32, 1, 2, 3, 1), swizzle(v, .xyzx));
    try testing.expectEqual(vec4(i32, 3, 3, 2, 1), swizzle(v, .zzyx));
}

test "vec4 swizzle" {
    const v = vec4(i32, 10, 20, 30, 40);
    try testing.expectEqual(
        vec4(i32, 10, 20, 30, 40),
        swizzle(v, .xyzw),
    );
    try testing.expectEqual(
        vec4(i32, 40, 30, 20, 10),
        swizzle(v, .wzyx),
    );
    try testing.expectEqual(
        vec3(i32, 20, 20, 40),
        swizzle(v, .yyw),
    );
}

test "rgba swizzle" {
    const v = vec4(i32, 10, 20, 30, 40);
    try testing.expectEqual(
        vec4(i32, 40, 30, 20, 10),
        swizzle(v, .abgr),
    );
}
