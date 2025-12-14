//! Meth
const std = @import("std");
const testing = std.testing;

/// A vector with 2 components. Extraordinary.
pub fn Vec2(comptime T: type) type {
    return struct {
        repr: @Vector(2, T),

        pub fn x(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn r(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn g(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
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

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn z(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn r(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn g(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn b(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
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

        pub fn y(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn z(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn w(vec: @This()) T {
            return vec.repr[3];
        }

        pub fn r(vec: @This()) T {
            return vec.repr[0];
        }

        pub fn g(vec: @This()) T {
            return vec.repr[1];
        }

        pub fn b(vec: @This()) T {
            return vec.repr[2];
        }

        pub fn a(vec: @This()) T {
            return vec.repr[3];
        }

        pub fn nth(vec: @This(), comptime idx: comptime_int) T {
            return vec.repr[idx];
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
    try testing.expectEqual(v2.r(), v2.x());
    try testing.expectEqual(v2.nth(0), v2.r());
    try testing.expectEqual(v2.toArray()[0], v2.nth(0));
    try testing.expectEqual(v2.y(), 2);
    try testing.expectEqual(v2.g(), v2.y());
    try testing.expectEqual(v2.nth(1), v2.g());
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

const VecInfo = struct {
    len: comptime_int,
    child: type,
};

fn vecInfo(comptime T: type) VecInfo {
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
    return VectorWithLen(vec_info.len, vec_info.child);
}

fn lengthOfVector(comptime T: type) comptime_int {
    return vecInfo(T).len;
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
